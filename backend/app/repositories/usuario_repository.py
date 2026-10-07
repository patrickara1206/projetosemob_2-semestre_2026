from app.database.supabase_client import supabase


def buscar_usuario_por_email(email):
    resposta = (
        supabase
        .table("usuarios")
        .select("*")
        .eq("email", email)
        .eq("ativo", True)
        .limit(1)
        .execute()
    )

    if not resposta.data:
        return None

    return resposta.data[0]