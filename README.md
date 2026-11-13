# SEMOB-SCS

Dashboard de operação de transporte de São Caetano do Sul, com interface
Flutter, API FastAPI e persistência no Supabase.

## Organização do projeto

```text
lib/
  core/           Tema, estado compartilhado e utilitários
  layout/         Cabeçalho, menu e estrutura das páginas
  models/         Modelos de dados da interface
  pages/          Telas da aplicação
  services/       Acesso à API
  widgets/        Componentes reutilizáveis e gráficos
backend/
  app/
    core/         Configurações dos relatórios
    database/     Conexão com o banco
    readers/      Leitura dos arquivos importados
    repositories/ Acesso aos dados
    routes/       Endpoints e validação dos filtros
    services/     Regras de negócio e agregações
scripts/          Inicialização local
test/             Testes Flutter, Python e JavaScript
assets/           Imagens da aplicação
```

As pastas de plataforma (`android`, `ios`, `web`, `windows`, `linux` e
`macos`) mantêm a estrutura do Flutter.

## Execução no Windows

1. Tenha Python e Flutter disponíveis no computador.
2. Copie `backend/.env.example` para `backend/.env` e configure
   `SUPABASE_URL` e `SUPABASE_KEY`.
3. Na raiz do projeto, execute:

   ```powershell
   .\INICIAR-SEMOB.cmd
   ```

O iniciador prepara o ambiente Python, inicia a API em
`http://127.0.0.1:8000` e a interface em `http://127.0.0.1:8080`.
Mantenha o terminal aberto durante o uso. Ao encerrar, o iniciador para
somente o backend que ele próprio abriu.

Para abrir o navegador manualmente:

```powershell
.\INICIAR-SEMOB.cmd -Device web-server
```

Se necessário, informe o SDK ou portas alternativas:

```powershell
.\INICIAR-SEMOB.cmd -FlutterSdk "C:\src\flutter" -ApiPort 8004 -WebPort 8084
```

Credenciais, ambiente virtual, logs e configurações de `.semob-local/`
são locais e permanecem ignorados pelo Git.

## API e filtros

A documentação interativa fica em `http://127.0.0.1:8000/docs`.
As rotas de resumo aceitam `escopo=total`, `escopo=mes` ou
`escopo=quinzena`. Os dois últimos exigem `mes` no formato `AAAA-MM`.

Exemplo: `/dashboard/overview?escopo=mes&mes=2026-08`.

`/financeiro/overview` inclui a série `dias_financeiros`.
`/financeiro/dashboard` oferece também busca e paginação.
Meses sem dados retornam indicadores ausentes e séries vazias.

## Convenções de manutenção

- Use `dart format lib test` para a formatação Dart.
- Use quatro espaços para indentação Python e dois para Dart e YAML,
  conforme `.editorconfig`.
- Mantenha widgets reutilizáveis em `lib/widgets`, chamadas HTTP em
  `lib/services` e regras de negócio em `backend/app/services`.
- Mantenha o acesso ao banco em `backend/app/repositories`.
- Preserve contratos da API, nomes dos campos e regras de cálculo em
  alterações exclusivamente visuais ou de formatação.
- Não versione credenciais, ambientes virtuais ou arquivos de compilação.

## Validação

Com as dependências preparadas:

```powershell
.\.venv\Scripts\python.exe -m unittest discover -s test -p '*test.py'
node --test test/web_bootstrap_test.js
flutter analyze
flutter test
flutter build web
```

Os testes de API usam simulações do banco e não gravam registros no
Supabase. Alguns testes legados de filtros ainda fazem referência à API
anterior de `PeriodoNotifier`; o teste de cor de anomalias também precisa
ser reconciliado com a implementação atual. Uma alteração de formatação
não modifica esses comportamentos para ocultar falhas.
