from contextlib import asynccontextmanager
from datetime import date
import csv
import hmac
from io import StringIO
import logging
import os
from typing import Annotated
from fastapi import FastAPI, Depends, HTTPException, Header, Query, UploadFile, File
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import Response, JSONResponse
from app.storage import Store
from app.importer import parse_archive, MAX_BYTES
from app.dashboard_api import context, overview, operation, passengers, finance

store = Store()


@asynccontextmanager
async def lifespan(app):
    store.migrate_local()
    yield


app = FastAPI(title='SEMOB-SCS · Dashboard de Transporte',version='1.0.0',lifespan=lifespan)
app.add_middleware(CORSMiddleware,allow_origins=[x.strip() for x in os.getenv('CORS_ORIGINS','http://127.0.0.1:8080,http://localhost:8080,http://127.0.0.1:8081,http://localhost:8081').split(',')],
                   allow_methods=['GET','POST'],allow_headers=['Content-Type','X-Admin-Key'])


@app.exception_handler(Exception)
async def internal_error(request, exc):
    logging.exception('Falha na API',exc_info=exc)
    return JSONResponse(status_code=503,content={'detail':'Serviço de dados indisponível. Verifique o banco e a importação no backend.'})


def filters(periodo:str='mes',mes:str='2026-08',referencia:date|None=None,inicio:date|None=None,fim:date|None=None,linha:str|None=None):
    return {'periodo':periodo,'mes':mes,'referencia':str(referencia) if referencia else None,
            'inicio':str(inicio) if inicio else None,'fim':str(fim) if fim else None,'linha':linha}


def data(f):
    try:
        return context(store,f)
    except ValueError as e:
        raise HTTPException(422,str(e)) from e


@app.get('/health')
def health():
    with store.connection() as c:
        store.query(c,'SELECT count(*) FROM semob_imports').fetchone()
    return {'status':'ok','storage':'Supabase PostgreSQL + JSONB' if store.pg else 'SQLite local + documentos JSON'}


@app.get('/meta')
def meta():
    records=store.records()
    catalog=store.catalog()
    return {**catalog,'months':sorted({r['date'][:7] for r in records}),'dates':[r['date'] for r in records],
            'first':records[0]['date'] if records else None,'last':records[-1]['date'] if records else None,
            'days':len(records),'storage':'supabase' if store.pg else 'local','model_trained':False}


@app.get('/dashboard/overview')
def dashboard_overview(f:Annotated[dict,Depends(filters)]):
    return overview(*data(f))


@app.get('/operacao/overview')
def operation_overview(f:Annotated[dict,Depends(filters)]):
    return operation(store,*data(f))


@app.get('/passageiros/overview')
def passenger_overview(f:Annotated[dict,Depends(filters)]):
    return passengers(*data(f))


@app.get('/financeiro/overview')
def finance_overview(f:Annotated[dict,Depends(filters)]):
    return finance(*data(f))


@app.get('/monitoramento')
def monitor(f:Annotated[dict,Depends(filters)]):
    result,rows,_=data(f)
    return {'alerts':result['alerts'],'meta':result['meta'],'rules':[
        'Viagens não realizadas > 0 no dia.',
        'Total de passageiros deve ser igual a pagantes + não pagantes.',
        'Demanda varia mais de 35% da mediana dos últimos quatro dias de mesmo dia da semana, com ao menos três observações anteriores.'
    ],'model_trained':False,'limitation':'Os dados não contêm horários planejados, rótulos de anomalias ou modelo validado. Não são calculadas pontualidade, acurácia ou previsões de IA.'}


@app.get('/trips')
def trips(f:Annotated[dict,Depends(filters)],offset:int=Query(0,ge=0),limit:int=Query(50,ge=1,le=200)):
    result,_,_=data(f)
    rows=store.selected_trips(result['meta']['inicio'],result['meta']['fim'],f.get('linha'))
    return {'total':len(rows),'items':[store.decode(r['document']) for r in rows[offset:offset+limit]]}


@app.get('/documents/{ident}')
def document(ident:int,offset:int=Query(0,ge=0),limit:int=Query(50,ge=1,le=200)):
    r=store.raw_document(ident,offset,limit)
    if r is None:
        raise HTTPException(404,'Documento não encontrado.')
    return r


@app.get('/export.csv')
def export(f:Annotated[dict,Depends(filters)]):
    result,rows,_=data(f)
    columns=['date','km_productive','km_unproductive','km_total','trips_planned','trips_completed','trips_missed','paid','unpaid','passengers','sales','usage','circulating']
    output=StringIO()
    writer=csv.DictWriter(output,fieldnames=columns,delimiter=';',extrasaction='ignore')
    writer.writeheader()
    for row in rows:
        writer.writerow({k:(str(v).replace('.',',') if isinstance(v,float) else v) for k,v in row.items()})
    return Response('\ufeff'+output.getvalue(),media_type='text/csv; charset=utf-8',headers={'Content-Disposition':f'attachment; filename="semob-{result["meta"]["inicio"]}-{result["meta"]["fim"]}.csv"'})


@app.post('/imports')
async def import_zip(file:Annotated[UploadFile,File()],x_admin_key:Annotated[str|None,Header()]=None):
    expected=os.getenv('ADMIN_KEY','')
    if not expected or not x_admin_key or not hmac.compare_digest(expected,x_admin_key):
        raise HTTPException(403,'Importação requer a chave administrativa configurada no backend.')
    content=await file.read(MAX_BYTES+1)
    if len(content)>MAX_BYTES:
        raise HTTPException(413,'Arquivo excede 160 MB.')
    try:
        batch=parse_archive(content)
    except Exception as e:
        raise HTTPException(422,'ZIP inválido ou relatório incompatível.') from e
    return store.import_batch(batch,(file.filename or 'transport.zip').replace('\\','/').split('/')[-1])
