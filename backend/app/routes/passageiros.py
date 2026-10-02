from fastapi import APIRouter
from app.services.passageiros_service import obter_overview_passageiros

router = APIRouter(
    prefix="/passageiros",
    tags=["Passageiros"]
)

@router.get("/overview")
def overview_passageiros(periodo: str = "mes"):
    return obter_overview_passageiros()