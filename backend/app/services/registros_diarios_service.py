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
