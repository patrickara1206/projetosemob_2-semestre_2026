import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../core/formatters.dart';
import '../core/theme.dart';

class TariffDonut extends StatelessWidget {
  final double? pctPagantes;

  const TariffDonut({super.key, required this.pctPagantes});

  static const _pagantes = Color(0xFF0B5FB0);
  static const _naoPagantes = Color(0xFFC5CAF5);

  @override
  Widget build(BuildContext context) {
    final p = pctPagantes?.clamp(0.0, 100.0).toDouble();
    final n = p == null ? null : 100 - p;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Expanded(
                child: Text(
                  'PERFIL TARIFÁRIO',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF374151),
                  ),
                ),
              ),
              Icon(Icons.more_vert, size: 18, color: AppColors.muted),
            ],
          ),
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 190,
                    height: 190,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        PieChart(
                          PieChartData(
                            startDegreeOffset: -90,
                            sectionsSpace: 0,
                            centerSpaceRadius: 62,
                            sections: p == null
                                ? [
                                    PieChartSectionData(
                                      value: 1,
                                      color: AppColors.border,
                                      radius: 28,
                                      showTitle: false,
                                    ),
                                  ]
                                : [
                                    PieChartSectionData(
                                      value: p,
                                      color: _pagantes,
                                      radius: 28,
                                      showTitle: false,
                                    ),
                                    PieChartSectionData(
                                      value: n!,
                                      color: _naoPagantes,
                                      radius: 28,
                                      showTitle: false,
                                    ),
                                  ],
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              p == null ? '--' : '${p.round()}%',
                              style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                                color: AppColors.navy,
                              ),
                            ),
                            const Text(
                              'PAGANTES',
                              style: TextStyle(
                                fontSize: 10,
                                color: AppColors.muted,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  _LegendRow(
                    color: _pagantes,
                    label: 'Pagantes',
                    value: p == null ? '--' : '${fmtDec(p)}%',
                  ),
                  const SizedBox(height: 8),
                  _LegendRow(
                    color: _naoPagantes,
                    label: 'Não Pagantes (Total)',
                    value: n == null ? '--' : '${fmtDec(n)}%',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendRow extends StatelessWidget {
  final Color color;
  final String label;
  final String value;
  const _LegendRow({
    required this.color,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      child: Row(
        children: [
          Icon(Icons.circle, size: 10, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 12, color: Color(0xFF374151)),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.navy,
            ),
          ),
        ],
      ),
    );
  }
}
