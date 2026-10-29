import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../models/operacao_overview.dart';

class KmBarChart extends StatelessWidget {
  final List<KmMes> dados;
  const KmBarChart({super.key, required this.dados});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, box) {
        final isMobile = box.maxWidth < 600;

        return Container(
          padding: EdgeInsets.all(isMobile ? 14 : 20),
          decoration: cardDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'EVOLUÇÃO DA QUILOMETRAGEM MENSAL',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: isMobile ? 11 : 12,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF374151),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.more_vert, size: 20),
                    onPressed: () {},
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: isMobile ? 220 : 260,
                child: dados.isEmpty
                    ? const Center(
                        child: Text(
                          'Sem dados para o período selecionado',
                          style: TextStyle(color: AppColors.muted),
                        ),
                      )
                    : _chart(isMobile),
              ),
              SizedBox(height: isMobile ? 8 : 12),
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
      },
    );
  }

  Widget _chart(bool isMobile) {
    final maxTotal = dados
        .map((d) => d.produtiva + d.morta)
        .reduce((a, b) => a > b ? a : b);

    final rodWidth = isMobile ? (dados.length > 6 ? 14.0 : 18.0) : 26.0;

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
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: isMobile ? 34 : 44,
              getTitlesWidget: (v, meta) => Text(
                v >= 1000 ? '${(v / 1000).round()}k' : '${v.toInt()}',
                style: const TextStyle(fontSize: 9, color: AppColors.muted),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 24,
              getTitlesWidget: (v, meta) {
                final i = v.toInt();
                if (i < 0 || i >= dados.length) return const SizedBox();
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    dados[i].rotulo,
                    style: const TextStyle(
                      fontSize: 9,
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
                  width: rodWidth,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(3)),
                  rodStackItems: [
                    BarChartRodStackItem(
                      0,
                      dados[i].produtiva,
                      AppColors.navy,
                    ),
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
      mainAxisSize: MainAxisSize.min,
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