import os
import re
import unicodedata

NOMES_RELATORIOS = {
    "operacao": "Operação geral",
    "fcv": "FCV",
    "faixa_horaria": "Faixa horária",
    "linhas": "Linhas",
    "resumo_faixa_horaria": "Resumo por faixa horária",
    "viagens": "Viagens",
    "viagens_nao_iniciadas": "Viagens não iniciadas",
    "viagens_nao_realizadas": "Viagens não realizadas",
    "viagens_nao_terminadas": "Viagens não terminadas",
    "passageiros": "Passageiros",
    "financeiro": "Financeiro",
}


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
    nome = os.path.basename(nome_arquivo).lower()

    if nome.endswith(".html"):
        nome = nome[:-5]

    elif nome.endswith(".htm"):
        nome = nome[:-4]

    return nome


def detectar_tipo_por_nome(nome_arquivo):
    nome = preparar_nome_arquivo(nome_arquivo)

    if "viag_ninic" in nome:
        return "viagens_nao_iniciadas"

    if "viag_nrealiz" in nome:
        return "viagens_nao_realizadas"

    if "viag_nterm" in nome:
        return "viagens_nao_terminadas"

    if "resumo_fxhr" in nome:
        return "resumo_faixa_horaria"

    if "_fxhr" in nome:
        return "faixa_horaria"

    if "_linhas" in nome:
        return "linhas"

    if "_fcv" in nome:
        return "fcv"

    if "_viagens" in nome:
        return "viagens"

    if nome.startswith("passageiros"):
        return "passageiros"

    if nome.startswith("saldos"):
        return "financeiro"

    if re.fullmatch(r"(mensal|quinzenal)_\d{6}", nome):
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
        segunda_coluna = df.iloc[:, 1].astype(str)

        proporcao_faixa = segunda_coluna.str.contains(
            r"^\s*\d{1,2}\s*(?:h|hs|:00)?\s*$",
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
        raise ValueError(f"Tipo de relatório inválido: " f"{tipo_relatorio}.")

    tipo_detectado = detectar_tipo_relatorio(df, nome_arquivo)

    if tipo_detectado is None:
        raise ValueError(
            "Não foi possível identificar o tipo "
            "do arquivo enviado. Verifique se o "
            "documento corresponde a um dos "
            "relatórios aceitos pelo sistema."
        )

    if tipo_detectado != tipo_relatorio:
        esperado = NOMES_RELATORIOS[tipo_relatorio]

        detectado = NOMES_RELATORIOS[tipo_detectado]

        raise ValueError(
            f"O arquivo enviado não corresponde "
            f"ao relatório '{esperado}'. "
            f"O documento identificado é "
            f"'{detectado}'. "
            f"Selecione o tipo de relatório correto."
        )


def validar_mes_relatorio(df, mes):
    if "data" not in df.columns:
        raise ValueError("Não foi possível validar o mês " "do relatório.")

    datas = df["data"].dropna()

    if datas.empty:
        raise ValueError("Nenhuma data válida foi encontrada " "no relatório.")

    meses_encontrados = set(datas.dt.strftime("%Y-%m"))

    if meses_encontrados != {mes}:
        encontrados = ", ".join(sorted(meses_encontrados))

        raise ValueError(
            f"O mês selecionado ({mes}) não "
            f"corresponde ao mês encontrado "
            f"no arquivo ({encontrados})."
        )


def detectar_periodo_por_nome(nome_arquivo):
    nome = preparar_nome_arquivo(nome_arquivo)

    if "quinzenal" in nome:
        return "quinzenal"

    if "mensal" in nome:
        return "mensal"

    return None


def validar_periodo_relatorio(df, tipo_periodo, nome_arquivo=""):
    if tipo_periodo not in {
        "mensal",
        "quinzenal",
    }:
        raise ValueError("Período inválido. " "Selecione 'Mensal' ou " "'1ª Quinzena'.")

    periodo_detectado = detectar_periodo_por_nome(nome_arquivo)

    if periodo_detectado is not None:
        if periodo_detectado != tipo_periodo:
            encontrado = "Mensal" if periodo_detectado == "mensal" else "1ª Quinzena"

            selecionado = "Mensal" if tipo_periodo == "mensal" else "1ª Quinzena"

            raise ValueError(
                f"O período selecionado "
                f"('{selecionado}') não "
                f"corresponde ao arquivo. "
                f"O documento identificado "
                f"é '{encontrado}'."
            )

        return

    if "data" not in df.columns:
        raise ValueError("Não foi possível validar o período " "do relatório.")

    datas = df["data"].dropna()

    if datas.empty:
        raise ValueError(
            "Nenhuma data válida foi encontrada " "para validar o período."
        )

    maior_dia = int(datas.dt.day.max())

    if tipo_periodo == "quinzenal" and maior_dia > 15:
        raise ValueError(
            "O arquivo contém dados posteriores "
            "ao dia 15 e não pode ser importado "
            "como 1ª Quinzena."
        )
