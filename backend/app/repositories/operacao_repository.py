from app.database.supabase_client import supabase


def inserir_operacao(df):
    dados = df.copy()

    dados["data"] = dados["data"].dt.strftime("%Y-%m-%d")

    registros = dados.to_dict(orient="records")

    resposta = (
        supabase.table("operacao")
        .upsert(registros, on_conflict="data,tipo_periodo")
        .execute()
    )

    return resposta.data


def buscar_operacao_mes(mes):
    resposta = (
        supabase.table("operacao")
        .select("*")
        .eq("mes_referencia", mes)
        .order("data")
        .execute()
    )

    registros = resposta.data or []

    registros = sorted(
        registros,
        key=lambda registro: (0 if registro.get("tipo_periodo") == "mensal" else 1),
    )

    registros_por_data = {}

    for registro in registros:
        data = str(registro["data"])[:10]

        if data not in registros_por_data:
            registros_por_data[data] = registro

    return [registros_por_data[data] for data in sorted(registros_por_data)]
