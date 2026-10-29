import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../core/formatters.dart';
import '../core/theme.dart';
import '../models/operacao_overview.dart';

class KmBarChart extends StatelessWidget {
  final List<KmMes> dados;

  const KmBarChart({
    super.key,
    required this.dados,
  });

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).colorScheme;

    final escuro =
        Theme.of(context).brightness == Brightness.dark;

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

          const SizedBox(height: 6),

          Text(
            'Comparativo da quilometragem por tipo de operação',
            style: TextStyle(
              fontSize: 11,
              color: cores.onSurfaceVariant,
            ),
          ),

          const SizedBox(height: 20),

          SizedBox(
            height: 285,
            child: dados.isEmpty
                ? Center(
                    child: Text(
                      'Sem dados para o período selecionado',
                      style: TextStyle(
                        color: cores.onSurfaceVariant,
                      ),
                    ),
                  )
                : dados.length == 1
                    ? _comparativoPeriodo(
                        context,
                        produtiva,
                        morta,
                      )
                    : _comparativoMeses(
                        context,
                        produtiva,
                        morta,
                      ),
          ),
        ],
      ),
    );
  }

  Widget _comparativoPeriodo(
    BuildContext context,
    Color produtiva,
    Color morta,
  ) {
    final cores = Theme.of(context).colorScheme;

    final item = dados.first;

    final maior = item.produtiva > item.morta
        ? item.produtiva
        : item.morta;

    final maxY = maior <= 0
        ? 1.0
        : maior * 1.12;

    return BarChart(
      BarChartData(
        minY: 0,
        maxY: maxY,
        alignment: BarChartAlignment.spaceAround,

        borderData: FlBorderData(
          show: false,
        ),

        gridData: FlGridData(
          drawVerticalLine: false,
          getDrawingHorizontalLine: (_) {
            return FlLine(
              color: cores.outlineVariant,
              strokeWidth: 1,
              dashArray: [4, 4],
            );
          },
        ),

        titlesData: FlTitlesData(
          topTitles: const AxisTitles(
            sideTitles: SideTitles(
              showTitles: false,
            ),
          ),

          rightTitles: const AxisTitles(
            sideTitles: SideTitles(
              showTitles: false,
            ),
          ),

          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 48,
              getTitlesWidget: (
                valor,
                meta,
              ) {
                return Text(
                  valor >= 1000
                      ? '${(valor / 1000).toStringAsFixed(0)}k'
                      : valor.toInt().toString(),
                  style: TextStyle(
                    fontSize: 10,
                    color: cores.onSurfaceVariant,
                  ),
                );
              },
            ),
          ),

          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 34,
              getTitlesWidget: (
                valor,
                meta,
              ) {
                if (valor == 0) {
                  return Padding(
                    padding:
                        const EdgeInsets.only(top: 8),
                    child: Text(
                      'Produtiva',
                      style: TextStyle(
                        fontSize: 11,
                        color:
                            cores.onSurfaceVariant,
                      ),
                    ),
                  );
                }

                if (valor == 1) {
                  return Padding(
                    padding:
                        const EdgeInsets.only(top: 8),
                    child: Text(
                      'Morta',
                      style: TextStyle(
                        fontSize: 11,
                        color:
                            cores.onSurfaceVariant,
                      ),
                    ),
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ),

        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData:
              BarTouchTooltipData(
            getTooltipColor:
                (_) => cores.inverseSurface,

            fitInsideHorizontally: true,
            fitInsideVertically: true,

            getTooltipItem: (
              grupo,
              grupoIndex,
              barra,
              barraIndex,
            ) {
              final produtivaSelecionada =
                  grupo.x == 0;

              final valor =
                  produtivaSelecionada
                      ? item.produtiva
                      : item.morta;

              final nome =
                  produtivaSelecionada
                      ? 'Produtiva'
                      : 'Morta';

              return BarTooltipItem(
                '$nome\n${fmtInt(valor)} km',
                TextStyle(
                  color:
                      cores.onInverseSurface,
                  fontSize: 11,
                ),
              );
            },
          ),
        ),

        barGroups: [
          BarChartGroupData(
            x: 0,
            barRods: [
              BarChartRodData(
                toY: item.produtiva,
                width: 70,
                color: produtiva,
                borderRadius:
                    const BorderRadius.vertical(
                  top: Radius.circular(6),
                ),
              ),
            ],
          ),

          BarChartGroupData(
            x: 1,
            barRods: [
              BarChartRodData(
                toY: item.morta,
                width: 70,
                color: morta,
                borderRadius:
                    const BorderRadius.vertical(
                  top: Radius.circular(6),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _comparativoMeses(
    BuildContext context,
    Color produtiva,
    Color morta,
  ) {
    final cores = Theme.of(context).colorScheme;

    final maiorValor = dados
        .expand(
          (item) => [
            item.produtiva,
            item.morta,
          ],
        )
        .reduce(
          (a, b) => a > b ? a : b,
        );

    final maxY = maiorValor <= 0
        ? 1.0
        : maiorValor * 1.12;

    final intervaloX = dados.length <= 6
        ? 1.0
        : (dados.length / 6)
            .ceilToDouble();

    return BarChart(
      BarChartData(
        minY: 0,
        maxY: maxY,

        alignment:
            BarChartAlignment.spaceAround,

        borderData: FlBorderData(
          show: false,
        ),

        gridData: FlGridData(
          drawVerticalLine: false,
          getDrawingHorizontalLine: (_) {
            return FlLine(
              color: cores.outlineVariant,
              strokeWidth: 1,
              dashArray: [4, 4],
            );
          },
        ),

        titlesData: FlTitlesData(
          topTitles: const AxisTitles(
            sideTitles: SideTitles(
              showTitles: false,
            ),
          ),

          rightTitles: const AxisTitles(
            sideTitles: SideTitles(
              showTitles: false,
            ),
          ),

          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 48,
              getTitlesWidget: (
                valor,
                meta,
              ) {
                return Text(
                  valor >= 1000
                      ? '${(valor / 1000).toStringAsFixed(0)}k'
                      : valor.toInt().toString(),
                  style: TextStyle(
                    fontSize: 10,
                    color:
                        cores.onSurfaceVariant,
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
              getTitlesWidget: (
                valor,
                meta,
              ) {
                final indice =
                    valor.round();

                if (
                  (valor - indice).abs() >
                      0.001
                  || indice < 0
                  || indice >= dados.length
                ) {
                  return const SizedBox.shrink();
                }

                return Padding(
                  padding:
                      const EdgeInsets.only(
                    top: 8,
                  ),
                  child: Text(
                    dados[indice].rotulo,
                    style: TextStyle(
                      fontSize: 10,
                      color:
                          cores
                              .onSurfaceVariant,
                    ),
                  ),
                );
              },
            ),
          ),
        ),

        barTouchData: BarTouchData(
          enabled: true,

          touchTooltipData:
              BarTouchTooltipData(
            getTooltipColor:
                (_) => cores.inverseSurface,

            fitInsideHorizontally: true,
            fitInsideVertically: true,

            getTooltipItem: (
              grupo,
              grupoIndex,
              barra,
              barraIndex,
            ) {
              final item =
                  dados[grupo.x];

              final produtivaSelecionada =
                  barraIndex == 0;

              final nome =
                  produtivaSelecionada
                      ? 'Produtiva'
                      : 'Morta';

              final valor =
                  produtivaSelecionada
                      ? item.produtiva
                      : item.morta;

              return BarTooltipItem(
                '${item.rotulo}\n'
                '$nome: ${fmtInt(valor)} km',
                TextStyle(
                  color:
                      cores.onInverseSurface,
                  fontSize: 11,
                ),
              );
            },
          ),
        ),

        barGroups: [
          for (
            var i = 0;
            i < dados.length;
            i++
          )
            BarChartGroupData(
              x: i,
              barsSpace: 4,
              barRods: [
                BarChartRodData(
                  toY:
                      dados[i].produtiva,
                  width:
                      dados.length > 8
                          ? 10
                          : 18,
                  color:
                      produtiva,
                  borderRadius:
                      const BorderRadius.vertical(
                    top:
                        Radius.circular(4),
                  ),
                ),

                BarChartRodData(
                  toY:
                      dados[i].morta,
                  width:
                      dados.length > 8
                          ? 10
                          : 18,
                  color:
                      morta,
                  borderRadius:
                      const BorderRadius.vertical(
                    top:
                        Radius.circular(4),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}