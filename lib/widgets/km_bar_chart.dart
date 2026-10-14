import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../models/operacao_overview.dart';

class KmBarChart extends StatelessWidget {
  final List<KmMes> dados;
  const KmBarChart({super.key, required this.dados});

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
                  'EVOLUÇÃO DA QUILOMETRAGEM MENSAL',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF374151),
                  ),
                ),
              ),
              IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 260,
            child: dados.isEmpty
                ? const Center(
                    child: Text(
                      'Sem dados para o período selecionado',
                      style: TextStyle(color: AppColors.muted),
                    ),
                  )
                : _chart(),
          ),
          const SizedBox(height: 12),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _Dot(color: AppColors.navy, label: 'Produtiva'),
              SizedBox(width: 20),
              _Dot(color: AppColors.cyan, label: 'Morta'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _chart() {
    final maxTotal = dados
        .map((d) => d.produtiva + d.morta)
        .reduce((a, b) => a > b ? a : b);

    return BarChart(
      BarChartData(
        maxY: maxTotal == 0 ? 1 : maxTotal * 1.15,
        alignment: BarChartAlignment.spaceAround,
        borderData: FlBorderData(show: false),
        barTouchData: BarTouchData(enabled: true),
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
              reservedSize: 44,
              getTitlesWidget: (v, meta) => Text(
                v >= 1000 ? '${(v / 1000).round()}k' : '${v.toInt()}',
                style: const TextStyle(fontSize: 10, color: AppColors.muted),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
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
        barGroups: [
          for (var i = 0; i < dados.length; i++)
            BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: dados[i].produtiva + dados[i].morta,
                  width: 26,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(3),
                  ),
                  rodStackItems: [
                    BarChartRodStackItem(0, dados[i].produtiva, AppColors.navy),
                    BarChartRodStackItem(
                      dados[i].produtiva,
                      dados[i].produtiva + dados[i].morta,
                      AppColors.cyan,
                    ),
                  ],
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  final Color color;
  final String label;
  const _Dot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.circle, size: 8, color: color),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Color(0xFF374151)),
        ),
      ],
    );
  }
}
