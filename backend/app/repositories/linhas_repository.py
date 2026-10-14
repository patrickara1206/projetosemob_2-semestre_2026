from app.database.supabase_client import supabase


def inserir_linhas(df):
    dados = df.copy()

    dados["data"] = dados["data"].dt.strftime("%Y-%m-%d")

    registros = dados.to_dict(orient="records")

    resposta = supabase.table("linhas").insert(registros).execute()

    return resposta.data


def buscar_linhas_mes(mes):
    return (
        supabase.table("linhas")
        .select("*")
        .eq("mes_referencia", mes)
        .order("data")
        .execute()
        .data
    )
