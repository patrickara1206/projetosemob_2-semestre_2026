# SEMOB-SCS — Dashboard de Transporte

Entrega local com dados reais dos relatórios de julho, agosto e setembro de 2026. Nenhum commit foi feito nesta implementação.

## Abrir pelo pendrive

1. Abra a pasta `E:\SEMOB-Dashboard`.
2. Dê dois cliques em `INICIAR-SEMOB.cmd`.
3. Aguarde a preparação inicial (precisa de internet na primeira execução).
4. O sistema abrirá em http://127.0.0.1:8081. A API está em http://127.0.0.1:8001/docs.
5. Mantenha a janela aberta. Ctrl+C encerra o sistema.

Python 3.12+ é necessário. Python 3.13 já foi instalado no computador do Patrick. A interface já vem compilada e não exige Flutter para ser aberta. Em outro computador, instale Python e execute o mesmo iniciador. Não abra web-dist/index.html diretamente.

## Abrir no VS Code

Escolha Arquivo > Abrir Pasta e selecione a pasta do projeto no pendrive. Depois escolha Terminal > Executar Tarefa > SEMOB: iniciar sistema.

Para desenvolver o Flutter, use o SDK instalado no computador. Em outro computador, ajuste `dart.flutterSdkPath` nas configurações do workspace, rode `flutter pub get` e `flutter run -d edge --web-port 8081`. A API usa a porta 8001. O compilador foi validado com Flutter 3.47.6 e Dart 3.13.5.

## Telas e recursos

- Visão geral: viagens realizadas/programadas, quilômetros, passageiros e vendas de créditos.
- Operação: quilômetros diários, distribuição dos horários de registros produtivos e alertas de viagens não realizadas.
- Passageiros: total, pagantes/não pagantes, categorias, evolução diária e dia de maior demanda.
- Financeiro: vendas, utilização, crédito circulante e detalhamento diário.
- Monitoramento: regras de consistência, viagens não realizadas e desvios de demanda.
- Viagens: consulta paginada por período e linha.
- Dados e Banco: importações, relatórios originais, inspeção paginada e upload de ZIP com chave administrativa.
- Filtros: dia, semana móvel de sete dias, mês e intervalo personalizado; exportação CSV do período/linha selecionados.

Os dados são históricos: 01/07/2026 a 14/09/2026. Selecione um período coberto. Setembro está incompleto. Filtrar por linha não inventa passageiros ou valores financeiros que não existem discriminados por linha.

## Banco local e Supabase

O banco local incluso (`data/semob.sqlite`) já contém os dados. A implementação Supabase usa tabelas relacionais PostgreSQL e documentos JSONB com índice GIN. JSONB é um modelo documental flexível dentro de PostgreSQL, não um servidor NoSQL separado.

A conexão real com Supabase ainda não foi ativada: o usuário ainda não tem projeto criado. Veja `docs/SUPABASE.md` para criar, aplicar a migração e importar os dados.

## Importar novamente

Na raiz, depois de preparar o ambiente:

```powershell
cd backend
..\.venv\Scripts\python.exe -m app.cli import ..\data\transport.zip
```

O mesmo ZIP é reconhecido pelo SHA-256 e não duplica os dados. Relatórios mensais têm preferência sobre quinzenais no mesmo dia. Os 107.927 registros brutos ficam preservados para auditoria.

Para habilitar upload pela tela Dados e Banco, copie backend/.env.example para backend/.env, configure ADMIN_KEY com uma chave criada por você e reinicie. A chave é digitada apenas durante o envio e não é salva pela interface.

## Validação e limites

A validação está em `docs/VALIDACAO.md`. Os dados não incluem horários planejados ou anomalias rotuladas: pontualidade, acurácia, falsos positivos e previsões de modelo não são fabricados. Diferença entre vendas e utilização não é lucro. As informações financeiras preservam os significados do relatório de origem.

As plataformas Android, iOS e desktop foram preservadas como código. Esta entrega foi compilada e testada para navegador. A aceitação formal pela SEMOB e o acesso direto à Smart Data dependem dos parceiros.
