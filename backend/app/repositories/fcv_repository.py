from app.database.supabase_client import supabase


def inserir_fcv(df):
    dados = df.copy()

    dados["data"] = (
        dados["data"]
        .dt.strftime("%Y-%m-%d")
    )

    registros = dados.to_dict(
        orient="records"
    )

    resposta = (
        supabase
        .table("fcv")
        .insert(registros)
        .execute()
    )

    return resposta.data


def buscar_fcv_mes(mes):
    resposta = (
        supabase
        .table("fcv")
        .select("*")
        .eq("mes_referencia", mes)
        .order("data")
        .execute()
    )

    return resposta.data