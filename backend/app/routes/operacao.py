from fastapi import APIRouter

from app.services.operacao_service import obter_overview_operacao


router = APIRouter(
    prefix="/operacao",
    tags=["Operação"]
)

@router.get("/overview")
def overview_operacao(periodo: str = "mes"):
    return obter_overview_operacao()