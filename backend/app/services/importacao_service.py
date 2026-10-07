import hashlib
import json

from app.services.validacao_importacao_service import (
    validar_tipo_relatorio,
    validar_mes_relatorio,
    validar_periodo_relatorio,
)

from app.services.relatorios_service import (
    normalizar_fcv,
    normalizar_linhas,
    normalizar_resumo_faixa_horaria,
    normalizar_faixa_horaria,
    normalizar_viagens,
    normalizar_viagens_ocorrencias,
)

from app.repositories.viagens_ocorrencias_repository import (
    inserir_viagens_ocorrencias,
)

from app.repositories.viagens_repository import (
    inserir_viagens,
)

from app.repositories.faixa_horaria_repository import (
    inserir_faixa_horaria,
)

from app.repositories.resumo_faixa_horaria_repository import (
    inserir_resumo_faixa_horaria,
)

from app.core.relatorios_config import RELATORIOS

from app.readers.leitor_html import (
    ler_tabela_html_bytes,
)

from app.repositories.importacao_repository import (
    buscar_importacao_por_hash,
    criar_importacao,
    atualizar_importacao,
)

from app.repositories.dados_relatorio_repository import (
    inserir_dados_relatorio,
)

from app.repositories.operacao_repository import (
    inserir_operacao,
)

from app.repositories.passageiros_repository import (
    inserir_passageiros,
)

from app.repositories.financeiro_repository import (
    inserir_financeiro,
)

from app.repositories.fcv_repository import (
    inserir_fcv,
)

from app.repositories.linhas_repository import (
    inserir_linhas,
)

from app.services.operacao_service import (
    normalizar_operacao,
)

from app.services.passageiros_service import (
    normalizar_passageiros,
)

from app.services.financeiro_service import (
    normalizar_financeiro,
)


def calcular_hash(conteudo):
    return hashlib.sha256(conteudo).hexdigest()


def verificar_arquivo_duplicado(conteudo):
    hash_arquivo = calcular_hash(conteudo)

    existente = buscar_importacao_por_hash(
        hash_arquivo
    )

    if existente:
        raise ValueError(
            "Este arquivo já foi importado."
        )

    return hash_arquivo


def iniciar_importacao(
    nome_arquivo,
    tipo_relatorio,
    mes,
    tipo_periodo,
    hash_arquivo
):
    return criar_importacao({
        "nome_arquivo": nome_arquivo,
        "tipo_relatorio": tipo_relatorio,
        "mes_referencia": mes,
        "tipo_periodo": tipo_periodo,
        "hash_arquivo": hash_arquivo,
        "quantidade_registros": 0,
        "status": "processando",
    })


def concluir_importacao(
    importacao_id,
    quantidade
):
    atualizar_importacao(
        importacao_id,
        {
            "status": "concluido",
            "quantidade_registros": quantidade,
        }
    )


def registrar_erro_importacao(
    importacao_id,
    erro
):
    atualizar_importacao(
        importacao_id,
        {
            "status": "erro",
            "erro_mensagem": str(erro),
        }
    )


def montar_resultado(
    importacao_id,
    quantidade
):
    return {
        "importacao_id": importacao_id,
        "registros": quantidade,
    }


def validar_dados(
    df,
    mes,
    tipo_periodo,
    nome_arquivo
):
    validar_mes_relatorio(
        df,
        mes
    )

    validar_periodo_relatorio(
        df,
        tipo_periodo,
        nome_arquivo
    )


def importar_operacao(
    conteudo,
    nome_arquivo,
    mes,
    tipo_periodo="mensal"
):
    df_original = ler_tabela_html_bytes(
        conteudo,
        indice=1
    )

    validar_tipo_relatorio(
        df=df_original,
        tipo_relatorio="operacao",
        nome_arquivo=nome_arquivo,
    )

    df = normalizar_operacao(
        df_original,
        mes,
        tipo_periodo
    )

    validar_dados(
        df,
        mes,
        tipo_periodo,
        nome_arquivo
    )

    hash_arquivo = verificar_arquivo_duplicado(
        conteudo
    )

    importacao = iniciar_importacao(
        nome_arquivo=nome_arquivo,
        tipo_relatorio="operacao",
        mes=mes,
        tipo_periodo=tipo_periodo,
        hash_arquivo=hash_arquivo,
    )

    try:
        df["importacao_id"] = importacao["id"]

        inserir_operacao(df)

        concluir_importacao(
            importacao["id"],
            len(df)
        )

        return montar_resultado(
            importacao["id"],
            len(df)
        )

    except Exception as erro:
        registrar_erro_importacao(
            importacao["id"],
            erro
        )
        raise


def importar_passageiros(
    conteudo,
    nome_arquivo,
    mes,
    tipo_periodo="mensal"
):
    df_original = ler_tabela_html_bytes(
        conteudo,
        indice=1
    )

    validar_tipo_relatorio(
        df=df_original,
        tipo_relatorio="passageiros",
        nome_arquivo=nome_arquivo,
    )

    df = normalizar_passageiros(
        df_original,
        mes,
        tipo_periodo
    )

    validar_dados(
        df,
        mes,
        tipo_periodo,
        nome_arquivo
    )

    hash_arquivo = verificar_arquivo_duplicado(
        conteudo
    )

    importacao = iniciar_importacao(
        nome_arquivo=nome_arquivo,
        tipo_relatorio="passageiros",
        mes=mes,
        tipo_periodo=tipo_periodo,
        hash_arquivo=hash_arquivo,
    )

    try:
        df["importacao_id"] = importacao["id"]

        inserir_passageiros(df)

        concluir_importacao(
            importacao["id"],
            len(df)
        )

        return montar_resultado(
            importacao["id"],
            len(df)
        )

    except Exception as erro:
        registrar_erro_importacao(
            importacao["id"],
            erro
        )
        raise


def importar_financeiro(
    conteudo,
    nome_arquivo,
    mes,
    tipo_periodo="mensal"
):
    df_original = ler_tabela_html_bytes(
        conteudo,
        indice=2
    )

    validar_tipo_relatorio(
        df=df_original,
        tipo_relatorio="financeiro",
        nome_arquivo=nome_arquivo,
    )

    df = normalizar_financeiro(
        df_original,
        mes,
        tipo_periodo
    )

    validar_dados(
        df,
        mes,
        tipo_periodo,
        nome_arquivo
    )

    hash_arquivo = verificar_arquivo_duplicado(
        conteudo
    )

    importacao = iniciar_importacao(
        nome_arquivo=nome_arquivo,
        tipo_relatorio="financeiro",
        mes=mes,
        tipo_periodo=tipo_periodo,
        hash_arquivo=hash_arquivo,
    )

    try:
        df["importacao_id"] = importacao["id"]

        inserir_financeiro(df)

        concluir_importacao(
            importacao["id"],
            len(df)
        )

        return montar_resultado(
            importacao["id"],
            len(df)
        )

    except Exception as erro:
        registrar_erro_importacao(
            importacao["id"],
            erro
        )
        raise


def importar_fcv(
    conteudo,
    nome_arquivo,
    mes,
    tipo_periodo="mensal"
):
    df_original = ler_tabela_html_bytes(
        conteudo,
        indice=1
    )

    validar_tipo_relatorio(
        df=df_original,
        tipo_relatorio="fcv",
        nome_arquivo=nome_arquivo,
    )

    df = normalizar_fcv(
        df_original,
        mes,
        tipo_periodo
    )

    validar_dados(
        df,
        mes,
        tipo_periodo,
        nome_arquivo
    )

    hash_arquivo = verificar_arquivo_duplicado(
        conteudo
    )

    importacao = iniciar_importacao(
        nome_arquivo=nome_arquivo,
        tipo_relatorio="fcv",
        mes=mes,
        tipo_periodo=tipo_periodo,
        hash_arquivo=hash_arquivo,
    )

    try:
        df["importacao_id"] = importacao["id"]

        inserir_fcv(df)

        concluir_importacao(
            importacao["id"],
            len(df)
        )

        return montar_resultado(
            importacao["id"],
            len(df)
        )

    except Exception as erro:
        registrar_erro_importacao(
            importacao["id"],
            erro
        )
        raise


def importar_linhas(
    conteudo,
    nome_arquivo,
    mes,
    tipo_periodo="mensal"
):
    df_original = ler_tabela_html_bytes(
        conteudo,
        indice=1
    )

    validar_tipo_relatorio(
        df=df_original,
        tipo_relatorio="linhas",
        nome_arquivo=nome_arquivo,
    )

    df = normalizar_linhas(
        df_original,
        mes,
        tipo_periodo
    )

    validar_dados(
        df,
        mes,
        tipo_periodo,
        nome_arquivo
    )

    hash_arquivo = verificar_arquivo_duplicado(
        conteudo
    )

    importacao = iniciar_importacao(
        nome_arquivo=nome_arquivo,
        tipo_relatorio="linhas",
        mes=mes,
        tipo_periodo=tipo_periodo,
        hash_arquivo=hash_arquivo,
    )

    try:
        df["importacao_id"] = importacao["id"]

        inserir_linhas(df)

        concluir_importacao(
            importacao["id"],
            len(df)
        )

        return montar_resultado(
            importacao["id"],
            len(df)
        )

    except Exception as erro:
        registrar_erro_importacao(
            importacao["id"],
            erro
        )
        raise


def importar_resumo_faixa_horaria(
    conteudo,
    nome_arquivo,
    mes,
    tipo_periodo="mensal"
):
    df_original = ler_tabela_html_bytes(
        conteudo,
        indice=1
    )

    validar_tipo_relatorio(
        df=df_original,
        tipo_relatorio="resumo_faixa_horaria",
        nome_arquivo=nome_arquivo,
    )

    df = normalizar_resumo_faixa_horaria(
        df_original,
        mes,
        tipo_periodo
    )

    validar_dados(
        df,
        mes,
        tipo_periodo,
        nome_arquivo
    )

    hash_arquivo = verificar_arquivo_duplicado(
        conteudo
    )

    importacao = iniciar_importacao(
        nome_arquivo=nome_arquivo,
        tipo_relatorio="resumo_faixa_horaria",
        mes=mes,
        tipo_periodo=tipo_periodo,
        hash_arquivo=hash_arquivo,
    )

    try:
        df["importacao_id"] = importacao["id"]

        inserir_resumo_faixa_horaria(df)

        concluir_importacao(
            importacao["id"],
            len(df)
        )

        return montar_resultado(
            importacao["id"],
            len(df)
        )

    except Exception as erro:
        registrar_erro_importacao(
            importacao["id"],
            erro
        )
        raise


def importar_faixa_horaria(
    conteudo,
    nome_arquivo,
    mes,
    tipo_periodo="mensal"
):
    df_original = ler_tabela_html_bytes(
        conteudo,
        indice=1
    )

    validar_tipo_relatorio(
        df=df_original,
        tipo_relatorio="faixa_horaria",
        nome_arquivo=nome_arquivo,
    )

    df = normalizar_faixa_horaria(
        df_original,
        mes,
        tipo_periodo
    )

    validar_dados(
        df,
        mes,
        tipo_periodo,
        nome_arquivo
    )

    hash_arquivo = verificar_arquivo_duplicado(
        conteudo
    )

    importacao = iniciar_importacao(
        nome_arquivo=nome_arquivo,
        tipo_relatorio="faixa_horaria",
        mes=mes,
        tipo_periodo=tipo_periodo,
        hash_arquivo=hash_arquivo,
    )

    try:
        df["importacao_id"] = importacao["id"]

        inserir_faixa_horaria(df)

        concluir_importacao(
            importacao["id"],
            len(df)
        )

        return montar_resultado(
            importacao["id"],
            len(df)
        )

    except Exception as erro:
        registrar_erro_importacao(
            importacao["id"],
            erro
        )
        raise


def importar_viagens(
    conteudo,
    nome_arquivo,
    mes,
    tipo_periodo="mensal"
):
    df_original = ler_tabela_html_bytes(
        conteudo,
        indice=1
    )

    validar_tipo_relatorio(
        df=df_original,
        tipo_relatorio="viagens",
        nome_arquivo=nome_arquivo,
    )

    df = normalizar_viagens(
        df_original,
        mes,
        tipo_periodo
    )

    validar_dados(
        df,
        mes,
        tipo_periodo,
        nome_arquivo
    )

    hash_arquivo = verificar_arquivo_duplicado(
        conteudo
    )

    importacao = iniciar_importacao(
        nome_arquivo=nome_arquivo,
        tipo_relatorio="viagens",
        mes=mes,
        tipo_periodo=tipo_periodo,
        hash_arquivo=hash_arquivo,
    )

    try:
        df["importacao_id"] = importacao["id"]

        inserir_viagens(df)

        concluir_importacao(
            importacao["id"],
            len(df)
        )

        return montar_resultado(
            importacao["id"],
            len(df)
        )

    except Exception as erro:
        registrar_erro_importacao(
            importacao["id"],
            erro
        )
        raise


def importar_viagens_ocorrencias(
    tipo_relatorio,
    tipo_ocorrencia,
    conteudo,
    nome_arquivo,
    mes,
    tipo_periodo="mensal"
):
    df_original = ler_tabela_html_bytes(
        conteudo,
        indice=1
    )

    validar_tipo_relatorio(
        df=df_original,
        tipo_relatorio=tipo_relatorio,
        nome_arquivo=nome_arquivo,
    )

    df = normalizar_viagens_ocorrencias(
        df_original,
        mes,
        tipo_periodo,
        tipo_ocorrencia
    )

    validar_dados(
        df,
        mes,
        tipo_periodo,
        nome_arquivo
    )

    hash_arquivo = verificar_arquivo_duplicado(
        conteudo
    )

    importacao = iniciar_importacao(
        nome_arquivo=nome_arquivo,
        tipo_relatorio=tipo_relatorio,
        mes=mes,
        tipo_periodo=tipo_periodo,
        hash_arquivo=hash_arquivo,
    )

    try:
        df["importacao_id"] = importacao["id"]

        inserir_viagens_ocorrencias(df)

        concluir_importacao(
            importacao["id"],
            len(df)
        )

        return montar_resultado(
            importacao["id"],
            len(df)
        )

    except Exception as erro:
        registrar_erro_importacao(
            importacao["id"],
            erro
        )
        raise


def importar_generico(
    tipo_relatorio,
    conteudo,
    nome_arquivo,
    mes,
    tipo_periodo="mensal"
):
    hash_arquivo = verificar_arquivo_duplicado(
        conteudo
    )

    importacao = iniciar_importacao(
        nome_arquivo=nome_arquivo,
        tipo_relatorio=tipo_relatorio,
        mes=mes,
        tipo_periodo=tipo_periodo,
        hash_arquivo=hash_arquivo,
    )

    try:
        config = RELATORIOS[
            tipo_relatorio
        ]

        df = ler_tabela_html_bytes(
            conteudo,
            indice=config["indice_tabela"]
        )

        registros_dataframe = json.loads(
            df.to_json(
                orient="records",
                date_format="iso",
                force_ascii=False,
            )
        )

        registros = []

        for numero_linha, dados in enumerate(
            registros_dataframe,
            start=1
        ):
            registros.append({
                "tipo_relatorio": tipo_relatorio,
                "mes_referencia": mes,
                "tipo_periodo": tipo_periodo,
                "numero_linha": numero_linha,
                "dados": dados,
                "importacao_id": importacao["id"],
            })

        if registros:
            inserir_dados_relatorio(
                registros
            )

        concluir_importacao(
            importacao["id"],
            len(registros)
        )

        return montar_resultado(
            importacao["id"],
            len(registros)
        )

    except Exception as erro:
        registrar_erro_importacao(
            importacao["id"],
            erro
        )
        raise


def importar_relatorio(
    tipo_relatorio,
    conteudo,
    nome_arquivo,
    mes,
    tipo_periodo="mensal"
):
    if tipo_relatorio not in RELATORIOS:
        raise ValueError(
            f"Tipo de relatório inválido: "
            f"{tipo_relatorio}"
        )

    if tipo_relatorio == "operacao":
        return importar_operacao(
            conteudo=conteudo,
            nome_arquivo=nome_arquivo,
            mes=mes,
            tipo_periodo=tipo_periodo,
        )

    if tipo_relatorio == "passageiros":
        return importar_passageiros(
            conteudo=conteudo,
            nome_arquivo=nome_arquivo,
            mes=mes,
            tipo_periodo=tipo_periodo,
        )

    if tipo_relatorio == "financeiro":
        return importar_financeiro(
            conteudo=conteudo,
            nome_arquivo=nome_arquivo,
            mes=mes,
            tipo_periodo=tipo_periodo,
        )

    if tipo_relatorio == "fcv":
        return importar_fcv(
            conteudo=conteudo,
            nome_arquivo=nome_arquivo,
            mes=mes,
            tipo_periodo=tipo_periodo,
        )

    if tipo_relatorio == "linhas":
        return importar_linhas(
            conteudo=conteudo,
            nome_arquivo=nome_arquivo,
            mes=mes,
            tipo_periodo=tipo_periodo,
        )

    if tipo_relatorio == "resumo_faixa_horaria":
        return importar_resumo_faixa_horaria(
            conteudo=conteudo,
            nome_arquivo=nome_arquivo,
            mes=mes,
            tipo_periodo=tipo_periodo,
        )

    if tipo_relatorio == "faixa_horaria":
        return importar_faixa_horaria(
            conteudo=conteudo,
            nome_arquivo=nome_arquivo,
            mes=mes,
            tipo_periodo=tipo_periodo,
        )

    if tipo_relatorio == "viagens":
        return importar_viagens(
            conteudo=conteudo,
            nome_arquivo=nome_arquivo,
            mes=mes,
            tipo_periodo=tipo_periodo,
        )

    if tipo_relatorio == "viagens_nao_iniciadas":
        return importar_viagens_ocorrencias(
            tipo_relatorio=tipo_relatorio,
            tipo_ocorrencia="nao_iniciada",
            conteudo=conteudo,
            nome_arquivo=nome_arquivo,
            mes=mes,
            tipo_periodo=tipo_periodo,
        )

    if tipo_relatorio == "viagens_nao_realizadas":
        return importar_viagens_ocorrencias(
            tipo_relatorio=tipo_relatorio,
            tipo_ocorrencia="nao_realizada",
            conteudo=conteudo,
            nome_arquivo=nome_arquivo,
            mes=mes,
            tipo_periodo=tipo_periodo,
        )

    if tipo_relatorio == "viagens_nao_terminadas":
        return importar_viagens_ocorrencias(
            tipo_relatorio=tipo_relatorio,
            tipo_ocorrencia="nao_terminada",
            conteudo=conteudo,
            nome_arquivo=nome_arquivo,
            mes=mes,
            tipo_periodo=tipo_periodo,
        )

    return importar_generico(
        tipo_relatorio=tipo_relatorio,
        conteudo=conteudo,
        nome_arquivo=nome_arquivo,
        mes=mes,
        tipo_periodo=tipo_periodo,
    )