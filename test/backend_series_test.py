import sys
import types
import unittest
from pathlib import Path
from unittest.mock import patch
sys.path.insert(0, str(Path(__file__).resolve().parents[1] / 'backend'))
import pandas as pd
# Replace only external repositories; exercise the real aggregation services.
for name, function in [('operacao', 'buscar_operacao_mes'), ('passageiros', 'buscar_passageiros_mes'), ('financeiro', 'buscar_financeiro_mes')]:
    module = types.ModuleType('app.repositories.' + name + '_repository')
    setattr(module, function, lambda mes: [])
    sys.modules[module.__name__] = module
from app.services import dashboard_service, operacao_service, passageiros_service, financeiro_service
from app.services.registros_diarios_service import selecionar_registros_diarios

class SeriesTests(unittest.TestCase):
    def test_empty_month_has_no_invented_zero_values(self):
        result = dashboard_service.obter_dashboard_overview()
        self.assertEqual(result['serie'], [])
        self.assertIsNone(result['quilometragem']['valor'])
        self.assertIsNone(result['passageiros_pagantes']['valor'])
        self.assertIsNone(result['financeiro']['valor'])

    def test_daily_trips_are_sorted_and_aggregated(self):
        df = pd.DataFrame([
            {'data': pd.Timestamp('2026-08-02'), 'viagens_programadas': 10, 'viagens_realizadas': 8, 'km_produtiva': 50., 'km_morta': 5.},
            {'data': pd.Timestamp('2026-08-01'), 'viagens_programadas': 20, 'viagens_realizadas': 19, 'km_produtiva': 100., 'km_morta': 10.},
            {'data': pd.Timestamp('2026-08-01'), 'viagens_programadas': 3, 'viagens_realizadas': 2, 'km_produtiva': 10., 'km_morta': 1.},
        ])
        with patch.object(operacao_service, 'carregar_operacao_banco', return_value=df):
            result = operacao_service.obter_overview_operacao()
        self.assertEqual(result['serie_viagens'][0], {'rotulo': '01/08', 'realizado': 21., 'esperado': 23., 'anomalia': False})
        self.assertEqual(result['total_viagens']['realizado'], 29)

    def test_daily_passengers_match_totals(self):
        df = pd.DataFrame([
            {'data': pd.Timestamp('2026-08-02'), 'pagantes': 40, 'nao_pagantes': 60, 'total_passageiros': 100},
            {'data': pd.Timestamp('2026-08-01'), 'pagantes': 10, 'nao_pagantes': 20, 'total_passageiros': 30},
        ])
        with patch.object(passageiros_service, 'carregar_passageiros_banco', return_value=df):
            result = passageiros_service.obter_overview_passageiros()
        self.assertEqual([p['rotulo'] for p in result['serie']], ['01/08', '02/08'])
        self.assertEqual(sum(p['volume'] for p in result['serie']), result['total_passageiros']['valor'])

    def test_overlapping_reports_prefer_monthly_in_both_orders(self):
        rows = [
            {'data': pd.Timestamp('2026-08-01'), 'tipo_periodo': 'quinzenal', 'viagens_programadas': 50, 'viagens_realizadas': 40, 'km_produtiva': 500., 'km_morta': 50., 'pagantes': 600, 'nao_pagantes': 400, 'total_passageiros': 1000},
            {'data': pd.Timestamp('2026-08-01'), 'tipo_periodo': 'mensal', 'viagens_programadas': 10, 'viagens_realizadas': 8, 'km_produtiva': 50., 'km_morta': 5., 'pagantes': 60, 'nao_pagantes': 40, 'total_passageiros': 100},
            {'data': pd.Timestamp('2026-08-02'), 'tipo_periodo': 'quinzenal', 'viagens_programadas': 5, 'viagens_realizadas': 4, 'km_produtiva': 20., 'km_morta': 2., 'pagantes': 30, 'nao_pagantes': 20, 'total_passageiros': 50},
        ]
        for records in (rows, list(reversed(rows))):
            df = pd.DataFrame(records)
            with patch.object(operacao_service, 'carregar_operacao_banco', return_value=df):
                operacao = operacao_service.obter_overview_operacao()
            with patch.object(passageiros_service, 'carregar_passageiros_banco', return_value=df):
                passageiros = passageiros_service.obter_overview_passageiros()
            self.assertEqual(operacao['total_viagens'], {'realizado': 12, 'programado': 15})
            self.assertEqual(operacao['quilometragem'], {'produtiva': 70., 'morta': 7.})
            self.assertEqual([p['realizado'] for p in operacao['serie_viagens']], [8., 4.])
            self.assertEqual(passageiros['total_passageiros']['valor'], 150.)
            self.assertEqual([p['volume'] for p in passageiros['serie']], [100., 50.])

    def test_invalid_and_other_month_dates_are_excluded_without_period_column(self):
        df = pd.DataFrame([
            {'data': '2026-08-01', 'value': 10},
            {'data': '2026-08-01', 'value': 20},
            {'data': '2026-09-01', 'value': 30},
            {'data': 'invalid', 'value': 40},
            {'data': None, 'value': 50},
        ])
        selected = selecionar_registros_diarios(df, '2026-08')
        self.assertEqual(len(selected), 2)
        self.assertEqual(selected['value'].sum(), 30)
        self.assertTrue(selecionar_registros_diarios(df, '2026-07').empty)

if __name__ == '__main__':
    unittest.main()
