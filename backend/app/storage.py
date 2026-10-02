"""Relational facts and original documents, local SQLite or Supabase PostgreSQL."""
from contextlib import contextmanager
from datetime import datetime, timezone
import json
import os
from pathlib import Path
import sqlite3

from dotenv import load_dotenv

ROOT = Path(__file__).resolve().parents[2]
load_dotenv(ROOT / 'backend' / '.env')
OP = ['fleet', 'fleet_planned', 'trips_planned', 'trips_completed', 'trips_missed', 'km_productive', 'km_unproductive', 'km_total']
PASS = ['paid', 'unpaid', 'passengers', 'cash_passengers', 'prepaid_passengers']
FIN = ['sales', 'usage', 'circulating']


class Store:
    def __init__(self, database_url=None, local_path=None):
        self.url = database_url if database_url is not None else os.getenv('DATABASE_URL', '')
        self.pg = bool(self.url)
        self.path = Path(local_path or os.getenv('LOCAL_DATABASE', str(ROOT / 'data' / 'semob.sqlite')))

    @contextmanager
    def connection(self):
        if self.pg:
            import psycopg
            from psycopg.rows import dict_row
            connection = psycopg.connect(self.url, row_factory=dict_row, connect_timeout=15)
        else:
            self.path.parent.mkdir(parents=True, exist_ok=True)
            connection = sqlite3.connect(self.path, timeout=60)
            connection.row_factory = sqlite3.Row
            connection.execute('PRAGMA foreign_keys=ON')
        try:
            with connection:
                yield connection
        finally:
            connection.close()

    def query(self, c, sql, args=()):
        return c.execute(sql.replace('?', '%s') if self.pg else sql, args)

    def many(self, c, sql, args):
        with c.cursor() if self.pg else _SqliteCursor(c) as cursor:
            cursor.executemany(sql.replace('?', '%s') if self.pg else sql, args)

    def document(self, obj):
        if self.pg:
            from psycopg.types.json import Jsonb
            return Jsonb(obj)
        return json.dumps(obj, ensure_ascii=False, allow_nan=False, default=str)

    @staticmethod
    def decode(obj):
        return json.loads(obj) if isinstance(obj, str) else obj

    def migrate_local(self):
        if self.pg:
            return  # Supabase migration is applied explicitly by the owner.
        with self.connection() as c:
            c.executescript((ROOT / 'backend' / 'db' / 'local.sql').read_text('utf-8'))

    def import_batch(self, batch, name):
        with self.connection() as c:
            if self.pg:
                c.execute('SELECT pg_advisory_xact_lock(2062026)')
            else:
                c.execute('BEGIN IMMEDIATE')
            existing = self.query(c, 'SELECT id FROM semob_imports WHERE sha256=?', (batch['hash'],)).fetchone()
            if existing:
                return {'id': existing['id'], 'duplicate': True}
            stats = {key: len(batch[key]) for key in ('daily', 'lines', 'raw', 'trips')}
            ident = self.query(c, 'INSERT INTO semob_imports(name,sha256,created_at,statistics) VALUES(?,?,?,?) RETURNING id',
                               (name, batch['hash'], datetime.now(timezone.utc).isoformat(), self.document(stats))).fetchone()['id']
            tables = {'operation': ('operation_daily', OP), 'passengers': ('passenger_daily', PASS), 'finance': ('finance_daily', FIN)}
            for row in batch['daily']:
                table, cols = tables[row['kind']]
                names = ['day'] + cols + ['priority', 'source', 'import_id']
                update = ','.join(f'{col}=excluded.{col}' for col in names[1:])
                self.query(c, f"INSERT INTO semob_{table}({','.join(names)}) VALUES({','.join('?' for _ in names)}) "
                           f'ON CONFLICT(day) DO UPDATE SET {update} WHERE excluded.priority>=semob_{table}.priority',
                           (row['date'], *(row['values'].get(col) for col in cols), row['rank'], row['source'], ident))
            codes = sorted({r['line'] for r in batch['lines']} | {r['line'] for r in batch['trips'] if r['line']})
            self.many(c, 'INSERT INTO semob_lines(code,name) VALUES(?,?) ON CONFLICT(code) DO NOTHING', [(code, 'Linha '+code) for code in codes])
            vehicles = sorted({r['vehicle'] for r in batch['trips'] if r['vehicle']})
            self.many(c, 'INSERT INTO semob_vehicles(code) VALUES(?) ON CONFLICT(code) DO NOTHING', [(v,) for v in vehicles])
            self.many(c, '''INSERT INTO semob_line_daily(day,line_code,km_productive,trips_completed,priority,source,import_id)
                VALUES(?,?,?,?,?,?,?) ON CONFLICT(day,line_code) DO UPDATE SET
                km_productive=excluded.km_productive,trips_completed=excluded.trips_completed,priority=excluded.priority,
                source=excluded.source,import_id=excluded.import_id WHERE excluded.priority>=semob_line_daily.priority''',
                [(r['date'],r['line'],r['km_productive'],r['trips_completed'],r['rank'],r['source'],ident) for r in batch['lines']])
            self.many(c, 'INSERT INTO semob_documents(import_id,source,table_index,sha256,document) VALUES(?,?,?,?,?)',
                [(ident,r['name'],r['table_index'],r['sha256'],self.document({'columns':r['columns'],'rows':r['rows']})) for r in batch['raw']])
            self.many(c, '''INSERT INTO semob_trips(import_id,day,line_code,vehicle_code,priority,source,start_time,km_productive,km_unproductive,document)
                VALUES(?,?,?,?,?,?,?,?,?,?)''',
                [(ident,r['date'],r['line'],r['vehicle'],r['rank'],r['source'],str(r['start']) if r['start'] else None,
                  r['km_productive'],r['km_unproductive'],self.document(r)) for r in batch['trips']])
            return {'id': ident, 'duplicate': False, 'statistics': stats}

    def records(self, line=None):
        with self.connection() as c:
            if line:
                rows = self.query(c, 'SELECT day,km_productive,trips_completed FROM semob_line_daily WHERE line_code=? ORDER BY day', (line,)).fetchall()
                return [{'date': str(r['day']), 'km_productive': float(r['km_productive']), 'trips_completed': r['trips_completed']} for r in rows]
            days = {}
            for table, cols in [('operation_daily', OP), ('passenger_daily', PASS), ('finance_daily', FIN)]:
                for r in self.query(c, f'SELECT day,{",".join(cols)} FROM semob_{table} ORDER BY day').fetchall():
                    day = str(r['day'])
                    days.setdefault(day, {'date':day}).update({key: float(r[key]) if r[key] is not None else None for key in cols})
            return [days[key] for key in sorted(days)]

    def catalog(self):
        with self.connection() as c:
            imports = [dict(r) for r in self.query(c, 'SELECT * FROM semob_imports ORDER BY id DESC').fetchall()]
            for r in imports:
                r['statistics'] = self.decode(r['statistics'])
                r['created_at'] = str(r['created_at'])
            docs = [dict(r) for r in self.query(c, 'SELECT id,source,table_index,sha256 FROM semob_documents ORDER BY id').fetchall()]
            lines = [dict(r) for r in self.query(c, 'SELECT code,name FROM semob_lines ORDER BY code').fetchall()]
            n = self.query(c, 'SELECT count(*) AS n FROM semob_trips').fetchone()['n']
            return {'imports': imports, 'documents': docs, 'lines': lines, 'trips_archived': n}

    def raw_document(self, ident, offset=0, limit=100):
        with self.connection() as c:
            r = self.query(c, 'SELECT id,source,document FROM semob_documents WHERE id=?', (ident,)).fetchone()
            if not r:
                return None
            doc = self.decode(r['document'])
            return {'id': r['id'], 'source': r['source'], 'columns': doc['columns'], 'total': len(doc['rows']), 'rows':doc['rows'][offset:offset+limit]}

    def selected_trips(self, start, end, line=None):
        with self.connection() as c:
            sql = '''SELECT t.* FROM semob_trips t WHERE t.day BETWEEN ? AND ?
                AND t.priority=(SELECT MAX(x.priority) FROM semob_trips x WHERE x.day=t.day)
                AND t.import_id=(SELECT MAX(x.import_id) FROM semob_trips x WHERE x.day=t.day AND x.priority=t.priority)'''
            params = [start,end]
            if line:
                sql += ' AND t.line_code=?'
                params.append(line)
            return [dict(r) for r in self.query(c, sql+' ORDER BY t.day,t.start_time,t.id', params).fetchall()]


class _SqliteCursor:
    def __init__(self, c):
        self.cursor = c.cursor()
    def __enter__(self):
        return self.cursor
    def __exit__(self, *args):
        self.cursor.close()
