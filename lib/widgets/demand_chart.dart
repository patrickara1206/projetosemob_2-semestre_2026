import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../models/passageiros_overview.dart';

class DemandChart extends StatelessWidget {
  final List<DemandaPonto> serie;
  const DemandChart({super.key, required this.serie});

  static const _line = Color(0xFF0B5FB0);
  static const _leftReserved = 44.0;
  static const _bottomReserved = 28.0;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: cardDecoration(),
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
              children: const [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'EVOLUÇÃO DIÁRIA DE DEMANDA',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF374151),
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Volume por hora com detecção de anomalias (ML)',
                      style: TextStyle(fontSize: 11, color: AppColors.muted),
                    ),
                  ],
                ),
                _Legend(),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: serie.isEmpty
                ? const Center(
                    child: Text(
                      'Sem dados para o período selecionado',
                      style: TextStyle(color: AppColors.muted),
                    ),
                  )
                : _buildChart(),
          ),
        ],
      ),
    );
  }

  Widget _buildChart() {
    return LayoutBuilder(
      builder: (context, box) {
        final n = serie.length;
        final maxVol = serie.map((e) => e.volume).reduce(math.max);
        final maxY = maxVol <= 0 ? 1.0 : maxVol * 1.15;
        final interval = n <= 6 ? 1.0 : (n / 6).ceilToDouble();

        final spots = [
          for (var i = 0; i < n; i++) FlSpot(i.toDouble(), serie[i].volume),
        ];

        Widget? callout;
        final idx = serie.indexWhere((p) => p.anomalia);
        if (idx != -1) {
          const cw = 210.0;
          const ch = 92.0;
          final plotW = box.maxWidth - _leftReserved;
          final plotH = box.maxHeight - _bottomReserved;
          final dx = _leftReserved + (n == 1 ? 0 : idx / (n - 1)) * plotW;
          final dy = plotH - (serie[idx].volume / maxY) * plotH;

          final maxLeft = math.max(_leftReserved, box.maxWidth - cw);
          final left = (dx - cw / 2).clamp(_leftReserved, maxLeft).toDouble();
          var top = dy - ch - 14;
          if (top < 0) top = dy + 14;

          callout = Positioned(
            left: left,
            top: top,
            width: cw,
            child: IgnorePointer(
              child: _Callout(
                titulo: serie[idx].titulo ?? 'Anomalia',
                detalhe: serie[idx].detalhe ?? '',
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
                      const FlLine(color: AppColors.border, strokeWidth: 1),
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
                      reservedSize: _leftReserved,
                      getTitlesWidget: (v, meta) {
                        final k = v / 1000;
                        final txt = v == 0
                            ? '0'
                            : '${k == k.roundToDouble() ? k.toInt() : k.toStringAsFixed(1)}k';
                        return Text(
                          txt,
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
                      reservedSize: _bottomReserved,
                      interval: interval,
                      getTitlesWidget: (v, meta) {
                        final i = v.toInt();
                        if (i < 0 || i >= n) return const SizedBox();
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            serie[i].rotulo,
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
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: _line,
                    barWidth: 5,
                    belowBarData: BarAreaData(
                      show: true,
                      color: _line.withValues(alpha: 0.06),
                    ),
                    dotData: FlDotData(
                      show: true,
                      checkToShowDot: (spot, _) =>
                          serie[spot.x.toInt()].anomalia,
                      getDotPainter: (spot, percent, bar, index) =>
                          FlDotCirclePainter(
                            radius: 6,
                            color: AppColors.red,
                            strokeWidth: 2,
                            strokeColor: Colors.white,
                          ),
                    ),
                  ),
                ],
              ),
            ),
            ?callout,
          ],
        );
      },
    );
  }
}

class _Callout extends StatelessWidget {
  final String titulo;
  final String detalhe;
  const _Callout({required this.titulo, required this.detalhe});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFFF3C7C7)),
        boxShadow: const [
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
              const Icon(
                Icons.warning_amber_rounded,
                size: 14,
                color: AppColors.red,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  titulo,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.red,
                  ),
                ),
              ),
            ],
          ),
          if (detalhe.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              detalhe,
              style: const TextStyle(fontSize: 10, color: AppColors.text),
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
        Icon(Icons.circle, size: 9, color: c),
        const SizedBox(width: 6),
        Text(t, style: const TextStyle(fontSize: 10, color: Color(0xFF374151))),
      ],
    );

    return Wrap(
      spacing: 14,
      children: [
        item(const Color(0xFF0B5FB0), 'Volume Padrão'),
        item(AppColors.red, 'Anomalia (Queda)'),
      ],
    );
  }
}
