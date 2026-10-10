import sys
import types
import unittest
from pathlib import Path
from unittest.mock import patch
sys.path.insert(0,str(Path(__file__).resolve().parents[1]/'backend'))
repo=types.ModuleType('app.repositories.financeiro_repository')
repo.buscar_financeiro_mes=lambda mes:[]
sys.modules[repo.__name__]=repo
from app.services import financeiro_dashboard_service as service
from app.routes.financeiro import router
from fastapi import FastAPI
from fastapi.testclient import TestClient
app=FastAPI();app.include_router(router)
client=TestClient(app)

def row(day,vendas=10,uso=4,tipo='mensal'):
    return {'data':f'2026-08-{day:02d}','tipo_periodo':tipo,'total_vendas':vendas,'total_utilizacao':uso,'credito_circulante':vendas-uso}

class FinanceiroTests(unittest.TestCase):
    def call(self,rows,**kwargs):
        with patch.object(service,'buscar_financeiro_mes',return_value=rows):
            return service.obter_dashboard_financeiro(**kwargs)
    def test_monthly_precedence_in_both_orders(self):
        records=[row(1,100,40,'quinzenal'),row(1,12,2),row(2,20,5,'quinzenal')]
        for rows in [records,list(reversed(records))]:
            result=self.call(rows)
            self.assertEqual(result['dias'],2)
            self.assertEqual(result['total_vendas'],32)
            self.assertEqual(result['total_utilizacao'],7)
            self.assertEqual(result['credito_circulante'],25)
    def test_latest_day_and_seven_day_window(self):
        records=[row(i) for i in range(1,11)]
        self.assertEqual(self.call(records,periodo='hoje')['dias'],1)
        week=self.call(records,periodo='semana')
        self.assertEqual((week['inicio'],week['fim'],week['dias']),('2026-08-04','2026-08-10',7))
    def test_empty_month_has_null_indicators(self):
        result=self.call([])
        self.assertIsNone(result['total_vendas'])
        self.assertEqual(result['evolucao'],[])
        self.assertEqual(result['movimentos']['total_registros'],0)
    def test_search_pagination_and_decimal_totals(self):
        records=[row(i,.1,.03) for i in range(1,24)]
        result=self.call(records,pagina=999)
        self.assertEqual(result['movimentos']['pagina'],3)
        self.assertEqual(len(result['movimentos']['itens']),3)
        self.assertEqual(result['total_vendas'],2.3)
        filtered=self.call(records,busca='05/08')
        self.assertEqual(filtered['movimentos']['total_registros'],1)
        self.assertEqual(filtered['total_vendas'],2.3)
    def test_route_contract_and_validation(self):
        with patch.object(service,'buscar_financeiro_mes',return_value=[row(1)]):
            response=client.get('/financeiro/overview?mes=2026-08&periodo=mes')
        self.assertEqual(response.status_code,200)
        self.assertEqual(response.json()['evolucao'][0]['vendas'],10)
        for query in ['mes=2026-13','mes=bad','pagina=0','periodo=bad']:
            self.assertEqual(client.get('/financeiro/overview?'+query).status_code,422)

if __name__=='__main__':unittest.main()
