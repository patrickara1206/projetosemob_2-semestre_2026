import pandas as pd

from app.core.dados_config import MESES
from app.readers.leitor_html import ler_tabela_html
from app.repositories.financeiro_repository import buscar_financeiro_mes


def carregar_financeiro_mes(mes):
    config = MESES[mes]

    caminho = (
        config["pasta"]
        / config["financeiro"]
    )

    df = ler_tabela_html(
        caminho,
        indice=2
    )

    return normalizar_financeiro(
        df,
        mes,
        config["tipo"]
    )


def obter_overview_financeiro(mes="2026-08"):
    df = carregar_financeiro_banco(mes)

    return {
        "total_vendas": float(
            df["total_vendas"].sum()
        ),
        "total_utilizacao": float(
            df["total_utilizacao"].sum()
        ),
        "credito_circulante": float(
            df["credito_circulante"].sum()
        ),
    }

def normalizar_financeiro(
    df,
    mes,
    tipo_periodo
):
    df = df.copy()

    # Mantém somente o mês solicitado
    df = df[
        df["Mês"]
        .astype(str)
        == mes
    ].copy()

    # Remove linhas como "Total Mês"
    df = df[
        df["Dia"]
        .astype(str)
        .str.match(r"^\d{1,2}$")
    ].copy()

    df["dia"] = (
        pd.to_numeric(
            df["Dia"],
            errors="coerce"
        )
        .astype("Int64")
    )

    df["total_vendas"] = pd.to_numeric(
        df["Total Vendas"],
        errors="coerce"
    ).fillna(0)

    df["total_utilizacao"] = pd.to_numeric(
        df["Total Utilização"],
        errors="coerce"
    ).fillna(0)

    df["credito_circulante"] = pd.to_numeric(
        df["Crédito Circulante"],
        errors="coerce"
    ).fillna(0)

    df["data"] = pd.to_datetime(
        mes
        + "-"
        + df["dia"].astype(str),
        errors="coerce"
    )

    df["mes_referencia"] = mes
    df["tipo_periodo"] = tipo_periodo

    return df[
        [
            "data",
            "dia",
            "total_vendas",
            "total_utilizacao",
            "credito_circulante",
            "mes_referencia",
            "tipo_periodo",
        ]
    ]

def carregar_financeiro_banco(mes):
    registros = buscar_financeiro_mes(
        mes
    )

    if not registros:
        return pd.DataFrame()

    df = pd.DataFrame(registros)

    df["data"] = pd.to_datetime(
        df["data"],
        errors="coerce"
    )

    return df