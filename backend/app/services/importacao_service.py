import hashlib
import json

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

# ============================================================
# FUNÇÕES AUXILIARES
# ============================================================

def calcular_hash(conteudo):
    """
    Calcula o SHA-256 do arquivo.

    Utilizado para impedir que o mesmo arquivo seja
    importado duas vezes.
    """
    return hashlib.sha256(
        conteudo
    ).hexdigest()


def verificar_arquivo_duplicado(
    conteudo
):
    """
    Verifica se o mesmo arquivo já foi importado.
    """
    hash_arquivo = calcular_hash(
        conteudo
    )

    existente = (
        buscar_importacao_por_hash(
            hash_arquivo
        )
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
    """
    Cria o registro de controle da importação.
    """
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
    """
    Marca a importação como concluída.
    """
    atualizar_importacao(
        importacao_id,
        {
            "status": "concluido",
            "quantidade_registros":
                quantidade,
        }
    )


def registrar_erro_importacao(
    importacao_id,
    erro
):
    """
    Registra o erro ocorrido durante uma importação.
    """
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
    """
    Padroniza a resposta das importações.
    """
    return {
        "importacao_id":
            importacao_id,
        "registros":
            quantidade,
    }


# ============================================================
# IMPORTAÇÃO DE OPERAÇÃO
# ============================================================

def importar_operacao(
    conteudo,
    nome_arquivo,
    mes,
    tipo_periodo="mensal"
):
    hash_arquivo = (
        verificar_arquivo_duplicado(
            conteudo
        )
    )

    importacao = iniciar_importacao(
        nome_arquivo=nome_arquivo,
        tipo_relatorio="operacao",
        mes=mes,
        tipo_periodo=tipo_periodo,
        hash_arquivo=hash_arquivo,
    )

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


# ============================================================
# IMPORTAÇÃO DE PASSAGEIROS
# ============================================================

def importar_passageiros(
    conteudo,
    nome_arquivo,
    mes,
    tipo_periodo="mensal"
):
    hash_arquivo = (
        verificar_arquivo_duplicado(
            conteudo
        )
    )

    importacao = iniciar_importacao(
        nome_arquivo=nome_arquivo,
        tipo_relatorio="passageiros",
        mes=mes,
        tipo_periodo=tipo_periodo,
        hash_arquivo=hash_arquivo,
    )

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


# ============================================================
# IMPORTAÇÃO FINANCEIRA
# ============================================================

def importar_financeiro(
    conteudo,
    nome_arquivo,
    mes,
    tipo_periodo="mensal"
):
    hash_arquivo = (
        verificar_arquivo_duplicado(
            conteudo
        )
    )

    importacao = iniciar_importacao(
        nome_arquivo=nome_arquivo,
        tipo_relatorio="financeiro",
        mes=mes,
        tipo_periodo=tipo_periodo,
        hash_arquivo=hash_arquivo,
    )

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


# ============================================================
# IMPORTAÇÃO DE FCV
# ============================================================

def importar_fcv(
    conteudo,
    nome_arquivo,
    mes,
    tipo_periodo="mensal"
):
    hash_arquivo = (
        verificar_arquivo_duplicado(
            conteudo
        )
    )

    importacao = iniciar_importacao(
        nome_arquivo=nome_arquivo,
        tipo_relatorio="fcv",
        mes=mes,
        tipo_periodo=tipo_periodo,
        hash_arquivo=hash_arquivo,
    )

    try:
        df = ler_tabela_html_bytes(
            conteudo,
            indice=1
        )

        df = normalizar_fcv(
            df,
            mes,
            tipo_periodo
        )

        df["importacao_id"] = (
            importacao["id"]
        )

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


# ============================================================
# IMPORTAÇÃO DE LINHAS
# ============================================================

def importar_linhas(
    conteudo,
    nome_arquivo,
    mes,
    tipo_periodo="mensal"
):
    hash_arquivo = (
        verificar_arquivo_duplicado(
            conteudo
        )
    )

    importacao = iniciar_importacao(
        nome_arquivo=nome_arquivo,
        tipo_relatorio="linhas",
        mes=mes,
        tipo_periodo=tipo_periodo,
        hash_arquivo=hash_arquivo,
    )

    try:
        df = ler_tabela_html_bytes(
            conteudo,
            indice=1
        )

        df = normalizar_linhas(
            df,
            mes,
            tipo_periodo
        )

        df["importacao_id"] = (
            importacao["id"]
        )

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


# ============================================================
# IMPORTAÇÃO GENÉRICA / STAGING
# ============================================================

def importar_generico(
    tipo_relatorio,
    conteudo,
    nome_arquivo,
    mes,
    tipo_periodo="mensal"
):
    """
    Utilizado temporariamente para relatórios
    que ainda não possuem tabela estruturada.

    Os registros são armazenados em dados_relatorio.
    """

    hash_arquivo = (
        verificar_arquivo_duplicado(
            conteudo
        )
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

        # Converte os valores do DataFrame
        # para tipos JSON compatíveis.
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
                "tipo_relatorio":
                    tipo_relatorio,
                "mes_referencia":
                    mes,
                "tipo_periodo":
                    tipo_periodo,
                "numero_linha":
                    numero_linha,
                "dados":
                    dados,
                "importacao_id":
                    importacao["id"],
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
    
def importar_resumo_faixa_horaria(
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
        tipo_relatorio="resumo_faixa_horaria",
        mes=mes,
        tipo_periodo=tipo_periodo,
        hash_arquivo=hash_arquivo,
    )

    try:
        df = ler_tabela_html_bytes(
            conteudo,
            indice=1
        )

        df = normalizar_resumo_faixa_horaria(
            df,
            mes,
            tipo_periodo
        )

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
        df = ler_tabela_html_bytes(
            conteudo,
            indice=1
        )

        df = normalizar_faixa_horaria(
            df,
            mes,
            tipo_periodo
        )

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
        df = ler_tabela_html_bytes(
            conteudo,
            indice=1
        )

        df = normalizar_viagens(
            df,
            mes,
            tipo_periodo
        )

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
        df = ler_tabela_html_bytes(
            conteudo,
            indice=1
        )

        df = normalizar_viagens_ocorrencias(
            df,
            mes,
            tipo_periodo,
            tipo_ocorrencia
        )

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


# ============================================================
# ROTEADOR CENTRAL DAS IMPORTAÇÕES
# ============================================================

def importar_relatorio(
    tipo_relatorio,
    conteudo,
    nome_arquivo,
    mes,
    tipo_periodo="mensal"
):
    """
    Decide qual processo de importação será utilizado
    conforme o tipo de relatório selecionado no Flutter.
    """

    if tipo_relatorio not in RELATORIOS:
        raise ValueError(
            "Tipo de relatório inválido: "
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
        
    # Enquanto os demais relatórios ainda
    # não possuem persistência estruturada,
    # continuam sendo armazenados em dados_relatorio.
    return importar_generico(
        tipo_relatorio=tipo_relatorio,
        conteudo=conteudo,
        nome_arquivo=nome_arquivo,
        mes=mes,
        tipo_periodo=tipo_periodo,
    )