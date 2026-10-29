import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../models/operacao_overview.dart';

class HourlyChart extends StatelessWidget {
  final List<ViagensHora> dados;
  const HourlyChart({super.key, required this.dados});

  static const _line = Color(0xFF0B5FB0);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, box) {
        final isMobile = box.maxWidth < 600;

        return Container(
          padding: EdgeInsets.all(isMobile ? 14 : 20),
          decoration: cardDecoration(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'RELAÇÃO VIAGENS / HORA DO DIA',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: isMobile ? 11 : 12,
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Color(0xFFF1F3F6),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'Média Dia Útil',
                      style: TextStyle(
                        fontSize: 10,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: isMobile ? 12 : 16),
              SizedBox(
                height: isMobile ? 240 : 290,
                child: dados.isEmpty
                    ? Center(
                        child: Text(
                          'Sem dados para o período selecionado',
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      )
                    : _chart(context, isMobile),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _chart(BuildContext context, bool isMobile) {
    final spots = [
      for (var i = 0; i < dados.length; i++)
        FlSpot(i.toDouble(), dados[i].viagens),
    ];

    final maxDivisions = isMobile ? 4 : 6;
    final interval = dados.length <= maxDivisions
        ? 1.0
        : (dados.length / maxDivisions).ceilToDouble();

    return LineChart(
      LineChartData(
        minY: 0,
        borderData: FlBorderData(show: false),
        gridData: FlGridData(
          drawVerticalLine: false,
          getDrawingHorizontalLine: (_) =>
              FlLine(color: AppColors.border, strokeWidth: 1),
        ),
        titlesData: FlTitlesData(
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: isMobile ? 30 : 36,
              getTitlesWidget: (v, meta) => Text(
                '${v.toInt()}',
                style: TextStyle(
                  fontSize: 9,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: interval,
              reservedSize: 24,
              getTitlesWidget: (v, meta) {
                final i = v.toInt();
                if (i < 0 || i >= dados.length) return SizedBox();
                return Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Text(
                    dados[i].rotulo,
                    style: TextStyle(
                      fontSize: 9,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: _line,
            barWidth: isMobile ? 3.5 : 5,
            belowBarData: BarAreaData(
              show: true,
              color: _line.withOpacity(0.06),
            ),
            dotData: FlDotData(
              show: true,
              checkToShowDot: (spot, _) => dados[spot.x.toInt()].pico,
              getDotPainter: (spot, percent, bar, index) => FlDotCirclePainter(
                radius: isMobile ? 4 : 5,
                color: Colors.white,
                strokeWidth: 2,
                strokeColor: _line,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
