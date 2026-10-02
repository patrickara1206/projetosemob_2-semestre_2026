import pandas as pd

from app.core.dados_config import MESES
from app.readers.leitor_html import ler_tabela_html


def carregar_financeiro_mes(mes):
    config = MESES[mes]

    caminho = (
        config["pasta"]
        / config["financeiro"]
    )

    # Nos arquivos Saldos, os dados financeiros
    # estão na tabela de índice 2.
    df = ler_tabela_html(
        caminho,
        indice=2
    )

    # IMPORTANTE:
    # o arquivo de agosto contém também uma linha de setembro,
    # então filtramos explicitamente pelo mês desejado.
    df = df[
        df["Mês"].astype(str) == mes
    ].copy()

    # Remove "Total Mês", mantendo apenas dias.
    df = df[
        df["Dia"]
        .astype(str)
        .str.match(r"^\d{1,2}$")
    ].copy()

    colunas = [
        "Total Vendas",
        "Total Utilização",
        "Crédito Circulante",
    ]

    for coluna in colunas:
        df[coluna] = pd.to_numeric(
            df[coluna],
            errors="coerce"
        ).fillna(0)

    return df


def obter_overview_financeiro(mes="2026-08"):
    df = carregar_financeiro_mes(mes)

    return {
        "total_vendas": float(
            df["Total Vendas"].sum()
        ),
        "total_utilizacao": float(
            df["Total Utilização"].sum()
        ),
        "credito_circulante": float(
            df["Crédito Circulante"].sum()
        ),
    }