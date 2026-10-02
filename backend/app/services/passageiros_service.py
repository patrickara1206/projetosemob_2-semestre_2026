import pandas as pd

from app.core.dados_config import MESES
from app.readers.leitor_html import ler_tabela_html


def carregar_passageiros_mes(mes):
    config = MESES[mes]

    caminho = (
        config["pasta"]
        / config["passageiros"]
    )

    df = ler_tabela_html(
        caminho,
        indice=1
    )

    # Mantém apenas linhas de dias.
    # Isso evita somar "Total Mês".
    df = df[
        df["Dia"]
        .astype(str)
        .str.match(r"^\d{1,2}$")
    ].copy()

    colunas_numericas = [
        "Catraca",
        "Antecipados",
        "Não Pagantes",
        "Total Passageiros",
    ]

    for coluna in colunas_numericas:
        df[coluna] = pd.to_numeric(
            df[coluna],
            errors="coerce"
        ).fillna(0)

    df["pagantes"] = (
        df["Catraca"]
        + df["Antecipados"]
    )

    df["mes_referencia"] = mes
    df["tipo_periodo"] = config["tipo"]

    return df

def carregar_passageiros_todos_meses():
    dataframes = []

    for mes in MESES:
        dataframes.append(
            carregar_passageiros_mes(mes)
        )

    return pd.concat(
        dataframes,
        ignore_index=True
    )

def resumo_passageiros_por_mes():
    df = carregar_passageiros_todos_meses()

    resumo = (
        df.groupby("mes_referencia")
        .agg(
            pagantes=("pagantes", "sum"),
            nao_pagantes=(
                "Não Pagantes",
                "sum"
            ),
            total_passageiros=(
                "Total Passageiros",
                "sum"
            ),
        )
        .reset_index()
    )

    return resumo

def obter_overview_passageiros(mes="2026-08"):
    df = carregar_passageiros_mes(mes)

    pagantes = float(df["pagantes"].sum())
    nao_pagantes = float(df["Não Pagantes"].sum())
    total = float(df["Total Passageiros"].sum())

    pct_pagantes = pagantes / total * 100 if total > 0 else 0
    pct_gratuidades = nao_pagantes / total * 100 if total > 0 else 0

    return {
        "total_passageiros": {
            "valor": total,
            "variacao": None,
        },
        "pagantes": {
            "percentual": pct_pagantes,
            "quantidade": pagantes,
        },
        "gratuidades": {
            "percentual": pct_gratuidades,
            "quantidade": nao_pagantes,
        },
        "pico_demanda": {
            "faixa": None,
            "media_hora": None,
        },
        "serie": [],
        "categorias": [],
    }

