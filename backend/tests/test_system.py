from io import BytesIO
from pathlib import Path
import copy
import json
import zipfile
import pytest
from fastapi.testclient import TestClient
from app.importer import parse_archive
from app.storage import Store
from app.dashboard_api import context
from app import server

ROOT=Path(__file__).resolve().parents[2]

@pytest.fixture(scope='module')
def batch():
    return parse_archive((ROOT/'data/transport.zip').read_bytes())

@pytest.fixture(scope='module')
def store(tmp_path_factory,batch):
    s=Store(database_url='',local_path=tmp_path_factory.mktemp('semob')/'test.sqlite')
    s.migrate_local()
    s.import_batch(batch,'transport.zip')
    return s

@pytest.fixture
def client(store,monkeypatch):
    monkeypatch.setattr(server,'store',store)
    with TestClient(server.app) as c:
        yield c


def test_real_august_totals(store):
    filters=dict(periodo='mes',mes='2026-08',referencia=None,inicio=None,fim=None,linha=None)
    result,rows,_=context(store,filters)
    assert len(rows)==31
    assert result['totals']['passengers']==1050248
    assert result['totals']['paid']==288378
    assert result['totals']['unpaid']==761870
    assert result['totals']['km_total']==275694.5
    assert result['totals']['trips_completed']==34994
    assert result['totals']['trips_missed']==56
    assert result['totals']['sales']==668605.71


def test_idempotent_and_monthly_priority(store,batch):
    before=store.catalog()
    assert store.import_batch(batch,'second-name.zip')['duplicate']
    assert store.catalog()['trips_archived']==before['trips_archived']==107927
    with store.connection() as c:
        assert squery(store,c,"SELECT priority FROM semob_operation_daily WHERE day='2026-08-01'")['priority']==2


def squery(store,c,query):
    return store.query(c,query).fetchone()


def test_atomic_rollback(store,batch):
    bad=copy.deepcopy(batch)
    bad['hash']='f'*64
    bad['daily'][0]['values']['trips_planned']=-10
    with pytest.raises(Exception):
        store.import_batch(bad,'invalid.zip')
    assert len(store.catalog()['imports'])==1

@pytest.mark.parametrize('path',['/health','/meta','/dashboard/overview','/operacao/overview','/passageiros/overview','/financeiro/overview','/monitoramento','/trips'])
def test_endpoints(client,path):
    response=client.get(path)
    assert response.status_code==200,response.text
    assert 'NaN' not in response.text
    assert 'Infinity' not in response.text


def test_period_filter_and_missing_facts(client):
    daily=client.get('/dashboard/overview?periodo=dia&referencia=2026-08-01').json()
    assert daily['meta']['dias_com_dados']==1
    weekly=client.get('/dashboard/overview?periodo=semana&referencia=2026-08-07').json()
    assert weekly['meta']['dias_com_dados']==7
    no_data=client.get('/dashboard/overview?periodo=mes&mes=2026-10').json()
    assert no_data['quilometragem']['valor'] is None
    assert no_data['meta']['dias_com_dados']==0
    line=client.get('/passageiros/overview?linha=1').json()
    assert line['total_passageiros']['valor'] is None
    assert client.get('/dashboard/overview?periodo=personalizado&inicio=2026-08-31&fim=2026-08-01').status_code==422
    assert client.get('/dashboard/overview?mes=invalid').status_code==422


def test_hours_and_unavailable_predictions(client):
    data=client.get('/operacao/overview').json()
    assert len(data['viagens_por_hora'])==24
    assert sum(row['viagens'] for row in data['viagens_por_hora'])>30000
    assert data['pontualidade']['valor'] is None
    assert client.get('/monitoramento').json()['model_trained'] is False


def test_export_and_document_pagination(client):
    response=client.get('/export.csv?periodo=mes&mes=2026-08')
    assert response.status_code==200
    assert response.text.startswith('\ufeffdate;')
    assert len(response.text.splitlines())==32
    doc=client.get('/documents/9?limit=2&offset=1').json()
    assert len(doc['rows'])==2
    assert doc['total']>30000
    assert client.get('/documents/99999').status_code==404
    assert client.get('/trips?limit=2&offset=2').json()['items']


def test_upload_authorization_and_duplicate(client,monkeypatch):
    body=(ROOT/'data/transport.zip').read_bytes()
    assert client.post('/imports',files={'file':('transport.zip',body)}).status_code==403
    monkeypatch.setenv('ADMIN_KEY','test-only-key')
    result=client.post('/imports',headers={'X-Admin-Key':'test-only-key'},files={'file':('transport.zip',body)})
    assert result.status_code==200
    assert result.json()['duplicate'] is True


def test_zip_traversal_rejected():
    content=BytesIO()
    with zipfile.ZipFile(content,'w') as z:
        z.writestr('../outside.html','<html></html>')
    with pytest.raises(ValueError,match='inválido'):
        parse_archive(content.getvalue())
