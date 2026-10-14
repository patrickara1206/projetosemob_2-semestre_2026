import pandas as pd

from app.repositories.passageiros_repository import buscar_passageiros_mes

def obter_overview_passageiros(mes="2026-08"):
    df = carregar_passageiros_banco(mes)

    pagantes = float(df["pagantes"].sum())

    nao_pagantes = float(df["nao_pagantes"].sum())

    total = float(df["total_passageiros"].sum())

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


def normalizar_passageiros(df, mes, tipo_periodo):
    df = df.copy()

    df = df[df["Dia"].astype(str).str.match(r"^\d{1,2}$")].copy()

    df["dia"] = pd.to_numeric(df["Dia"], errors="coerce").astype("Int64")

    colunas_origem = [
        "Catraca",
        "Antecipados",
        "Não Pagantes",
        "Total Passageiros",
    ]

    for coluna in colunas_origem:
        df[coluna] = (
            pd.to_numeric(df[coluna], errors="coerce").fillna(0).astype("Int64")
        )

    df["catraca"] = df["Catraca"]
    df["antecipados"] = df["Antecipados"]
    df["nao_pagantes"] = df["Não Pagantes"]
    df["total_passageiros"] = df["Total Passageiros"]

    df["pagantes"] = df["catraca"] + df["antecipados"]

    df["data"] = pd.to_datetime(mes + "-" + df["dia"].astype(str), errors="coerce")

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
    registros = buscar_passageiros_mes(mes)

    if not registros:
        return pd.DataFrame()

    df = pd.DataFrame(registros)

    df["data"] = pd.to_datetime(df["data"], errors="coerce")

    return df
