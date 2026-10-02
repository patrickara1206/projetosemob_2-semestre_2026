import pandas as pd

from app.core.dados_config import MESES
from app.readers.leitor_html import ler_tabela_html


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


def carregar_operacao_mes(mes):
    config = MESES[mes]

    caminho = (
        config["pasta"]
        / config["operacao"]
    )

    df = ler_tabela_html(
        caminho,
        indice=1
    )

    df.columns = COLUNAS_OPERACAO

    df["data"] = pd.to_datetime(
        df["data"],
        format="%d/%m/%Y",
        errors="coerce"
    )

    colunas_numericas = [
        "veiculos",
        "max_veiculos",
        "viagens_programadas",
        "viagens_realizadas",
        "viagens_nao_realizadas",
        "km_produtiva",
        "km_morta",
        "km_total",
    ]

    for coluna in colunas_numericas:
        df[coluna] = pd.to_numeric(
            df[coluna],
            errors="coerce"
        )

    df = df.dropna(subset=["data"])

    df["mes_referencia"] = mes
    df["tipo_periodo"] = config["tipo"]

    return df

def carregar_operacao_todos_meses():
    dataframes = []

    for mes in MESES:
        df = carregar_operacao_mes(mes)
        dataframes.append(df)

    return pd.concat(
        dataframes,
        ignore_index=True
    )

def resumo_operacao_por_mes():
    df = carregar_operacao_todos_meses()

    resumo = (
        df.groupby("mes_referencia")
        .agg(
            viagens_programadas=(
                "viagens_programadas",
                "sum"
            ),
            viagens_realizadas=(
                "viagens_realizadas",
                "sum"
            ),
            km_produtiva=(
                "km_produtiva",
                "sum"
            ),
            km_morta=(
                "km_morta",
                "sum"
            ),
        )
        .reset_index()
    )

    return resumo

def obter_overview_operacao(mes="2026-08"):
    df = carregar_operacao_mes(mes)

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