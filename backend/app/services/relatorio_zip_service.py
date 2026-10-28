"""Identifica cada relatório do lote sem usar a data de geração do HTML."""

import re
from html import unescape

import pandas as pd

from app.core.relatorios_config import RELATORIOS
from app.readers.leitor_html import ler_tabelas_html_bytes
from app.services.validacao_importacao_service import (
    detectar_tipo_por_estrutura,
    detectar_tipo_por_nome,
    normalizar_nome_coluna,
)


MESES = (
    "janeiro", "fevereiro", "marco", "abril", "maio", "junho",
    "julho", "agosto", "setembro", "outubro", "novembro", "dezembro",
)


def _texto_html(valor):
    try:
        texto = valor.decode("utf-8")
    except UnicodeDecodeError:
        texto = valor.decode("cp1252", errors="replace")
    return unescape(re.sub(r"<[^>]+>", " ", texto))


def _cabecalhos(conteudo):
    titulos = re.findall(
        rb"<(?:title|h1)\b[^>]*>(.*?)</(?:title|h1)\s*>",
        conteudo,
        flags=re.IGNORECASE | re.DOTALL,
    )
    return [_texto_html(titulo) for titulo in titulos]


def _valor_unico(valores, descricao, padrao=None):
    valores = set(valores)
    if len(valores) > 1:
        raise ValueError(
            f"{descricao} conflitantes no relatório: {', '.join(sorted(valores))}."
        )
    return next(iter(valores), padrao)


def _meses_caminho(caminho):
    texto = normalizar_nome_coluna(caminho)
    meses = {
        f"{ano}-{mes}"
        for ano, mes in re.findall(
            r"(?<!\d)(20\d{2})_?(0[1-9]|1[0-2])(?!\d)", texto
        )
    }
    for numero, nome in enumerate(MESES, start=1):
        for ano in re.findall(rf"(?:^|_){nome}_(20\d{{2}})(?:_|$)", texto):
            meses.add(f"{ano}-{numero:02d}")
    return meses


def _meses_dados(df):
    for coluna in df.columns:
        if normalizar_nome_coluna(coluna) == "mes":
            return {
                valor.strip()
                for valor in df[coluna].dropna().astype(str)
                if re.fullmatch(r"20\d{2}-(0[1-9]|1[0-2])", valor.strip())
            }
    datas = pd.to_datetime(df.iloc[:, 0], format="%d/%m/%Y", errors="coerce")
    return set(datas.dropna().dt.strftime("%Y-%m"))


def _tabela_ocorrencia_vazia(conteudo):
    # O Smart Report gera ocorrências vazias com <th> soltos, sem <tr>.
    # pandas não devolve essa tabela; exige-se o cabeçalho completo conhecido.
    esperadas = [
        "data", "linha", "atendimento", "prefixo", "atividade", "motorista",
        "sentido", "tabela", "statussaida", "statuschegada", "inicioprogramado",
        "iniciorealizado", "fimprogramado", "fimrealizado", "kmprod",
    ]
    for tabela in re.findall(rb"<table\b[^>]*>.*?</table\s*>", conteudo, re.I | re.S):
        if re.search(rb"<td\b", tabela, re.I):
            continue
        cabecalho = re.findall(rb"<th\b[^>]*>(.*?)</th\s*>", tabela, re.I | re.S)
        nomes = [
            normalizar_nome_coluna(_texto_html(valor)).replace("_", "")
            for valor in cabecalho
        ]
        if nomes == esperadas:
            return pd.DataFrame(columns=range(15))
    return None


def preparar_relatorio_zip(conteudo, caminho, mes_padrao, periodo_padrao):
    """Retorna tipo, tabela e referência validada de um membro do ZIP."""
    titulos = _cabecalhos(conteudo)
    tipo = _valor_unico(
        [
            detectado
            for texto in [caminho, *titulos]
            if (detectado := detectar_tipo_por_nome(texto)) is not None
        ],
        "Tipos de relatório",
    )
    tabelas = ler_tabelas_html_bytes(conteudo)
    candidatas = [
        (indice, df, detectar_tipo_por_estrutura(df))
        for indice, df in enumerate(tabelas)
    ]
    if tipo is None:
        tipo = _valor_unico(
            [detectado for _, _, detectado in candidatas if detectado is not None],
            "Tipos de relatório",
        )
    if tipo is None:
        raise ValueError("Não foi possível identificar o tipo do relatório HTML.")

    compativeis = [
        (indice, df)
        for indice, df, detectado in candidatas
        if detectado == tipo
        or (tipo.startswith("viagens_nao_") and len(df.columns) == 15)
    ]
    if not compativeis and tipo.startswith("viagens_nao_"):
        vazia = _tabela_ocorrencia_vazia(conteudo)
        if vazia is not None:
            compativeis.append((-1, vazia))
    if not compativeis:
        raise ValueError("Nenhuma tabela é compatível com o tipo de relatório identificado.")
    if len(compativeis) == 1:
        _, df = compativeis[0]
    else:
        # Mantém os índices dos formatos Smart Report já aceitos pelo sistema.
        indice_esperado = RELATORIOS[tipo]["indice_tabela"]
        correspondentes = [df for indice, df in compativeis if indice == indice_esperado]
        if not correspondentes:
            raise ValueError("Há mais de uma tabela compatível no relatório HTML.")
        df = correspondentes[0]

    meses_dados = _meses_dados(df)
    mes_caminho = _valor_unico(_meses_caminho(caminho), "Meses de referência")
    observacoes = []
    if (
        tipo in {"passageiros", "financeiro"}
        and len(meses_dados) > 1
        and mes_caminho in meses_dados
    ):
        # Esses formatos podem incluir dias iniciais do mês seguinte.
        # Preserva o recorte por referência dos normalizadores existentes.
        mes = mes_caminho
        outros = sorted(meses_dados - {mes})
        coluna_mes = next(c for c in df.columns if normalizar_nome_coluna(c) == "mes")
        coluna_dia = next(c for c in df.columns if normalizar_nome_coluna(c) == "dia")
        fora = df[coluna_mes].astype(str).str.strip().isin(outros)
        dias = df[coluna_dia].astype(str).str.match(r"^\d{1,2}$")
        quantidade = int((fora & dias).sum())
        observacoes.append(
            f"Referência da pasta/arquivo: {mes}. {quantidade} linha(s) diária(s) de "
            f"{', '.join(outros)} fora dessa referência não foram importadas."
        )
    else:
        mes = _valor_unico(
            meses_dados | ({mes_caminho} if mes_caminho else set()),
            "Meses de referência", mes_padrao,
        )
    if not re.fullmatch(r"20\d{2}-(0[1-9]|1[0-2])", mes):
        raise ValueError("Mês de referência inválido. Utilize o formato AAAA-MM.")
    periodos = {
        periodo
        for texto in [caminho, *titulos]
        for periodo in ("mensal", "quinzenal")
        if re.search(rf"(?:^|_){periodo}(?:_|$)", normalizar_nome_coluna(texto))
    }
    periodo = _valor_unico(periodos, "Períodos", periodo_padrao)
    if periodo not in {"mensal", "quinzenal"}:
        raise ValueError("Período inválido. Selecione Mensal ou Quinzenal.")
    df.attrs["observacoes_importacao"] = observacoes
    return tipo, df, mes, periodo
