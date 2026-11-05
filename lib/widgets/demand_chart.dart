import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../models/passageiros_overview.dart';

/// Evolução diária de demanda.
/// Deve receber altura definida pelo pai (ex.: SizedBox).
class DemandChart extends StatelessWidget {
  final List<DemandaPonto> serie;

  const DemandChart({
    super.key,
    required this.serie,
  });

  static const _line = Color(0xFF0B5FB0);
  static const _leftReserved = 40.0;
  static const _bottomReserved = 28.0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, box) {
        final isMobile = box.maxWidth < 600;

        return Container(
          padding: EdgeInsets.all(
            isMobile ? 12 : 20,
          ),
          decoration: cardDecoration(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: double.infinity,
                child: Wrap(
                  alignment:
                      WrapAlignment.spaceBetween,
                  crossAxisAlignment:
                      WrapCrossAlignment.center,
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          'EVOLUÇÃO DIÁRIA DE DEMANDA',
                          style: TextStyle(
                            fontSize:
                                isMobile ? 11 : 12,
                            fontWeight:
                                FontWeight.w700,
                            color:
                                Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Volume de passageiros no período selecionado',
                          style: TextStyle(
                            fontSize: 10,
                            color:
                                Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    const _Legend(),
                  ],
                ),
              ),

              SizedBox(
                height: isMobile ? 10 : 16,
              ),

              Expanded(
                child: serie.isEmpty
                    ? Center(
                        child: Text(
                          'Sem dados para o período selecionado',
                          style: TextStyle(
                            color:
                                Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                          ),
                        ),
                      )
                    : _buildChart(isMobile),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildChart(bool isMobile) {
    return LayoutBuilder(
      builder: (context, box) {
        final n = serie.length;

        final maxVol =
            serie.map((e) => e.volume).reduce(math.max);

        final maxY =
            maxVol <= 0
                ? 1.0
                : maxVol * 1.15;

        final interval =
            isMobile
                ? (
                    n <= 4
                        ? 1.0
                        : (n / 3).ceilToDouble()
                  )
                : (
                    n <= 6
                        ? 1.0
                        : (n / 6).ceilToDouble()
                  );

        final spots = [
          for (var i = 0; i < n; i++)
            FlSpot(
              i.toDouble(),
              serie[i].volume,
            ),
        ];

        return LineChart(
          LineChartData(
            minX: 0,
            maxX: (n - 1).toDouble(),
            minY: 0,
            maxY: maxY,

            borderData: FlBorderData(
              show: false,
            ),

            gridData: FlGridData(
              drawVerticalLine: false,
              getDrawingHorizontalLine:
                  (_) => FlLine(
                    color: AppColors.border,
                    strokeWidth: 1,
                  ),
            ),

            titlesData: FlTitlesData(
              topTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: false,
                ),
              ),

              rightTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: false,
                ),
              ),

              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: _leftReserved,
                  getTitlesWidget: (
                    v,
                    meta,
                  ) {
                    final k = v / 1000;

                    final txt =
                        v == 0
                            ? '0'
                            : '${k == k.roundToDouble() ? k.toInt() : k.toStringAsFixed(1)}k';

                    return Text(
                      txt,
                      style: TextStyle(
                        fontSize: 9,
                        color:
                            Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant,
                      ),
                    );
                  },
                ),
              ),

              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: _bottomReserved,
                  interval: interval,
                  getTitlesWidget: (
                    v,
                    meta,
                  ) {
                    final i = v.toInt();

                    if (
                      i < 0
                      || i >= n
                    ) {
                      return const SizedBox();
                    }

                    return Padding(
                      padding:
                          const EdgeInsets.only(
                        top: 8,
                      ),
                      child: Text(
                        serie[i].rotulo,
                        style: TextStyle(
                          fontSize: 9,
                          color:
                              Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            lineBarsData: [
              LineChartBarData(
                spots: spots,
                isCurved: true,
                color: _line,
                barWidth:
                    isMobile ? 3 : 5,

                belowBarData: BarAreaData(
                  show: true,
                  color:
                      _line.withOpacity(
                    0.06,
                  ),
                ),

                dotData: FlDotData(
                  show: false,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend();

  @override
  Widget build(BuildContext context) {
    Widget item(
      Color color,
      String texto,
    ) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.circle,
            size: 8,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            texto,
            style: TextStyle(
              fontSize: 10,
              color:
                  Theme.of(context)
                      .colorScheme
                      .onSurfaceVariant,
            ),
          ),
        ],
      );
    }

    return Wrap(
      spacing: 12,
      runSpacing: 4,
      children: [
        item(
          const Color(0xFF0B5FB0),
          'Volume',
        ),
      ],
    );
  }
}