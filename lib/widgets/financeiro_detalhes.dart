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

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).colorScheme;

    if (dias.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(32),
        decoration: cardDecoration(context),
        child: Text(
          'Sem registros financeiros para o mês selecionado.',
          textAlign: TextAlign.center,
          style: TextStyle(color: cores.onSurfaceVariant),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, box) {
        final grafico = SizedBox(
          height: 400,
          child: _grafico(context),
        );

        final tabela = SizedBox(
          height: 400,
          child: _tabela(context),
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

  Widget _legenda(
    BuildContext context,
    Color cor,
    String titulo,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 16, height: 3, color: cor),
        const SizedBox(width: 6),
        Text(
          titulo,
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _grafico(BuildContext context) {
    final cores = Theme.of(context).colorScheme;
    final escuro = Theme.of(context).brightness == Brightness.dark;

    final azul = escuro
        ? const Color(0xFF60A5FA)
        : const Color(0xFF2563EB);

    final laranja = escuro
        ? const Color(0xFFFB923C)
        : const Color(0xFFEA580C);

    final vendas = <FlSpot>[];
    final utilizacao = <FlSpot>[];

    double maiorValor = 0;
    double menorValor = 0;

    for (var i = 0; i < dias.length; i++) {
      final dia = dias[i];

      if (dia.vendas != null) {
        vendas.add(FlSpot(i.toDouble(), dia.vendas!));

        if (dia.vendas! > maiorValor) maiorValor = dia.vendas!;
        if (dia.vendas! < menorValor) menorValor = dia.vendas!;
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
      decoration: cardDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Vendas e utilização por dia',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: cores.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Valores em reais dos relatórios importados',
            style: TextStyle(
              fontSize: 12,
              color: cores.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 20,
            runSpacing: 8,
            children: [
              _legenda(context, azul, 'Vendas'),
              _legenda(context, laranja, 'Utilização'),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: !possuiValores
                ? Center(
                    child: Text(
                      'Valores diários indisponíveis',
                      style: TextStyle(color: cores.onSurfaceVariant),
                    ),
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
                        drawVerticalLine: false,
                        horizontalInterval: intervaloY,
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
                            interval: intervaloY,
                            reservedSize: 68,
                            getTitlesWidget: (valor, meta) => Text(
                              fmtInt(valor),
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
                                  indice >= dias.length) {
                                return const SizedBox.shrink();
                              }

                              return Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  dias[indice].rotulo,
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
          Text(
            'Toque ou passe o mouse para consultar os valores.',
            style: TextStyle(
              fontSize: 11,
              color: cores.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _tabela(BuildContext context) {
    final cores = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: cardDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Movimentos financeiros',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: cores.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${dias.length} dias com registros',
            style: TextStyle(
              fontSize: 12,
              color: cores.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: SingleChildScrollView(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columnSpacing: 20,
                  dividerThickness: 1,
                  border: TableBorder(
                    horizontalInside: BorderSide(
                      color: cores.outlineVariant,
                    ),
                  ),
                  headingRowColor: WidgetStatePropertyAll<Color>(
                    cores.surfaceContainerHighest,
                  ),
                  headingTextStyle: TextStyle(
                    color: cores.onSurface,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                  dataTextStyle: TextStyle(
                    color: cores.onSurface,
                    fontSize: 12,
                  ),
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
                    for (var i = 0; i < dias.length; i++)
                      DataRow(
                        color: WidgetStatePropertyAll<Color>(
                          i.isOdd
                              ? cores.surfaceContainerHighest
                              : cores.surface,
                        ),
                        cells: [
                          DataCell(Text(dias[i].rotulo)),
                          DataCell(Text(fmtMoney(dias[i].vendas))),
                          DataCell(Text(fmtMoney(dias[i].utilizacao))),
                          DataCell(
                            Text(fmtMoney(dias[i].creditoCirculante)),
                          ),
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