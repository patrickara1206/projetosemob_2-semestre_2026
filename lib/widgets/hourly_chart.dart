import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../models/operacao_overview.dart';

class HourlyChart extends StatelessWidget {
  final List<ViagensHora> dados;

  const HourlyChart({super.key, required this.dados});

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: cardDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'RELAÇÃO VIAGENS / HORA DO DIA',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: cores.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: cores.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              'Média Dia Útil',
              style: TextStyle(
                fontSize: 10,
                color: cores.onSurfaceVariant,
              ),
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
                : _chart(context),
          ),
        ],
      ),
    );
  }

  Widget _chart(BuildContext context) {
    final cores = Theme.of(context).colorScheme;
    final escuro = Theme.of(context).brightness == Brightness.dark;
    final linha = escuro
        ? const Color(0xFF60A5FA)
        : const Color(0xFF0B5FB0);

    final intervalo = dados.length <= 6
        ? 1.0
        : (dados.length / 6).ceilToDouble();

    return LineChart(
      LineChartData(
        minX: 0,
        maxX: dados.length == 1 ? 1.0 : (dados.length - 1).toDouble(),
        minY: 0,
        borderData: FlBorderData(show: false),
        gridData: FlGridData(
          drawVerticalLine: false,
          getDrawingHorizontalLine: (_) => FlLine(
            color: cores.outlineVariant,
            strokeWidth: 1,
            dashArray: [4, 4],
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
              reservedSize: 42,
              getTitlesWidget: (valor, meta) => Text(
                '${valor.toInt()}',
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
              interval: intervalo,
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
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => cores.inverseSurface,
            fitInsideHorizontally: true,
            fitInsideVertically: true,
            getTooltipItems: (pontos) {
              return pontos.map((ponto) {
                final indice = ponto.x.round();

                return LineTooltipItem(
                  '${dados[indice].rotulo}\n'
                  '${ponto.y.toStringAsFixed(0)} viagens',
                  TextStyle(
                    color: cores.onInverseSurface,
                    fontSize: 12,
                  ),
                );
              }).toList();
            },
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: [
              for (var i = 0; i < dados.length; i++)
                FlSpot(i.toDouble(), dados[i].viagens),
            ],
            isCurved: false,
            color: linha,
            barWidth: 3,
            belowBarData: BarAreaData(
              show: true,
              color: linha.withValues(alpha: 0.08),
            ),
            dotData: FlDotData(
              show: true,
              checkToShowDot: (spot, _) => dados[spot.x.toInt()].pico,
              getDotPainter: (spot, percent, bar, index) {
                return FlDotCirclePainter(
                  radius: 5,
                  color: cores.surface,
                  strokeWidth: 2.5,
                  strokeColor: linha,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}