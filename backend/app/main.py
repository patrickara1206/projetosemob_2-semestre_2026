from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.routes.financeiro import router as financeiro_router
from app.routes.auth import router as auth_router
from app.routes.operacao import router as operacao_router
from app.routes.passageiros import router as passageiros_router
from app.routes.dashboard import router as dashboard_router
from app.routes.importacao import router as importacao_router


app = FastAPI(
    title="SEMOB-SCS API",
    description="Backend do Dashboard de Operação de Transporte",
    version="0.1.0",
)


app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(financeiro_router)
app.include_router(auth_router)
app.include_router(operacao_router)
app.include_router(passageiros_router)
app.include_router(dashboard_router)
app.include_router(importacao_router)


@app.get("/")
def home():
    return {
        "projeto": "SEMOB-SCS",
        "api": "Dashboard de Operação de Transporte",
        "versao": "0.1.0",
        "status": "online",
    }


@app.get("/health")
def health():
    return {
        "status": "ok"
    }