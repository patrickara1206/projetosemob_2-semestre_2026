"""Flutter contracts derived from imported facts, including historical date filters."""
from collections import Counter
from datetime import date, timedelta
from app.analytics import dashboard


def bounds(records, periodo='mes', mes='2026-08', referencia=None, inicio=None, fim=None):
    if periodo == 'personalizado':
        if not inicio or not fim:
            raise ValueError('Informe início e fim para o período personalizado.')
        first, last = date.fromisoformat(inicio), date.fromisoformat(fim)
    elif periodo in ('hoje','dia','semana'):
        ref = date.fromisoformat(referencia or (records[-1]['date'] if records else date.today().isoformat()))
        first, last = (ref-timedelta(days=6),ref) if periodo == 'semana' else (ref,ref)
    elif periodo == 'mes':
        first = date.fromisoformat(mes+'-01')
        last = (first.replace(day=28)+timedelta(days=4)).replace(day=1)-timedelta(days=1)
    else:
        raise ValueError('Período inválido.')
    if first > last or (last-first).days > 366:
        raise ValueError('Selecione um intervalo válido de até 366 dias.')
    return first.isoformat(), last.isoformat()


def context(store, filters):
    records = store.records(filters.get('linha'))
    start, end = bounds(records, **{k:filters[k] for k in ('periodo','mes','referencia','inicio','fim')})
    selected = [r for r in records if start <= r['date'] <= end]
    result = dashboard(records,start,end,line=filters.get('linha'))
    history = dashboard(records,line=filters.get('linha'))
    result['alerts'] = [a for a in history['alerts'] if start <= a['date'] <= end]
    width = (date.fromisoformat(end)-date.fromisoformat(start)).days+1
    prev_end = date.fromisoformat(start)-timedelta(days=1)
    prev_start = prev_end-timedelta(days=width-1)
    prev = dashboard(records,prev_start.isoformat(),prev_end.isoformat(),line=filters.get('linha'))
    def variation(key):
        current, before = result['totals'].get(key), prev['totals'].get(key)
        coverage = result.get('coverage',{}).get('metrics',{}).get(key,0)
        previous_coverage = prev.get('coverage',{}).get('metrics',{}).get(key,0)
        if current is None or not before or coverage != width or previous_coverage != width:
            return None
        return round((current/before-1)*100,2)
    result['meta'] = {'inicio':start,'fim':end,'dias_com_dados':len(selected),'dias_esperados':width,
                      'linha':filters.get('linha'),'fonte':'Smart Report','cobertura':result.get('coverage',{}).get('metrics',{})}
    return result, selected, variation


def overview(result, rows, variation):
    t = result['totals']
    kpi = lambda key: {'valor':t.get(key),'variacao':variation(key)}
    alerts = result['alerts']
    return {'quilometragem':kpi('km_total'),'viagens':kpi('trips_completed'),
            'passageiros_pagantes':kpi('paid'),'passageiros_nao_pagantes':kpi('unpaid'),'financeiro':kpi('sales'),
            'serie':[{'rotulo':r['date'][8:]+'/'+r['date'][5:7],'realizado':r['trips_completed'],
                      'esperado':r['trips_planned'],'anomalia':(r.get('trips_missed') or 0)>0}
                     for r in rows if r.get('trips_completed') is not None and r.get('trips_planned') is not None],
            'anomalias':[{'titulo':a['date']+' · '+a['kind'],'observado':a['message'],'esperado':'Verificar o relatório de origem',
                         'desvio':0,'score':0,'severidade':'alta' if a['severity']=='critical' else 'media'} for a in alerts[:5]],
            'inteligencia':{'anomalias_criticas':sum(a['severity']=='critical' for a in alerts),'alertas_ativos':len(alerts),'acuracia':None,'falsos_positivos':None},
            'status_modelo':'Regras de monitoramento','meta':result['meta']}


def operation(store, result, rows, variation):
    t = result['totals']
    hours = Counter()
    trips = store.selected_trips(result['meta']['inicio'],result['meta']['fim'],result['meta']['linha'])
    for trip in trips:
        doc = store.decode(trip['document'])
        kind = str(doc.get('kind','')).lower()
        if trip['line_code'] and (trip['km_productive'] or 0) > 0:
            time = trip['start_time'] or ''
            if ':' in time:
                hour = time.split(':')[0][-2:]
                if hour.isdigit() and 0 <= int(hour) < 24:
                    hours[int(hour)] += 1
    peak = max(hours.values(),default=0)
    return {'total_viagens':{'realizado':int(t['trips_completed']) if t.get('trips_completed') is not None else None,
                            'programado':int(t['trips_planned']) if t.get('trips_planned') is not None else None},
            'pontualidade':{'valor':None,'variacao':None,'meta':None},
            'quilometragem':{'produtiva':t.get('km_productive'),'morta':t.get('km_unproductive')},
            'km_mensal':[{'rotulo':r['date'][8:]+'/'+r['date'][5:7],'produtiva':r['km_productive'],'morta':r['km_unproductive']}
                         for r in rows if r.get('km_productive') is not None and r.get('km_unproductive') is not None],
            'viagens_por_hora':[{'rotulo':f'{h:02}:00','viagens':hours[h],'pico':peak>0 and hours[h]==peak} for h in range(24)] if hours else [],
            'anomalias':[{'id_rota':a['date'],'tipo':a['message'],'veiculo':'Não identificado no resumo',
                         'severidade':'alta' if a['severity']=='critical' else 'media','acao':'investigar'} for a in result['alerts'] if a['kind']=='viagens'],
            'meta':result['meta']}


def passengers(result, rows, variation):
    t = result['totals']
    total, paid, unpaid = t.get('passengers'),t.get('paid'),t.get('unpaid')
    ratio = lambda v: round(v/total*100,2) if total and v is not None else None
    def sum_field(key):
        values = [r[key] for r in rows if r.get(key) is not None]
        return sum(values) if values else None
    categories = [('Pagantes em dinheiro',sum_field('cash_passengers')),('Pagantes pré-pagos',sum_field('prepaid_passengers')),('Não pagantes',unpaid)]
    peak = max((r for r in rows if r.get('passengers') is not None),key=lambda r:r['passengers'],default=None)
    return {'total_passageiros':{'valor':total,'variacao':variation('passengers')},
            'pagantes':{'quantidade':paid,'percentual':ratio(paid)},'gratuidades':{'quantidade':unpaid,'percentual':ratio(unpaid)},
            'pico_demanda':{'faixa':peak['date'] if peak else None,'media_hora':peak['passengers'] if peak else None},
            'serie':[{'rotulo':r['date'][8:]+'/'+r['date'][5:7],'volume':r['passengers'],
                      'anomalia':any(a['date']==r['date'] and a['kind']=='demanda' for a in result['alerts']),
                      'titulo':'Desvio de demanda','detalhe':'Variação > 35% da mediana de dias equivalentes.'}
                     for r in rows if r.get('passengers') is not None],
            'categorias':[{'nome':name,'volume':value,'percentual':ratio(value) or 0,'status':'ativo'} for name,value in categories if value is not None],
            'meta':result['meta']}


def finance(result, rows, variation):
    t = result['totals']
    sales, usage = t.get('sales'),t.get('usage')
    return {'total_vendas':sales,'total_utilizacao':usage,'credito_circulante':t.get('circulating'),
            'diferenca':round(sales-usage,2) if sales is not None and usage is not None else None,
            'variacao_vendas':variation('sales'),'serie':[r for r in rows if r.get('sales') is not None],
            'nota':'Crédito circulante é o total diário reportado no intervalo. Diferença vendas/utilização não representa lucro.',
            'meta':result['meta']}
