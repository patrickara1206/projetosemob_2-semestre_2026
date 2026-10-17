from app.database.supabase_client import supabase


def inserir_resumo_faixa_horaria(df):
    dados = df.copy()

    dados["data"] = dados["data"].dt.strftime("%Y-%m-%d")

    registros = dados.to_dict(orient="records")

    return supabase.table("resumo_faixa_horaria").insert(registros).execute().data
