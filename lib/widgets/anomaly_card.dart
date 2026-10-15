import 'package:flutter/material.dart';

import '../core/formatters.dart';
import '../core/theme.dart';
import '../models/dashboard_overview.dart';

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
    final esquema = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: cardDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: esquema.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'ANOMALIAS DETECTADAS',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: esquema.onSurface,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: esquema.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'Recentes',
                  style: TextStyle(
                    fontSize: 10,
                    color: esquema.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (anomalias.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(
                  'Nenhuma anomalia no período',
                  style: TextStyle(
                    color: esquema.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
              ),
            )
          else
            for (final anomalia in anomalias)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: AnomalyCard(
                  anomalia: anomalia,
                  onPressed: () => onTapItem(anomalia),
                ),
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
    final esquema = Theme.of(context).colorScheme;
    final escuro = Theme.of(context).brightness == Brightness.dark;
    final alta = anomalia.severidade == 'alta';

    final accent = alta
        ? (escuro ? const Color(0xFFFCA5A5) : AppColors.red)
        : (escuro
            ? const Color(0xFFFCD34D)
            : const Color(0xFFB45309));

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: esquema.surfaceContainerHighest,
        border: Border(
          left: BorderSide(color: accent, width: 4),
        ),
        borderRadius: BorderRadius.circular(6),
      ),
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
                    color: esquema.onSurface,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Score: ${anomalia.score.toStringAsFixed(2)}',
                style: TextStyle(fontSize: 10, color: accent),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Obs: ${anomalia.observado} | Esp: ${anomalia.esperado}',
            style: TextStyle(
              fontSize: 11,
              color: esquema.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Desvio: ${fmtPercent(anomalia.desvio)}',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: accent,
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: OutlinedButton(
              onPressed: onPressed,
              child: Text(alta ? 'VER DETALHES' : 'ANALISAR'),
            ),
          ),
        ],
      ),
    );
  }
}