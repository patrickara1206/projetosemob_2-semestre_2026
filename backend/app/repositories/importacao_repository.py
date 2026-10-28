import time
from concurrent.futures import ThreadPoolExecutor
from app.database.supabase_client import supabase

_cache_disponibilidade = None
_cache_timestamp = 0.0
CACHE_TTL_SEGUNDOS = 60.0


def limpar_cache_disponibilidade():
    """Invalida o cache de disponibilidade (deve ser chamado após importações)."""
    global _cache_disponibilidade, _cache_timestamp
    _cache_disponibilidade = None
    _cache_timestamp = 0.0


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


def limpar_dados_importacao_com_erro(importacao_id, tipo_relatorio):
    """Remove somente os lotes parciais da importação que será retomada."""
    tabelas = {
        "operacao", "passageiros", "financeiro", "fcv", "linhas",
        "resumo_faixa_horaria", "faixa_horaria", "viagens",
    }
    if tipo_relatorio.startswith("viagens_nao_"):
        tabela = "viagens_ocorrencias"
    elif tipo_relatorio in tabelas:
        tabela = tipo_relatorio
    else:
        tabela = "dados_relatorio"
    supabase.table(tabela).delete().eq("importacao_id", importacao_id).execute()


def _consultar_periodos_tabela(tabela):
    resposta = (
        supabase.table(tabela)
        .select("mes_referencia,tipo_periodo")
        .execute()
    )
    return resposta.data or []


def listar_periodos_disponiveis():
    global _cache_disponibilidade, _cache_timestamp
    agora = time.time()

    if _cache_disponibilidade is not None and (agora - _cache_timestamp) < CACHE_TTL_SEGUNDOS:
        return _cache_disponibilidade

    tabelas = ["operacao", "passageiros", "financeiro"]
    with ThreadPoolExecutor(max_workers=3) as executor:
        resultados = list(executor.map(_consultar_periodos_tabela, tabelas))

    disponibilidade = {}
    for registros in resultados:
        for registro in registros:
            mes = registro.get("mes_referencia")
            periodo = registro.get("tipo_periodo")
            if not mes or not periodo:
                continue
            if mes not in disponibilidade:
                disponibilidade[mes] = set()
            disponibilidade[mes].add(periodo)

    dados = {
        mes: sorted(periodos)
        for mes, periodos in sorted(
            disponibilidade.items(),
            reverse=True,
        )
    }

    _cache_disponibilidade = dados
    _cache_timestamp = agora
    return dados


def listar_meses_disponiveis():
    periodos = listar_periodos_disponiveis()
    return sorted(periodos.keys(), reverse=True)
