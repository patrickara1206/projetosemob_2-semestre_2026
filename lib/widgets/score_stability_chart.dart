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
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Expanded(
                child: Text('ESTABILIDADE DO SCORE (7 DIAS)',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF374151))),
              ),
              Icon(Icons.more_vert, size: 18, color: AppColors.muted),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: serie.isEmpty
                ? const Center(
                    child: Text('Sem dados para o período selecionado',
                        style: TextStyle(color: AppColors.muted)))
                : _chart(),
          ),
        ],
      ),
    );
  }

  Widget _chart() {
    final n = serie.length;

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
              const FlLine(color: AppColors.border, strokeWidth: 1),
        ),
        titlesData: FlTitlesData(
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 32,
              interval: 0.2,
              getTitlesWidget: (v, meta) => Text(v.toStringAsFixed(1),
                  style: const TextStyle(fontSize: 10, color: AppColors.muted)),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              getTitlesWidget: (v, meta) {
                final i = v.toInt();
                if (i < 0 || i >= n) return const SizedBox();
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(serie[i].rotulo,
                      style: const TextStyle(
                          fontSize: 10, color: AppColors.muted)),
                );
              },
            ),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: [
              for (var i = 0; i < n; i++) FlSpot(i.toDouble(), serie[i].score)
            ],
            isCurved: false,
            color: _line,
            barWidth: 4,
            belowBarData: BarAreaData(
              show: true,
              color: _line.withValues(alpha: 0.06),
            ),
            dotData: FlDotData(
              show: true,
              checkToShowDot: (spot, _) => serie[spot.x.toInt()].destaque,
              getDotPainter: (spot, percent, bar, index) => FlDotCirclePainter(
                radius: 6,
                color: Colors.white,
                strokeWidth: 3,
                strokeColor: _line,
              ),
            ),
          ),
        ],
      ),
    );
  }
}