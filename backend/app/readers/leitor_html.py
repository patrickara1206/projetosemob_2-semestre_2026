import pandas as pd


def ler_tabela_html(caminho: str, indice: int = 1): # O indice eh igual a 1 pq nos relatorios o 0 costuma ser o cabecalho do Smart Report 
    tabelas = pd.read_html(caminho)

    if len(tabelas) <= indice:
        raise ValueError(f"Tabela {indice} não encontrada em {caminho}")

    return tabelas[indice]