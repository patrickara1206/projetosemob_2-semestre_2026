import pandas as pd

from app.database.supabase_client import supabase


def inserir_viagens_ocorrencias(df, tamanho_lote=1000):
    dados = df.copy()

    dados["data"] = dados["data"].dt.strftime("%Y-%m-%d")

    for coluna in [
        "inicio_programado",
        "inicio_realizado",
        "fim_programado",
        "fim_realizado",
    ]:
        dados[coluna] = dados[coluna].apply(
            lambda valor: valor.isoformat() if pd.notna(valor) else None
        )

    dados = dados.astype(object).where(pd.notna(dados), None)

    registros = dados.to_dict(orient="records")

    inseridos = []

    for inicio in range(0, len(registros), tamanho_lote):
        lote = registros[inicio : inicio + tamanho_lote]

        resposta = supabase.table("viagens_ocorrencias").insert(lote).execute()

        inseridos.extend(resposta.data)

    return inseridos


def buscar_viagens_ocorrencias_mes(mes):
    resposta = (
        supabase.table("viagens_ocorrencias")
        .select("*")
        .eq("mes_referencia", mes)
        .order("data")
        .execute()
    )

    return resposta.data


def buscar_viagens_ocorrencias_tipo(mes, tipo_ocorrencia):
    resposta = (
        supabase.table("viagens_ocorrencias")
        .select("*")
        .eq("mes_referencia", mes)
        .eq("tipo_ocorrencia", tipo_ocorrencia)
        .order("data")
        .execute()
    )

    return resposta.data
