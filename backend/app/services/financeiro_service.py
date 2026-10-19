import pandas as pd
from app.services.registros_diarios_service import selecionar_dados
from app.repositories.financeiro_repository import buscar_financeiro


def obter_overview_financeiro(
    escopo="mes",
    mes=None,
):
    df = carregar_financeiro_banco(
        escopo=escopo,
        mes=mes,
    )

    if df.empty:
        return {
            "total_vendas": None,
            "total_utilizacao": None,
            "credito_circulante": None,
            "dias_financeiros": [],
        }

    df = df.sort_values("data")

    def numero(valor):
        if pd.isna(valor):
            return None
        return round(float(valor), 2)

    dias_financeiros = []

    for _, registro in df.iterrows():
        if pd.isna(registro["data"]):
            continue

        dias_financeiros.append({
            "data": registro["data"].strftime("%Y-%m-%d"),
            "rotulo": registro["data"].strftime("%d/%m"),
            "vendas": numero(registro["total_vendas"]),
            "utilizacao": numero(registro["total_utilizacao"]),
            "credito_circulante": numero(
                registro["credito_circulante"]
            ),
        })

    return {
        "total_vendas": numero(
            df["total_vendas"].sum(min_count=1)
        ),
        "total_utilizacao": numero(
            df["total_utilizacao"].sum(min_count=1)
        ),
        "credito_circulante": numero(
            df["credito_circulante"].sum(min_count=1)
        ),
        "dias_financeiros": dias_financeiros,
    }

def normalizar_financeiro(
    df,
    mes,
    tipo_periodo,
):
    df = df.copy()

    # Mantém somente o mês escolhido no app.
    df = df[
        df["Mês"]
        .astype(str)
        .str.strip()
        == mes
    ].copy()

    df = df[
        df["Dia"]
        .astype(str)
        .str.match(r"^\d{1,2}$")
    ].copy()

    if df.empty:
        raise ValueError(
            f"Nenhum dado do mês {mes} "
            "foi encontrado no arquivo."
        )

    df["dia"] = pd.to_numeric(
        df["Dia"],
        errors="coerce",
    ).astype("Int64")

    df["total_vendas"] = pd.to_numeric(
        df["Total Vendas"],
        errors="coerce",
    ).fillna(0)

    df["total_utilizacao"] = pd.to_numeric(
        df["Total Utilização"],
        errors="coerce",
    ).fillna(0)

    df["credito_circulante"] = pd.to_numeric(
        df["Crédito Circulante"],
        errors="coerce",
    ).fillna(0)

    df["data"] = pd.to_datetime(
        mes
        + "-"
        + df["dia"].astype(str),
        errors="coerce",
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


def carregar_financeiro_banco(
    escopo="mes",
    mes=None,
):
    registros = buscar_financeiro(
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
