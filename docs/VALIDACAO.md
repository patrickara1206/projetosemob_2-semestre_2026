# Validação da entrega

- Backend: 16 testes aprovados. Evidência: backend-tests.xml.
- Interface: 2 testes aprovados, cobrindo moeda, navegação nas telas e tamanho de celular. Evidência: frontend-tests.txt.
- PostgreSQL: migração aplicada, reaplicação idempotente, dados reais importados, tabelas relacionais e 47 documentos JSONB conferidos, 9 tabelas com RLS e acesso anônimo negado. Evidência: postgres-validation.json.
- Flutter: análise sem problemas e build web release, com recursos CanvasKit locais.
- Cobertura importada: 76 dias, 47 tabelas de origem e 107.927 registros brutos de viagens.
- Agosto conciliado: 1.050.248 passageiros (288.378 pagantes e 761.870 não pagantes), 275.694,5 km, 35.050 viagens programadas, 34.994 realizadas e 56 não realizadas; R$ 668.605,71 em vendas.

A migração foi testada em PostgreSQL local. Não há validação de conexão com um projeto Supabase remoto porque o usuário ainda não tem projeto criado.

O CSV usa separador ponto e vírgula, BOM UTF-8 e vírgula decimal. Os filtros preservam dados ausentes como nulos e informam a cobertura do período. As viagens são paginadas e documentos podem ser inspecionados em páginas de 50 linhas. A importação exige chave administrativa e rejeita caminhos ZIP que tentam sair da pasta de destino.

## Limites dos dados e do produto

- Não há horário planejado por viagem; pontualidade não é calculada.
- Não há modelo treinado, rótulos de anomalias ou validação de acurácia; monitoramento usa regras documentadas.
- Setembro tem dados só até dia 14; os relatórios não são uma fonte em tempo real.
- Passageiros e financeiro não são discriminados por linha. Ao selecionar linha, esses campos ficam indisponíveis.
- Não existe autenticação de usuários para implantação pública nesta etapa; o iniciador atende apenas em 127.0.0.1. Antes de publicar, implemente autenticação/autorização para a API.
- Acesso direto à Smart Data, aceite formal e feedback da SEMOB ainda não foram obtidos.
