import pandas as pd

from app.services.registros_diarios_service import selecionar_dados
from app.repositories.operacao_repository import buscar_operacao
from app.repositories.resumo_faixa_horaria_repository import (
    buscar_resumo_faixa_horaria,
)

COLUNAS_OPERACAO = [
    "data",
    "dia_semana",
    "veiculos",
    "max_veiculos",
    "viagens_programadas",
    "viagens_realizadas",
    "viagens_nao_realizadas",
    "km_produtiva",
    "km_morta",
    "km_total",
]


def normalizar_operacao(
    df,
    mes,
    tipo_periodo,
):
    df = df.copy()
    df.columns = COLUNAS_OPERACAO

    df["data"] = pd.to_datetime(
        df["data"],
        format="%d/%m/%Y",
        errors="coerce",
    )

    colunas_inteiras = [
        "veiculos",
        "max_veiculos",
        "viagens_programadas",
        "viagens_realizadas",
        "viagens_nao_realizadas",
    ]

    for coluna in colunas_inteiras:
        df[coluna] = (
            pd.to_numeric(
                df[coluna],
                errors="coerce",
            )
            .round()
            .astype("Int64")
        )

    colunas_decimais = [
        "km_produtiva",
        "km_morta",
        "km_total",
    ]

    for coluna in colunas_decimais:
        df[coluna] = pd.to_numeric(
            df[coluna],
            errors="coerce",
        )

    df = df.dropna(
        subset=["data"],
    )

    df["mes_referencia"] = mes
    df["tipo_periodo"] = tipo_periodo

    return df


def carregar_operacao_banco(
    escopo="mes",
    mes=None,
):
    registros = buscar_operacao(
        mes=mes if escopo != "total" else None,
        tipo_periodo=None,
    )

    if not registros:
        return pd.DataFrame()

    df = pd.DataFrame(registros)

    df["data"] = pd.to_datetime(
        df["data"],
        errors="coerce",
    )

    return selecionar_dados(
        df,
        escopo=escopo,
        mes=mes,
    )


def carregar_viagens_por_hora(
    escopo="mes",
    mes=None,
):
    registros = buscar_resumo_faixa_horaria(
        mes=mes if escopo != "total" else None,
        tipo_periodo=None,
    )

    if not registros:
        return []

    df = pd.DataFrame(registros)

    if df.empty:
        return []

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
        return []

    df["numero_viagens"] = pd.to_numeric(
        df["numero_viagens"],
        errors="coerce",
    ).fillna(0)

    df = df.dropna(
        subset=["faixa_horaria"],
    )

    if df.empty:
        return []

    agrupado = df.groupby(
        "faixa_horaria",
        sort=True,
    )["numero_viagens"].mean()

    if agrupado.empty:
        return []

    maior_valor = float(agrupado.max())

    return [
        {
            "rotulo": str(faixa),
            "viagens": float(valor),
            "pico": bool(float(valor) == maior_valor),
        }
        for faixa, valor in agrupado.items()
    ]


def obter_overview_operacao(
    escopo="mes",
    mes=None,
):
    df = carregar_operacao_banco(
        escopo=escopo,
        mes=mes,
    )

    if df.empty:
        return {
            "total_viagens": {
                "realizado": None,
                "programado": None,
            },
            "pontualidade": {
                "valor": None,
                "variacao": None,
                "meta": 95,
            },
            "quilometragem": {
                "produtiva": None,
                "morta": None,
            },
            "km_mensal": [],
            "viagens_por_hora": [],
            "anomalias": [],
            "serie_viagens": [],
        }

    diario = (
        df.groupby(
            "data",
            sort=True,
        )[
            [
                "viagens_realizadas",
                "viagens_programadas",
            ]
        ]
        .sum()
        .reset_index()
    )

    serie = [
        {
            "rotulo": (
                row.data.strftime(
                    "%d/%m",
                )
            ),
            "realizado": float(row.viagens_realizadas),
            "esperado": float(row.viagens_programadas),
            "anomalia": False,
        }
        for row in diario.itertuples()
    ]

    viagens_programadas = int(df["viagens_programadas"].sum())

    viagens_realizadas = int(df["viagens_realizadas"].sum())
    indice_execucao = (
        viagens_realizadas / viagens_programadas * 100
        if viagens_programadas > 0
        else None
    )
    km_produtiva = float(df["km_produtiva"].sum())

    km_morta = float(df["km_morta"].sum())

    viagens_por_hora = carregar_viagens_por_hora(
        escopo=escopo,
        mes=mes,
    )

    if escopo == "total":
        km_por_mes = (
            df.groupby(
                "mes_referencia",
                sort=True,
            )[
                [
                    "km_produtiva",
                    "km_morta",
                ]
            ]
            .sum()
            .reset_index()
        )

        km_mensal = [
            {
                "rotulo": str(row.mes_referencia),
                "produtiva": float(row.km_produtiva),
                "morta": float(row.km_morta),
            }
            for row in km_por_mes.itertuples()
        ]
    else:
        km_mensal = [
            {
                "rotulo": str(mes),
                "produtiva": (km_produtiva),
                "morta": km_morta,
            }
        ]

    return {
        "total_viagens": {
            "realizado": (viagens_realizadas),
            "programado": (viagens_programadas),
        },
        "pontualidade": {
            "valor": indice_execucao,
            "variacao": None,
            "meta": 95,
        },
        "quilometragem": {
            "produtiva": (km_produtiva),
            "morta": km_morta,
        },
        "km_mensal": km_mensal,
        "serie_viagens": serie,
        "viagens_por_hora": (viagens_por_hora),
        "anomalias": [],
    }
