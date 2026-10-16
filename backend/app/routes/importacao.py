from fastapi import (
    APIRouter,
    UploadFile,
    File,
    HTTPException,
)

from app.services.importacao_service import (
    importar_relatorio,
    importar_zip,
)


router = APIRouter(
    prefix="/importacao",
    tags=["Importação"],
)


@router.post("/lote/zip")
async def importar_pasta_zipada(
    mes: str,
    tipo_periodo: str = "mensal",
    arquivo: UploadFile = File(...),
):
    nome_arquivo = arquivo.filename or ""

    if not nome_arquivo.lower().endswith(".zip"):
        raise HTTPException(
            status_code=400,
            detail="O arquivo deve estar no formato ZIP.",
        )

    conteudo = await arquivo.read()

    try:
        resultado = importar_zip(
            conteudo=conteudo,
            nome_arquivo=nome_arquivo,
            mes=mes,
            tipo_periodo=tipo_periodo,
        )

        return {
            "status": "sucesso",
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


@router.post("/{tipo_relatorio}")
async def importar_arquivo(
    tipo_relatorio: str,
    mes: str,
    tipo_periodo: str = "mensal",
    arquivo: UploadFile = File(...),
):
    nome_arquivo = arquivo.filename or ""

    if not nome_arquivo.lower().endswith(
        (".html", ".htm")
    ):
        raise HTTPException(
            status_code=400,
            detail="O arquivo deve ser HTML.",
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