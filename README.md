# SEMOB-SCS

Dashboard Flutter com API FastAPI e dados do Supabase. A branch `aprimoramentos` contém login, Visão Geral, Operação, Passageiros, Financeiro, importação HTML e configurações de conexão/mês. Machine Learning permanece indisponível.

## Iniciar no Windows

1. Instale Python e Flutter; informe o caminho do SDK Flutter caso ele não esteja no PATH.
2. Copie `backend/.env.example` para `backend/.env` e configure suas próprias credenciais Supabase. O arquivo `.env` não deve ser commitado.
3. Na pasta do projeto, execute `INICIAR-SEMOB.cmd`. O iniciador prepara as dependências, inicia o backend desta pasta e abre o frontend na mesma API.

Se o Flutter não estiver no PATH:

```powershell
.\INICIAR-SEMOB.cmd -FlutterSdk "C:\src\flutter"
```

O caminho acima é um exemplo: use a pasta em que seu SDK está instalado. O backend usa a porta 8000 e o frontend 8080. Se as portas estiverem ocupadas, encerre a execução antiga ou informe `-ApiPort 8004 -WebPort 8084`. O script não encerra servidores de outros projetos. Ao finalizar o Flutter, encerra somente o backend que iniciou. Logs locais: `.semob-local/`.

## Terminais separados no VS Code

Abra esta pasta no VS Code. No primeiro terminal, na raiz:

```powershell
python -m venv .venv
.\.venv\Scripts\python.exe -m pip install -r backend\requirements.txt
cd backend
..\.venv\Scripts\python.exe -m uvicorn app.main:app --reload --host 127.0.0.1 --port 8000
```

No segundo terminal, na raiz:

```powershell
flutter pub get
flutter run -d chrome --web-port=8080 --dart-define=API_URL=http://127.0.0.1:8000
```

Execute ambos os terminais a partir da mesma cópia/branch do projeto. Depois de atualizar o backend, reinicie o servidor. Depois de atualizar o frontend, reinicie o Flutter ou recarregue a página.

## Dados e filtros

- O mês inicial é 2026-08. Configurações permite mudar o mês da Visão Geral, Operação e Passageiros. Financeiro também possui campo próprio de mês.
- Último dia e Últimos 7 dias usam a última data registrada no mês selecionado. Mês completo usa todos os dias disponíveis. Personalizado permite selecionar um intervalo dentro do mês de referência.
- Relatórios mensais têm preferência sobre quinzenais para o mesmo dia, evitando duplicar totais.
- Indicadores ausentes e listas vazias são apresentados como indisponíveis, sem inventar dados.
- Exportar Relatório baixa CSV dos valores mostrados. No Financeiro, inclui todas as páginas da tabela para o filtro de busca aplicado.
- Subsídios, custos operacionais, repasses, pontualidade real e séries horárias dependem de dados que a base atual não fornece. Não são preenchidos artificialmente. Machine Learning não foi implementado nesta atualização.

## Financeiro não carrega

Acesse Configurações para verificar a conexão e se o servidor possui a rota financeira. Uma mensagem de versão incompatível indica que o backend executado não pertence à mesma versão do frontend. Uma mensagem de conexão indisponível indica que é necessário iniciar/verificar o backend. O iniciador verifica a existência da rota antes de abrir a aplicação.

## Testes

```powershell
.\.venv\Scripts\python.exe -m unittest discover -s test -p '*test.py'
flutter test
flutter analyze
flutter build web
```

Os testes de API e importação usam repositórios simulados; não gravam registros no Supabase. A chave do banco nunca deve aparecer no código, nos testes nem em commits.
