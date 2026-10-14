import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../core/formatters.dart';
import '../core/theme.dart';
import '../models/financeiro_overview.dart';

class FinanceiroDetalhes extends StatelessWidget {
  final List<DiaFinanceiro> dias;

  const FinanceiroDetalhes({
    super.key,
    required this.dias,
  });

  static const azul = Color(0xFF2563EB);
  static const laranja = Color(0xFFEA580C);

  @override
  Widget build(BuildContext context) {
    if (dias.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(32),
        decoration: cardDecoration(),
        child: const Text(
          'Sem registros financeiros para o mês selecionado.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.muted),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, box) {
        final grafico = SizedBox(
          height: 400,
          child: _grafico(),
        );

        final tabela = SizedBox(
          height: 400,
          child: _tabela(),
        );

        if (box.maxWidth >= 1000) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 3, child: grafico),
              const SizedBox(width: 20),
              Expanded(flex: 2, child: tabela),
            ],
          );
        }

        return Column(
          children: [
            grafico,
            const SizedBox(height: 16),
            tabela,
          ],
        );
      },
    );
  }

  Widget _legenda(Color cor, String titulo) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 3,
          color: cor,
        ),
        const SizedBox(width: 6),
        Text(
          titulo,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.muted,
          ),
        ),
      ],
    );
  }

  Widget _grafico() {
    final vendas = <FlSpot>[];
    final utilizacao = <FlSpot>[];

    double maiorValor = 0;
    double menorValor = 0;

    for (var i = 0; i < dias.length; i++) {
      final dia = dias[i];

      if (dia.vendas != null) {
        vendas.add(FlSpot(i.toDouble(), dia.vendas!));

        if (dia.vendas! > maiorValor) {
          maiorValor = dia.vendas!;
        }

        if (dia.vendas! < menorValor) {
          menorValor = dia.vendas!;
        }
      } else {
        vendas.add(FlSpot.nullSpot);
      }

      if (dia.utilizacao != null) {
        utilizacao.add(FlSpot(i.toDouble(), dia.utilizacao!));

        if (dia.utilizacao! > maiorValor) {
          maiorValor = dia.utilizacao!;
        }

        if (dia.utilizacao! < menorValor) {
          menorValor = dia.utilizacao!;
        }
      } else {
        utilizacao.add(FlSpot.nullSpot);
      }
    }

    final possuiValores = dias.any(
      (dia) => dia.vendas != null || dia.utilizacao != null,
    );

    final amplitude = maiorValor - menorValor;

    final intervaloY = amplitude <= 100
        ? 20.0
        : (amplitude / 5 / 100).ceil() * 100.0;

    final minY = menorValor < 0
        ? (menorValor / intervaloY).floor() * intervaloY
        : 0.0;

    final maxY =
        (maiorValor / intervaloY).ceil() * intervaloY + intervaloY;

    final intervaloX = dias.length <= 6
        ? 1.0
        : ((dias.length - 1) / 5).ceilToDouble();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Vendas e utilização por dia',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppColors.navy,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Valores em reais dos relatórios importados',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.muted,
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 20,
            runSpacing: 8,
            children: [
              _legenda(azul, 'Vendas'),
              _legenda(laranja, 'Utilização'),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: !possuiValores
                ? const Center(
                    child: Text('Valores diários indisponíveis'),
                  )
                : LineChart(
                    LineChartData(
                      minX: 0,
                      maxX: dias.length == 1
                          ? 1.0
                          : (dias.length - 1).toDouble(),
                      minY: minY,
                      maxY: maxY,
                      borderData: FlBorderData(show: false),
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        horizontalInterval: intervaloY,
                        getDrawingHorizontalLine: (_) => const FlLine(
                          color: AppColors.border,
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
                            reservedSize: 68,
                            getTitlesWidget: (valor, meta) {
                              return Text(
                                fmtInt(valor),
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: AppColors.muted,
                                ),
                              );
                            },
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
                                  indice >= dias.length) {
                                return const SizedBox.shrink();
                              }

                              return Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  dias[indice].rotulo,
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
                      lineTouchData: LineTouchData(
                        touchTooltipData: LineTouchTooltipData(
                          getTooltipColor: (_) => AppColors.navy,
                          fitInsideHorizontally: true,
                          fitInsideVertically: true,
                          maxContentWidth: 220,
                          getTooltipItems: (pontos) {
                            return pontos.map((ponto) {
                              final indice = ponto.x.round();
                              final titulo = ponto.barIndex == 0
                                  ? 'Vendas'
                                  : 'Utilização';

                              return LineTooltipItem(
                                '${dias[indice].rotulo}'
                                ' · $titulo: ${fmtMoney(ponto.y)}',
                                const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              );
                            }).toList();
                          },
                        ),
                      ),
                      lineBarsData: [
                        LineChartBarData(
                          spots: vendas,
                          isCurved: false,
                          color: azul,
                          barWidth: 3,
                          dotData: const FlDotData(show: true),
                        ),
                        LineChartBarData(
                          spots: utilizacao,
                          isCurved: false,
                          color: laranja,
                          barWidth: 2,
                          dashArray: [6, 4],
                          dotData: const FlDotData(show: false),
                        ),
                      ],
                    ),
                  ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Toque ou passe o mouse para consultar os valores.',
            style: TextStyle(
              fontSize: 11,
              color: AppColors.muted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _tabela() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Movimentos financeiros',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppColors.navy,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${dias.length} dias com registros',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.muted,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: SingleChildScrollView(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columnSpacing: 20,
                  columns: const [
                    DataColumn(label: Text('Data')),
                    DataColumn(
                      label: Text('Vendas'),
                      numeric: true,
                    ),
                    DataColumn(
                      label: Text('Utilização'),
                      numeric: true,
                    ),
                    DataColumn(
                      label: Text('Crédito circulante'),
                      numeric: true,
                    ),
                  ],
                  rows: [
                    for (final dia in dias)
                      DataRow(
                        cells: [
                          DataCell(Text(dia.rotulo)),
                          DataCell(Text(fmtMoney(dia.vendas))),
                          DataCell(Text(fmtMoney(dia.utilizacao))),
                          DataCell(Text(fmtMoney(dia.creditoCirculante))),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}