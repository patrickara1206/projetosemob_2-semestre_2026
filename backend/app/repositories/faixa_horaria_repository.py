from app.database.supabase_client import supabase


def inserir_faixa_horaria(df):
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
        .table("faixa_horaria")
        .insert(registros)
        .execute()
    )

    return resposta.data


def buscar_faixa_horaria_mes(mes):
    resposta = (
        supabase
        .table("faixa_horaria")
        .select("*")
        .eq("mes_referencia", mes)
        .order("data")
        .execute()
    )

    return resposta.data