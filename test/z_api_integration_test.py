import sys
import types
import unittest
from datetime import date
from pathlib import Path
from unittest.mock import Mock, patch

import pandas as pd
from fastapi.testclient import TestClient

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / 'backend'))


class ApiIntegrationTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        database = types.ModuleType('app.database.supabase_client')
        database.supabase = Mock()
        for name in ('operacao', 'passageiros', 'financeiro'):
            repository = sys.modules.get(f'app.repositories.{name}_repository')
            if repository is not None and not hasattr(repository, f'inserir_{name}'):
                setattr(repository, f'inserir_{name}', Mock())
        with patch.dict(sys.modules, {'app.database.supabase_client': database}):
            from app.main import app
        cls.client = TestClient(app)

    def fixtures(self):
        return pd.DataFrame([
            {'data': pd.Timestamp(f'2026-08-{day:02d}'), 'tipo_periodo': 'mensal',
             'viagens_realizadas': day, 'viagens_programadas': day + 1,
             'km_produtiva': day * 2., 'km_morta': day * .5,
             'pagantes': day * 10, 'nao_pagantes': day * 10, 'total_passageiros': day * 20}
            for day in range(1, 11)
        ])

    def test_all_overviews_apply_week_latest_and_custom_filters(self):
        from app.services import operacao_service, passageiros_service, financeiro_service
        financial = [{'data': f'2026-08-{day:02d}', 'tipo_periodo': 'mensal',
                      'total_vendas': 10., 'total_utilizacao': 4., 'credito_circulante': 6.}
                     for day in range(1, 11)]
        with patch.object(operacao_service, 'carregar_operacao_banco', return_value=self.fixtures()), \
             patch.object(passageiros_service, 'carregar_passageiros_banco', return_value=self.fixtures()), \
             patch.object(financeiro_service, 'buscar_financeiro_mes', return_value=financial):
            for query, count, trips in [('periodo=mes', 10, 55), ('periodo=semana', 7, 49),
                                        ('periodo=hoje', 1, 10),
                                        ('periodo=personalizado&inicio=2026-08-02&fim=2026-08-04', 3, 9)]:
                dashboard = self.client.get('/dashboard/overview?mes=2026-08&' + query)
                operation = self.client.get('/operacao/overview?mes=2026-08&' + query)
                passengers = self.client.get('/passageiros/overview?mes=2026-08&' + query)
                self.assertEqual([dashboard.status_code, operation.status_code, passengers.status_code], [200] * 3)
                self.assertEqual(len(dashboard.json()['serie']), count)
                self.assertEqual(dashboard.json()['viagens']['valor'], trips)
                self.assertEqual(dashboard.json()['inteligencia']['dias_analisados'], count)
                self.assertIsNotNone(dashboard.json()['inteligencia']['cumprimento_programacao'])
                self.assertEqual(dashboard.json()['financeiro']['valor'], count * 10)
                self.assertEqual(operation.json()['total_viagens']['realizado'], trips)
                self.assertEqual(passengers.json()['total_passageiros']['valor'], trips * 20)

    def test_custom_range_rejects_missing_reversed_and_other_month_dates(self):
        for path in ('dashboard', 'operacao', 'passageiros'):
            for query in ('periodo=personalizado', 'periodo=invalido', 'mes=2026-13',
                          'periodo=personalizado&inicio=2026-08-04&fim=2026-08-01',
                          'periodo=personalizado&inicio=2026-08-01&fim=2026-09-01'):
                self.assertEqual(self.client.get(f'/{path}/overview?' + query).status_code, 422)

    def test_login_success_and_invalid_credentials(self):
        from app.routes import auth
        with patch.object(auth, 'autenticar_usuario', return_value={'id': 1, 'nome': 'Teste'}):
            response = self.client.post('/auth/login', json={'email': 'teste@example.com', 'senha': 'senha-de-teste'})
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.json()['status'], 'sucesso')
        with patch.object(auth, 'autenticar_usuario', side_effect=ValueError('Credenciais inválidas')):
            response = self.client.post('/auth/login', json={'email': 'teste@example.com', 'senha': 'incorreta'})
        self.assertEqual(response.status_code, 401)

    def test_import_upload_success_and_errors_without_database_writes(self):
        from app.routes import importacao
        with patch.object(importacao, 'importar_relatorio', return_value={'importacao_id': 9, 'registros': 2}) as importer:
            response = self.client.post('/importacao/financeiro?mes=2026-08&tipo_periodo=mensal',
                                        files={'arquivo': ('relatorio.html', b'<table></table>', 'text/html')})
            self.assertEqual(response.status_code, 200)
            self.assertEqual(response.json()['registros'], 2)
            importer.assert_called_once()
            importer.reset_mock()
            response = self.client.post('/importacao/financeiro?mes=2026-08',
                                        files={'arquivo': ('relatorio.csv', b'csv', 'text/csv')})
            self.assertEqual(response.status_code, 400)
            importer.assert_not_called()
        with patch.object(importacao, 'importar_relatorio', side_effect=ValueError('Relatório incompatível')):
            response = self.client.post('/importacao/financeiro?mes=2026-08',
                                        files={'arquivo': ('relatorio.html', b'<html></html>', 'text/html')})
        self.assertEqual(response.status_code, 400)

    def test_main_financial_contract_and_empty_overviews_are_preserved(self):
        from app.services import financeiro_service
        records = [{'data': '2026-08-01', 'tipo_periodo': 'mensal',
                    'total_vendas': 12.34, 'total_utilizacao': 2.34, 'credito_circulante': 10}]
        with patch.object(financeiro_service, 'buscar_financeiro_mes', return_value=records):
            response = self.client.get('/financeiro/overview?mes=2026-08')
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.json()['dias_financeiros'][0]['vendas'], 12.34)
        self.assertEqual(response.json()['total_vendas'], 12.34)
        for path in ('dashboard', 'operacao', 'passageiros', 'financeiro'):
            response = self.client.get(f'/{path}/overview?mes=2026-08')
            self.assertEqual(response.status_code, 200)

    def test_main_zip_import_route_is_preserved(self):
        from app.routes import importacao
        with patch.object(importacao, 'importar_zip', return_value={'arquivos_importados': 2}) as importer:
            response = self.client.post('/importacao/lote/zip?mes=2026-08',
                files={'arquivo': ('relatorios.zip', b'zip-test', 'application/zip')})
            self.assertEqual(response.status_code, 200)
            self.assertEqual(response.json()['arquivos_importados'], 2)
            importer.assert_called_once()
            importer.reset_mock()
            response = self.client.post('/importacao/lote/zip?mes=2026-08',
                files={'arquivo': ('relatorios.txt', b'txt', 'text/plain')})
            self.assertEqual(response.status_code, 400)
            importer.assert_not_called()

    def test_application_registers_all_required_routes_except_ml(self):
        schema = self.client.get('/openapi.json').json()
        for path in ('/auth/login', '/dashboard/overview', '/operacao/overview', '/passageiros/overview',
                     '/financeiro/overview', '/importacao/{tipo_relatorio}'):
            self.assertIn(path, schema['paths'])
        self.assertEqual(self.client.get('/health').status_code, 200)


if __name__ == '__main__':
    unittest.main()
