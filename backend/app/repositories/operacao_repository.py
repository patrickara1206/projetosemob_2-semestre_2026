from app.database.supabase_client import supabase


def inserir_operacao(df):
    dados = df.copy()

    dados["data"] = dados["data"].dt.strftime("%Y-%m-%d")

    registros = dados.to_dict(orient="records")

    resposta = (
        supabase.table("operacao")
        .upsert(
            registros,
            on_conflict="data,tipo_periodo",
        )
        .execute()
    )

    return resposta.data


def buscar_operacao(
    mes=None,
    tipo_periodo=None,
):
    query = supabase.table("operacao").select("*")

    if mes is not None:
        query = query.eq("mes_referencia", mes)

    if tipo_periodo is not None:
        query = query.eq("tipo_periodo", tipo_periodo)

    resposta = query.order("data").execute()

    return resposta.data or []