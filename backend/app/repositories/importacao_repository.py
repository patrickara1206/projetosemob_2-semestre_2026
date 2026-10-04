from app.database.supabase_client import supabase


def buscar_importacao_por_hash(hash_arquivo):
    resposta = (
        supabase
        .table("importacoes")
        .select("*")
        .eq("hash_arquivo", hash_arquivo)
        .execute()
    )

    return resposta.data


def criar_importacao(dados):
    resposta = (
        supabase
        .table("importacoes")
        .insert(dados)
        .execute()
    )

    return resposta.data[0]


def atualizar_importacao(importacao_id, dados):
    resposta = (
        supabase
        .table("importacoes")
        .update(dados)
        .eq("id", importacao_id)
        .execute()
    )

    return resposta.data