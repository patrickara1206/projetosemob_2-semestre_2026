import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../models/dashboard_overview.dart';

class VolumeChart extends StatelessWidget {
  final List<SeriePonto> serie;

  const VolumeChart({
    super.key,
    required this.serie,
  });

  static const azul = Color(0xFF2563EB);
  static const laranja = Color(0xFFEA580C);
  static const texto = Color(0xFF64748B);

  String _numero(double valor) {
    return valor.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]}.',
    );
  }

  Widget _legenda(Color cor, String titulo) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 18,
          height: 4,
          decoration: BoxDecoration(
            color: cor,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          titulo,
          style: const TextStyle(
            fontSize: 12,
            color: texto,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalRealizado = serie.fold<double>(
      0,
      (total, ponto) => total + ponto.realizado,
    );

    final totalProgramado = serie.fold<double>(
      0,
      (total, ponto) => total + ponto.esperado,
    );

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Viagens realizadas e programadas',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Quantidade de viagens por dia',
            style: TextStyle(
              fontSize: 12,
              color: texto,
            ),
          ),
          if (serie.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'No período: ${_numero(totalRealizado)} realizadas'
                ' de ${_numero(totalProgramado)} programadas',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF334155),
                ),
              ),
            ),
          ],
          const SizedBox(height: 16),
          Wrap(
            spacing: 20,
            runSpacing: 8,
            children: [
              _legenda(azul, 'Realizadas'),
              _legenda(laranja, 'Programadas · tracejado'),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 280,
            child: serie.isEmpty
                ? const Center(
                    child: Text(
                      'Sem dados para o período selecionado',
                      style: TextStyle(color: texto),
                    ),
                  )
                : _buildChart(),
          ),
          const SizedBox(height: 12),
          const Text(
            'Passe o mouse ou toque em um dia para ver os valores.'
            ' Linhas sobrepostas indicam valores iguais ou próximos.',
            style: TextStyle(
              fontSize: 11,
              color: texto,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChart() {
    final realizados = <FlSpot>[];
    final programados = <FlSpot>[];
    double maiorValor = 0;

    for (var i = 0; i < serie.length; i++) {
      final ponto = serie[i];

      realizados.add(
        FlSpot(i.toDouble(), ponto.realizado),
      );

      programados.add(
        FlSpot(i.toDouble(), ponto.esperado),
      );

      if (ponto.realizado > maiorValor) {
        maiorValor = ponto.realizado;
      }

      if (ponto.esperado > maiorValor) {
        maiorValor = ponto.esperado;
      }
    }

    final intervaloY = maiorValor <= 10
        ? 2.0
        : maiorValor <= 100
            ? 20.0
            : maiorValor <= 500
                ? 100.0
                : (maiorValor / 5 / 100).ceil() * 100.0;

    final maxY = maiorValor == 0
        ? intervaloY * 5
        : (maiorValor / intervaloY).ceil() * intervaloY
            + intervaloY;

    final intervaloX = serie.length <= 6
        ? 1.0
        : ((serie.length - 1) / 5).ceilToDouble();

    return LineChart(
      LineChartData(
        minX: 0,
        maxX: serie.length == 1
            ? 1.0
            : (serie.length - 1).toDouble(),
        minY: 0,
        maxY: maxY,
        borderData: FlBorderData(show: false),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: intervaloY,
          getDrawingHorizontalLine: (_) => const FlLine(
            color: Color(0xFFE2E8F0),
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
              interval: intervaloY,
              reservedSize: 52,
              getTitlesWidget: (valor, meta) {
                return Text(
                  _numero(valor),
                  style: const TextStyle(
                    fontSize: 11,
                    color: texto,
                  ),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: intervaloX,
              reservedSize: 34,
              getTitlesWidget: (valor, meta) {
                final indice = valor.round();

                if ((valor - indice).abs() > 0.001 ||
                    indice < 0 ||
                    indice >= serie.length) {
                  return const SizedBox.shrink();
                }

                return Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(
                    serie[indice].rotulo,
                    style: const TextStyle(
                      fontSize: 11,
                      color: texto,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        lineTouchData: LineTouchData(
          enabled: true,
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => const Color(0xFF0F172A),
            fitInsideHorizontally: true,
            fitInsideVertically: true,
            maxContentWidth: 220,
            getTooltipItems: (pontos) {
              return pontos.map((ponto) {
                final indice = ponto.x.round();
                final titulo = ponto.barIndex == 0
                    ? 'Realizadas'
                    : 'Programadas';

                return LineTooltipItem(
                  '${serie[indice].rotulo}'
                  ' · $titulo: ${_numero(ponto.y)}',
                  const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                );
              }).toList();
            },
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: realizados,
            isCurved: false,
            color: azul,
            barWidth: 3,
            belowBarData: BarAreaData(
              show: true,
              color: azul.withOpacity(0.07),
            ),
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, bar, index) {
                return FlDotCirclePainter(
                  radius: 2.5,
                  color: azul,
                  strokeWidth: 1,
                  strokeColor: Colors.white,
                );
              },
            ),
          ),
          // Desenhada por cima para continuar visível
          // quando os valores coincidem com os realizados.
          LineChartBarData(
            spots: programados,
            isCurved: false,
            color: laranja,
            barWidth: 2,
            dashArray: [6, 5],
            dotData: const FlDotData(show: false),
          ),
        ],
      ),
    );
  }
}