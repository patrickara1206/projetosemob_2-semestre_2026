import hashlib
import json
from io import BytesIO
from pathlib import Path
from zipfile import ZipFile, BadZipFile

from app.core.relatorios_config import RELATORIOS
from app.readers.leitor_html import ler_tabela_html_bytes
from app.repositories.importacao_repository import (
    buscar_importacao_por_hash,
    criar_importacao,
    atualizar_importacao,
    limpar_cache_disponibilidade,
)
from app.repositories.dados_relatorio_repository import inserir_dados_relatorio
from app.repositories.operacao_repository import inserir_operacao
from app.repositories.passageiros_repository import inserir_passageiros
from app.repositories.financeiro_repository import inserir_financeiro
from app.repositories.fcv_repository import inserir_fcv
from app.repositories.linhas_repository import inserir_linhas
from app.repositories.resumo_faixa_horaria_repository import (
    inserir_resumo_faixa_horaria,
)
from app.repositories.faixa_horaria_repository import inserir_faixa_horaria
from app.repositories.viagens_repository import inserir_viagens
from app.repositories.viagens_ocorrencias_repository import inserir_viagens_ocorrencias
from app.services.operacao_service import normalizar_operacao
from app.services.passageiros_service import normalizar_passageiros
from app.services.financeiro_service import normalizar_financeiro
from app.services.relatorios_service import (
    normalizar_fcv,
    normalizar_linhas,
    normalizar_resumo_faixa_horaria,
    normalizar_faixa_horaria,
    normalizar_viagens,
    normalizar_viagens_ocorrencias,
)
from app.services.validacao_importacao_service import (
    validar_tipo_relatorio,
    validar_mes_relatorio,
    validar_periodo_relatorio,
    detectar_tipo_por_nome,
)

# Mapeamento de configuração para cada relatório estruturado
CONFIG_IMPORTACAO = {
    "operacao": {
        "indice": 1,
        "normalizar": normalizar_operacao,
        "inserir": inserir_operacao,
    },
    "passageiros": {
        "indice": 1,
        "normalizar": normalizar_passageiros,
        "inserir": inserir_passageiros,
    },
    "financeiro": {
        "indice": 2,
        "normalizar": normalizar_financeiro,
        "inserir": inserir_financeiro,
    },
    "fcv": {
        "indice": 1,
        "normalizar": normalizar_fcv,
        "inserir": inserir_fcv,
    },
    "linhas": {
        "indice": 1,
        "normalizar": normalizar_linhas,
        "inserir": inserir_linhas,
    },
    "resumo_faixa_horaria": {
        "indice": 1,
        "normalizar": normalizar_resumo_faixa_horaria,
        "inserir": inserir_resumo_faixa_horaria,
    },
    "faixa_horaria": {
        "indice": 1,
        "normalizar": normalizar_faixa_horaria,
        "inserir": inserir_faixa_horaria,
    },
    "viagens": {
        "indice": 1,
        "normalizar": normalizar_viagens,
        "inserir": inserir_viagens,
    },
    "viagens_nao_iniciadas": {
        "indice": 1,
        "normalizar": lambda df, mes, tp: normalizar_viagens_ocorrencias(
            df, mes, tp, "nao_iniciada"
        ),
        "inserir": inserir_viagens_ocorrencias,
    },
    "viagens_nao_realizadas": {
        "indice": 1,
        "normalizar": lambda df, mes, tp: normalizar_viagens_ocorrencias(
            df, mes, tp, "nao_realizada"
        ),
        "inserir": inserir_viagens_ocorrencias,
    },
    "viagens_nao_terminadas": {
        "indice": 1,
        "normalizar": lambda df, mes, tp: normalizar_viagens_ocorrencias(
            df, mes, tp, "nao_terminada"
        ),
        "inserir": inserir_viagens_ocorrencias,
    },
}


def calcular_hash(conteudo):
    return hashlib.sha256(conteudo).hexdigest()


def verificar_arquivo_duplicado(conteudo):
    hash_arquivo = calcular_hash(conteudo)
    existente = buscar_importacao_por_hash(hash_arquivo)
    if existente:
        raise ValueError("Este arquivo já foi importado.")
    return hash_arquivo


def iniciar_importacao(
    nome_arquivo,
    tipo_relatorio,
    mes,
    tipo_periodo,
    hash_arquivo,
):
    return criar_importacao(
        {
            "nome_arquivo": nome_arquivo,
            "tipo_relatorio": tipo_relatorio,
            "mes_referencia": mes,
            "tipo_periodo": tipo_periodo,
            "hash_arquivo": hash_arquivo,
            "quantidade_registros": 0,
            "status": "processando",
        }
    )


def concluir_importacao(
    importacao_id,
    quantidade,
):
    atualizar_importacao(
        importacao_id,
        {
            "status": "concluido",
            "quantidade_registros": quantidade,
        },
    )


def registrar_erro_importacao(
    importacao_id,
    erro,
):
    atualizar_importacao(
        importacao_id,
        {
            "status": "erro",
            "erro_mensagem": str(erro),
        },
    )


def montar_resultado(
    importacao_id,
    quantidade,
):
    return {
        "importacao_id": importacao_id,
        "registros": quantidade,
    }


def validar_dados(
    df,
    mes,
    tipo_periodo,
    nome_arquivo,
):
    validar_mes_relatorio(df, mes)
    validar_periodo_relatorio(df, tipo_periodo, nome_arquivo)


def _importar_estruturado(
    tipo_relatorio,
    conteudo,
    nome_arquivo,
    mes,
    tipo_periodo="mensal",
):
    spec = CONFIG_IMPORTACAO[tipo_relatorio]
    df_original = ler_tabela_html_bytes(conteudo, indice=spec["indice"])
    validar_tipo_relatorio(
        df=df_original, tipo_relatorio=tipo_relatorio, nome_arquivo=nome_arquivo
    )

    df = spec["normalizar"](df_original, mes, tipo_periodo)
    validar_dados(df, mes, tipo_periodo, nome_arquivo)

    hash_arquivo = verificar_arquivo_duplicado(conteudo)
    importacao = iniciar_importacao(
        nome_arquivo=nome_arquivo,
        tipo_relatorio=tipo_relatorio,
        mes=mes,
        tipo_periodo=tipo_periodo,
        hash_arquivo=hash_arquivo,
    )

    try:
        df["importacao_id"] = importacao["id"]
        spec["inserir"](df)
        concluir_importacao(importacao["id"], len(df))
        limpar_cache_disponibilidade()
        return montar_resultado(importacao["id"], len(df))
    except Exception as erro:
        registrar_erro_importacao(importacao["id"], erro)
        raise


# Funções especializadas mantidas para compatibilidade retroativa
def importar_operacao(conteudo, nome_arquivo, mes, tipo_periodo="mensal"):
    return _importar_estruturado("operacao", conteudo, nome_arquivo, mes, tipo_periodo)


def importar_passageiros(conteudo, nome_arquivo, mes, tipo_periodo="mensal"):
    return _importar_estruturado(
        "passageiros", conteudo, nome_arquivo, mes, tipo_periodo
    )


def importar_financeiro(conteudo, nome_arquivo, mes, tipo_periodo="mensal"):
    return _importar_estruturado(
        "financeiro", conteudo, nome_arquivo, mes, tipo_periodo
    )


def importar_fcv(conteudo, nome_arquivo, mes, tipo_periodo="mensal"):
    return _importar_estruturado("fcv", conteudo, nome_arquivo, mes, tipo_periodo)


def importar_linhas(conteudo, nome_arquivo, mes, tipo_periodo="mensal"):
    return _importar_estruturado("linhas", conteudo, nome_arquivo, mes, tipo_periodo)


def importar_resumo_faixa_horaria(conteudo, nome_arquivo, mes, tipo_periodo="mensal"):
    return _importar_estruturado(
        "resumo_faixa_horaria", conteudo, nome_arquivo, mes, tipo_periodo
    )


def importar_faixa_horaria(conteudo, nome_arquivo, mes, tipo_periodo="mensal"):
    return _importar_estruturado(
        "faixa_horaria", conteudo, nome_arquivo, mes, tipo_periodo
    )


def importar_viagens(conteudo, nome_arquivo, mes, tipo_periodo="mensal"):
    return _importar_estruturado("viagens", conteudo, nome_arquivo, mes, tipo_periodo)


def importar_viagens_ocorrencias(
    tipo_relatorio, tipo_ocorrencia, conteudo, nome_arquivo, mes, tipo_periodo="mensal"
):
    return _importar_estruturado(
        tipo_relatorio, conteudo, nome_arquivo, mes, tipo_periodo
    )


def importar_generico(
    tipo_relatorio,
    conteudo,
    nome_arquivo,
    mes,
    tipo_periodo="mensal",
):
    hash_arquivo = verificar_arquivo_duplicado(conteudo)
    importacao = iniciar_importacao(
        nome_arquivo=nome_arquivo,
        tipo_relatorio=tipo_relatorio,
        mes=mes,
        tipo_periodo=tipo_periodo,
        hash_arquivo=hash_arquivo,
    )

    try:
        config = RELATORIOS[tipo_relatorio]
        df = ler_tabela_html_bytes(conteudo, indice=config["indice_tabela"])

        registros_dataframe = json.loads(
            df.to_json(orient="records", date_format="iso", force_ascii=False)
        )

        registros = [
            {
                "tipo_relatorio": tipo_relatorio,
                "mes_referencia": mes,
                "tipo_periodo": tipo_periodo,
                "numero_linha": numero_linha,
                "dados": dados,
                "importacao_id": importacao["id"],
            }
            for numero_linha, dados in enumerate(registros_dataframe, start=1)
        ]

        if registros:
            inserir_dados_relatorio(registros)

        concluir_importacao(importacao["id"], len(registros))
        limpar_cache_disponibilidade()
        return montar_resultado(importacao["id"], len(registros))

    except Exception as erro:
        registrar_erro_importacao(importacao["id"], erro)
        raise


def importar_relatorio(
    tipo_relatorio,
    conteudo,
    nome_arquivo,
    mes,
    tipo_periodo="mensal",
):
    if tipo_relatorio not in RELATORIOS:
        raise ValueError(f"Tipo de relatório inválido: {tipo_relatorio}")

    if tipo_relatorio in CONFIG_IMPORTACAO:
        return _importar_estruturado(
            tipo_relatorio=tipo_relatorio,
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


# O detector unificado de nome de arquivo usa detectar_tipo_por_nome
identificar_tipo_relatorio = detectar_tipo_por_nome


def identificar_contexto_zip(caminho):
    caminho_normalizado = caminho.replace("\\", "/")

    partes = [parte for parte in caminho_normalizado.split("/") if parte]

    mes = None
    tipo_periodo = None

    mapa_meses = {
        "janeiro": "01",
        "fevereiro": "02",
        "marco": "03",
        "março": "03",
        "abril": "04",
        "maio": "05",
        "junho": "06",
        "julho": "07",
        "agosto": "08",
        "setembro": "09",
        "outubro": "10",
        "novembro": "11",
        "dezembro": "12",
    }

    for parte in partes:
        texto = parte.lower()

        for nome_mes, numero_mes in mapa_meses.items():
            if nome_mes in texto:
                numeros = "".join(
                    caractere for caractere in texto if caractere.isdigit()
                )

                if len(numeros) >= 4:
                    ano = numeros[-4:]
                    mes = f"{ano}-{numero_mes}"

        if texto == "mensal":
            tipo_periodo = "mensal"

        elif texto == "quinzenal":
            tipo_periodo = "quinzenal"

    return mes, tipo_periodo


def importar_zip(
    conteudo,
    nome_arquivo,
    mes=None,
    tipo_periodo=None,
):
    try:
        zip_buffer = BytesIO(conteudo)

        with ZipFile(zip_buffer) as arquivo_zip:
            arquivos_html = [
                item
                for item in arquivo_zip.infolist()
                if (
                    not item.is_dir()
                    and item.filename.lower().endswith(
                        (".html", ".htm")
                    )
                )
            ]

            if not arquivos_html:
                raise ValueError(
                    "O arquivo ZIP não contém relatórios HTML."
                )

            resultados = []

            total_importados = 0
            total_erros = 0
            total_ignorados = 0
            total_registros = 0

            for item in arquivos_html:
                nome_html = Path(
                    item.filename
                ).name

                tipo_relatorio = (
                    identificar_tipo_relatorio(
                        nome_html
                    )
                )

                # Tenta identificar automaticamente
                # mês e período pelo caminho interno
                # do arquivo dentro do ZIP.
                (
                    mes_arquivo,
                    periodo_arquivo,
                ) = identificar_contexto_zip(
                    item.filename
                )

                if tipo_relatorio is None:
                    total_ignorados += 1

                    resultados.append(
                        {
                            "arquivo": nome_html,
                            "caminho": item.filename,
                            "status": "ignorado",
                            "motivo": (
                                "Não foi possível identificar "
                                "o tipo do relatório."
                            ),
                        }
                    )

                    continue

                if mes_arquivo is None:
                    total_erros += 1

                    resultados.append(
                        {
                            "arquivo": nome_html,
                            "caminho": item.filename,
                            "tipo_relatorio": tipo_relatorio,
                            "status": "erro",
                            "mensagem": (
                                "Não foi possível identificar "
                                "o mês pelo caminho do arquivo "
                                "dentro do ZIP."
                            ),
                        }
                    )

                    continue

                if periodo_arquivo is None:
                    total_erros += 1

                    resultados.append(
                        {
                            "arquivo": nome_html,
                            "caminho": item.filename,
                            "tipo_relatorio": tipo_relatorio,
                            "status": "erro",
                            "mensagem": (
                                "Não foi possível identificar "
                                "o período pelo caminho do arquivo "
                                "dentro do ZIP."
                            ),
                        }
                    )

                    continue

                conteudo_html = arquivo_zip.read(
                    item
                )

                try:
                    resultado = importar_relatorio(
                        tipo_relatorio=tipo_relatorio,
                        conteudo=conteudo_html,
                        nome_arquivo=nome_html,
                        mes=mes_arquivo,
                        tipo_periodo=periodo_arquivo,
                    )

                    qtd = resultado.get(
                        "registros",
                        0,
                    )

                    total_importados += 1
                    total_registros += qtd

                    resultados.append(
                        {
                            "arquivo": nome_html,
                            "caminho": item.filename,
                            "tipo_relatorio": tipo_relatorio,
                            "mes_referencia": mes_arquivo,
                            "tipo_periodo": periodo_arquivo,
                            "status": "sucesso",
                            "registros": qtd,
                        }
                    )

                except Exception as erro:
                    total_erros += 1

                    resultados.append(
                        {
                            "arquivo": nome_html,
                            "caminho": item.filename,
                            "tipo_relatorio": tipo_relatorio,
                            "mes_referencia": mes_arquivo,
                            "tipo_periodo": periodo_arquivo,
                            "status": "erro",
                            "mensagem": str(erro),
                        }
                    )

            return {
                "arquivo_zip": nome_arquivo,
                "arquivos_encontrados": len(
                    arquivos_html
                ),
                "arquivos_importados": total_importados,
                "arquivos_com_erro": total_erros,
                "arquivos_ignorados": total_ignorados,
                "total_registros": total_registros,
                "resultados": resultados,
            }

    except BadZipFile:
        raise ValueError(
            "O arquivo enviado não é um ZIP válido."
        )