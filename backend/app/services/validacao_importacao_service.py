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

    texto = unicodedata.normalize(
        "NFKD",
        texto
    )

    texto = "".join(
        caractere
        for caractere in texto
        if not unicodedata.combining(caractere)
    )

    texto = re.sub(
        r"[^a-z0-9]+",
        "_",
        texto
    )

    return texto.strip("_")


def normalizar_colunas(df):
    return {
        normalizar_nome_coluna(coluna)
        for coluna in df.columns
    }


def detectar_tipo_relatorio(
    df,
    nome_arquivo=""
):
    quantidade = len(df.columns)

    colunas = normalizar_colunas(df)

    nome = nome_arquivo.lower()

    if quantidade == 10:
        return "operacao"

    if quantidade == 9:
        return "fcv"

    if quantidade == 11:
        return "viagens"

    if quantidade == 15:
        if "ninic" in nome:
            return "viagens_nao_iniciadas"

        if "nrealiz" in nome:
            return "viagens_nao_realizadas"

        if "nterm" in nome:
            return "viagens_nao_terminadas"

        return None

    if quantidade == 4:
        if {
            "data",
            "linha",
            "kmtotal",
            "nrviagens",
        }.issubset(colunas):
            return "linhas"

        if {
            "data",
            "fx_hor",
            "nr_veiculos",
            "nr_viagens",
        }.issubset(colunas):
            return "resumo_faixa_horaria"

    if quantidade == 6:
        if {
            "data",
            "linha",
            "fx_hor",
            "nr_veiculos",
            "nr_viagens",
            "partidas",
        }.issubset(colunas):
            return "faixa_horaria"

        if (
            "dia" in colunas
            and "catraca" in colunas
            and "antecipados" in colunas
        ):
            return "passageiros"

    if quantidade == 5:
        if (
            "mes" in colunas
            and "dia" in colunas
            and "total_vendas" in colunas
        ):
            return "financeiro"

    return None


def validar_tipo_relatorio(
    df,
    tipo_relatorio,
    nome_arquivo
):
    if tipo_relatorio not in NOMES_RELATORIOS:
        raise ValueError(
            f"Tipo de relatório inválido: "
            f"{tipo_relatorio}."
        )

    tipo_detectado = detectar_tipo_relatorio(
        df,
        nome_arquivo
    )

    if tipo_detectado is None:
        raise ValueError(
            "Não foi possível identificar o tipo "
            "do arquivo enviado. Verifique se o "
            "documento corresponde a um dos "
            "relatórios aceitos pelo sistema."
        )

    if tipo_detectado != tipo_relatorio:
        esperado = NOMES_RELATORIOS[
            tipo_relatorio
        ]

        detectado = NOMES_RELATORIOS[
            tipo_detectado
        ]

        raise ValueError(
            f"O arquivo enviado não corresponde "
            f"ao relatório '{esperado}'. "
            f"O documento identificado é "
            f"'{detectado}'. "
            f"Selecione o tipo de relatório correto."
        )


def validar_mes_relatorio(
    df,
    mes
):
    if "data" not in df.columns:
        raise ValueError(
            "Não foi possível validar o mês "
            "do relatório."
        )

    datas = df["data"].dropna()

    if datas.empty:
        raise ValueError(
            "Nenhuma data válida foi encontrada "
            "no relatório."
        )

    meses_encontrados = set(
        datas.dt.strftime("%Y-%m")
    )

    if meses_encontrados != {mes}:
        encontrados = ", ".join(
            sorted(meses_encontrados)
        )

        raise ValueError(
            f"O mês selecionado ({mes}) não "
            f"corresponde ao mês encontrado "
            f"no arquivo ({encontrados})."
        )


def validar_periodo_relatorio(
    df,
    tipo_periodo
):
    if tipo_periodo not in {
        "mensal",
        "quinzenal",
    }:
        raise ValueError(
            "Período inválido. "
            "Selecione 'Mensal' ou "
            "'1ª Quinzena'."
        )

    if "data" not in df.columns:
        raise ValueError(
            "Não foi possível validar o período "
            "do relatório."
        )

    datas = df["data"].dropna()

    if datas.empty:
        raise ValueError(
            "Nenhuma data válida foi encontrada "
            "para validar o período."
        )

    maior_dia = int(
        datas.dt.day.max()
    )

    if (
        tipo_periodo == "quinzenal"
        and maior_dia > 15
    ):
        raise ValueError(
            "O arquivo enviado é mensal, pois "
            "contém dados posteriores ao dia 15. "
            "Selecione 'Mensal' como período."
        )

    if (
        tipo_periodo == "mensal"
        and maior_dia <= 15
    ):
        raise ValueError(
            "O arquivo enviado corresponde à "
            "1ª Quinzena, pois contém dados "
            "somente até o dia 15. "
            "Selecione '1ª Quinzena' como período."
        )