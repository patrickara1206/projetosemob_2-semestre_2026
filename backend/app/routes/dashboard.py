from fastapi import APIRouter, Depends

from app.routes.filtros import filtros_overview
from app.services.dashboard_service import obter_dashboard_overview
from app.repositories.importacao_repository import listar_meses_disponiveis
from app.repositories.importacao_repository import (
    listar_meses_disponiveis,
    listar_periodos_disponiveis,
)

router = APIRouter(
    prefix="/dashboard",
    tags=["Dashboard"],
)


@router.get("/overview")
def dashboard_overview(
    filtros: dict = Depends(filtros_overview),
):
    return obter_dashboard_overview(
        **filtros
    )


@router.get("/meses")
def dashboard_meses():
    return {
        "meses":
            listar_meses_disponiveis(),

        "periodos":
            listar_periodos_disponiveis(),
    }