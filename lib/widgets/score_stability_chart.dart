import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../models/ml_overview.dart';

/// Estabilidade do score (7 dias). Deve receber altura definida pelo pai.
class ScoreStabilityChart extends StatelessWidget {
  final List<ScoreDia> serie;
  const ScoreStabilityChart({super.key, required this.serie});

  static const _line = Color(0xFF0B5FB0);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, box) {
        final isMobile = box.maxWidth < 500;

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
                      'ESTABILIDADE DO SCORE (7 DIAS)',
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
              SizedBox(height: isMobile ? 12 : 16),
              Expanded(
                child: serie.isEmpty
                    ? Center(
                        child: Text(
                          'Sem dados para o período selecionado',
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      )
                    : _chart(context, isMobile),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _chart(BuildContext context, bool isMobile) {
    final n = serie.length;
    final interval = isMobile ? (n > 5 ? 2.0 : 1.0) : 1.0;

    return LineChart(
      LineChartData(
        minX: 0,
        maxX: n > 1 ? (n - 1).toDouble() : 1,
        minY: 0.4,
        maxY: 1.0,
        borderData: FlBorderData(show: false),
        gridData: FlGridData(
          drawVerticalLine: false,
          horizontalInterval: 0.2,
          getDrawingHorizontalLine: (_) =>
              FlLine(color: AppColors.border, strokeWidth: 1),
        ),
        titlesData: FlTitlesData(
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: isMobile ? 26 : 32,
              interval: 0.2,
              getTitlesWidget: (v, meta) => Text(
                v.toStringAsFixed(1),
                style: TextStyle(
                  fontSize: 9,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: interval,
              reservedSize: 26,
              getTitlesWidget: (v, meta) {
                final i = v.toInt();
                if (i < 0 || i >= n) return SizedBox();
                return Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Text(
                    serie[i].rotulo,
                    style: TextStyle(
                      fontSize: 9,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: [
              for (var i = 0; i < n; i++) FlSpot(i.toDouble(), serie[i].score),
            ],
            isCurved: false,
            color: _line,
            barWidth: isMobile ? 3 : 4,
            belowBarData: BarAreaData(
              show: true,
              color: _line.withOpacity(0.06),
            ),
            dotData: FlDotData(
              show: true,
              checkToShowDot: (spot, _) => serie[spot.x.toInt()].destaque,
              getDotPainter: (spot, percent, bar, index) => FlDotCirclePainter(
                radius: isMobile ? 4 : 6,
                color: Colors.white,
                strokeWidth: 2.5,
                strokeColor: _line,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
