from app.services.operacao_service import obter_overview_operacao
from app.services.passageiros_service import obter_overview_passageiros
from app.services.financeiro_service import obter_overview_financeiro
from datetime import date
from app.repositories.operacao_repository import buscar_operacao_mes


def obter_dashboard_overview(mes="2026-08"):
    operacao = obter_overview_operacao(mes)
    passageiros = obter_overview_passageiros(mes)
    financeiro = obter_overview_financeiro(mes)

    km_produtiva = operacao["quilometragem"]["produtiva"] or 0

    km_morta = operacao["quilometragem"]["morta"] or 0
    # Busca os registros diários de operação no Supabase.
    from app.services.operacao_service import obter_overview_operacao
    from app.services.passageiros_service import obter_overview_passageiros
    from app.services.financeiro_service import obter_overview_financeiro
    from datetime import date
    from app.repositories.operacao_repository import buscar_operacao_mes


    def obter_dashboard_overview(mes="2026-08"):
        operacao = obter_overview_operacao(mes)
        passageiros = obter_overview_passageiros(mes)
        financeiro = obter_overview_financeiro(mes)

        km_produtiva = operacao["quilometragem"]["produtiva"] or 0

        km_morta = operacao["quilometragem"]["morta"] or 0
        # Busca os registros diários de operação no Supabase.
        registros = buscar_operacao_mes(mes)

        registros_por_data = {
        str(registro["data"])[:10]: registro
        for registro in registros
        }
        
        serie = []

        for data, registro in sorted(registros_por_data.items()):
            serie.append(
            {
            "rotulo": date.fromisoformat(data).strftime("%d/%m"),
            "realizado": float(registro.get("viagens_realizadas") or 0),
            "esperado": float(registro.get("viagens_programadas") or 0),
            "anomalia": False,
            }
            )
            # Usa apenas os dias com os dois valores disponíveis.
            dias_validos = [
            registro
            for registro in registros_por_data.values()
            if registro.get("viagens_realizadas") is not None
            and registro.get("viagens_programadas") is not None
            ]

            total_realizado = sum(
            int(registro["viagens_realizadas"]) for registro in dias_validos
            )

            total_programado = sum(
            int(registro["viagens_programadas"]) for registro in dias_validos
            )

            cumprimento_programacao = (
            round(total_realizado / total_programado * 100, 2)
            if total_programado > 0
        else None
        )

        # Viagens extras em um dia não compensam faltas em outro.
        viagens_nao_realizadas = sum(
        max(
        int(registro["viagens_programadas"]) - int(registro["viagens_realizadas"]),
        0,
        )
        for registro in dias_validos
        )

        dias_com_desvio = sum(
        1
        for registro in dias_validos
        if int(registro["viagens_realizadas"]) != int(registro["viagens_programadas"])
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
    "serie": serie,
    "anomalias": [],
    "inteligencia": {
    "cumprimento_programacao": cumprimento_programacao,
    "viagens_nao_realizadas": (
    viagens_nao_realizadas if dias_validos else None
    ),
    "dias_com_desvio": (dias_com_desvio if dias_validos else None),
    "dias_analisados": len(dias_validos),
    },
    "status_modelo": "OK",
    }

    serie = []

    for data, registro in sorted(registros_por_data.items()):
        serie.append(
        {
        "rotulo": date.fromisoformat(data).strftime("%d/%m"),
        "realizado": float(registro.get("viagens_realizadas") or 0),
        "esperado": float(registro.get("viagens_programadas") or 0),
        "anomalia": False,
        }
        )
        # Usa apenas os dias com os dois valores disponíveis.
        dias_validos = [
        registro
        for registro in registros_por_data.values()
        if registro.get("viagens_realizadas") is not None
        and registro.get("viagens_programadas") is not None
        ]

        total_realizado = sum(
        int(registro["viagens_realizadas"]) for registro in dias_validos
        )

        total_programado = sum(
        int(registro["viagens_programadas"]) for registro in dias_validos
        )

        cumprimento_programacao = (
        round(total_realizado / total_programado * 100, 2)
        if total_programado > 0
    else None
    )

    # Viagens extras em um dia não compensam faltas em outro.
    viagens_nao_realizadas = sum(
    max(
    int(registro["viagens_programadas"]) - int(registro["viagens_realizadas"]),
    0,
    )
    for registro in dias_validos
    )

    dias_com_desvio = sum(
    1
    for registro in dias_validos
    if int(registro["viagens_realizadas"]) != int(registro["viagens_programadas"])
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
"serie": serie,
"anomalias": [],
"inteligencia": {
"cumprimento_programacao": cumprimento_programacao,
"viagens_nao_realizadas": (
viagens_nao_realizadas if dias_validos else None
),
"dias_com_desvio": (dias_com_desvio if dias_validos else None),
"dias_analisados": len(dias_validos),
},
"status_modelo": "OK",
}
