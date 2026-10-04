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

  bool carregando = false;
  String? mensagem;

  Future<void> importar() async {
    setState(() {
      carregando = true;
      mensagem = null;
    });

    try {
      final resultado = await ImportacaoService().enviarArquivo(
        tipo: tipo,
        mes: mes,
        tipoPeriodo: 'mensal',
      );

      setState(() {
        mensagem =
            'Importação concluída: ${resultado['registros']} registros.';
      });
    } catch (erro) {
      setState(() {
        mensagem = 'Erro na importação: $erro';
      });
    } finally {
      setState(() {
        carregando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Importar dados',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          const Text(
            'Selecione o tipo de relatório, o mês de referência e o arquivo HTML.',
          ),

          const SizedBox(height: 32),

          const Text('Tipo de relatório'),

          const SizedBox(height: 8),

          DropdownButton<String>(
            value: tipo,
            items: const [
              DropdownMenuItem(
                value: 'operacao',
                child: Text('Operação'),
              ),
              DropdownMenuItem(
                value: 'passageiros',
                child: Text('Passageiros'),
              ),
              DropdownMenuItem(
                value: 'financeiro',
                child: Text('Financeiro'),
              ),
            ],
            onChanged: (valor) {
              if (valor != null) {
                setState(() {
                  tipo = valor;
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
              DropdownMenuItem(
                value: '2026-07',
                child: Text('Julho/2026'),
              ),
              DropdownMenuItem(
                value: '2026-08',
                child: Text('Agosto/2026'),
              ),
              DropdownMenuItem(
                value: '2026-09',
                child: Text('Setembro/2026'),
              ),
            ],
            onChanged: (valor) {
              if (valor != null) {
                setState(() {
                  mes = valor;
                });
              }
            },
          ),

          const SizedBox(height: 32),

          ElevatedButton.icon(
            onPressed: carregando ? null : importar,
            icon: const Icon(Icons.upload_file),
            label: Text(
              carregando
                  ? 'Importando...'
                  : 'Selecionar e importar HTML',
            ),
          ),

          const SizedBox(height: 24),

          if (mensagem != null)
            Text(
              mensagem!,
            ),
        ],
      ),
    );
  }
}