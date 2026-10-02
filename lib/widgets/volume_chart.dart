import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../models/dashboard_overview.dart';

class VolumeChart extends StatelessWidget {
  final List<SeriePonto> serie;
  const VolumeChart({super.key, required this.serie});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('VIAGENS REALIZADAS E PROGRAMADAS',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF374151))),
                    SizedBox(height: 2),
                    Text('Série temporal com detecção de anomalias',
                        style:
                            TextStyle(fontSize: 11, color: AppColors.muted)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Align(alignment: Alignment.centerRight, child: _Legend()),
          const SizedBox(height: 8),
          SizedBox(
            height: 320,
            child: serie.isEmpty
                ? const Center(
                    child: Text('Sem dados para o período selecionado',
                        style: TextStyle(color: AppColors.muted)))
                : _buildChart(),
          ),
        ],
      ),
    );
  }

  Widget _buildChart() {
    final realizado = <FlSpot>[];
    final esperado = <FlSpot>[];
    for (var i = 0; i < serie.length; i++) {
      realizado.add(FlSpot(i.toDouble(), serie[i].realizado));
      esperado.add(FlSpot(i.toDouble(), serie[i].esperado));
    }
    final interval = serie.length <= 6 ? 1.0 : (serie.length / 6).ceilToDouble();

    return LineChart(
      LineChartData(
        minY: 0,
        borderData: FlBorderData(show: false),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (_) =>
              const FlLine(color: AppColors.border, strokeWidth: 1),
        ),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 44,
              getTitlesWidget: (v, meta) => Text(
                v >= 1000 ? '${(v / 1000).toStringAsFixed(1)}k' : '${v.toInt()}',
                style: const TextStyle(fontSize: 10, color: AppColors.muted),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: interval,
              getTitlesWidget: (v, meta) {
                final i = v.toInt();
                if (i < 0 || i >= serie.length) return const SizedBox();
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
          // Esperado (modelo)
          LineChartBarData(
            spots: esperado,
            isCurved: true,
            color: const Color(0xFFB0B7C3),
            barWidth: 1.5,
            dashArray: [6, 4],
            dotData: const FlDotData(show: false),
          ),
          // Realizado + pontos de anomalia
          LineChartBarData(
            spots: realizado,
            isCurved: true,
            color: AppColors.navy,
            barWidth: 3,
            belowBarData: BarAreaData(
              show: true,
              color: AppColors.navy.withValues(alpha:0.04),
            ),
            dotData: FlDotData(
              show: true,
              checkToShowDot: (spot, _) => serie[spot.x.toInt()].anomalia,
              getDotPainter: (spot, percent, bar, index) =>
                  FlDotCirclePainter(
                radius: 5,
                color: AppColors.red,
                strokeWidth: 2,
                strokeColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend();

  @override
  Widget build(BuildContext context) {
    Widget item(Widget mark, String text) => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            mark,
            const SizedBox(width: 6),
            Text(text,
                style: const TextStyle(fontSize: 10, color: Color(0xFF374151))),
            const SizedBox(width: 14),
          ],
        );

    return Wrap(
      children: [
        item(Container(width: 16, height: 3, color: AppColors.navy),
            'REALIZADO'),
        item(Container(width: 16, height: 2, color: const Color(0xFFB0B7C3)),
            'PROGRAMADO'),
        item(
            const Icon(Icons.circle, size: 8, color: AppColors.red), 'ANOMALIA'),
      ],
    );
  }
}
