import bcrypt

from app.repositories.usuario_repository import (
    buscar_usuario_por_email,
)


def autenticar_usuario(
    email,
    senha
):
    usuario = buscar_usuario_por_email(
        email
    )

    if usuario is None:
        raise ValueError(
            "E-mail ou senha inválidos."
        )

    senha_valida = bcrypt.checkpw(
        senha.encode(),
        usuario["senha_hash"].encode()
    )

    if not senha_valida:
        raise ValueError(
            "E-mail ou senha inválidos."
        )

    return {
        "id": usuario["id"],
        "nome": usuario["nome"],
        "email": usuario["email"],
    }