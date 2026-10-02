from pathlib import Path
import pandas as pd

from app.readers.leitor_html import ler_tabela_html


BASE_DIR = Path(__file__).resolve().parents[2]

ARQUIVO_PASSAGEIROS = (
    BASE_DIR
    / "data"
    / "Julho_2026"
    / "Mensal"
    / "Passageiros.html"
)


def tratar_passageiros():
    df = ler_tabela_html(str(ARQUIVO_PASSAGEIROS))

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
        )

    return df


def obter_overview_passageiros():
    df = tratar_passageiros()

    catraca = df["Catraca"].sum()
    antecipados = df["Antecipados"].sum()
    nao_pagantes = df["Não Pagantes"].sum()

    pagantes = catraca + antecipados
    total = pagantes + nao_pagantes

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
            "valor": float(total),
            "variacao": None,
        },

        "pagantes": {
            "percentual": float(pct_pagantes),
            "quantidade": float(pagantes),
        },

        "gratuidades": {
            "percentual": float(pct_gratuidades),
            "quantidade": float(nao_pagantes),
        },

        "pico_demanda": {
            "faixa": None,
            "media_hora": None,
        },

        "serie": [],

        "categorias": [],
    }