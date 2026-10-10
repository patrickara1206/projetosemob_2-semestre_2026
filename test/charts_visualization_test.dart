import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:semob_dashboard/widgets/volume_chart.dart';
import 'package:semob_dashboard/widgets/hourly_chart.dart';
import 'package:semob_dashboard/widgets/demand_chart.dart';
import 'package:semob_dashboard/widgets/km_bar_chart.dart';
import 'package:semob_dashboard/widgets/revenue_subsidy_chart.dart';
import 'package:semob_dashboard/models/dashboard_overview.dart';
import 'package:semob_dashboard/models/operacao_overview.dart';
import 'package:semob_dashboard/models/passageiros_overview.dart';
import 'package:semob_dashboard/models/financeiro_overview.dart';
import 'package:semob_dashboard/core/theme.dart';

void main() {
  testWidgets('Charts render empty, single zero and populated series', (tester) async {
    final charts = <Widget>[
      const VolumeChart(serie: []),
      const VolumeChart(serie: [SeriePonto(rotulo: 'Ago', realizado: 0, esperado: 0)]),
      const HourlyChart(dados: [ViagensHora(rotulo: '08h', viagens: 0)]),
      const DemandChart(serie: [DemandaPonto(rotulo: '08h', volume: 0)]),
      const KmBarChart(dados: [KmMes(rotulo: 'Ago', produtiva: 0, morta: 0)]),
      const VolumeChart(serie: [SeriePonto(rotulo: 'Jul', realizado: 100, esperado: 120), SeriePonto(rotulo: 'Ago', realizado: 150, esperado: 130, anomalia: true)]),
      const DemandChart(serie: [DemandaPonto(rotulo: '08h', volume: 120, anomalia: true), DemandaPonto(rotulo: '09h', volume: 140)]),
      const RevenueSubsidyChart(serie: []),
      const RevenueSubsidyChart(serie: [FinPonto(rotulo: '31/08', vendas: 0, utilizacao: 0)]),
      const RevenueSubsidyChart(serie: [FinPonto(rotulo: '30/08', vendas: 100, utilizacao: 40), FinPonto(rotulo: '31/08', vendas: 150, utilizacao: 80)]),
    ];
    for (final chart in charts) {
      await tester.pumpWidget(MaterialApp(home: Scaffold(body: Center(child: SizedBox(width: 340, height: 440, child: chart)))));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: chart.runtimeType.toString());
    }
  });

  testWidgets('Single demand point uses red only for an anomaly', (tester) async {
    for (final anomaly in [false, true]) {
      await tester.pumpWidget(MaterialApp(home: Scaffold(body: SizedBox(width: 340, height: 440, child: DemandChart(serie: [DemandaPonto(rotulo: '31/08', volume: 120, anomalia: anomaly)])))));
      await tester.pumpAndSettle();
      final chart = tester.widget<LineChart>(find.byType(LineChart));
      final bar = chart.data.lineBarsData.single;
      final spot = bar.spots.single;
      expect(bar.dotData.checkToShowDot(spot, bar), isTrue);
      final dot = bar.dotData.getDotPainter(spot, 0, bar, 0) as FlDotCirclePainter;
      expect(dot.color, anomaly ? AppColors.red : const Color(0xFF0B5FB0));
      expect(tester.takeException(), isNull);
    }
  });
}
