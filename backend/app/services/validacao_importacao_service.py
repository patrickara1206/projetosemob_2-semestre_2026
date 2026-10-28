import os
import re
import unicodedata

from app.core.relatorios_config import RELATORIOS

NOMES_RELATORIOS = {k: v["nome"] for k, v in RELATORIOS.items()}


def normalizar_nome_coluna(valor):
    texto = str(valor).strip().lower()
    texto = unicodedata.normalize("NFKD", texto)
    texto = "".join(
        caractere for caractere in texto if not unicodedata.combining(caractere)
    )
    texto = re.sub(r"[^a-z0-9]+", "_", texto)
    return texto.strip("_")


def normalizar_colunas(df):
    return {normalizar_nome_coluna(coluna) for coluna in df.columns}


def preparar_nome_arquivo(nome_arquivo):
    nome = os.path.basename(nome_arquivo.replace("\\", "/")).lower()
    if nome.endswith(".html"):
        nome = nome[:-5]
    elif nome.endswith(".htm"):
        nome = nome[:-4]
    return normalizar_nome_coluna(nome)


def detectar_tipo_por_nome(nome_arquivo):
    nome = preparar_nome_arquivo(nome_arquivo)

    if "viag_ninic" in nome or "ninic" in nome or "nao_inic" in nome:
        return "viagens_nao_iniciadas"

    if "viag_nrealiz" in nome or "nrealiz" in nome or "nao_realiz" in nome:
        return "viagens_nao_realizadas"

    if "viag_nterm" in nome or "nterm" in nome or "nao_term" in nome:
        return "viagens_nao_terminadas"

    if "resumo_fxhr" in nome or ("resumo" in nome and ("fxhr" in nome or "faixa" in nome)):
        return "resumo_faixa_horaria"

    if "fxhr" in nome or "faixa_horaria" in nome or "faixahr" in nome:
        return "faixa_horaria"

    if "linhas" in nome or "resumo_por_linha" in nome:
        return "linhas"

    if "fcv" in nome or "fator_de_cumprimento_de_viagem" in nome:
        return "fcv"

    if "_viagens" in nome or "viagens" in nome:
        return "viagens"

    if nome.startswith("passageiros") or "passageiros" in nome:
        return "passageiros"

    if "saldo" in nome or "financeiro" in nome or "venda_x_utilizacao" in nome:
        return "financeiro"

    if re.fullmatch(r"(mensal|quinzenal)_\d{6}", nome) or "resumo_geral" in nome or "operacao" in nome:
        return "operacao"

    return None


def detectar_tipo_por_estrutura(df):
    quantidade = len(df.columns)
    colunas = normalizar_colunas(df)

    if quantidade == 10:
        return "operacao"

    if quantidade == 9:
        return "fcv"

    if quantidade == 11:
        return "viagens"

    if quantidade == 15:
        return None

    if quantidade == 4:
        if "linha" in colunas:
            return "linhas"
        if colunas & {"faixa_horaria", "fx_hor", "fx_hr"}:
            return "resumo_faixa_horaria"
        segunda_coluna = df.iloc[:, 1].astype(str)
        proporcao_faixa = segunda_coluna.str.contains(
            r"^\s*\d{1,2}\s*(?:h|hs|:00)\s*$",
            case=False,
            regex=True,
            na=False,
        ).mean()

        if proporcao_faixa > 0.5:
            return "resumo_faixa_horaria"

        return "linhas"

    if quantidade == 6:
        primeira_coluna = df.iloc[:, 0].astype(str)
        proporcao_data = primeira_coluna.str.match(
            r"^\s*\d{1,2}/\d{1,2}/\d{4}\s*$",
            na=False,
        ).mean()

        if proporcao_data > 0.5:
            return "faixa_horaria"

        if "dia" in colunas and "catraca" in colunas and "antecipados" in colunas:
            return "passageiros"

    if quantidade == 5:
        if "mes" in colunas and "dia" in colunas and "total_vendas" in colunas:
            return "financeiro"

    return None


def detectar_tipo_relatorio(df, nome_arquivo=""):
    tipo_nome = detectar_tipo_por_nome(nome_arquivo)
    if tipo_nome is not None:
        return tipo_nome
    return detectar_tipo_por_estrutura(df)


def validar_tipo_relatorio(df, tipo_relatorio, nome_arquivo):
    if tipo_relatorio not in NOMES_RELATORIOS:
        raise ValueError(f"Tipo de relatório inválido: {tipo_relatorio}.")

    tipo_detectado = detectar_tipo_relatorio(df, nome_arquivo)

    if tipo_detectado is None:
        raise ValueError(
            "Não foi possível identificar o tipo do arquivo enviado. "
            "Verifique se o documento corresponde a um dos relatórios aceitos pelo sistema."
        )

    if tipo_detectado != tipo_relatorio:
        esperado = NOMES_RELATORIOS[tipo_relatorio]
        detectado = NOMES_RELATORIOS[tipo_detectado]
        raise ValueError(
            f"O arquivo enviado não corresponde ao relatório '{esperado}'. "
            f"O documento identificado é '{detectado}'. Selecione o tipo de relatório correto."
        )


def validar_mes_relatorio(df, mes):
    if "data" not in df.columns:
        raise ValueError("Não foi possível validar o mês do relatório.")

    datas = df["data"].dropna()
    if datas.empty:
        raise ValueError("Nenhuma data válida foi encontrada no relatório.")

    meses_encontrados = set(datas.dt.strftime("%Y-%m"))
    if meses_encontrados != {mes}:
        encontrados = ", ".join(sorted(meses_encontrados))
        raise ValueError(
            f"O mês selecionado ({mes}) não corresponde ao mês encontrado no arquivo ({encontrados})."
        )


def detectar_periodo_por_nome(nome_arquivo):
    nome = preparar_nome_arquivo(nome_arquivo)
    if "quinzenal" in nome:
        return "quinzenal"
    if "mensal" in nome:
        return "mensal"
    return None


def validar_periodo_relatorio(df, tipo_periodo, nome_arquivo=""):
    if tipo_periodo not in {"mensal", "quinzenal"}:
        raise ValueError("Período inválido. Selecione 'Mensal' ou '1ª Quinzena'.")

    periodo_detectado = detectar_periodo_por_nome(nome_arquivo)

    if periodo_detectado is not None:
        if periodo_detectado != tipo_periodo:
            encontrado = "Mensal" if periodo_detectado == "mensal" else "1ª Quinzena"
            selecionado = "Mensal" if tipo_periodo == "mensal" else "1ª Quinzena"
            raise ValueError(
                f"O período selecionado ('{selecionado}') não corresponde ao arquivo. "
                f"O documento identificado é '{encontrado}'."
            )
    if "data" not in df.columns:
        raise ValueError("Não foi possível validar o período do relatório.")

    datas = df["data"].dropna()
    if datas.empty:
        raise ValueError("Nenhuma data válida foi encontrada para validar o período.")

    maior_dia = int(datas.dt.day.max())
    if tipo_periodo == "quinzenal" and maior_dia > 15:
        raise ValueError(
            "O arquivo contém dados posteriores ao dia 15 e não pode ser importado como 1ª Quinzena."
        )
