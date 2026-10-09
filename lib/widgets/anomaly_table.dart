import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../models/operacao_overview.dart';

class AnomalyTable extends StatelessWidget {
  final List<AnomaliaOp> anomalias;
  final void Function(AnomaliaOp) onAction;
  final VoidCallback onVerTodas;

  const AnomalyTable({
    super.key,
    required this.anomalias,
    required this.onAction,
    required this.onVerTodas,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: cardDecoration(),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  color: AppColors.red,
                  size: 22,
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Anomalias Operacionais Detectadas (ML)',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.navy,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: onVerTodas,
                  child: const Text(
                    'Ver Todas',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
          LayoutBuilder(
            builder: (context, box) {
              final width = math.max(box.maxWidth, 720.0);
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: width,
                  child: Column(
                    children: [
                      const _Row(
                        header: true,
                        cells: [
                          'ID ROTA',
                          'TIPO DE DESVIO',
                          'VEÍCULO',
                          'SEVERIDADE',
                          'AÇÃO',
                        ],
                      ),
                      if (anomalias.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(24),
                          child: Text(
                            'Nenhuma anomalia no período',
                            style: TextStyle(color: AppColors.muted),
                          ),
                        )
                      else
                        for (var i = 0; i < anomalias.length; i++)
                          _DataRow(
                            anomalia: anomalias[i],
                            zebra: i.isOdd,
                            onAction: () => onAction(anomalias[i]),
                          ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

const _flex = [2, 4, 2, 2, 2];

class _Row extends StatelessWidget {
  final bool header;
  final List<String> cells;
  const _Row({required this.header, required this.cells});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.navy,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          for (var i = 0; i < cells.length; i++)
            Expanded(
              flex: _flex[i],
              child: Align(
                alignment: i == 4
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                child: Text(
                  cells[i],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _DataRow extends StatelessWidget {
  final AnomaliaOp anomalia;
  final bool zebra;
  final VoidCallback onAction;
  const _DataRow({
    required this.anomalia,
    required this.zebra,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final alta = anomalia.severidade == 'alta';

    return Container(
      color: zebra ? const Color(0xFFF8F9FC) : Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          Expanded(
            flex: _flex[0],
            child: Text(
              anomalia.idRota,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.navy,
              ),
            ),
          ),
          Expanded(
            flex: _flex[1],
            child: Text(
              anomalia.tipo,
              style: const TextStyle(fontSize: 12, color: AppColors.text),
            ),
          ),
          Expanded(
            flex: _flex[2],
            child: Text(
              anomalia.veiculo,
              style: const TextStyle(fontSize: 12, color: AppColors.text),
            ),
          ),
          Expanded(
            flex: _flex[3],
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: alta ? AppColors.redSoft : AppColors.orangeSoft,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  alta ? 'Alta' : 'Média',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: alta ? AppColors.red : const Color(0xFFB7791F),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            flex: _flex[4],
            child: Align(
              alignment: Alignment.centerRight,
              child: _actionButton(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButton() {
    const size = Size(0, 30);
    const text = TextStyle(fontSize: 10, fontWeight: FontWeight.w600);

    switch (anomalia.acao) {
      case 'notificar':
        return OutlinedButton(
          onPressed: onAction,
          style: OutlinedButton.styleFrom(minimumSize: size, textStyle: text),
          child: const Text('Notificar'),
        );
      case 'ajustar':
        return OutlinedButton(
          onPressed: onAction,
          style: OutlinedButton.styleFrom(minimumSize: size, textStyle: text),
          child: const Text('Ajustar Int.'),
        );
      default:
        return FilledButton(
          onPressed: onAction,
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            minimumSize: size,
            textStyle: text,
          ),
          child: const Text('Investigar'),
        );
    }
  }
}
