import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../core/theme.dart';
import 'chart_summary.dart';
import '../core/formatters.dart';
import '../models/dashboard_overview.dart';

class VolumeChart extends StatelessWidget {
  final List<SeriePonto> serie;
  const VolumeChart({super.key, required this.serie});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
    final total = serie.fold<double>(0, (sum, p) => sum + p.realizado);
    final planned = serie.fold<double>(0, (sum, p) => sum + p.esperado);
    final execution = planned > 0 ? total / planned * 100 : null;
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
                    Text(
                      'VIAGENS REALIZADAS E PROGRAMADAS',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF374151),
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Evolução diária • passe o mouse para ver os valores',
                      style: TextStyle(fontSize: 11, color: AppColors.muted),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (serie.isNotEmpty)
            ChartSummary(items: [
              (label: 'Realizadas', value: fmtInt(total)),
              (label: 'Programadas', value: fmtInt(planned)),
              (label: 'Execução', value: execution == null ? '—' : '${fmtDec(execution)}%'),
            ]),
          const SizedBox(height: 8),
          Align(alignment: Alignment.centerRight, child: _Legend(showAnomaly: serie.any((p) => p.anomalia))),
          const SizedBox(height: 8),
          SizedBox(
            height: constraints.maxWidth < 500 ? 190 : 280,
            child: serie.isEmpty
                ? const Center(
                    child: Text(
                      'Sem dados para o período selecionado',
                      style: TextStyle(color: AppColors.muted),
                    ),
                  )
                : _buildChart(),
          ),
        ],
      ),
    );
    });
  }

  Widget _buildChart() {
    final realizado = <FlSpot>[];
    final esperado = <FlSpot>[];
    for (var i = 0; i < serie.length; i++) {
      realizado.add(FlSpot(i.toDouble(), serie[i].realizado));
      esperado.add(FlSpot(i.toDouble(), serie[i].esperado));
    }
    final interval = serie.length <= 6
        ? 1.0
        : (serie.length / 6).ceilToDouble();

    return LineChart(
      LineChartData(
        minX: 0,
        maxX: serie.length <= 1 ? 1 : (serie.length - 1).toDouble(),
        minY: 0,
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            fitInsideHorizontally: true,
            fitInsideVertically: true,
            getTooltipItems: (spots) => spots.map((spot) {
              final index = spot.x.round().clamp(0, serie.length - 1);
              final label = serie[index].rotulo;
              final seriesLabel = spot.barIndex == 0
                  ? 'Programado: '
                  : 'Realizado: ';
              return LineTooltipItem(
                '$label\n$seriesLabel${fmtInt(spot.y)} viagens',
                const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              );
            }).toList(),
          ),
        ),

        borderData: FlBorderData(show: false),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (_) =>
              const FlLine(color: AppColors.border, strokeWidth: 1),
        ),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 44,
              maxIncluded: false,
              getTitlesWidget: (v, meta) => Text(
                fmtCompact(v),
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
                  child: Text(
                    serie[i].rotulo,
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.muted,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        lineBarsData: [
          // Esperado (modelo)
          LineChartBarData(
            spots: esperado,
            isCurved: false,
            color: const Color(0xFF64748B),
            barWidth: 2,
            dashArray: [6, 4],
            dotData: const FlDotData(show: false),
          ),
          // Realizado + pontos de anomalia
          LineChartBarData(
            spots: realizado,
            isCurved: false,
            color: AppColors.navy,
            barWidth: 3,
            belowBarData: BarAreaData(
              show: true,
              color: AppColors.navy.withValues(alpha: 0.04),
            ),
            dotData: FlDotData(
              show: true,
              checkToShowDot: (spot, _) =>
                  serie.length == 1 || serie[spot.x.toInt()].anomalia,
              getDotPainter: (spot, percent, bar, index) => FlDotCirclePainter(
                radius: 5,
                color: serie[spot.x.toInt()].anomalia ? AppColors.red : AppColors.navy,
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
  final bool showAnomaly;
  const _Legend({required this.showAnomaly});

  @override
  Widget build(BuildContext context) {
    Widget item(Widget mark, String text) => Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        mark,
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(fontSize: 10, color: Color(0xFF374151)),
        ),
        const SizedBox(width: 14),
      ],
    );

    return Wrap(
      children: [
        item(
          Container(width: 16, height: 3, color: AppColors.navy),
          'REALIZADO',
        ),
        item(
          Container(width: 16, height: 2, color: const Color(0xFF64748B)),
          'PROGRAMADO',
        ),
        if (showAnomaly) item(
          const Icon(Icons.circle, size: 8, color: AppColors.red),
          'ANOMALIA',
        ),
      ],
    );
  }
}
