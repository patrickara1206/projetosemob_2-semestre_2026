import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../core/formatters.dart';
import '../core/theme.dart';

/// Perfil tarifário (rosca). Deve receber altura definida pelo pai.
class TariffDonut extends StatelessWidget {
  final double? pctPagantes; // 0 a 100

  const TariffDonut({super.key, required this.pctPagantes});

  static const _pagantes = Color(0xFF0B5FB0);
  static const _naoPagantes = Color(0xFFC5CAF5);

  @override
  Widget build(BuildContext context) {
    final p = pctPagantes?.clamp(0.0, 100.0).toDouble();
    final n = p == null ? null : 100 - p;

    return LayoutBuilder(
      builder: (context, box) {
        final isMobile = box.maxWidth < 500;
        final chartSize = isMobile ? 150.0 : 190.0;
        final radius = isMobile ? 22.0 : 28.0;
        final centerRadius = isMobile ? 48.0 : 62.0;

        return Container(
          padding: EdgeInsets.all(isMobile ? 14 : 20),
          decoration: cardDecoration(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'PERFIL TARIFÁRIO',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: isMobile ? 11 : 12,
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(
                    Icons.more_vert,
                    size: 18,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: chartSize,
                          height: chartSize,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              PieChart(
                                PieChartData(
                                  startDegreeOffset: -90,
                                  sectionsSpace: 0,
                                  centerSpaceRadius: centerRadius,
                                  sections: p == null
                                      ? [
                                          PieChartSectionData(
                                            value: 1,
                                            color: AppColors.border,
                                            radius: radius,
                                            showTitle: false,
                                          ),
                                        ]
                                      : [
                                          PieChartSectionData(
                                            value: p,
                                            color: _pagantes,
                                            radius: radius,
                                            showTitle: false,
                                          ),
                                          PieChartSectionData(
                                            value: n!,
                                            color: _naoPagantes,
                                            radius: radius,
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
                                    style: TextStyle(
                                      fontSize: isMobile ? 22 : 26,
                                      fontWeight: FontWeight.w800,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurface,
                                    ),
                                  ),
                                  Text(
                                    'PAGANTES',
                                    style: TextStyle(
                                      fontSize: isMobile ? 9 : 10,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: isMobile ? 14 : 20),
                        _LegendRow(
                          color: _pagantes,
                          label: 'Pagantes',
                          value: p == null ? '--' : '${fmtDec(p)}%',
                        ),
                        SizedBox(height: 8),
                        _LegendRow(
                          color: _naoPagantes,
                          label: 'Não Pagantes (Total)',
                          value: n == null ? '--' : '${fmtDec(n)}%',
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
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
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: 220),
      child: Row(
        children: [
          Icon(Icons.circle, size: 10, color: color),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          SizedBox(width: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
