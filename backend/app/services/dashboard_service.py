from concurrent.futures import ThreadPoolExecutor

from app.services.operacao_service import obter_overview_operacao
from app.services.passageiros_service import obter_overview_passageiros
from app.services.financeiro_service import obter_overview_financeiro


def obter_dashboard_overview(
    escopo="mes",
    mes=None,
):
    # Executa as 3 consultas de serviço em paralelo para reduzir latência
    with ThreadPoolExecutor(max_workers=3) as executor:
        f_operacao = executor.submit(obter_overview_operacao, escopo=escopo, mes=mes)
        f_passageiros = executor.submit(obter_overview_passageiros, escopo=escopo, mes=mes)
        f_financeiro = executor.submit(obter_overview_financeiro, escopo=escopo, mes=mes)

        operacao = f_operacao.result()
        passageiros = f_passageiros.result()
        financeiro = f_financeiro.result()

    km_produtiva = operacao["quilometragem"]["produtiva"] or 0
    km_morta = operacao["quilometragem"]["morta"] or 0
    serie = operacao["serie_viagens"]

    total_realizado = 0
    total_programado = 0
    viagens_nao_realizadas = 0
    dias_com_desvio = 0
    total_dias = len(serie)

    for item in serie:
        realizado = int(item["realizado"])
        esperado = int(item["esperado"])
        total_realizado += realizado
        total_programado += esperado
        if esperado > realizado:
            viagens_nao_realizadas += (esperado - realizado)
        if realizado != esperado:
            dias_com_desvio += 1

    cumprimento_programacao = (
        round(total_realizado / total_programado * 100, 2)
        if total_programado > 0
        else None
    )

    return {
        "quilometragem": {
            "valor": (
                km_produtiva + km_morta
                if operacao["quilometragem"]["produtiva"] is not None
                else None
            ),
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
        "serie": serie,
        "anomalias": [],
        "inteligencia": {
            "cumprimento_programacao": cumprimento_programacao,
            "viagens_nao_realizadas": viagens_nao_realizadas if total_dias > 0 else None,
            "dias_com_desvio": dias_com_desvio if total_dias > 0 else None,
            "dias_analisados": total_dias,
        },
        "status_modelo": "OK",
    }
