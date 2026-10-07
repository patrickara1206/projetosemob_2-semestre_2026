from fastapi import (
    APIRouter,
    UploadFile,
    File,
    HTTPException,
)

from app.services.importacao_service import (
    importar_operacao
)

from app.services.importacao_service import (
    importar_operacao,
    importar_passageiros,
    importar_financeiro,
)

router = APIRouter(
    prefix="/importacao",
    tags=["Importação"]
)


@router.post("/operacao")
async def importar_arquivo_operacao(
    mes: str,
    tipo_periodo: str = "mensal",
    arquivo: UploadFile = File(...)
):
    if not arquivo.filename.lower().endswith(
        (".html", ".htm")
    ):
        raise HTTPException(
            status_code=400,
            detail="O arquivo deve ser HTML."
        )

    conteudo = await arquivo.read()

    try:
        resultado = importar_operacao(
            conteudo=conteudo,
            nome_arquivo=arquivo.filename,
            mes=mes,
            tipo_periodo=tipo_periodo,
        )

        return {
            "status": "sucesso",
            "arquivo": arquivo.filename,
            **resultado,
        }

    except ValueError as erro:
        raise HTTPException(
            status_code=400,
            detail=str(erro)
        )

    except Exception as erro:
        raise HTTPException(
            status_code=500,
            detail=str(erro)
        )

@router.post("/passageiros")
async def importar_arquivo_passageiros(
    mes: str,
    tipo_periodo: str = "mensal",
    arquivo: UploadFile = File(...)
):
    if not arquivo.filename.lower().endswith(
        (".html", ".htm")
    ):
        raise HTTPException(
            status_code=400,
            detail="O arquivo deve ser HTML."
        )

    conteudo = await arquivo.read()

    try:
        resultado = importar_passageiros(
            conteudo=conteudo,
            nome_arquivo=arquivo.filename,
            mes=mes,
            tipo_periodo=tipo_periodo,
        )

        return {
            "status": "sucesso",
            "arquivo": arquivo.filename,
            **resultado,
        }

    except ValueError as erro:
        raise HTTPException(
            status_code=400,
            detail=str(erro)
        )

    except Exception as erro:
        raise HTTPException(
            status_code=500,
            detail=str(erro)
        )

@router.post("/financeiro")
async def importar_arquivo_financeiro(
    mes: str,
    tipo_periodo: str = "mensal",
    arquivo: UploadFile = File(...)
):
    if not arquivo.filename.lower().endswith(
        (".html", ".htm")
    ):
        raise HTTPException(
            status_code=400,
            detail="O arquivo deve ser HTML."
        )

    conteudo = await arquivo.read()

    try:
        resultado = importar_financeiro(
            conteudo=conteudo,
            nome_arquivo=arquivo.filename,
            mes=mes,
            tipo_periodo=tipo_periodo,
        )

        return {
            "status": "sucesso",
            "arquivo": arquivo.filename,
            **resultado,
        }

    except ValueError as erro:
        raise HTTPException(
            status_code=400,
            detail=str(erro)
        )

    except Exception as erro:
        raise HTTPException(
            status_code=500,
            detail=str(erro)
        )
        
from fastapi import (
    APIRouter,
    UploadFile,
    File,
    HTTPException,
)

from app.services.importacao_service import (
    importar_relatorio
)

router = APIRouter(
    prefix="/importacao",
    tags=["Importação"],
)


@router.post("/{tipo_relatorio}")
async def importar_arquivo(
    tipo_relatorio: str,
    mes: str,
    tipo_periodo: str = "mensal",
    arquivo: UploadFile = File(...)
):
    nome_arquivo = arquivo.filename or ""

    if not nome_arquivo.lower().endswith(
        (".html", ".htm")
    ):
        raise HTTPException(
            status_code=400,
            detail="O arquivo deve ser HTML."
        )

    conteudo = await arquivo.read()

    try:
        resultado = importar_relatorio(
            tipo_relatorio=tipo_relatorio,
            conteudo=conteudo,
            nome_arquivo=nome_arquivo,
            mes=mes,
            tipo_periodo=tipo_periodo,
        )

        return {
            "status": "sucesso",
            "arquivo": nome_arquivo,
            "tipo_relatorio": tipo_relatorio,
            **resultado,
        }

    except ValueError as erro:
        raise HTTPException(
            status_code=400,
            detail=str(erro),
        )

    except Exception as erro:
        raise HTTPException(
            status_code=500,
            detail=str(erro),
        )