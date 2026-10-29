import 'package:flutter/material.dart';

import '../core/formatters.dart';
import '../core/theme.dart';
import '../models/dashboard_overview.dart';

/// Painel "Anomalias Detectadas" com a lista de anomalias.
class AnomalyPanel extends StatelessWidget {
  final List<Anomalia> anomalias;
  final void Function(Anomalia) onTapItem;
  const AnomalyPanel({
    super.key,
    required this.anomalias,
    required this.onTapItem,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: cardDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: AppColors.orange,
                size: 20,
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'ANOMALIAS DETECTADAS',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              SizedBox(width: 8),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Color(0xFFFDECEC),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'Recentes',
                  style: TextStyle(fontSize: 10, color: AppColors.red),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          if (anomalias.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(
                  'Nenhuma anomalia no período',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
              ),
            )
          else
            for (final a in anomalias)
              Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: AnomalyCard(anomalia: a, onPressed: () => onTapItem(a)),
              ),
        ],
      ),
    );
  }
}

class AnomalyCard extends StatelessWidget {
  final Anomalia anomalia;
  final VoidCallback onPressed;
  const AnomalyCard({
    super.key,
    required this.anomalia,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final alta = anomalia.severidade == 'alta';
    final accent = alta ? AppColors.red : AppColors.orange;
    final bg = alta ? Color(0xFFFDF2F2) : Color(0xFFFFF8E7);
    final desvioTxt = fmtPercent(anomalia.desvio);

    return LayoutBuilder(
      builder: (context, box) {
        final isMobile = box.maxWidth < 360;

        return Container(
          decoration: BoxDecoration(
            color: bg,
            border: Border(left: BorderSide(color: accent, width: 4)),
            borderRadius: BorderRadius.circular(6),
          ),
          padding: EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      anomalia.titulo,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: accent.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Score: ${anomalia.score.toStringAsFixed(2)}',
                      style: TextStyle(fontSize: 10, color: accent),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              if (isMobile) ...[
                Text(
                  'Obs: ${anomalia.observado} | Esp: ${anomalia.esperado}',
                  style: TextStyle(fontSize: 11),
                ),
                SizedBox(height: 4),
                Text(
                  'Desvio: $desvioTxt',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: accent,
                  ),
                ),
              ] else ...[
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Obs: ${anomalia.observado} | Esp: ${anomalia.esperado}',
                        style: TextStyle(fontSize: 11),
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Desvio: $desvioTxt',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: accent,
                      ),
                    ),
                  ],
                ),
              ],
              SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: alta
                    ? FilledButton(
                        onPressed: onPressed,
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          minimumSize: Size(0, 30),
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          textStyle: TextStyle(fontSize: 10),
                        ),
                        child: Text('VER DETALHES'),
                      )
                    : OutlinedButton(
                        onPressed: onPressed,
                        style: OutlinedButton.styleFrom(
                          minimumSize: Size(0, 30),
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          textStyle: TextStyle(fontSize: 10),
                        ),
                        child: Text('ANALISAR'),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
