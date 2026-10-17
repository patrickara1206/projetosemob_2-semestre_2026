from app.services.operacao_service import obter_overview_operacao
from app.services.passageiros_service import obter_overview_passageiros
from app.services.financeiro_service import obter_overview_financeiro


def obter_dashboard_overview(mes="2026-08", periodo="mes", inicio=None, fim=None):
    operacao = obter_overview_operacao(mes, periodo, inicio, fim)
    passageiros = obter_overview_passageiros(mes, periodo, inicio, fim)
    financeiro = obter_overview_financeiro(mes, periodo, inicio, fim)
    km_produtiva = operacao["quilometragem"]["produtiva"] or 0
    km_morta = operacao["quilometragem"]["morta"] or 0
    serie = operacao["serie_viagens"]
    dias_validos = [{"viagens_realizadas": item["realizado"],
                     "viagens_programadas": item["esperado"]} for item in serie]
    total_realizado = sum(
        (int(registro["viagens_realizadas"]) for registro in dias_validos)
    )
    total_programado = sum(
        (int(registro["viagens_programadas"]) for registro in dias_validos)
    )
    cumprimento_programacao = (
        round(total_realizado / total_programado * 100, 2)
        if total_programado > 0
        else None
    )
    viagens_nao_realizadas = sum(
        (
            max(
                int(registro["viagens_programadas"])
                - int(registro["viagens_realizadas"]),
                0,
            )
            for registro in dias_validos
        )
    )
    dias_com_desvio = sum(
        (
            1
            for registro in dias_validos
            if int(registro["viagens_realizadas"])
            != int(registro["viagens_programadas"])
        )
    )
    return {
        "quilometragem": {"valor": (km_produtiva + km_morta) if operacao["quilometragem"]["produtiva"] is not None else None, "variacao": None},
        "viagens": {"valor": operacao["total_viagens"]["realizado"], "variacao": None},
        "passageiros_pagantes": {
            "valor": passageiros["pagantes"]["quantidade"],
            "variacao": None,
        },
        "passageiros_nao_pagantes": {
            "valor": passageiros["gratuidades"]["quantidade"],
            "variacao": None,
        },
        "financeiro": {"valor": financeiro["total_vendas"], "variacao": None},
        "serie": serie,
        "anomalias": [],
        "inteligencia": {
            "cumprimento_programacao": cumprimento_programacao,
            "viagens_nao_realizadas": viagens_nao_realizadas if dias_validos else None,
            "dias_com_desvio": dias_com_desvio if dias_validos else None,
            "dias_analisados": len(dias_validos),
        },
        "status_modelo": "OK",
    }
