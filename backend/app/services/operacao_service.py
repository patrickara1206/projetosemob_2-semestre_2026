import pandas as pd

from app.repositories.operacao_repository import buscar_operacao_mes


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
    tipo_periodo
):
    df = df.copy()

    df.columns = COLUNAS_OPERACAO

    df["data"] = pd.to_datetime(
        df["data"],
        format="%d/%m/%Y",
        errors="coerce"
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
                errors="coerce"
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
            errors="coerce"
        )

    df = df.dropna(
        subset=["data"]
    )

    df["mes_referencia"] = mes
    df["tipo_periodo"] = tipo_periodo

    return df

def carregar_operacao_banco(mes):
    registros = buscar_operacao_mes(
        mes
    )

    if not registros:
        return pd.DataFrame()

    df = pd.DataFrame(
        registros
    )

    df["data"] = pd.to_datetime(
        df["data"],
        errors="coerce"
    )

    return df

def obter_overview_operacao(mes="2026-08"):
    df = carregar_operacao_banco(mes)

    viagens_programadas = int(
        df["viagens_programadas"].sum()
    )

    viagens_realizadas = int(
        df["viagens_realizadas"].sum()
    )

    km_produtiva = float(
        df["km_produtiva"].sum()
    )

    km_morta = float(
        df["km_morta"].sum()
    )

    return {
        "total_viagens": {
            "realizado": viagens_realizadas,
            "programado": viagens_programadas,
        },

        "pontualidade": {
            "valor": None,
            "variacao": None,
            "meta": 95,
        },

        "quilometragem": {
            "produtiva": km_produtiva,
            "morta": km_morta,
        },

        "km_mensal": [
            {
                "rotulo": mes,
                "produtiva": km_produtiva,
                "morta": km_morta,
            }
        ],

        "viagens_por_hora": [],

        "anomalias": [],
    }