import pandas as pd


def normalizar_fcv(
    df,
    mes,
    tipo_periodo
):
    df = df.copy()

    colunas = [
        "data",
        "manha_programadas",
        "manha_realizadas",
        "tarde_programadas",
        "tarde_realizadas",
        "noite_programadas",
        "noite_realizadas",
        "programadas",
        "realizadas",
    ]

    if len(df.columns) != len(colunas):
        raise ValueError(
            "Arquivo incompatível com relatório FCV. "
            f"Esperadas {len(colunas)} colunas, "
            f"mas foram encontradas {len(df.columns)}."
        )

    df.columns = colunas

    df["data"] = pd.to_datetime(
        df["data"],
        format="%d/%m/%Y",
        errors="coerce",
    )

    for coluna in colunas[1:]:
        df[coluna] = (
            pd.to_numeric(
                df[coluna],
                errors="coerce",
            )
            .round()
            .astype("Int64")
        )

    df = df.dropna(subset=["data"])

    df["mes_referencia"] = mes
    df["tipo_periodo"] = tipo_periodo

    return df


def normalizar_linhas(
    df,
    mes,
    tipo_periodo
):
    df = df.copy()

    colunas = [
        "data",
        "linha",
        "km_total",
        "numero_viagens",
    ]

    if len(df.columns) != len(colunas):
        raise ValueError(
            "Arquivo incompatível com relatório de Linhas. "
            f"Esperadas {len(colunas)} colunas, "
            f"mas foram encontradas {len(df.columns)}."
        )

    df.columns = colunas

    df["data"] = pd.to_datetime(
        df["data"],
        format="%d/%m/%Y",
        errors="coerce",
    )

    df["linha"] = df["linha"].astype(str)

    df["km_total"] = pd.to_numeric(
        df["km_total"],
        errors="coerce",
    )

    df["numero_viagens"] = (
        pd.to_numeric(
            df["numero_viagens"],
            errors="coerce",
        )
        .round()
        .astype("Int64")
    )

    df = df.dropna(subset=["data"])

    df["mes_referencia"] = mes
    df["tipo_periodo"] = tipo_periodo

    return df


def normalizar_resumo_faixa_horaria(
    df,
    mes,
    tipo_periodo
):
    df = df.copy()

    colunas = [
        "data",
        "faixa_horaria",
        "numero_veiculos",
        "numero_viagens",
    ]

    if len(df.columns) != len(colunas):
        raise ValueError(
            "Arquivo incompatível com Resumo por Faixa Horária. "
            f"Esperadas {len(colunas)} colunas, "
            f"mas foram encontradas {len(df.columns)}."
        )

    df.columns = colunas

    df["data"] = pd.to_datetime(
        df["data"],
        format="%d/%m/%Y",
        errors="coerce",
    )

    for coluna in [
        "numero_veiculos",
        "numero_viagens",
    ]:
        df[coluna] = (
            pd.to_numeric(
                df[coluna],
                errors="coerce",
            )
            .round()
            .astype("Int64")
        )

    df = df.dropna(subset=["data"])

    df["mes_referencia"] = mes
    df["tipo_periodo"] = tipo_periodo

    return df


def normalizar_faixa_horaria(
    df,
    mes,
    tipo_periodo
):
    df = df.copy()

    colunas = [
        "data",
        "linha",
        "faixa_horaria",
        "numero_veiculos",
        "numero_viagens",
        "partidas",
    ]

    if len(df.columns) != len(colunas):
        raise ValueError(
            "Arquivo incompatível com relatório de Faixa Horária. "
            f"Esperadas {len(colunas)} colunas, "
            f"mas foram encontradas {len(df.columns)}."
        )

    df.columns = colunas

    df["data"] = pd.to_datetime(
        df["data"],
        format="%d/%m/%Y",
        errors="coerce",
    )

    df["linha"] = df["linha"].astype(str)

    for coluna in [
        "numero_veiculos",
        "numero_viagens",
    ]:
        df[coluna] = (
            pd.to_numeric(
                df[coluna],
                errors="coerce",
            )
            .round()
            .astype("Int64")
        )

    df = df.dropna(subset=["data"])

    df["mes_referencia"] = mes
    df["tipo_periodo"] = tipo_periodo

    return df


def normalizar_viagens(
    df,
    mes,
    tipo_periodo
):
    df = df.copy()

    colunas = [
        "data",
        "linha",
        "prefixo",
        "atividade",
        "sentido",
        "faixa_horaria",
        "inicio_realizado",
        "fim_realizado",
        "km_produtiva",
        "km_improdutiva",
        "km_total",
    ]

    if len(df.columns) != len(colunas):
        raise ValueError(
            "Arquivo incompatível com Viagens. "
            f"Esperadas {len(colunas)} colunas, "
            f"mas foram encontradas {len(df.columns)}."
        )

    df.columns = colunas

    df["data"] = pd.to_datetime(
        df["data"],
        format="%d/%m/%Y",
        errors="coerce",
    )

    for coluna in [
        "inicio_realizado",
        "fim_realizado",
    ]:
        df[coluna] = pd.to_datetime(
            df[coluna],
            errors="coerce",
        )

    for coluna in [
        "km_produtiva",
        "km_improdutiva",
        "km_total",
    ]:
        df[coluna] = pd.to_numeric(
            df[coluna],
            errors="coerce",
        )

    df = df.dropna(subset=["data"])

    df["mes_referencia"] = mes
    df["tipo_periodo"] = tipo_periodo

    return df


def normalizar_viagens_ocorrencias(
    df,
    mes,
    tipo_periodo,
    tipo_ocorrencia
):
    df = df.copy()

    colunas = [
        "data",
        "linha",
        "atendimento",
        "prefixo",
        "atividade",
        "motorista",
        "sentido",
        "tabela",
        "status_saida",
        "status_chegada",
        "inicio_programado",
        "inicio_realizado",
        "fim_programado",
        "fim_realizado",
        "km_produtiva",
    ]

    if len(df.columns) != len(colunas):
        raise ValueError(
            "Arquivo incompatível com ocorrência de viagens. "
            f"Esperadas {len(colunas)} colunas, "
            f"mas foram encontradas {len(df.columns)}."
        )

    df.columns = colunas

    df["data"] = pd.to_datetime(
        df["data"],
        format="%d/%m/%Y",
        errors="coerce",
    )

    for coluna in [
        "inicio_programado",
        "inicio_realizado",
        "fim_programado",
        "fim_realizado",
    ]:
        df[coluna] = pd.to_datetime(
            df[coluna],
            errors="coerce",
        )

    df["km_produtiva"] = pd.to_numeric(
        df["km_produtiva"],
        errors="coerce",
    )

    df = df.dropna(subset=["data"])

    df["tipo_ocorrencia"] = tipo_ocorrencia
    df["mes_referencia"] = mes
    df["tipo_periodo"] = tipo_periodo

    return df