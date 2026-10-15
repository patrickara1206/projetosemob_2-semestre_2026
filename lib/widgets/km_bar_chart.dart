import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../models/operacao_overview.dart';

class KmBarChart extends StatelessWidget {
  final List<KmMes> dados;

  const KmBarChart({super.key, required this.dados});

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).colorScheme;
    final escuro = Theme.of(context).brightness == Brightness.dark;
    final produtiva = escuro
        ? const Color(0xFF60A5FA)
        : AppColors.navy;
    final morta = escuro
        ? const Color(0xFF67E8F9)
        : AppColors.cyan;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: cardDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'QUILOMETRAGEM PRODUTIVA E MORTA',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: cores.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 290,
            child: dados.isEmpty
                ? Center(
                    child: Text(
                      'Sem dados para o período selecionado',
                      style: TextStyle(color: cores.onSurfaceVariant),
                    ),
                  )
                : _chart(context, produtiva, morta),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 20,
            runSpacing: 8,
            children: [
              _Dot(color: produtiva, label: 'Produtiva'),
              _Dot(color: morta, label: 'Morta'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _chart(
    BuildContext context,
    Color produtiva,
    Color morta,
  ) {
    final cores = Theme.of(context).colorScheme;

    final maxTotal = dados
        .map((dia) => dia.produtiva + dia.morta)
        .reduce((a, b) => a > b ? a : b);

    final intervaloX = dados.length <= 6
        ? 1.0
        : (dados.length / 6).ceilToDouble();

    return BarChart(
      BarChartData(
        minY: 0,
        maxY: maxTotal <= 0 ? 1.0 : maxTotal * 1.15,
        alignment: BarChartAlignment.spaceAround,
        borderData: FlBorderData(show: false),
        gridData: FlGridData(
          drawVerticalLine: false,
          getDrawingHorizontalLine: (_) => FlLine(
            color: cores.outlineVariant,
            strokeWidth: 1,
            dashArray: [4, 4],
          ),
        ),
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (_) => cores.inverseSurface,
            fitInsideHorizontally: true,
            fitInsideVertically: true,
            getTooltipItem: (grupo, indiceGrupo, barra, indiceBarra) {
              final dia = dados[grupo.x];

              return BarTooltipItem(
                '${dia.rotulo}\n'
                'Produtiva: ${dia.produtiva.toStringAsFixed(1)} km\n'
                'Morta: ${dia.morta.toStringAsFixed(1)} km',
                TextStyle(
                  color: cores.onInverseSurface,
                  fontSize: 11,
                ),
              );
            },
          ),
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
              getTitlesWidget: (valor, meta) => Text(
                valor >= 1000
                    ? '${(valor / 1000).toStringAsFixed(1)}k'
                    : '${valor.toInt()}',
                style: TextStyle(
                  fontSize: 10,
                  color: cores.onSurfaceVariant,
                ),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: intervaloX,
              reservedSize: 32,
              getTitlesWidget: (valor, meta) {
                final indice = valor.round();

                if ((valor - indice).abs() > 0.001 ||
                    indice < 0 ||
                    indice >= dados.length) {
                  return const SizedBox.shrink();
                }

                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    dados[indice].rotulo,
                    style: TextStyle(
                      fontSize: 10,
                      color: cores.onSurfaceVariant,
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
                  width: dados.length > 12 ? 8 : 22,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(3),
                  ),
                  rodStackItems: [
                    BarChartRodStackItem(
                      0,
                      dados[i].produtiva,
                      produtiva,
                    ),
                    BarChartRodStackItem(
                      dados[i].produtiva,
                      dados[i].produtiva + dados[i].morta,
                      morta,
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
        Icon(Icons.circle, size: 9, color: color),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}