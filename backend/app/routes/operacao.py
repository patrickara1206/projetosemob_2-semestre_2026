from fastapi import APIRouter, Depends
from app.routes.filtros import filtros_overview

from app.services.operacao_service import obter_overview_operacao


router = APIRouter(
    prefix="/operacao",
    tags=["Operação"]
)


@router.get("/overview")
def overview_operacao(
    filtros: dict = Depends(filtros_overview),
):
    return obter_overview_operacao(**filtros)
