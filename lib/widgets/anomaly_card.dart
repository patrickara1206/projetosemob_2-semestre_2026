import 'package:flutter/material.dart';

import '../core/formatters.dart';
import '../core/theme.dart';
import '../models/dashboard_overview.dart';

/// Painel "Anomalias Detectadas" com a lista de anomalias.
class AnomalyPanel extends StatelessWidget {
  final List<Anomalia> anomalias;
  final void Function(Anomalia) onTapItem;
  const AnomalyPanel(
      {super.key, required this.anomalias, required this.onTapItem});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.warning_amber_rounded,
                  color: AppColors.orange, size: 20),
              const SizedBox(width: 8),
              const Expanded(
                child: Text('ANOMALIAS DETECTADAS',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF374151))),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFFDECEC),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text('Recentes',
                    style: TextStyle(fontSize: 10, color: AppColors.red)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (anomalias.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text('Nenhuma anomalia no período',
                    style: TextStyle(color: AppColors.muted, fontSize: 12)),
              ),
            )
          else
            for (final a in anomalias)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
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
  const AnomalyCard(
      {super.key, required this.anomalia, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final alta = anomalia.severidade == 'alta';
    final accent = alta ? AppColors.red : AppColors.orange;
    final bg = alta ? const Color(0xFFFDF2F2) : const Color(0xFFFFF8E7);
    final desvioTxt = fmtPercent(anomalia.desvio);

    return Container(
      decoration: BoxDecoration(
        color: bg,
        border: Border(left: BorderSide(color: accent, width: 4)),
        borderRadius: BorderRadius.circular(6),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(anomalia.titulo,
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w700)),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text('Score: ${anomalia.score.toStringAsFixed(2)}',
                    style: TextStyle(fontSize: 10, color: accent)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                    'Obs: ${anomalia.observado} | Esp: ${anomalia.esperado}',
                    style: const TextStyle(fontSize: 11)),
              ),
              Text('Desvio: $desvioTxt',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: accent)),
            ],
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: alta
                ? FilledButton(
                    onPressed: onPressed,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      minimumSize: const Size(0, 30),
                      textStyle: const TextStyle(fontSize: 10),
                    ),
                    child: const Text('VER DETALHES'),
                  )
                : OutlinedButton(
                    onPressed: onPressed,
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 30),
                      textStyle: const TextStyle(fontSize: 10),
                    ),
                    child: const Text('ANALISAR'),
                  ),
          ),
        ],
      ),
    );
  }
}