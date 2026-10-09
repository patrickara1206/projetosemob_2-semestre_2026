from io import BytesIO

import pandas as pd

def ler_tabela_html_bytes(conteudo, indice=1):
    tabelas = pd.read_html(
        BytesIO(conteudo),
        thousands=".",
        decimal=",",
    )

    if len(tabelas) <= indice:
        raise ValueError(
            f"Tabela {indice} não encontrada no arquivo enviado."
        )

    return tabelas[indice]