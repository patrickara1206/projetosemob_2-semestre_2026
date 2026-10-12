from fastapi import APIRouter, Depends
from app.routes.filtros import filtros_overview

from app.services.passageiros_service import obter_overview_passageiros


router = APIRouter(
    prefix="/passageiros",
    tags=["Passageiros"]
)


@router.get("/overview")
def overview_passageiros(
    filtros: dict = Depends(filtros_overview),
):
    return obter_overview_passageiros(**filtros)
