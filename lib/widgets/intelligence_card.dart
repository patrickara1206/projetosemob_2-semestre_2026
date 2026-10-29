import 'package:flutter/material.dart';

import '../core/formatters.dart';
import '../core/theme.dart';
import '../models/dashboard_overview.dart';

class IntelligenceCard extends StatelessWidget {
  final InteligenciaOperacional data;
  const IntelligenceCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final acuracia =
        data.acuracia == null ? '--' : '${data.acuracia!.round()}%';

    return LayoutBuilder(
      builder: (context, box) {
        final isMobile = box.maxWidth < 500;

        return Container(
          padding: EdgeInsets.all(isMobile ? 14 : 20),
          decoration: cardDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.auto_awesome, color: AppColors.primary, size: 18),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Inteligência Operacional',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.navy,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: isMobile ? 12 : 16),
              Row(
                children: [
                  _Metric(
                    value: fmtInt(data.anomaliasCriticas),
                    label: 'Anomalias críticas',
                    color: AppColors.red,
                  ),
                  const SizedBox(width: 10),
                  _Metric(
                    value: fmtInt(data.alertasAtivos),
                    label: 'Alertas ativos',
                    color: AppColors.orange,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  _Metric(
                    value: acuracia,
                    label: 'Acurácia do modelo',
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 10),
                  _Metric(
                    value: fmtInt(data.falsosPositivos),
                    label: 'Falsos positivos',
                    color: AppColors.primary,
                  ),
                ],
              ),
            ],
          ),
        );
      },
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
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
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
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.muted,
                fontSize: 10,
                height: 1.15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}