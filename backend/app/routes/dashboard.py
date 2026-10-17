from fastapi import APIRouter, Depends
from app.routes.filtros import filtros_overview

from app.services.dashboard_service import obter_dashboard_overview


router = APIRouter(
    prefix="/dashboard",
    tags=["Dashboard"]
)


@router.get("/overview")
def dashboard_overview(
    filtros: dict = Depends(filtros_overview),
):
    return obter_dashboard_overview(**filtros)
