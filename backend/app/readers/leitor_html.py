import pandas as pd


def ler_tabela_html(caminho, indice=1):
    tabelas = pd.read_html(
        caminho,
        thousands=".",
        decimal=","
    )

    if len(tabelas) <= indice:
        raise ValueError(
            f"Tabela {indice} não encontrada em {caminho}"
        )

    return tabelas[indice]