import pandas as pd

from app.core.dados_config import MESES
from app.readers.leitor_html import ler_tabela_html
from app.repositories.passageiros_repository import buscar_passageiros_mes


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

    return normalizar_passageiros(
        df,
        mes,
        config["tipo"]
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
    df = carregar_passageiros_banco(mes)

    pagantes = float(
        df["pagantes"].sum()
    )

    nao_pagantes = float(
        df["nao_pagantes"].sum()
    )

    total = float(
        df["total_passageiros"].sum()
    )

    pct_pagantes = (
        pagantes / total * 100
        if total > 0
        else 0
    )

    pct_gratuidades = (
        nao_pagantes / total * 100
        if total > 0
        else 0
    )

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

def normalizar_passageiros(
    df,
    mes,
    tipo_periodo
):
    df = df.copy()

    # Mantém somente dias.
    # Remove linhas como "Total Mês".
    df = df[
        df["Dia"]
        .astype(str)
        .str.match(r"^\d{1,2}$")
    ].copy()

    df["dia"] = pd.to_numeric(
        df["Dia"],
        errors="coerce"
    ).astype("Int64")

    colunas_origem = [
        "Catraca",
        "Antecipados",
        "Não Pagantes",
        "Total Passageiros",
    ]

    for coluna in colunas_origem:
        df[coluna] = (
            pd.to_numeric(
                df[coluna],
                errors="coerce"
            )
            .fillna(0)
            .astype("Int64")
        )

    df["catraca"] = df["Catraca"]
    df["antecipados"] = df["Antecipados"]
    df["nao_pagantes"] = df["Não Pagantes"]
    df["total_passageiros"] = (
        df["Total Passageiros"]
    )

    df["pagantes"] = (
        df["catraca"]
        + df["antecipados"]
    )

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
            "catraca",
            "antecipados",
            "nao_pagantes",
            "total_passageiros",
            "pagantes",
            "mes_referencia",
            "tipo_periodo",
        ]
    ]

def carregar_passageiros_banco(mes):
    registros = buscar_passageiros_mes(
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