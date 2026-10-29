import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:semob_dashboard/core/state.dart';
import 'package:semob_dashboard/core/theme.dart';
import 'package:semob_dashboard/pages/financeiro_page.dart';

void main() {
  testWidgets('Financeiro preserves daily details in both themes', (
    tester,
  ) async {
    final client = MockClient(
      (request) async => http.Response(
        jsonEncode({
          'total_vendas': 123.45,
          'total_utilizacao': 50,
          'credito_circulante': 73.45,
          'dias_financeiros': [
            {
              'data': '2026-08-31',
              'rotulo': '31/08',
              'vendas': 123.45,
              'utilizacao': 50,
              'credito_circulante': 73.45,
            },
          ],
        }),
        200,
      ),
    );
    await http.runWithClient(() async {
      for (final brightness in Brightness.values) {
        await tester.pumpWidget(
          MaterialApp(
            theme: buildTheme(brightness: brightness),
            home: const Scaffold(body: FinanceiroPage()),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.text('Gestão Financeira'), findsOneWidget);
        expect(find.text(r'R$ 123,45'), findsWidgets);
        expect(find.byTooltip('Exportar relatório'), findsOneWidget);
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox());
      }
    }, () => client);
  });

  testWidgets('Changing month drops stale data and retries failed request', (
    tester,
  ) async {
    final months = <String?>[];
    final client = MockClient((request) async {
      months.add(request.url.queryParameters['mes']);
      if (months.length == 2) return http.Response('{}', 500);
      return http.Response(
        jsonEncode({'total_vendas': 123.45, 'dias_financeiros': []}),
        200,
      );
    });
    await http.runWithClient(() async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: FinanceiroPage())),
      );
      await tester.pumpAndSettle();
      expect(find.text(r'R$ 123,45'), findsWidgets);
      periodoNotifier.selecionarMes('2026-09');
      await tester.pumpAndSettle();
      expect(find.text(r'R$ 123,45'), findsNothing);
      await tester.tap(find.text('Tentar novamente'));
      await tester.pumpAndSettle();
      expect(months, ['2026-08', '2026-09', '2026-09']);
      expect(find.text(r'R$ 123,45'), findsWidgets);
      await tester.pumpWidget(const SizedBox());
    }, () => client);
    periodoNotifier.selecionarMes('2026-08');
  });

  testWidgets('Empty month remains available without fabricated values', (
    tester,
  ) async {
    final client = MockClient(
      (request) async => http.Response('{"dias_financeiros":[]}', 200),
    );
    await http.runWithClient(() async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: FinanceiroPage())),
      );
      await tester.pumpAndSettle();
      expect(find.text('Gestão Financeira'), findsOneWidget);
      expect(
        find.text('Sem registros financeiros para o mês selecionado.'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    }, () => client);
  });
}
