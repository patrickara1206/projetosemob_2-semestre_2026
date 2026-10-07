from app.database.supabase_client import supabase


def inserir_dados_relatorio(
    registros,
    tamanho_lote=1000
):
    """
    Insere registros genéricos na tabela dados_relatorio.

    Usado como staging para relatórios que eventualmente
    ainda não tenham persistência estruturada própria.
    """

    inseridos = []

    for inicio in range(
        0,
        len(registros),
        tamanho_lote
    ):
        lote = registros[
            inicio:
            inicio + tamanho_lote
        ]

        resposta = (
            supabase
            .table("dados_relatorio")
            .insert(lote)
            .execute()
        )

        inseridos.extend(
            resposta.data
        )

    return inseridos


def buscar_dados_relatorio(
    tipo_relatorio=None,
    mes=None
):
    query = (
        supabase
        .table("dados_relatorio")
        .select("*")
    )

    if tipo_relatorio:
        query = query.eq(
            "tipo_relatorio",
            tipo_relatorio
        )

    if mes:
        query = query.eq(
            "mes_referencia",
            mes
        )

    resposta = (
        query
        .order("numero_linha")
        .execute()
    )

    return resposta.data