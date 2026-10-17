import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../core/formatters.dart';
import '../core/theme.dart';

class TariffDonut extends StatelessWidget {
  final double? pctPagantes;

  const TariffDonut({super.key, required this.pctPagantes});

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).colorScheme;
    final escuro = Theme.of(context).brightness == Brightness.dark;

    final pagantes = escuro
        ? const Color(0xFF60A5FA)
        : const Color(0xFF0B5FB0);

    final naoPagantes = escuro
        ? const Color(0xFFA5B4FC)
        : const Color(0xFFC5CAF5);

    final percentual = pctPagantes?.clamp(0.0, 100.0).toDouble();
    final restante = percentual == null ? null : 100 - percentual;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: cardDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'PERFIL TARIFÁRIO',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: cores.onSurface,
                  ),
                ),
              ),
              Icon(
                Icons.more_vert,
                size: 18,
                color: cores.onSurfaceVariant,
              ),
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
                            sectionsSpace: 2,
                            centerSpaceRadius: 62,
                            sections: percentual == null
                                ? [
                                    PieChartSectionData(
                                      value: 1,
                                      color: cores.outlineVariant,
                                      radius: 28,
                                      showTitle: false,
                                    ),
                                  ]
                                : [
                                    PieChartSectionData(
                                      value: percentual,
                                      color: pagantes,
                                      radius: 28,
                                      showTitle: false,
                                    ),
                                    PieChartSectionData(
                                      value: restante!,
                                      color: naoPagantes,
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
                              percentual == null
                                  ? '--'
                                  : '${percentual.round()}%',
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                                color: cores.onSurface,
                              ),
                            ),
                            Text(
                              'PAGANTES',
                              style: TextStyle(
                                fontSize: 10,
                                color: cores.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  _LegendRow(
                    color: pagantes,
                    label: 'Pagantes',
                    value: percentual == null
                        ? '--'
                        : '${fmtDec(percentual)}%',
                  ),
                  const SizedBox(height: 10),
                  _LegendRow(
                    color: naoPagantes,
                    label: 'Não Pagantes (Total)',
                    value: restante == null
                        ? '--'
                        : '${fmtDec(restante)}%',
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
    final cores = Theme.of(context).colorScheme;

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 260),
      child: Row(
        children: [
          Icon(Icons.circle, size: 10, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: cores.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: cores.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}