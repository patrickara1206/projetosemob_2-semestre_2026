import pandas as pd
from app.services.registros_diarios_service import selecionar_dados
from app.repositories.passageiros_repository import buscar_passageiros


def obter_overview_passageiros(
    escopo="mes",
    mes=None,
):
    df = carregar_passageiros_banco(
        escopo=escopo,
        mes=mes,
    )

    if df.empty:
        return {
            "total_passageiros": {"valor": None, "variacao": None},
            "pagantes": {"percentual": None, "quantidade": None},
            "gratuidades": {"percentual": None, "quantidade": None},
            "pico_demanda": {"faixa": None, "media_hora": None},
            "serie": [],
            "categorias": [],
        }

    diario = (
        df.groupby("data", sort=True)["total_passageiros"]
        .sum()
    )
    serie = [
        {"rotulo": data.strftime("%d/%m"), "volume": float(volume), "anomalia": False}
        for data, volume in diario.items()
    ]

    pagantes = float(df["pagantes"].sum())
    nao_pagantes = float(df["nao_pagantes"].sum())
    total = float(df["total_passageiros"].sum())

    pct_pagantes = (pagantes / total * 100) if total > 0 else 0
    pct_gratuidades = (nao_pagantes / total * 100) if total > 0 else 0

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
        "serie": serie,
        "categorias": [],
    }


def normalizar_passageiros(
    df,
    mes,
    tipo_periodo,
):
    df = df.copy()

    # Mantém somente o mês escolhido no app.
    df = df[df["Mês"].astype(str).str.strip() == mes]
    df = df[df["Dia"].astype(str).str.match(r"^\d{1,2}$")]

    if df.empty:
        raise ValueError(
            f"Nenhum dado do mês {mes} foi encontrado no arquivo."
        )

    df["dia"] = pd.to_numeric(df["Dia"], errors="coerce").astype("Int64")
    df["catraca"] = pd.to_numeric(df["Catraca"], errors="coerce").fillna(0).astype("Int64")
    df["antecipados"] = pd.to_numeric(df["Antecipados"], errors="coerce").fillna(0).astype("Int64")
    df["nao_pagantes"] = pd.to_numeric(df["Não Pagantes"], errors="coerce").fillna(0).astype("Int64")
    df["total_passageiros"] = pd.to_numeric(df["Total Passageiros"], errors="coerce").fillna(0).astype("Int64")
    df["pagantes"] = df["catraca"] + df["antecipados"]

    df["data"] = pd.to_datetime(
        mes + "-" + df["dia"].astype(str),
        errors="coerce",
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


def carregar_passageiros_banco(
    escopo="mes",
    mes=None,
):
    registros = buscar_passageiros(
        mes=mes if escopo != "total" else None,
        tipo_periodo=None,
    )

    if not registros:
        return pd.DataFrame()

    df = pd.DataFrame(registros)
    df["data"] = pd.to_datetime(df["data"], errors="coerce")

    return selecionar_dados(
        df,
        escopo=escopo,
        mes=mes,
    )
