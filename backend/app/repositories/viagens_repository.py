import pandas as pd

from app.database.supabase_client import supabase


def inserir_viagens(
    df,
    tamanho_lote=1000
):
    dados = df.copy()

    # Converte a data principal
    dados["data"] = (
        dados["data"]
        .dt.strftime("%Y-%m-%d")
    )

    # Converte datas/horas para formato aceito pelo Supabase
    for coluna in [
        "inicio_realizado",
        "fim_realizado",
    ]:
        dados[coluna] = dados[coluna].apply(
            lambda valor:
                valor.isoformat()
                if pd.notna(valor)
                else None
        )

    # IMPORTANTE:
    # transforma NaN / NaT em None,
    # pois JSON não aceita NaN.
    dados = (
        dados
        .astype(object)
        .where(pd.notna(dados), None)
    )

    registros = dados.to_dict(
        orient="records"
    )

    inseridos = []

    # Insere em lotes para evitar requisições muito grandes
    for inicio in range(
        0,
        len(registros),
        tamanho_lote
    ):
        lote = registros[
            inicio:
            inicio + tamanho_lote
        ]

        resposta = (
            supabase
            .table("viagens")
            .insert(lote)
            .execute()
        )

        inseridos.extend(
            resposta.data
        )

    return inseridos


def buscar_viagens_mes(mes):
    resposta = (
        supabase
        .table("viagens")
        .select("*")
        .eq("mes_referencia", mes)
        .order("data")
        .execute()
    )

    return resposta.data