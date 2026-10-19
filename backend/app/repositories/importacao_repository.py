from app.database.supabase_client import supabase


def buscar_importacao_por_hash(hash_arquivo):
    resposta = (
        supabase.table("importacoes")
        .select("*")
        .eq("hash_arquivo", hash_arquivo)
        .execute()
    )

    return resposta.data


def criar_importacao(dados):
    resposta = supabase.table("importacoes").insert(dados).execute()

    return resposta.data[0]


def atualizar_importacao(importacao_id, dados):
    resposta = (
        supabase.table("importacoes").update(dados).eq("id", importacao_id).execute()
    )

    return resposta.data

def listar_meses_importados():
    resposta = (
        supabase.table("importacoes")
        .select("mes_referencia,status")
        .eq("status", "concluido")
        .execute()
    )

    registros = resposta.data or []

    meses = {
        registro.get("mes_referencia")
        for registro in registros
        if registro.get("mes_referencia")
    }

    return sorted(
        meses,
        reverse=True,
    )
    
    from app.database.supabase_client import supabase


def listar_meses_disponiveis():
    meses = set()

    tabelas = [
        "operacao",
        "passageiros",
        "financeiro",
    ]

    for tabela in tabelas:
        resposta = (
            supabase.table(tabela)
            .select("mes_referencia")
            .execute()
        )

        registros = resposta.data or []

        for registro in registros:
            mes = registro.get(
                "mes_referencia"
            )

            if mes:
                meses.add(mes)

    return sorted(
        meses,
        reverse=True,
    )

def listar_periodos_disponiveis():
    disponibilidade = {}

    tabelas = [
        "operacao",
        "passageiros",
        "financeiro",
    ]

    for tabela in tabelas:
        resposta = (
            supabase.table(tabela)
            .select(
                "mes_referencia,tipo_periodo"
            )
            .execute()
        )

        registros = resposta.data or []

        for registro in registros:
            mes = registro.get(
                "mes_referencia"
            )

            periodo = registro.get(
                "tipo_periodo"
            )

            if not mes or not periodo:
                continue

            if mes not in disponibilidade:
                disponibilidade[mes] = set()

            disponibilidade[mes].add(
                periodo
            )

    return {
        mes: sorted(periodos)
        for mes, periodos
        in sorted(
            disponibilidade.items(),
            reverse=True,
        )
    }