import 'package:flutter/material.dart';

import '../services/importacao_service.dart';

class ImportacaoPage extends StatefulWidget {
  const ImportacaoPage({super.key});

  @override
  State<ImportacaoPage> createState() => _ImportacaoPageState();
}

class _ImportacaoPageState extends State<ImportacaoPage> {
  String tipo = 'operacao';
  String mes = '2026-08';
  String tipoPeriodo = 'mensal';

  bool carregandoHtml = false;
  bool carregandoZip = false;

  String? mensagem;
  bool sucesso = false;

  bool get carregando => carregandoHtml || carregandoZip;

  Future<void> importar() async {
    setState(() {
      carregandoHtml = true;
      mensagem = null;
      sucesso = false;
    });

    try {
      final resultado = await ImportacaoService().enviarArquivo(
        tipo: tipo,
        mes: mes,
        tipoPeriodo: tipoPeriodo,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        sucesso = true;
        mensagem =
            'Importação concluída com sucesso. '
            '${resultado['registros']} registros importados.';
      });
    } catch (erro) {
      if (!mounted) {
        return;
      }

      var texto = erro.toString();
      texto = texto.replaceFirst('Exception: ', '');

      setState(() {
        sucesso = false;
        mensagem = texto;
      });
    } finally {
      if (mounted) {
        setState(() {
          carregandoHtml = false;
        });
      }
    }
  }

  Future<void> importarZip() async {
    setState(() {
      carregandoZip = true;
      mensagem = null;
      sucesso = false;
    });

    try {
      final resultado = await ImportacaoService().enviarZip(
        mes: mes,
        tipoPeriodo: tipoPeriodo,
      );

      if (!mounted) {
        return;
      }

      final importados = resultado['arquivos_importados'] ?? 0;
      final erros = resultado['arquivos_com_erro'] ?? 0;
      final ignorados = resultado['arquivos_ignorados'] ?? 0;
      final registros = resultado['total_registros'] ?? 0;

      setState(() {
        sucesso = erros == 0;

        mensagem =
            'Importação do ZIP concluída. '
            '$importados arquivo(s) importado(s), '
            '$registros registro(s) adicionados, '
            '$erros arquivo(s) com erro e '
            '$ignorados arquivo(s) ignorado(s).';
      });
    } catch (erro) {
      if (!mounted) {
        return;
      }

      var texto = erro.toString();
      texto = texto.replaceFirst('Exception: ', '');

      setState(() {
        sucesso = false;
        mensagem = texto;
      });
    } finally {
      if (mounted) {
        setState(() {
          carregandoZip = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(MediaQuery.sizeOf(context).width < 600 ? 16 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Importar dados',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 8),

          const Text(
            'Selecione o tipo de relatório, '
            'o mês de referência, o período '
            'e escolha se deseja importar um HTML '
            'ou um arquivo ZIP com vários relatórios.',
          ),

          const SizedBox(height: 32),

          const Text('Tipo de relatório'),

          const SizedBox(height: 8),

          DropdownButton<String>(
            value: tipo,
            items: const [
              DropdownMenuItem(
                value: 'operacao',
                child: Text('Operação geral'),
              ),
              DropdownMenuItem(value: 'fcv', child: Text('FCV')),
              DropdownMenuItem(
                value: 'faixa_horaria',
                child: Text('Faixa horária'),
              ),
              DropdownMenuItem(value: 'linhas', child: Text('Linhas')),
              DropdownMenuItem(
                value: 'resumo_faixa_horaria',
                child: Text('Resumo por faixa horária'),
              ),
              DropdownMenuItem(value: 'viagens', child: Text('Viagens')),
              DropdownMenuItem(
                value: 'viagens_nao_iniciadas',
                child: Text('Viagens não iniciadas'),
              ),
              DropdownMenuItem(
                value: 'viagens_nao_realizadas',
                child: Text('Viagens não realizadas'),
              ),
              DropdownMenuItem(
                value: 'viagens_nao_terminadas',
                child: Text('Viagens não terminadas'),
              ),
              DropdownMenuItem(
                value: 'passageiros',
                child: Text('Passageiros'),
              ),
              DropdownMenuItem(
                value: 'financeiro',
                child: Text('Saldos / Financeiro'),
              ),
            ],
            onChanged: carregando
                ? null
                : (valor) {
                    if (valor != null) {
                      setState(() {
                        tipo = valor;
                        mensagem = null;
                      });
                    }
                  },
          ),

          const SizedBox(height: 24),

          const Text('Mês'),

          const SizedBox(height: 8),

          DropdownButton<String>(
            value: mes,
            items: const [
              DropdownMenuItem(value: '2026-07', child: Text('Julho/2026')),
              DropdownMenuItem(value: '2026-08', child: Text('Agosto/2026')),
              DropdownMenuItem(value: '2026-09', child: Text('Setembro/2026')),
            ],
            onChanged: carregando
                ? null
                : (valor) {
                    if (valor != null) {
                      setState(() {
                        mes = valor;
                        mensagem = null;
                      });
                    }
                  },
          ),

          const SizedBox(height: 24),

          const Text('Período do relatório'),

          const SizedBox(height: 8),

          DropdownButton<String>(
            value: tipoPeriodo,
            items: const [
              DropdownMenuItem(value: 'mensal', child: Text('Mensal')),
              DropdownMenuItem(value: 'quinzenal', child: Text('Quinzenal')),
            ],
            onChanged: carregando
                ? null
                : (valor) {
                    if (valor != null) {
                      setState(() {
                        tipoPeriodo = valor;
                        mensagem = null;
                      });
                    }
                  },
          ),

          const SizedBox(height: 32),

          ElevatedButton.icon(
            onPressed: carregando ? null : importar,
            icon: carregandoHtml
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.upload_file),
            label: Text(
              carregandoHtml ? 'Importando...' : 'Selecionar e importar HTML',
            ),
          ),

          const SizedBox(height: 16),

          ElevatedButton.icon(
            onPressed: carregando ? null : importarZip,
            icon: carregandoZip
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.folder_zip_outlined),
            label: Text(
              carregandoZip ? 'Importando...' : 'Selecionar e importar ZIP',
            ),
          ),

          const SizedBox(height: 24),

          if (mensagem != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: sucesso ? Colors.green.shade50 : Colors.red.shade50,
                border: Border.all(
                  color: sucesso ? Colors.green.shade300 : Colors.red.shade300,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    sucesso ? Icons.check_circle : Icons.error_outline,
                    color: sucesso ? Colors.green : Colors.red,
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Text(
                      mensagem!,
                      style: TextStyle(
                        color: sucesso
                            ? Colors.green.shade900
                            : Colors.red.shade900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
