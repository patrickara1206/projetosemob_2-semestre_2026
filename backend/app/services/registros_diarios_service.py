import pandas as pd


def selecionar_registros_diarios(df, mes):
    """Seleciona um relatório por dia, priorizando o mensal ao quinzenal."""
    if df.empty:
        return df.copy()

    dados = df.copy()
    dados["data"] = pd.to_datetime(dados["data"], errors="coerce").dt.normalize()
    dados = dados[dados["data"].dt.strftime("%Y-%m") == mes].copy()
    if "tipo_periodo" not in dados.columns:
        return dados

    prioridade = dados["tipo_periodo"].map({"mensal": 0, "quinzenal": 1}).fillna(2)
    dados = dados.loc[prioridade.sort_values(kind="stable").index]
    return dados.drop_duplicates(subset=["data"], keep="first")


def filtrar_periodo(df, periodo="mes", inicio=None, fim=None):
    if df.empty or periodo == "mes":
        return df
    if periodo == "personalizado":
        if inicio is None or fim is None:
            raise ValueError("Informe início e fim do período personalizado.")
        return df[df["data"].between(pd.Timestamp(inicio), pd.Timestamp(fim))].copy()
    referencia = df["data"].max()
    inicio_periodo = referencia - pd.Timedelta(days=6) if periodo == "semana" else referencia
    return df[df["data"] >= inicio_periodo].copy()
