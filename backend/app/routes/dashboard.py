from fastapi import APIRouter

from app.services.dashboard_service import obter_dashboard_overview

router = APIRouter(prefix="/dashboard", tags=["Dashboard"])


@router.get("/overview")
def dashboard_overview(periodo: str = "mes", mes: str = "2026-08"):
    return obter_dashboard_overview(mes)
