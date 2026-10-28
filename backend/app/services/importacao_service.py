import hashlib
import json
from io import BytesIO
from zipfile import ZipFile, BadZipFile

from app.core.relatorios_config import RELATORIOS
from app.readers.leitor_html import ler_tabela_html_bytes
from app.repositories.importacao_repository import (
    buscar_importacao_por_hash,
    criar_importacao,
    atualizar_importacao,
    limpar_cache_disponibilidade,
    limpar_dados_importacao_com_erro,
)
from app.repositories.dados_relatorio_repository import inserir_dados_relatorio
from app.repositories.operacao_repository import inserir_operacao
from app.repositories.passageiros_repository import inserir_passageiros
from app.repositories.financeiro_repository import inserir_financeiro
from app.repositories.fcv_repository import inserir_fcv
from app.repositories.linhas_repository import inserir_linhas
from app.repositories.resumo_faixa_horaria_repository import inserir_resumo_faixa_horaria
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
from app.services.relatorio_zip_service import preparar_relatorio_zip

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
        "normalizar": lambda df, mes, tp: normalizar_viagens_ocorrencias(df, mes, tp, "nao_iniciada"),
        "inserir": inserir_viagens_ocorrencias,
    },
    "viagens_nao_realizadas": {
        "indice": 1,
        "normalizar": lambda df, mes, tp: normalizar_viagens_ocorrencias(df, mes, tp, "nao_realizada"),
        "inserir": inserir_viagens_ocorrencias,
    },
    "viagens_nao_terminadas": {
        "indice": 1,
        "normalizar": lambda df, mes, tp: normalizar_viagens_ocorrencias(df, mes, tp, "nao_terminada"),
        "inserir": inserir_viagens_ocorrencias,
    },
}


def calcular_hash(conteudo):
    return hashlib.sha256(conteudo).hexdigest()


class ArquivoJaImportadoError(ValueError):
    def __init__(self, importacao):
        super().__init__("Este arquivo já foi importado.")
        self.importacao = importacao


def _validar_importacao_existente(existentes, referencia):
    if not existentes:
        return None
    for existente in existentes:
        if any(
            existente.get(campo) is not None and existente[campo] != valor
            for campo, valor in referencia.items()
        ):
            raise ValueError(
                "O mesmo arquivo já possui uma importação com tipo, mês ou período "
                "diferente. Verifique a referência original antes de importá-lo novamente."
            )
        if existente.get("status") not in {"erro", "processando"}:
            raise ArquivoJaImportadoError(existente)
        if existente.get("status") == "processando":
            raise ValueError("Este arquivo já possui uma importação em andamento.")
    return existentes[0]


def verificar_arquivo_duplicado(conteudo, tipo_relatorio, mes, tipo_periodo):
    hash_arquivo = calcular_hash(conteudo)
    existente = buscar_importacao_por_hash(hash_arquivo)
    _validar_importacao_existente(existente, {
        "tipo_relatorio": tipo_relatorio, "mes_referencia": mes, "tipo_periodo": tipo_periodo,
    })
    return hash_arquivo


def iniciar_importacao(
    nome_arquivo,
    tipo_relatorio,
    mes,
    tipo_periodo,
    hash_arquivo,
):
    referencia = {
        "tipo_relatorio": tipo_relatorio, "mes_referencia": mes, "tipo_periodo": tipo_periodo,
    }
    existente = _validar_importacao_existente(buscar_importacao_por_hash(hash_arquivo), referencia)
    if existente is not None:
        # Reutiliza o mesmo hash e ID, sem duplicar lotes gravados antes da falha.
        atualizar_importacao(existente["id"], {
            **referencia, "nome_arquivo": nome_arquivo,
            "status": "processando", "erro_mensagem": None, "quantidade_registros": 0,
        })
        try:
            limpar_dados_importacao_com_erro(existente["id"], tipo_relatorio)
        except Exception as erro:
            registrar_erro_importacao(existente["id"], erro)
            raise
        return existente
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
    df_original=None,
):
    spec = CONFIG_IMPORTACAO[tipo_relatorio]
    if df_original is None:
        df_original = ler_tabela_html_bytes(conteudo, indice=spec["indice"])
        validar_tipo_relatorio(df=df_original, tipo_relatorio=tipo_relatorio, nome_arquivo=nome_arquivo)

    df = spec["normalizar"](df_original, mes, tipo_periodo)
    validar_dados(df, mes, tipo_periodo, nome_arquivo)

    hash_arquivo = verificar_arquivo_duplicado(conteudo, tipo_relatorio, mes, tipo_periodo)
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
    return _importar_estruturado("passageiros", conteudo, nome_arquivo, mes, tipo_periodo)


def importar_financeiro(conteudo, nome_arquivo, mes, tipo_periodo="mensal"):
    return _importar_estruturado("financeiro", conteudo, nome_arquivo, mes, tipo_periodo)


def importar_fcv(conteudo, nome_arquivo, mes, tipo_periodo="mensal"):
    return _importar_estruturado("fcv", conteudo, nome_arquivo, mes, tipo_periodo)


def importar_linhas(conteudo, nome_arquivo, mes, tipo_periodo="mensal"):
    return _importar_estruturado("linhas", conteudo, nome_arquivo, mes, tipo_periodo)


def importar_resumo_faixa_horaria(conteudo, nome_arquivo, mes, tipo_periodo="mensal"):
    return _importar_estruturado("resumo_faixa_horaria", conteudo, nome_arquivo, mes, tipo_periodo)


def importar_faixa_horaria(conteudo, nome_arquivo, mes, tipo_periodo="mensal"):
    return _importar_estruturado("faixa_horaria", conteudo, nome_arquivo, mes, tipo_periodo)


def importar_viagens(conteudo, nome_arquivo, mes, tipo_periodo="mensal"):
    return _importar_estruturado("viagens", conteudo, nome_arquivo, mes, tipo_periodo)


def importar_viagens_ocorrencias(tipo_relatorio, tipo_ocorrencia, conteudo, nome_arquivo, mes, tipo_periodo="mensal"):
    return _importar_estruturado(tipo_relatorio, conteudo, nome_arquivo, mes, tipo_periodo)


def importar_generico(
    tipo_relatorio,
    conteudo,
    nome_arquivo,
    mes,
    tipo_periodo="mensal",
):
    hash_arquivo = verificar_arquivo_duplicado(conteudo, tipo_relatorio, mes, tipo_periodo)
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
    df_original=None,
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
            df_original=df_original,
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


def importar_zip(
    conteudo,
    nome_arquivo,
    mes,
    tipo_periodo="mensal",
):
    try:
        zip_buffer = BytesIO(conteudo)
        with ZipFile(zip_buffer) as arquivo_zip:
            arquivos_html = [
                item
                for item in arquivo_zip.infolist()
                if (
                    not item.is_dir()
                    and item.filename.lower().endswith((".html", ".htm"))
                )
            ]

            if not arquivos_html:
                raise ValueError("O arquivo ZIP não contém relatórios HTML.")

            resultados = []
            total_importados = 0
            total_erros = 0
            total_ignorados = 0
            total_ja_importados = 0
            total_sem_dados = 0
            total_registros = 0

            for item in arquivos_html:
                nome_html = item.filename.replace("\\", "/")
                tipo_relatorio = None
                try:
                    conteudo_html = arquivo_zip.read(item)
                    tipo_relatorio, df, mes_html, periodo_html = preparar_relatorio_zip(
                        conteudo_html, nome_html, mes, tipo_periodo
                    )
                    if df.empty and tipo_relatorio.startswith("viagens_nao_"):
                        total_sem_dados += 1
                        resultados.append({
                            "arquivo": nome_html,
                            "tipo_relatorio": tipo_relatorio,
                            "mes_referencia": mes_html,
                            "tipo_periodo": periodo_html,
                            "status": "sem_dados",
                            "registros": 0,
                            "mensagem": "Relatório de ocorrências com cabeçalho válido e sem registros.",
                        })
                        continue
                    resultado = importar_relatorio(
                        tipo_relatorio=tipo_relatorio,
                        conteudo=conteudo_html,
                        nome_arquivo=nome_html,
                        mes=mes_html,
                        tipo_periodo=periodo_html,
                        df_original=df,
                    )
                    qtd = resultado.get("registros", 0)
                    total_importados += 1
                    total_registros += qtd
                    resultados.append({
                        "arquivo": nome_html,
                        "tipo_relatorio": tipo_relatorio,
                        "mes_referencia": mes_html,
                        "tipo_periodo": periodo_html,
                        "status": "sucesso",
                        "registros": qtd,
                        "observacoes": df.attrs.get("observacoes_importacao", []),
                    })
                except ArquivoJaImportadoError as erro:
                    total_ja_importados += 1
                    resultados.append({
                        "arquivo": nome_html,
                        "tipo_relatorio": tipo_relatorio,
                        "mes_referencia": mes_html,
                        "tipo_periodo": periodo_html,
                        "status": "ja_importado",
                        "mensagem": str(erro),
                        "importacao_id": erro.importacao["id"],
                    })
                except Exception as erro:
                    total_erros += 1
                    resultados.append({
                        "arquivo": nome_html,
                        "tipo_relatorio": tipo_relatorio,
                        "status": "erro",
                        "mensagem": str(erro),
                    })

            return {
                "status": (
                    "sucesso" if total_erros == 0
                    else "parcial" if total_importados + total_ja_importados + total_sem_dados > 0 else "erro"
                ),
                "arquivo_zip": nome_arquivo,
                "arquivos_encontrados": len(arquivos_html),
                "arquivos_importados": total_importados,
                "arquivos_ja_importados": total_ja_importados,
                "arquivos_sem_dados": total_sem_dados,
                "arquivos_com_erro": total_erros,
                "arquivos_ignorados": total_ignorados,
                "total_registros": total_registros,
                "resultados": resultados,
            }

    except BadZipFile:
        raise ValueError("O arquivo enviado não é um ZIP válido.")
