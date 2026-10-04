from app.database.supabase_client import supabase


def inserir_operacao(df):
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
        .table("operacao")
        .upsert(
        registros,
            on_conflict="data,tipo_periodo"
                )
        .execute()
    )

    return resposta.data


def buscar_operacao_mes(mes):
    resposta = (
        supabase
        .table("operacao")
        .select("*")
        .eq("mes_referencia", mes)
        .order("data")
        .execute()
    )

    return resposta.data