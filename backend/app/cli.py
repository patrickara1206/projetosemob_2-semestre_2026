"""Run: python -m app.cli import ../data/transport.zip; python -m app.cli migrate."""
import argparse
import json
from pathlib import Path
from app.importer import parse_archive
from app.storage import Store, ROOT


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('command', choices=['import','migrate','status'])
    parser.add_argument('file', nargs='?')
    args = parser.parse_args()
    store = Store()
    if args.command == 'migrate':
        if store.pg:
            with store.connection() as c:
                c.execute((ROOT / 'supabase/migrations/202610020001_semob.sql').read_text('utf-8'))
            print('Migração Supabase aplicada.')
        else:
            store.migrate_local()
            print('Banco local criado.')
    elif args.command == 'import':
        if not args.file:
            parser.error('Informe o caminho do ZIP.')
        store.migrate_local()
        path = Path(args.file)
        print(json.dumps(store.import_batch(parse_archive(path.read_bytes()), path.name), ensure_ascii=False))
    else:
        print(json.dumps(store.catalog(), ensure_ascii=False, default=str))


if __name__ == '__main__':
    main()
