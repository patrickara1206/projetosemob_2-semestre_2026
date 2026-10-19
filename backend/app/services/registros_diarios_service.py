import pandas as pd


def selecionar_dados(
    df,
    escopo="mes",
    mes=None,
):
    if df.empty:
        return df.copy()

    dados = df.copy()

    dados["data"] = pd.to_datetime(
        dados["data"],
        errors="coerce",
    )

    dados = dados.dropna(
        subset=["data"]
    )

    if mes is not None:
        dados = dados[
            dados["data"]
            .dt.strftime("%Y-%m")
            == mes
        ].copy()

    if "tipo_periodo" in dados.columns:
        prioridade = (
            dados["tipo_periodo"]
            .map(
                {
                    "mensal": 0,
                    "quinzenal": 1,
                }
            )
            .fillna(2)
        )

        dados = dados.assign(
            _prioridade=prioridade
        )

        dados = dados.sort_values(
            [
                "data",
                "_prioridade",
            ],
            kind="stable",
        )

        dados = dados.drop_duplicates(
            subset=["data"],
            keep="first",
        )

        dados = dados.drop(
            columns=["_prioridade"]
        )

    if escopo == "quinzena":
        dados = dados[
            dados["data"].dt.day <= 15
        ].copy()

    return dados.sort_values(
        "data"
    )