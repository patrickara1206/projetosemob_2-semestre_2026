"""Smart Report archive importer, never extracts untrusted ZIP paths."""
from hashlib import sha256
from io import BytesIO, StringIO
from pathlib import PurePosixPath
import re
import zipfile
import pandas as pd

MAX_BYTES = 160 * 1024 * 1024


def native(value):
    if pd.isna(value):
        return None
    if hasattr(value, 'item'):
        return value.item()
    return value


def parse_archive(content):
    if len(content) > MAX_BYTES:
        raise ValueError('Arquivo excede 160 MB.')
    daily, lines, raw, trips = [], [], [], []
    with zipfile.ZipFile(BytesIO(content)) as archive:
        entries = archive.infolist()
        if len(entries) > 500 or sum(x.file_size for x in entries) > MAX_BYTES:
            raise ValueError('ZIP excede o limite de arquivos ou tamanho descompactado.')
        for entry in sorted(entries, key=lambda x: x.filename):
            name = entry.filename
            path = PurePosixPath(name.replace('\\', '/'))
            if path.is_absolute() or '..' in path.parts:
                raise ValueError('Caminho inválido no ZIP.')
            if not name.lower().endswith('.html'):
                continue
            payload = archive.read(entry)
            try:
                html = payload.decode('utf-8')
            except UnicodeDecodeError:
                html = payload.decode('cp1252')
            try:
                tables = pd.read_html(StringIO(html), decimal=',', thousands='.')
            except Exception as error:
                raise ValueError(f'Relatório HTML inválido: {name}') from error
            rank = 2 if '/Mensal/' in name else 1
            base = path.name.lower()
            for index, table in enumerate(tables[1:], start=1):
                rows = [{str(k): native(v) for k, v in row.items()} for row in table.to_dict('records')]
                raw.append({'name': name, 'table_index': index, 'sha256': sha256(payload).hexdigest(),
                            'columns': [str(c) for c in table.columns], 'rows': rows})
                if re.fullmatch(r'(mensal|quinzenal)_\d{6}\.html', base):
                    if table.shape[1] != 10:
                        raise ValueError(f'Estrutura de operação inesperada: {name}')
                    for row in table.itertuples(index=False, name=None):
                        day = pd.to_datetime(str(row[0]), format='%d/%m/%Y', errors='coerce')
                        if pd.isna(day):
                            continue
                        values = dict(zip(['fleet', 'fleet_planned', 'trips_planned', 'trips_completed', 'trips_missed', 'km_productive', 'km_unproductive', 'km_total'], row[2:]))
                        daily.append({'date': day.strftime('%Y-%m-%d'), 'kind': 'operation', 'rank': rank, 'source': name,
                                      'values': {k: native(v) for k, v in values.items()}})
                elif 'passageiros' in base:
                    if table.shape[1] != 6 or 'Não Pagantes' not in table.columns:
                        raise ValueError(f'Estrutura de passageiros inesperada: {name}')
                    for row in table.itertuples(index=False, name=None):
                        if not str(row[1]).isdigit():
                            continue
                        day = f'{row[0]}-{int(row[1]):02}'
                        values = {'paid': native(row[2] + row[3]), 'unpaid': native(row[4]),
                                  'passengers': native(row[5]), 'cash_passengers': native(row[2]), 'prepaid_passengers': native(row[3])}
                        daily.append({'date': day, 'kind': 'passengers', 'rank': rank, 'source': name, 'values': values})
                elif 'saldos' in base and 'Total Vendas' in table.columns:
                    for row in table.itertuples(index=False, name=None):
                        if not str(row[1]).isdigit():
                            continue
                        daily.append({'date': f'{row[0]}-{int(row[1]):02}', 'kind': 'finance', 'rank': rank, 'source': name,
                                      'values': dict(zip(['sales', 'usage', 'circulating'], [native(x) for x in row[2:]]))})
                elif '_linhas_' in base:
                    for row in table.itertuples(index=False, name=None):
                        day = pd.to_datetime(str(row[0]), format='%d/%m/%Y', errors='coerce')
                        if pd.isna(day) or pd.isna(row[1]):
                            continue
                        lines.append({'date': day.strftime('%Y-%m-%d'), 'line': str(int(row[1])), 'rank': rank,
                                      'km_productive': native(row[2]), 'trips_completed': native(row[3]), 'source': name})
                elif re.search(r'_viagens_\d{6}\.html', base):
                    for row in table.itertuples(index=False, name=None):
                        day = pd.to_datetime(str(row[0]), format='%d/%m/%Y', errors='coerce')
                        if pd.isna(day):
                            continue
                        trips.append({'date': day.strftime('%Y-%m-%d'), 'line': None if pd.isna(row[1]) else str(int(row[1])),
                                      'vehicle': None if pd.isna(row[2]) else str(int(row[2])), 'kind': str(row[3]),
                                      'direction': native(row[4]), 'start': native(row[6]), 'end': native(row[7]),
                                      'km_productive': native(row[8]), 'km_unproductive': native(row[9]),
                                      'rank': rank, 'source': name})
    if not daily:
        raise ValueError('Nenhum relatório Smart Report compatível encontrado.')
    return {'hash': sha256(content).hexdigest(), 'daily': daily, 'lines': lines, 'raw': raw, 'trips': trips}


def consolidate(batch):
    selected = {}
    for record in batch['daily']:
        key = (record['date'], record['kind'])
        if key not in selected or record['rank'] > selected[key]['rank']:
            selected[key] = record
    days = {}
    for record in selected.values():
        days.setdefault(record['date'], {'date': record['date']}).update(record['values'])
    return sorted(days.values(), key=lambda x: x['date'])
