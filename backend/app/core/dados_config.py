from pathlib import Path

BASE_DIR = Path(__file__).resolve().parents[2]
DATA_DIR = BASE_DIR / "data"

MESES = {
    "2026-07": {
        "pasta": DATA_DIR / "Julho_2026" / "Mensal",
        "tipo": "mensal",
        "operacao": "Mensal_202607.html",
        "passageiros": "Passageiros.html",
        "financeiro": "Saldos.html",
    },

    "2026-08": {
        "pasta": DATA_DIR / "Agosto_2026" / "Mensal",
        "tipo": "mensal",
        "operacao": "Mensal_202608.html",
        "passageiros": "Passageiros_Mensal.html",
        "financeiro": "Saldos_Mensal.html",
    },

    "2026-09": {
        "pasta": DATA_DIR / "Setembro_2026" / "Quinzenal",
        "tipo": "quinzenal",
        "operacao": "Quinzenal_202609.html",
        "passageiros": "Passageiros_Quinzenal.html",
        "financeiro": "Saldos_Quinzenal.html",
    },
}