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
      decoration: cardDecoration(context),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: AppColors.red,
                  size: 20,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Anomalias Operacionais (ML)',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: onVerTodas,
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.symmetric(horizontal: 8),
                  ),
                  child: Text(
                    'Ver Todas',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
          LayoutBuilder(
            builder: (context, box) {
              final isMobile = box.maxWidth < 650;

              if (anomalias.isEmpty) {
                return Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text(
                      'Nenhuma anomalia no período',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                );
              }

              if (isMobile) {
                return ListView.separated(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: anomalias.length,
                  separatorBuilder: (_, __) =>
                      Divider(height: 1, color: AppColors.border),
                  itemBuilder: (context, i) => _MobileAnomalyCard(
                    anomalia: anomalias[i],
                    zebra: i.isOdd,
                    onAction: () => onAction(anomalias[i]),
                  ),
                );
              }

              final width = math.max(box.maxWidth, 720.0);
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: width,
                  child: Column(
                    children: [
                      _Row(
                        header: true,
                        cells: [
                          'ID ROTA',
                          'TIPO DE DESVIO',
                          'VEÍCULO',
                          'SEVERIDADE',
                          'AÇÃO',
                        ],
                      ),
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
      color: Theme.of(context).colorScheme.onSurface,
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
                  style: TextStyle(
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
      color: zebra ? Color(0xFFF8F9FC) : Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          Expanded(
            flex: _flex[0],
            child: Text(
              anomalia.idRota,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
          Expanded(
            flex: _flex[1],
            child: Text(
              anomalia.tipo,
              style: TextStyle(fontSize: 12, color: AppColors.text),
            ),
          ),
          Expanded(
            flex: _flex[2],
            child: Text(
              anomalia.veiculo,
              style: TextStyle(fontSize: 12, color: AppColors.text),
            ),
          ),
          Expanded(
            flex: _flex[3],
            child: Align(
              alignment: Alignment.centerLeft,
              child: _SeverityBadge(alta: alta),
            ),
          ),
          Expanded(
            flex: _flex[4],
            child: Align(
              alignment: Alignment.centerRight,
              child: _ActionButton(acao: anomalia.acao, onAction: onAction),
            ),
          ),
        ],
      ),
    );
  }
}

class _MobileAnomalyCard extends StatelessWidget {
  final AnomaliaOp anomalia;
  final bool zebra;
  final VoidCallback onAction;

  const _MobileAnomalyCard({
    required this.anomalia,
    required this.zebra,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final alta = anomalia.severidade == 'alta';

    return Container(
      color: zebra ? Color(0xFFF8F9FC) : Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                anomalia.idRota,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              SizedBox(width: 8),
              _SeverityBadge(alta: alta),
              Spacer(),
              _ActionButton(acao: anomalia.acao, onAction: onAction),
            ],
          ),
          SizedBox(height: 6),
          Text(
            anomalia.tipo,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.text,
            ),
          ),
          SizedBox(height: 2),
          Text(
            'Veículo: ${anomalia.veiculo}',
            style: TextStyle(
              fontSize: 11,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _SeverityBadge extends StatelessWidget {
  final bool alta;
  const _SeverityBadge({required this.alta});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: alta ? AppColors.redSoft : AppColors.orangeSoft,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        alta ? 'Alta' : 'Média',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: alta ? AppColors.red : Color(0xFFB7791F),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String acao;
  final VoidCallback onAction;

  const _ActionButton({required this.acao, required this.onAction});

  @override
  Widget build(BuildContext context) {
    const size = Size(0, 28);
    const text = TextStyle(fontSize: 10, fontWeight: FontWeight.w600);

    switch (acao) {
      case 'notificar':
        return OutlinedButton(
          onPressed: onAction,
          style: OutlinedButton.styleFrom(
            minimumSize: size,
            textStyle: text,
            padding: EdgeInsets.symmetric(horizontal: 10),
          ),
          child: Text('Notificar'),
        );
      case 'ajustar':
        return OutlinedButton(
          onPressed: onAction,
          style: OutlinedButton.styleFrom(
            minimumSize: size,
            textStyle: text,
            padding: EdgeInsets.symmetric(horizontal: 10),
          ),
          child: Text('Ajustar Int.'),
        );
      default:
        return FilledButton(
          onPressed: onAction,
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            minimumSize: size,
            textStyle: text,
            padding: EdgeInsets.symmetric(horizontal: 10),
          ),
          child: Text('Investigar'),
        );
    }
  }
}
