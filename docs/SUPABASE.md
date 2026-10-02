# Conectar ao Supabase

## Estado desta entrega

A migração, o importador e as consultas PostgreSQL estão implementados e foram testados em PostgreSQL local, com os dados reais. Não há projeto Supabase remoto criado nem credenciais configuradas nesta entrega.

## 1. Criar o projeto

Acesse https://supabase.com/dashboard e entre com sua conta. Crie um projeto, escolha uma região adequada e guarde a senha do banco. Selecione o plano de acordo com sua conta e orçamento; esta entrega não contratou serviços pagos.

## 2. Criar as tabelas

Abra SQL Editor e execute o arquivo `supabase/migrations/202610020001_semob.sql` completo. A migração cria:

- semob_imports: importações e SHA-256 único.
- semob_lines e semob_vehicles: entidades de linhas e veículos.
- semob_operation_daily: viagens, frota e quilômetros diários.
- semob_passenger_daily: contagens por categorias.
- semob_finance_daily: vendas, utilização e crédito circulante.
- semob_line_daily: indicadores diários por linha.
- semob_trips: registros vinculados a linha, veículo e importação; documento flexível.
- semob_documents: tabelas originais em JSONB com índice GIN.

As tabelas ficam com RLS ativado, sem políticas públicas de leitura/escrita. A interface consulta a API local; a API conecta ao banco por uma conexão privada. Não desative o RLS para fazer a interface funcionar.

## 3. Configurar a conexão privada

No Supabase, clique em Connect e copie a URI do **Session pooler**, adequada para conexões PostgreSQL persistentes e redes IPv4. Substitua a senha na URI, codificando caracteres especiais se necessário, e use TLS (`sslmode=require`; para validação completa, use verify-full com o certificado indicado pelo Supabase).

Copie `backend/.env.example` para `backend/.env` e preencha localmente:

```dotenv
DATABASE_URL=postgresql://USUARIO:SENHA@HOST:PORTA/postgres?sslmode=require
ADMIN_KEY=UMA_CHAVE_ADMINISTRATIVA_CRIADA_POR_VOCE
```

Não envie a senha nem a URI privada por chat. Não coloque essas informações em Dart, no navegador ou no Git. O arquivo .env não contém credenciais nesta entrega. Como o projeto fica em pendrive, proteja o dispositivo se decidir guardar credenciais nele.

## 4. Importar os dados

Prepare o ambiente com a tarefa do VS Code `SEMOB: preparar ambiente` ou pelo PowerShell:

```powershell
.\iniciar.ps1 -PrepararSomente
cd backend
..\.venv\Scripts\python.exe -m app.cli import ..\data\transport.zip
```

Se preferir aplicar a migração pelo backend em vez do SQL Editor:

```powershell
..\.venv\Scripts\python.exe -m app.cli migrate
```

A importação é transacional e idempotente por SHA-256. Os indicadores normalizados escolhem o mensal quando há sobreposição. As tabelas originais e os registros brutos permanecem disponíveis.

## 5. Confirmar

Reinicie `INICIAR-SEMOB.cmd`, abra Dados e Banco e confira `Supabase conectado`. Verifique /health e os totais de agosto: 1.050.248 passageiros; 288.378 pagantes; 761.870 não pagantes; 34.994 viagens realizadas; 275.694,5 km; R$ 668.605,71 em vendas.

## Exemplos de consulta

Relacional:

```sql
select sum(paid) as pagantes, sum(unpaid) as nao_pagantes
from semob_passenger_daily
where day between '2026-08-01' and '2026-08-31';
```

Documental:

```sql
select source, document->'columns' as colunas,
       jsonb_array_length(document->'rows') as linhas
from semob_documents;
```

JSONB armazena documentos flexíveis dentro de PostgreSQL. Se a exigência acadêmica for usar dois servidores distintos, sendo um NoSQL independente, essa arquitetura deverá incluir um segundo produto; Supabase sozinho não equivale a MongoDB.

## Referências oficiais

- https://supabase.com/docs/guides/database/connecting-to-postgres
- https://supabase.com/docs/guides/database/json
- https://supabase.com/docs/guides/database/postgres/row-level-security
- https://supabase.com/docs/guides/database/secure-data
