from fastapi import APIRouter, Depends, HTTPException

from app.routes.filtros import filtros_overview
from app.services.financeiro_dashboard_service import (
    obter_dashboard_financeiro,
)
from app.services.financeiro_service import (
    obter_overview_financeiro,
)


router = APIRouter(
    prefix="/financeiro",
    tags=["Financeiro"],
)


@router.get("/overview")
def financeiro_overview(
    filtros: dict = Depends(filtros_overview),
):
    return obter_overview_financeiro(
        **filtros
    )


@router.get("/dashboard")
def financeiro_dashboard(
    filtros: dict = Depends(filtros_overview),
    busca: str = "",
    pagina: int = 1,
):
    if pagina < 1 or len(busca) > 100:
        raise HTTPException(
            422,
            "Página ou busca inválida.",
        )

    return obter_dashboard_financeiro(
        **filtros,
        busca=busca,
        pagina=pagina,
    )