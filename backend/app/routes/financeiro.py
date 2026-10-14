from fastapi import APIRouter, Query

from app.services.financeiro_service import obter_overview_financeiro


router = APIRouter(
    prefix="/financeiro",
    tags=["Financeiro"],
)


@router.get("/overview")
def financeiro_overview(
    mes: str = Query(
        default="2026-08",
        pattern=r"^\d{4}-(0[1-9]|1[0-2])$",
    ),
):
    return obter_overview_financeiro(mes)