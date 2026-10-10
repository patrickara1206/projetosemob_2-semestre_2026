from typing import Literal
from fastapi import APIRouter, Query
from app.services.financeiro_dashboard_service import obter_dashboard_financeiro

router = APIRouter(prefix="/financeiro", tags=["Financeiro"])

@router.get("/overview")
def overview_financeiro(
    mes: str = Query("2026-08", pattern=r"^\d{4}-(0[1-9]|1[0-2])$"),
    periodo: Literal["mes", "semana", "hoje"] = "mes",
    busca: str = Query("", max_length=100),
    pagina: int = Query(1, ge=1),
):
    return obter_dashboard_financeiro(mes, periodo, busca, pagina)
