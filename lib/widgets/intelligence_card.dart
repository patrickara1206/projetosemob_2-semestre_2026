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
    final cumprimento = data.cumprimentoProgramacao == null
        ? '--'
        : '${data.cumprimentoProgramacao!.toStringAsFixed(2).replaceAll('.', ',')}%';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.auto_awesome,
                color: AppColors.primary,
                size: 18,
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Inteligência Operacional',
                  style: TextStyle(
                    color: AppColors.navy,
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
                color: AppColors.primary,
              ),
              const SizedBox(width: 12),
              _Metric(
                value: fmtInt(data.viagensNaoRealizadas),
                label: 'Viagens não realizadas',
                color: AppColors.red,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _Metric(
                value: fmtInt(data.diasComDesvio),
                label: 'Dias com desvio',
                color: AppColors.orange,
              ),
              const SizedBox(width: 12),
              _Metric(
                value: fmtInt(data.diasAnalisados),
                label: 'Dias analisados',
                color: AppColors.primary,
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Indicadores calculados por comparação entre '
            'viagens realizadas e programadas.',
            style: TextStyle(
              fontSize: 11,
              color: AppColors.muted,
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
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 16,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFFF3F6FB),
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
              height: 32,
              child: Center(
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.muted,
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