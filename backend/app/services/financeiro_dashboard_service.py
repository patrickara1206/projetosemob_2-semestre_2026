from datetime import date
from decimal import Decimal, ROUND_HALF_UP

import pandas as pd

from app.services.financeiro_service import carregar_financeiro_banco


def _money(value):
    return Decimal(str(value or 0)).quantize(
        Decimal("0.01"),
        rounding=ROUND_HALF_UP,
    )


def _resposta_vazia(mes, escopo):
    return {
        "total_vendas": None,
        "total_utilizacao": None,
        "credito_circulante": None,
        "mes": mes,
        "escopo": escopo,
        "referencia": None,
        "inicio": None,
        "fim": None,
        "dias": 0,
        "evolucao": [],
        "movimentos": {
            "itens": [],
            "pagina": 1,
            "total_paginas": 1,
            "total_registros": 0,
        },
        "disponibilidade": {
            "subsidios": False,
            "custos": False,
            "repasses": False,
        },
    }


def obter_dashboard_financeiro(
    escopo="mes",
    mes=None,
    busca="",
    pagina=1,
):
    df = carregar_financeiro_banco(
        escopo=escopo,
        mes=mes,
    )

    if df.empty:
        return _resposta_vazia(mes, escopo)

    df = df.sort_values("data")

    total_vendas = sum(
        (_money(valor) for valor in df["total_vendas"]),
        Decimal(0),
    )
    total_utilizacao = sum(
        (_money(valor) for valor in df["total_utilizacao"]),
        Decimal(0),
    )
    credito_circulante = sum(
        (_money(valor) for valor in df["credito_circulante"]),
        Decimal(0),
    )

    movimentos = []
    evolucao = []
    total_rows = len(df)

    for i, row in enumerate(df.itertuples()):
        if pd.isna(row.data):
            continue

        data_iso = row.data.strftime("%Y-%m-%d")
        vendas = float(_money(getattr(row, "total_vendas", 0)))
        utilizacao = float(_money(getattr(row, "total_utilizacao", 0)))
        credito = float(_money(getattr(row, "credito_circulante", 0)))

        movimentos.append({
            "data": data_iso,
            "vendas": vendas,
            "utilizacao": utilizacao,
            "credito_circulante": credito,
        })

        evolucao.append({
            "rotulo": row.data.strftime("%d/%m"),
            "vendas": vendas,
            "utilizacao": utilizacao,
            "atual": (i == total_rows - 1),
        })

    query = busca.strip().casefold()
    filtrados = [
        item
        for item in movimentos
        if (
            not query
            or query in item["data"]
            or query in date.fromisoformat(item["data"]).strftime("%d/%m/%Y")
        )
    ]

    total_paginas = max(1, (len(filtrados) + 9) // 10)
    pagina = min(pagina, total_paginas)
    inicio_pagina = (pagina - 1) * 10
    fim_pagina = pagina * 10

    referencia = df["data"].max() if not df.empty else None
    primeira_data = df["data"].min() if not df.empty else None

    return {
        "total_vendas": float(total_vendas),
        "total_utilizacao": float(total_utilizacao),
        "credito_circulante": float(credito_circulante),
        "mes": mes,
        "escopo": escopo,
        "referencia": referencia.strftime("%Y-%m-%d") if referencia is not None else None,
        "inicio": primeira_data.strftime("%Y-%m-%d") if primeira_data is not None else None,
        "fim": referencia.strftime("%Y-%m-%d") if referencia is not None else None,
        "dias": len(df),
        "evolucao": evolucao,
        "movimentos": {
            "itens": filtrados[inicio_pagina:fim_pagina],
            "pagina": pagina,
            "total_paginas": total_paginas,
            "total_registros": len(filtrados),
        },
        "disponibilidade": {
            "subsidios": False,
            "custos": False,
            "repasses": False,
        },
    }
