import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../core/formatters.dart';
import '../core/theme.dart';
import '../models/financeiro_overview.dart';

/// Evolução: Receita vs. Subsídio. Deve receber altura definida pelo pai.
class RevenueSubsidyChart extends StatelessWidget {
  final List<FinPonto> serie;
  const RevenueSubsidyChart({super.key, required this.serie});

  static const _blue = Color(0xFF0B5FB0);
  static const _lightBlue = Color(0xFF5B9BE0);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: double.infinity,
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 12,
              runSpacing: 8,
              children: const [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Evolução: Receita vs. Subsídio',
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: AppColors.navy)),
                    SizedBox(height: 2),
                    Text('Demonstrativo comparativo dos últimos 6 meses',
                        style:
                            TextStyle(fontSize: 11, color: AppColors.muted)),
                  ],
                ),
                _Legend(),
              ],
            ),
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
    final maxVal = serie
        .map((p) => math.max(p.receita, p.subsidio))
        .reduce(math.max);

    // Passos de R$ 500 mil no eixo Y
    final raw = maxVal * 1.1 / 4;
    final k = math.max(1, (raw / 500000).ceil());
    final step = k * 500000.0;
    final maxY = step * 4;

    return LineChart(
      LineChartData(
        minX: 0,
        maxX: n > 1 ? (n - 1).toDouble() : 1,
        minY: 0,
        maxY: maxY,
        borderData: FlBorderData(show: false),
        gridData: FlGridData(
          drawVerticalLine: false,
          horizontalInterval: step,
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
              reservedSize: 60,
              interval: step,
              getTitlesWidget: (v, meta) => Text(
                v == 0 ? 'R\$ 0' : 'R\$ ${fmtDec(v / 1000000)}M',
                style: const TextStyle(fontSize: 10, color: AppColors.muted),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              interval: 1,
              getTitlesWidget: (v, meta) {
                final i = v.toInt();
                if (i < 0 || i >= n) return const SizedBox();
                final atual = serie[i].atual;
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(serie[i].rotulo,
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight:
                              atual ? FontWeight.w800 : FontWeight.w400,
                          color: atual ? AppColors.navy : AppColors.muted)),
                );
              },
            ),
          ),
        ),
        lineBarsData: [
          // Subsídio (tracejada, pontos vazados)
          LineChartBarData(
            spots: [
              for (var i = 0; i < n; i++) FlSpot(i.toDouble(), serie[i].subsidio)
            ],
            isCurved: false,
            color: _lightBlue,
            barWidth: 2,
            dashArray: [5, 4],
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, bar, index) => FlDotCirclePainter(
                radius: 3.5,
                color: Colors.white,
                strokeWidth: 2,
                strokeColor: _lightBlue,
              ),
            ),
          ),
          // Receita (sólida)
          LineChartBarData(
            spots: [
              for (var i = 0; i < n; i++) FlSpot(i.toDouble(), serie[i].receita)
            ],
            isCurved: false,
            color: _blue,
            barWidth: 2.5,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, bar, index) => FlDotCirclePainter(
                radius: 4,
                color: _blue,
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
    Widget item(Widget mark, String t) => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            mark,
            const SizedBox(width: 6),
            Text(t,
                style:
                    const TextStyle(fontSize: 10, color: Color(0xFF374151))),
          ],
        );

    return Wrap(
      spacing: 14,
      children: [
        item(
            const Icon(Icons.circle, size: 9, color: Color(0xFF0B5FB0)),
            'Receita Tarifária'),
        item(
            Container(
              width: 9,
              height: 9,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF5B9BE0), width: 1.5),
              ),
            ),
            'Subsídio Municipal'),
      ],
    );
  }
}