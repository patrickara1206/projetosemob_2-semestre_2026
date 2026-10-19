from datetime import date
from decimal import Decimal, ROUND_HALF_UP

from app.repositories.financeiro_repository import buscar_financeiro
from app.services.registros_diarios_service import selecionar_dados


def _money(value):
    return Decimal(
        str(value or 0)
    ).quantize(
        Decimal("0.01"),
        rounding=ROUND_HALF_UP,
    )


def obter_dashboard_financeiro(
    escopo="mes",
    mes=None,
    busca="",
    pagina=1,
):
    registros = buscar_financeiro(
    mes=mes if escopo != "total" else None,
    tipo_periodo=None,
)

    if not registros:
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

    import pandas as pd

    df = pd.DataFrame(registros)

    df["data"] = pd.to_datetime(
        df["data"],
        errors="coerce",
    )

    df = selecionar_dados(
        df,
        escopo=escopo,
        mes=mes,
    )

    if df.empty:
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

    for _, row in df.iterrows():
        if pd.isna(row["data"]):
            continue

        movimentos.append(
            {
                "data": row["data"].strftime("%Y-%m-%d"),
                "vendas": float(
                    _money(row.get("total_vendas"))
                ),
                "utilizacao": float(
                    _money(row.get("total_utilizacao"))
                ),
                "credito_circulante": float(
                    _money(row.get("credito_circulante"))
                ),
            }
        )

    query = busca.strip().casefold()

    filtrados = [
        item
        for item in movimentos
        if (
            not query
            or query in item["data"]
            or query
            in date.fromisoformat(
                item["data"]
            ).strftime("%d/%m/%Y")
        )
    ]

    total_paginas = max(
        1,
        (len(filtrados) + 9) // 10,
    )

    pagina = min(
        pagina,
        total_paginas,
    )

    inicio_pagina = (
        pagina - 1
    ) * 10

    fim_pagina = (
        pagina * 10
    )

    referencia = (
        df["data"].max()
        if not df.empty
        else None
    )

    primeira_data = (
        df["data"].min()
        if not df.empty
        else None
    )

    return {
        "total_vendas": float(total_vendas),
        "total_utilizacao": float(total_utilizacao),
        "credito_circulante": float(
            credito_circulante
        ),
        "mes": mes,
        "escopo": escopo,
        "referencia": (
            referencia.strftime("%Y-%m-%d")
            if referencia is not None
            else None
        ),
        "inicio": (
            primeira_data.strftime("%Y-%m-%d")
            if primeira_data is not None
            else None
        ),
        "fim": (
            referencia.strftime("%Y-%m-%d")
            if referencia is not None
            else None
        ),
        "dias": len(df),
        "evolucao": [
            {
                "rotulo": date.fromisoformat(
                    item["data"]
                ).strftime("%d/%m"),
                "vendas": item["vendas"],
                "utilizacao": item["utilizacao"],
                "atual": (
                    i
                    == len(movimentos) - 1
                ),
            }
            for i, item in enumerate(
                movimentos
            )
        ],
        "movimentos": {
            "itens": filtrados[
                inicio_pagina:fim_pagina
            ],
            "pagina": pagina,
            "total_paginas": total_paginas,
            "total_registros": len(
                filtrados
            ),
        },
        "disponibilidade": {
            "subsidios": False,
            "custos": False,
            "repasses": False,
        },
    }