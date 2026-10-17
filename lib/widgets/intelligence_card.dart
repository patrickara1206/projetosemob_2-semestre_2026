import 'package:flutter/material.dart';

import '../core/formatters.dart';
import '../core/theme.dart';
import '../models/dashboard_overview.dart';

class IntelligenceCard extends StatelessWidget {
  final InteligenciaOperacional data;

  const IntelligenceCard({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    final esquema = Theme.of(context).colorScheme;
    final escuro = Theme.of(context).brightness == Brightness.dark;

    final azul = escuro
        ? const Color(0xFF93C5FD)
        : AppColors.primary;
    final vermelho = escuro
        ? const Color(0xFFFCA5A5)
        : AppColors.red;
    final laranja = escuro
        ? const Color(0xFFFCD34D)
        : const Color(0xFFB45309);

    final cumprimento = data.cumprimentoProgramacao == null
        ? '--'
        : '${data.cumprimentoProgramacao!.toStringAsFixed(2).replaceAll('.', ',')}%';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: cardDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.auto_awesome,
                color: esquema.primary,
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Inteligência Operacional',
                  style: TextStyle(
                    color: esquema.onSurface,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _Metric(
                value: cumprimento,
                label: 'Cumprimento da programação',
                color: azul,
              ),
              const SizedBox(width: 12),
              _Metric(
                value: fmtInt(data.viagensNaoRealizadas),
                label: 'Viagens não realizadas',
                color: vermelho,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _Metric(
                value: fmtInt(data.diasComDesvio),
                label: 'Dias com desvio',
                color: laranja,
              ),
              const SizedBox(width: 12),
              _Metric(
                value: fmtInt(data.diasAnalisados),
                label: 'Dias analisados',
                color: azul,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Indicadores calculados por comparação entre '
            'viagens realizadas e programadas.',
            style: TextStyle(
              fontSize: 11,
              color: esquema.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  final String value;
  final String label;
  final Color color;

  const _Metric({
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final esquema = Theme.of(context).colorScheme;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 16,
        ),
        decoration: BoxDecoration(
          color: esquema.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: TextStyle(
                  color: color,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(height: 6),
            SizedBox(
              height: 44,
              child: Center(
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: esquema.onSurfaceVariant,
                    fontSize: 11,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}