# Backend SEMOB-SCS

API FastAPI do dashboard de operação de transporte. Usa Pandas para
tratar relatórios e Supabase para persistência.

## Estrutura

- `app/routes`: endpoints e filtros de entrada.
- `app/services`: regras de negócio e agregação dos indicadores.
- `app/repositories`: consultas e persistência.
- `app/readers`: leitura dos arquivos importados.
- `app/database`: configuração do cliente Supabase.
- `app/core`: configurações dos relatórios.

## Execução manual no Windows

Na raiz do repositório:

```powershell
python -m venv .venv
.\.venv\Scripts\python.exe -m pip install -r backend\requirements.txt
Copy-Item backend\.env.example backend\.env
```

Configure `SUPABASE_URL` e `SUPABASE_KEY` no arquivo `backend/.env`.
Copie o exemplo somente ao criar a configuração; preserve um `.env`
existente com credenciais válidas.

Depois, ainda na raiz:

```powershell
cd backend
..\.venv\Scripts\python.exe -m uvicorn app.main:app --host 127.0.0.1 --port 8000
```

- Saúde da API: `http://127.0.0.1:8000/health`.
- Documentação dos endpoints: `http://127.0.0.1:8000/docs`.

Para executar backend e interface juntos, use `INICIAR-SEMOB.cmd` na
raiz do projeto. Consulte o README principal para opções e testes.

## Filtros dos resumos

As rotas `overview` recebem `escopo` (`total`, `mes` ou `quinzena`).
Para `mes` e `quinzena`, informe também `mes=AAAA-MM`.
Exemplo: `/financeiro/overview?escopo=mes&mes=2026-08`.

Credenciais e logs locais não devem ser adicionados ao repositório.
