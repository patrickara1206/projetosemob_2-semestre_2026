import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:semob_dashboard/layout/app_shell.dart';
import 'package:semob_dashboard/layout/sidebar.dart';
import 'package:semob_dashboard/main.dart';
import 'package:semob_dashboard/core/acessibilidade.dart';
import 'package:semob_dashboard/models/ml_overview.dart';
import 'package:semob_dashboard/models/passageiros_overview.dart';
import 'package:semob_dashboard/models/operacao_overview.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:semob_dashboard/core/theme.dart';
import 'package:semob_dashboard/widgets/kpi_card.dart';
import 'package:semob_dashboard/widgets/anomaly_table.dart';
import 'package:semob_dashboard/widgets/category_table.dart';
import 'package:semob_dashboard/widgets/feature_importance_table.dart';
import 'package:semob_dashboard/widgets/ai_logs_panel.dart';
import 'package:semob_dashboard/widgets/demand_chart.dart';
import 'package:semob_dashboard/widgets/hourly_chart.dart';
import 'package:semob_dashboard/widgets/score_stability_chart.dart';
import 'package:semob_dashboard/widgets/ml_flow_card.dart';
import 'package:semob_dashboard/widgets/tariff_donut.dart';

void main() {
  testWidgets('Navegacao cabe no celular e sidebar permite rolagem', (
    tester,
  ) async {
    for (final size in [const Size(320, 700), const Size(1200, 400)]) {
      await tester.binding.setSurfaceSize(size);
      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) =>
                const AppShell(child: Text('Conteudo de teste')),
          ),
        ],
      );
      final client = MockClient(
        (_) async => http.Response('{"meses":[],"periodos":{}}', 200),
      );
      await http.runWithClient(() async {
        acessibilidadeNotifier.value = const AcessibilidadeConfig(
          escalaFonte: 1.5,
        );
        await tester.pumpWidget(
          MaterialApp.router(
            routerConfig: router,
            builder: (context, child) => AcessibilidadeLayer(child: child),
          ),
        );
        await tester.pump(const Duration(milliseconds: 500));
        if (size.width < 900) {
          tester.state<ScaffoldState>(find.byType(Scaffold).first).openDrawer();
          await tester.pump(const Duration(milliseconds: 500));
        }
        expect(find.byType(Sidebar), findsOneWidget);
        expect(tester.takeException(), isNull, reason: '$size');
        await tester.pumpWidget(const SizedBox());
      }, () => client);
      router.dispose();
    }
    acessibilidadeNotifier.value = const AcessibilidadeConfig();
    await tester.binding.setSurfaceSize(null);
  });

  testWidgets('Login em celular preserva acessibilidade e formulario', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 740));
    acessibilidadeNotifier.value = const AcessibilidadeConfig(escalaFonte: 1.5);
    await tester.pumpWidget(const SemobApp());
    await tester.pumpAndSettle();
    expect(find.byType(TextFormField), findsNWidgets(2));
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
    acessibilidadeNotifier.value = const AcessibilidadeConfig();
    await tester.binding.setSurfaceSize(null);
  });

  testWidgets('Componentes responsivos em celular e desktop com fonte ampliada', (
    tester,
  ) async {
    final widgets = <Widget>[
      const KpiCard(
        title: 'Quilometragem produtiva',
        icon: Icons.route,
        value: '253.710',
        unit: 'km',
      ),
      AnomalyTable(anomalias: const [], onAction: (_) {}, onVerTodas: () {}),
      CategoryTable(categorias: const [], onVerRelatorio: () {}),
      const FeatureImportanceTable(
        features: [
          FeatureImportance(
            nome: 'Horario da viagem',
            categoria: 'Temporal',
            peso: 0.7,
          ),
        ],
      ),
      const AiLogsPanel(
        logs: [
          LogIa(
            hora: '08:00',
            mensagem:
                'Registro de teste para verificar quebra de texto em tela estreita',
            nivel: 'info',
          ),
        ],
      ),
      const DemandChart(serie: [DemandaPonto(rotulo: '01/08', volume: 123)]),
      const HourlyChart(dados: [ViagensHora(rotulo: '08h', viagens: 120)]),
      const ScoreStabilityChart(serie: [ScoreDia(rotulo: '01/08', score: 0.9)]),
      const MlFlowCard(),
      const TariffDonut(pctPagantes: 75),
    ];
    for (final width in [320.0, 390.0, 1200.0]) {
      await tester.binding.setSurfaceSize(Size(width, 700));
      for (final brightness in Brightness.values) {
        for (final widget in widgets) {
          await tester.pumpWidget(
            MaterialApp(
              theme: buildTheme(brightness: brightness),
              home: Builder(
                builder: (context) => MediaQuery(
                  data: MediaQuery.of(
                    context,
                  ).copyWith(textScaler: TextScaler.linear(1.5)),
                  child: Scaffold(
                    body: SingleChildScrollView(
                      child: SizedBox(height: 560, child: widget),
                    ),
                  ),
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();
          expect(
            tester.takeException(),
            isNull,
            reason: '${widget.runtimeType} width=$width theme=$brightness',
          );
        }
      }
    }
    await tester.binding.setSurfaceSize(null);
  });
}
