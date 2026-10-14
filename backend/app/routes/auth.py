from fastapi import APIRouter, HTTPException
from pydantic import BaseModel

from app.services.auth_service import (
    autenticar_usuario,
)

router = APIRouter(
    prefix="/auth",
    tags=["Autenticação"],
)


class LoginRequest(BaseModel):
    email: str
    senha: str


@router.post("/login")
def login(dados: LoginRequest):
    try:
        usuario = autenticar_usuario(dados.email, dados.senha)

        return {
            "status": "sucesso",
            "usuario": usuario,
        }

    except ValueError as erro:
        raise HTTPException(
            status_code=401,
            detail=str(erro),
        )
