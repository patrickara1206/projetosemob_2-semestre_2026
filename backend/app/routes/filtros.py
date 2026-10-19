from typing import Literal

from fastapi import HTTPException, Query


def filtros_overview(
    escopo: Literal["total", "mes", "quinzena"] = "mes",
    mes: str | None = Query(
        None,
        pattern=r"^\d{4}-(0[1-9]|1[0-2])$",
    ),
):
    if escopo in {"mes", "quinzena"} and mes is None:
        raise HTTPException(
            status_code=422,
            detail="Informe o mês para o escopo selecionado.",
        )

    return {
        "escopo": escopo,
        "mes": mes,
    }