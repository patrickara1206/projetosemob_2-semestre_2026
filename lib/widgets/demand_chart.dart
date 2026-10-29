import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../models/passageiros_overview.dart';

/// Evolução diária de demanda, com balão de anomalia (ML).
/// Deve receber altura definida pelo pai (ex.: SizedBox).
class DemandChart extends StatelessWidget {
  final List<DemandaPonto> serie;
  const DemandChart({super.key, required this.serie});

  static const _line = Color(0xFF0B5FB0);
  static const _leftReserved = 40.0;
  static const _bottomReserved = 28.0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, box) {
        final isMobile = box.maxWidth < 600;

        return Container(
          padding: EdgeInsets.all(isMobile ? 12 : 20),
          decoration: cardDecoration(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: double.infinity,
                child: Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'EVOLUÇÃO DIÁRIA DE DEMANDA',
                          style: TextStyle(
                            fontSize: isMobile ? 11 : 12,
                            fontWeight: FontWeight.w700,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Volume por hora com detecção de anomalias (ML)',
                          style: TextStyle(
                            fontSize: 10,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    _Legend(),
                  ],
                ),
              ),
              SizedBox(height: isMobile ? 10 : 16),
              Expanded(
                child: serie.isEmpty
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
                    : _buildChart(isMobile),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildChart(bool isMobile) {
    return LayoutBuilder(
      builder: (context, box) {
        final n = serie.length;
        final maxVol = serie.map((e) => e.volume).reduce(math.max);
        final maxY = maxVol <= 0 ? 1.0 : maxVol * 1.15;
        final interval = isMobile
            ? (n <= 4 ? 1.0 : (n / 3).ceilToDouble())
            : (n <= 6 ? 1.0 : (n / 6).ceilToDouble());

        final spots = [
          for (var i = 0; i < n; i++) FlSpot(i.toDouble(), serie[i].volume),
        ];

        Widget? callout;
        final idx = serie.indexWhere((p) => p.anomalia);
        if (idx != -1) {
          final cw = isMobile ? 160.0 : 210.0;
          final ch = isMobile ? 70.0 : 92.0;
          final plotW = box.maxWidth - _leftReserved;
          final plotH = box.maxHeight - _bottomReserved;
          final dx = _leftReserved + (n == 1 ? 0 : idx / (n - 1)) * plotW;
          final dy = plotH - (serie[idx].volume / maxY) * plotH;

          final maxLeft = math.max(_leftReserved, box.maxWidth - cw);
          final left = (dx - cw / 2).clamp(_leftReserved, maxLeft).toDouble();
          var top = dy - ch - 12;
          if (top < 0) top = dy + 12;

          callout = Positioned(
            left: left,
            top: top,
            width: cw,
            child: IgnorePointer(
              child: _Callout(
                titulo: serie[idx].titulo ?? 'Anomalia',
                detalhe: serie[idx].detalhe ?? '',
                isMobile: isMobile,
              ),
            ),
          );
        }

        return Stack(
          fit: StackFit.expand,
          children: [
            LineChart(
              LineChartData(
                minX: 0,
                maxX: (n - 1).toDouble(),
                minY: 0,
                maxY: maxY,
                borderData: FlBorderData(show: false),
                gridData: FlGridData(
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (_) =>
                      FlLine(color: AppColors.border, strokeWidth: 1),
                ),
                titlesData: FlTitlesData(
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: _leftReserved,
                      getTitlesWidget: (v, meta) {
                        final k = v / 1000;
                        final txt = v == 0
                            ? '0'
                            : '${k == k.roundToDouble() ? k.toInt() : k.toStringAsFixed(1)}k';
                        return Text(
                          txt,
                          style: TextStyle(
                            fontSize: 9,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: _bottomReserved,
                      interval: interval,
                      getTitlesWidget: (v, meta) {
                        final i = v.toInt();
                        if (i < 0 || i >= n) return SizedBox();
                        return Padding(
                          padding: EdgeInsets.only(top: 8),
                          child: Text(
                            serie[i].rotulo,
                            style: TextStyle(
                              fontSize: 9,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
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
                    barWidth: isMobile ? 3 : 5,
                    belowBarData: BarAreaData(
                      show: true,
                      color: _line.withOpacity(0.06),
                    ),
                    dotData: FlDotData(
                      show: true,
                      checkToShowDot: (spot, _) =>
                          serie[spot.x.toInt()].anomalia,
                      getDotPainter: (spot, percent, bar, index) =>
                          FlDotCirclePainter(
                            radius: isMobile ? 4 : 6,
                            color: AppColors.red,
                            strokeWidth: 2,
                            strokeColor: Colors.white,
                          ),
                    ),
                  ),
                ],
              ),
            ),
            if (callout != null) callout,
          ],
        );
      },
    );
  }
}

class _Callout extends StatelessWidget {
  final String titulo;
  final String detalhe;
  final bool isMobile;

  const _Callout({
    required this.titulo,
    required this.detalhe,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 6 : 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Color(0xFFF3C7C7)),
        boxShadow: [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning_amber_rounded, size: 13, color: AppColors.red),
              SizedBox(width: 4),
              Expanded(
                child: Text(
                  titulo,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.red,
                  ),
                ),
              ),
            ],
          ),
          if (detalhe.isNotEmpty) ...[
            SizedBox(height: 2),
            Text(
              detalhe,
              maxLines: isMobile ? 2 : 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 9, color: AppColors.text),
            ),
          ],
        ],
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend();

  @override
  Widget build(BuildContext context) {
    Widget item(Color c, String t) => Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.circle, size: 8, color: c),
        SizedBox(width: 4),
        Text(
          t,
          style: TextStyle(
            fontSize: 10,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );

    return Wrap(
      spacing: 12,
      runSpacing: 4,
      children: [
        item(Color(0xFF0B5FB0), 'Volume'),
        item(AppColors.red, 'Anomalia'),
      ],
    );
  }
}
