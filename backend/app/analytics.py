"""Aggregations preserve unavailable facts as null rather than manufactured zeros."""
import pandas as pd

METRICS = ['km_productive', 'km_unproductive', 'km_total', 'trips_planned',
           'trips_completed', 'trips_missed', 'paid', 'unpaid', 'passengers',
           'sales', 'usage', 'circulating']


def dashboard(records, start=None, end=None, frequency='daily', line=None):
    frame = pd.DataFrame(records)
    if frame.empty:
        return {'totals': {}, 'series': [], 'alerts': [], 'coverage': {}}
    frame['date'] = pd.to_datetime(frame['date'])
    if start:
        frame = frame[frame.date >= pd.Timestamp(start)]
    if end:
        frame = frame[frame.date <= pd.Timestamp(end)]
    if frame.empty:
        return {'totals': {}, 'series': [], 'alerts': [], 'coverage': {}}
    for col in METRICS:
        if col not in frame:
            frame[col] = float('nan')
    available = METRICS if line is None else ['km_productive', 'trips_completed']
    totals = frame[available].sum(min_count=1).to_dict()
    if line is None:
        p, c = totals.get('trips_planned'), totals.get('trips_completed')
        totals['completion_rate'] = round(c / p * 100, 2) if pd.notna(p) and p > 0 and pd.notna(c) else None
    rule = {'daily': 'D', 'weekly': 'W-SUN', 'monthly': 'MS'}[frequency]
    series = frame.set_index('date')[available].resample(rule).sum(min_count=1).reset_index()
    series['date'] = series.date.dt.strftime('%Y-%m-%d')
    alerts = []
    for _, row in frame.iterrows():
        day = row.date.strftime('%Y-%m-%d')
        if line is None and pd.notna(row.trips_missed) and row.trips_missed > 0:
            alerts.append({'date': day, 'severity': 'warning', 'kind': 'viagens',
                           'message': f'{int(row.trips_missed)} viagens não realizadas.'})
        if line is None and pd.notna(row.passengers) and pd.notna(row.paid) and pd.notna(row.unpaid) and row.passengers != row.paid + row.unpaid:
            alerts.append({'date': day, 'severity': 'critical', 'kind': 'consistencia',
                           'message': 'Total de passageiros diverge da soma dos tipos.'})
    # Compare only the same weekday; weekends have a different demand baseline.
    if line is None:
        ordered = frame.sort_values('date')
        for _, group in ordered.groupby(ordered.date.dt.dayofweek):
            baseline = group.passengers.shift(1).rolling(4, min_periods=3).median()
            for (_, row), typical in zip(group.iterrows(), baseline):
                if pd.notna(typical) and typical > 0 and pd.notna(row.passengers) and abs(row.passengers / typical - 1) > .35:
                    alerts.append({'date': row.date.strftime('%Y-%m-%d'), 'severity': 'warning',
                                   'kind': 'demanda', 'message': 'Demanda varia mais de 35% da mediana dos últimos dias equivalentes.'})
    coverage = {col: int(frame[col].notna().sum()) for col in available}
    clean = lambda value: None if pd.isna(value) else round(float(value), 2)
    return {'totals': {k: clean(v) for k, v in totals.items()},
            'series': [{k: (v if k == 'date' else clean(v)) for k, v in row.items()} for row in series.to_dict('records')],
            'alerts': sorted(alerts, key=lambda a: a['date'], reverse=True),
            'coverage': {'days': len(frame), 'metrics': coverage,
                         'first': frame.date.min().strftime('%Y-%m-%d'),
                         'last': frame.date.max().strftime('%Y-%m-%d')}}
