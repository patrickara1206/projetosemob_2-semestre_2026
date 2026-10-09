import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../models/operacao_overview.dart';

class HourlyChart extends StatelessWidget {
  final List<ViagensHora> dados;
  const HourlyChart({super.key, required this.dados});

  static const _line = Color(0xFF0B5FB0);

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
                child: Text(
                  'RELAÇÃO VIAGENS / HORA DO DIA',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF374151),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F3F6),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'Média Dia Útil',
                  style: TextStyle(fontSize: 10, color: AppColors.muted),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 290,
            child: dados.isEmpty
                ? const Center(
                    child: Text(
                      'Sem dados para o período selecionado',
                      style: TextStyle(color: AppColors.muted),
                    ),
                  )
                : _chart(),
          ),
        ],
      ),
    );
  }

  Widget _chart() {
    final spots = [
      for (var i = 0; i < dados.length; i++)
        FlSpot(i.toDouble(), dados[i].viagens),
    ];
    final interval = dados.length <= 6
        ? 1.0
        : (dados.length / 6).ceilToDouble();

    return LineChart(
      LineChartData(
        minY: 0,
        borderData: FlBorderData(show: false),
        gridData: FlGridData(
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
              reservedSize: 36,
              getTitlesWidget: (v, meta) => Text(
                '${v.toInt()}',
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
                if (i < 0 || i >= dados.length) return const SizedBox();
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    dados[i].rotulo,
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
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: _line,
            barWidth: 5,
            belowBarData: BarAreaData(
              show: true,
              color: _line.withValues(alpha: 0.06),
            ),
            dotData: FlDotData(
              show: true,
              checkToShowDot: (spot, _) => dados[spot.x.toInt()].pico,
              getDotPainter: (spot, percent, bar, index) => FlDotCirclePainter(
                radius: 5,
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
