import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../core/formatters.dart';
import '../core/theme.dart';
import '../models/passageiros_overview.dart';

class DemandChart extends StatelessWidget {
  final List<DemandaPonto> serie;

  const DemandChart({super.key, required this.serie});

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).colorScheme;
    final escuro = Theme.of(context).brightness == Brightness.dark;

    final linha = escuro
        ? const Color(0xFF60A5FA)
        : const Color(0xFF0B5FB0);

    final alerta = escuro
        ? const Color(0xFFFCA5A5)
        : AppColors.red;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: cardDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'EVOLUÇÃO DIÁRIA DE DEMANDA',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: cores.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Volume de passageiros por data do relatório',
            style: TextStyle(
              fontSize: 11,
              color: cores.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              _legenda(context, linha, 'Volume'),
              _legenda(context, alerta, 'Anomalia sinalizada'),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: serie.isEmpty
                ? Center(
                    child: Text(
                      'Sem dados para o período selecionado',
                      style: TextStyle(color: cores.onSurfaceVariant),
                    ),
                  )
                : _chart(context, linha, alerta),
          ),
          const SizedBox(height: 10),
          Text(
            'Toque ou passe o mouse para consultar os valores.',
            style: TextStyle(
              fontSize: 10,
              color: cores.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _legenda(BuildContext context, Color cor, String texto) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.circle, size: 9, color: cor),
        const SizedBox(width: 6),
        Text(
          texto,
          style: TextStyle(
            fontSize: 10,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _chart(
    BuildContext context,
    Color linha,
    Color alerta,
  ) {
    final cores = Theme.of(context).colorScheme;
    final maior = serie.map((ponto) => ponto.volume).reduce(math.max);
    final intervaloX = serie.length <= 6
        ? 1.0
        : ((serie.length - 1) / 5).ceilToDouble();

    return LineChart(
      LineChartData(
        minX: 0,
        maxX: serie.length == 1 ? 1.0 : (serie.length - 1).toDouble(),
        minY: 0,
        maxY: maior <= 0 ? 1.0 : maior * 1.15,
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
              reservedSize: 46,
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
                    indice >= serie.length) {
                  return const SizedBox.shrink();
                }

                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    serie[indice].rotulo,
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
            maxContentWidth: 230,
            getTooltipItems: (pontos) {
              return pontos.map((ponto) {
                final dado = serie[ponto.x.round()];
                final detalhes = <String>[
                  dado.rotulo,
                  '${fmtInt(dado.volume)} passageiros',
                  if (dado.anomalia)
                    dado.titulo ?? 'Anomalia sinalizada',
                  if (dado.anomalia && (dado.detalhe?.isNotEmpty ?? false))
                    dado.detalhe!,
                ];

                return LineTooltipItem(
                  detalhes.join('\n'),
                  TextStyle(
                    fontSize: 11,
                    color: cores.onInverseSurface,
                  ),
                );
              }).toList();
            },
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: [
              for (var i = 0; i < serie.length; i++)
                FlSpot(i.toDouble(), serie[i].volume),
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
              checkToShowDot: (spot, _) =>
                  serie.length == 1 || serie[spot.x.toInt()].anomalia,
              getDotPainter: (spot, percent, bar, index) {
                final anomalia = serie[spot.x.toInt()].anomalia;

                return FlDotCirclePainter(
                  radius: anomalia ? 5 : 3,
                  color: anomalia ? alerta : linha,
                  strokeWidth: 2,
                  strokeColor: cores.surface,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}