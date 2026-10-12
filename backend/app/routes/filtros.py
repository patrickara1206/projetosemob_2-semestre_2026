from datetime import date
from typing import Literal

from fastapi import HTTPException, Query


def filtros_overview(
    mes: str = Query("2026-08", pattern=r"^\d{4}-(0[1-9]|1[0-2])$"),
    periodo: Literal["mes", "semana", "hoje", "personalizado"] = "mes",
    inicio: date | None = None,
    fim: date | None = None,
):
    if periodo == "personalizado":
        if not inicio or not fim or inicio > fim:
            raise HTTPException(422, "Informe início e fim válidos para o período personalizado.")
        if inicio.strftime("%Y-%m") != mes or fim.strftime("%Y-%m") != mes:
            raise HTTPException(422, "Selecione datas dentro do mês de referência.")
    return {"mes": mes, "periodo": periodo, "inicio": inicio, "fim": fim}
