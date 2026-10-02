from pathlib import Path
import pandas as pd

from app.readers.leitor_html import ler_tabela_html


BASE_DIR = Path(__file__).resolve().parents[2]

ARQUIVO = (
    BASE_DIR
    / "data"
    / "Julho_2026"
    / "Mensal"
    / "Mensal_202607.html"
)

# essa funcao carrega o arquivo HTML da pasta zipada fornecida pelo cliente e retorna o dataframe com os dados
def carregar_operacao():
    df = ler_tabela_html(str(ARQUIVO))

    df.columns = [
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

    return df

# essa parte faz o tratamento dos dados, convertendo as colunas para o tipo correto e removendo linhas com datas inválidas
def tratar_operacao():
    df = carregar_operacao()

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

    return df

# essa parte faz o resumo dos dados, somando colunas de interesse e retornando resultados
def resumo_operacao():
    df = tratar_operacao()

    return {
        "viagens_programadas": int(
            df["viagens_programadas"].sum()
        ),
        "viagens_realizadas": int(
            df["viagens_realizadas"].sum()
        ),
        "km_produtiva": float(
            df["km_produtiva"].sum()
        ),
        "km_morta": float(
            df["km_morta"].sum()
        ),
    }

# essa parte vai fazer uma overview do projeto, devolvendo o JSON no formato que o flutter espera, com os dados de viagens, pontualidade, quilometragem, etc
def obter_overview_operacao():
    df = tratar_operacao()

    realizadas = int(df["viagens_realizadas"].sum())
    programadas = int(df["viagens_programadas"].sum())

    km_produtiva = float(df["km_produtiva"].sum())
    km_morta = float(df["km_morta"].sum())

    return {
        "total_viagens": {
            "realizado": realizadas,
            "programado": programadas,
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
                "rotulo": "Jul",
                "produtiva": km_produtiva,
                "morta": km_morta,
            }
        ],

        "viagens_por_hora": [],

        "anomalias": [],
    }