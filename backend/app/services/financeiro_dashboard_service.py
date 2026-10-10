from datetime import date, timedelta
from decimal import Decimal, ROUND_HALF_UP
from app.repositories.financeiro_repository import buscar_financeiro_mes


def _money(value):
    return Decimal(str(value or 0)).quantize(Decimal("0.01"), rounding=ROUND_HALF_UP)


def obter_dashboard_financeiro(mes="2026-08", periodo="mes", busca="", pagina=1):
    # Monthly records take precedence over overlapping fortnightly reports.
    daily = {}
    rows = buscar_financeiro_mes(mes)
    for row in rows:
        raw = str(row.get("data", ""))[:10]
        try:
            day = date.fromisoformat(raw)
        except ValueError:
            continue
        if day.strftime("%Y-%m") != mes:
            continue
        previous = daily.get(day)
        if previous is None or (row.get("tipo_periodo") == "mensal" and previous.get("tipo_periodo") != "mensal"):
            daily[day] = row
    reference = max(daily) if daily else None
    start = (reference - timedelta(days=6)) if reference and periodo == "semana" else reference if periodo == "hoje" else None
    selected = [(day, row) for day, row in sorted(daily.items()) if start is None or day >= start]
    totals = {key: float(sum((_money(row.get(key)) for _, row in selected), Decimal(0))) if selected else None
              for key in ("total_vendas", "total_utilizacao", "credito_circulante")}
    movements = [{"data": day.isoformat(), "vendas": float(_money(row.get("total_vendas"))),
                  "utilizacao": float(_money(row.get("total_utilizacao"))),
                  "credito_circulante": float(_money(row.get("credito_circulante")))} for day, row in selected]
    query = busca.strip().casefold()
    filtered = [item for item in movements if not query or query in item["data"] or query in date.fromisoformat(item["data"]).strftime("%d/%m/%Y")]
    pages = max(1, (len(filtered) + 9) // 10)
    page = min(pagina, pages)
    return {
        **totals,
        "mes": mes, "periodo": periodo, "referencia": reference.isoformat() if reference else None,
        "inicio": selected[0][0].isoformat() if selected else None,
        "fim": selected[-1][0].isoformat() if selected else None,
        "dias": len(selected),
        "evolucao": [{"rotulo": date.fromisoformat(item["data"]).strftime("%d/%m"),
                      "vendas": item["vendas"], "utilizacao": item["utilizacao"], "atual": i == len(movements)-1}
                     for i, item in enumerate(movements)],
        "movimentos": {"itens": filtered[(page-1)*10:page*10], "pagina": page,
                       "total_paginas": pages, "total_registros": len(filtered)},
        "disponibilidade": {"subsidios": False, "custos": False, "repasses": False},
    }
