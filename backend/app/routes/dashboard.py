from fastapi import APIRouter

from app.services.operacao_service import obter_overview_operacao


router = APIRouter(
    prefix="/dashboard",
    tags=["Dashboard"]
)


@router.get("/overview")
def dashboard_overview(periodo: str = "mes"):
    operacao = obter_overview_operacao()

    return {
        "quilometragem": {
            "valor": (
                operacao["quilometragem"]["produtiva"]
                + operacao["quilometragem"]["morta"]
            ),
            "variacao": None,
        },

        "viagens": {
            "valor": operacao["total_viagens"]["realizado"],
            "variacao": None,
        },

        "passageiros_pagantes": {
            "valor": None,
            "variacao": None,
        },

        "passageiros_nao_pagantes": {
            "valor": None,
            "variacao": None,
        },

        "financeiro": {
            "valor": None,
            "variacao": None,
        },

        "serie": [],

        "anomalias": [],

        "inteligencia": {
            "anomalias_criticas": None,
            "alertas_ativos": None,
            "acuracia": None,
            "falsos_positivos": None,
        },

        "status_modelo": "inicial",
    }