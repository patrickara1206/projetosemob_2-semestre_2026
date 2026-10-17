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
    final cores = Theme.of(context).colorScheme;

    return Container(
      decoration: cardDecoration(context),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: cores.error,
                  size: 22,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Anomalias Operacionais Detectadas (ML)',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: cores.onSurface,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: onVerTodas,
                  child: const Text(
                    'Ver Todas',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
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
                      const _TableHeader(),
                      if (anomalias.isEmpty)
                        Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text(
                            'Nenhuma anomalia no período',
                            style: TextStyle(
                              color: cores.onSurfaceVariant,
                            ),
                          ),
                        )
                      else
                        for (var i = 0; i < anomalias.length; i++)
                          _AnomalyRow(
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

class _TableHeader extends StatelessWidget {
  const _TableHeader();

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).colorScheme;

    const titulos = [
      'ID ROTA',
      'TIPO DE DESVIO',
      'VEÍCULO',
      'SEVERIDADE',
      'AÇÃO',
    ];

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 14,
      ),
      decoration: BoxDecoration(
        color: cores.surfaceContainerHighest,
        border: Border(
          bottom: BorderSide(color: cores.outlineVariant),
        ),
      ),
      child: Row(
        children: [
          for (var i = 0; i < titulos.length; i++)
            Expanded(
              flex: _flex[i],
              child: Align(
                alignment: i == titulos.length - 1
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                child: Text(
                  titulos[i],
                  style: TextStyle(
                    color: cores.onSurface,
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

class _AnomalyRow extends StatelessWidget {
  final AnomaliaOp anomalia;
  final bool zebra;
  final VoidCallback onAction;

  const _AnomalyRow({
    required this.anomalia,
    required this.zebra,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final cores = tema.colorScheme;
    final escuro = tema.brightness == Brightness.dark;
    final alta = anomalia.severidade.toLowerCase().trim() == 'alta';

    final corSeveridade = alta
        ? (escuro ? const Color(0xFFFCA5A5) : AppColors.red)
        : (escuro
              ? const Color(0xFFFCD34D)
              : const Color(0xFF92400E));

    final fundoSeveridade = alta
        ? (escuro ? const Color(0xFF451A1A) : AppColors.redSoft)
        : (escuro
              ? const Color(0xFF422E12)
              : AppColors.orangeSoft);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: zebra ? cores.surfaceContainerHighest : cores.surface,
        border: Border(
          bottom: BorderSide(color: cores.outlineVariant),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: _flex[0],
            child: Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Text(
                anomalia.idRota,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: cores.onSurface,
                ),
              ),
            ),
          ),
          Expanded(
            flex: _flex[1],
            child: Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Text(
                anomalia.tipo,
                style: TextStyle(
                  fontSize: 12,
                  color: cores.onSurface,
                ),
              ),
            ),
          ),
          Expanded(
            flex: _flex[2],
            child: Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Text(
                anomalia.veiculo,
                style: TextStyle(
                  fontSize: 12,
                  color: cores.onSurfaceVariant,
                ),
              ),
            ),
          ),
          Expanded(
            flex: _flex[3],
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: fundoSeveridade,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  alta ? 'Alta' : 'Média',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: corSeveridade,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            flex: _flex[4],
            child: Align(
              alignment: Alignment.centerRight,
              child: _actionButton(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButton(BuildContext context) {
    final cores = Theme.of(context).colorScheme;

    const tamanho = Size(0, 32);
    const estiloTexto = TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.w600,
    );

    switch (anomalia.acao) {
      case 'notificar':
      case 'ajustar':
        return OutlinedButton(
          onPressed: onAction,
          style: OutlinedButton.styleFrom(
            foregroundColor: cores.primary,
            side: BorderSide(color: cores.outline),
            minimumSize: tamanho,
            textStyle: estiloTexto,
          ),
          child: Text(
            anomalia.acao == 'notificar' ? 'Notificar' : 'Ajustar Int.',
          ),
        );
      default:
        return FilledButton(
          onPressed: onAction,
          style: FilledButton.styleFrom(
            backgroundColor: cores.primary,
            foregroundColor: cores.onPrimary,
            minimumSize: tamanho,
            textStyle: estiloTexto,
          ),
          child: const Text('Investigar'),
        );
    }
  }
}