# semob_dashboard

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.


## Execução local no Windows

Copie `backend/.env.example` para `backend/.env` e configure suas credenciais Supabase.
Na raiz do projeto, execute `INICIAR-SEMOB.cmd`. O iniciador prepara o ambiente Python,
inicia a API na porta 8000 e abre Flutter na porta 8080. Se necessário, informe
`-FlutterSdk "C:\src\flutter"` e portas alternativas com `-ApiPort 8004 -WebPort 8084`.
O iniciador encerra apenas o backend que ele próprio abriu. Credenciais e logs locais
permanecem ignorados pelo Git.

A tela Configurações permite verificar a API e escolher o mês de referência das telas.
Financeiro mantém os indicadores, gráficos diários e tabela existentes, com exportação CSV.
Os endpoints overview aceitam `mes`, `periodo` (mes, semana, hoje ou personalizado),
`inicio` e `fim`. Os períodos relativos usam o último dia disponível no mês.
`/financeiro/overview` preserva o contrato com `dias_financeiros`; o endpoint adicional
`/financeiro/dashboard` oferece busca e paginação. Relatórios mensais têm prioridade
sobre quinzenais sobrepostos. Meses sem dados retornam indicadores ausentes e séries vazias.

### Validação

```powershell
.\.venv\Scripts\python.exe -m pip install -r backend\requirements.txt httpx
.\.venv\Scripts\python.exe -m unittest discover -s test -p '*test.py'
node --test test/web_bootstrap_test.js
flutter analyze
flutter test
flutter build web
```

Os testes de API simulam o banco e não gravam registros no Supabase.
