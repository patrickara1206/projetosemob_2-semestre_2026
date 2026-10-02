from app.services.operacao_service import obter_overview_operacao
from app.services.passageiros_service import obter_overview_passageiros
from app.services.financeiro_service import obter_overview_financeiro


def obter_dashboard_overview(mes="2026-08"):
    operacao = obter_overview_operacao(mes)
    passageiros = obter_overview_passageiros(mes)
    financeiro = obter_overview_financeiro(mes)

    km_produtiva = (
        operacao["quilometragem"]["produtiva"] or 0
    )

    km_morta = (
        operacao["quilometragem"]["morta"] or 0
    )

    return {
        "quilometragem": {
            "valor": km_produtiva + km_morta,
            "variacao": None,
        },

        "viagens": {
            "valor": operacao["total_viagens"]["realizado"],
            "variacao": None,
        },

        "passageiros_pagantes": {
            "valor": passageiros["pagantes"]["quantidade"],
            "variacao": None,
        },

        "passageiros_nao_pagantes": {
            "valor": passageiros["gratuidades"]["quantidade"],
            "variacao": None,
        },

        "financeiro": {
            "valor": financeiro["total_vendas"],
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

        "status_modelo": "OK",
    }