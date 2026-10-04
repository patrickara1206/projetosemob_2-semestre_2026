import hashlib

from app.services.financeiro_service import (
    normalizar_financeiro
)

from app.repositories.financeiro_repository import (
    inserir_financeiro
)

from app.services.passageiros_service import (
    normalizar_passageiros
)

from app.repositories.passageiros_repository import (
    inserir_passageiros
)

from app.readers.leitor_html import (
    ler_tabela_html_bytes
)

from app.services.operacao_service import (
    normalizar_operacao
)

from app.repositories.operacao_repository import (
    inserir_operacao
)

from app.repositories.importacao_repository import (
    buscar_importacao_por_hash,
    criar_importacao,
    atualizar_importacao,
)


def calcular_hash(conteudo):
    return hashlib.sha256(
        conteudo
    ).hexdigest()


def importar_operacao(
    conteudo,
    nome_arquivo,
    mes,
    tipo_periodo="mensal"
):
    hash_arquivo = calcular_hash(
        conteudo
    )

    existente = buscar_importacao_por_hash(
        hash_arquivo
    )

    if existente:
        raise ValueError(
            "Este arquivo já foi importado."
        )

    importacao = criar_importacao({
        "nome_arquivo": nome_arquivo,
        "tipo_relatorio": "operacao",
        "mes_referencia": mes,
        "tipo_periodo": tipo_periodo,
        "hash_arquivo": hash_arquivo,
        "quantidade_registros": 0,
        "status": "processando",
    })

    try:
        df = ler_tabela_html_bytes(
            conteudo,
            indice=1
        )

        df = normalizar_operacao(
            df,
            mes,
            tipo_periodo
        )

        df["importacao_id"] = (
            importacao["id"]
        )

        inserir_operacao(df)

        atualizar_importacao(
            importacao["id"],
            {
                "status": "concluido",
                "quantidade_registros": len(df),
            }
        )

        return {
            "importacao_id":
                importacao["id"],
            "registros":
                len(df),
        }

    except Exception as erro:
        atualizar_importacao(
            importacao["id"],
            {
                "status": "erro",
                "erro_mensagem": str(erro),
            }
        )

        raise


def importar_passageiros(
    conteudo,
    nome_arquivo,
    mes,
    tipo_periodo="mensal"
):
    hash_arquivo = calcular_hash(
        conteudo
    )

    existente = buscar_importacao_por_hash(
        hash_arquivo
    )

    if existente:
        raise ValueError(
            "Este arquivo já foi importado."
        )

    importacao = criar_importacao({
        "nome_arquivo": nome_arquivo,
        "tipo_relatorio": "passageiros",
        "mes_referencia": mes,
        "tipo_periodo": tipo_periodo,
        "hash_arquivo": hash_arquivo,
        "quantidade_registros": 0,
        "status": "processando",
    })

    try:
        df = ler_tabela_html_bytes(
            conteudo,
            indice=1
        )

        df = normalizar_passageiros(
            df,
            mes,
            tipo_periodo
        )

        df["importacao_id"] = (
            importacao["id"]
        )

        inserir_passageiros(df)

        atualizar_importacao(
            importacao["id"],
            {
                "status": "concluido",
                "quantidade_registros":
                    len(df),
            }
        )

        return {
            "importacao_id":
                importacao["id"],
            "registros":
                len(df),
        }

    except Exception as erro:
        atualizar_importacao(
            importacao["id"],
            {
                "status": "erro",
                "erro_mensagem": str(erro),
            }
        )

        raise


def importar_financeiro(
    conteudo,
    nome_arquivo,
    mes,
    tipo_periodo="mensal"
):
    hash_arquivo = calcular_hash(
        conteudo
    )

    existente = buscar_importacao_por_hash(
        hash_arquivo
    )

    if existente:
        raise ValueError(
            "Este arquivo já foi importado."
        )

    importacao = criar_importacao({
        "nome_arquivo": nome_arquivo,
        "tipo_relatorio": "financeiro",
        "mes_referencia": mes,
        "tipo_periodo": tipo_periodo,
        "hash_arquivo": hash_arquivo,
        "quantidade_registros": 0,
        "status": "processando",
    })

    try:
        df = ler_tabela_html_bytes(
            conteudo,
            indice=2
        )

        df = normalizar_financeiro(
            df,
            mes,
            tipo_periodo
        )

        df["importacao_id"] = (
            importacao["id"]
        )

        inserir_financeiro(df)

        atualizar_importacao(
            importacao["id"],
            {
                "status": "concluido",
                "quantidade_registros":
                    len(df),
            }
        )

        return {
            "importacao_id":
                importacao["id"],
            "registros":
                len(df),
        }

    except Exception as erro:
        atualizar_importacao(
            importacao["id"],
            {
                "status": "erro",
                "erro_mensagem": str(erro),
            }
        )

        raise