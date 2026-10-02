import 'package:flutter/material.dart';

import '../core/formatters.dart';
import '../core/theme.dart';
import '../models/dashboard_overview.dart';

class IntelligenceCard extends StatelessWidget {
  final InteligenciaOperacional data;
  const IntelligenceCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.auto_awesome, color: AppColors.primary, size: 18),
              SizedBox(width: 8),
              Text('Inteligência Operacional',
                  style: TextStyle(
                      color: AppColors.navy,
                      fontWeight: FontWeight.w700,
                      fontSize: 15)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _Metric(
                  value: fmtInt(data.anomaliasCriticas),
                  label: 'Anomalias críticas',
                  color: AppColors.red),
              const SizedBox(width: 12),
              _Metric(
                  value: fmtInt(data.alertasAtivos),
                  label: 'Alertas ativos',
                  color: AppColors.orange),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _Metric(
                  value: 'Regras',
                  label: 'Método de detecção',
                  color: AppColors.primary),
              const SizedBox(width: 12),
              _Metric(
                  value: 'Pendente',
                  label: 'Validação pela SEMOB',
                  color: AppColors.primary),
            ],
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
  const _Metric(
      {required this.value, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFF3F6FB),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(value,
                style: TextStyle(
                    color: color, fontSize: 24, fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text(label,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.muted, fontSize: 10)),
          ],
        ),
      ),
    );
  }
}
