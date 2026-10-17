import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:go_router/go_router.dart';
import 'package:semob_dashboard/core/auth_state.dart';
import 'package:semob_dashboard/core/exportacao.dart';
import 'package:semob_dashboard/core/state.dart';
import 'package:semob_dashboard/pages/configuracoes_page.dart';

void main() {
  test('CSV preserves values, accented text, quotations and formula safety', () {
    final csv = gerarCsv([['Descrição', 'Valor'], ['Crédito "mensal"', 12.34], ['=1+1', null]]);
    expect(csv, startsWith('\uFEFF'));
    expect(csv, contains('"Crédito ""mensal""";"12,34"'));
    expect(csv, contains('"\'=1+1";""'));
    expect(csv.split('\r\n').length, 4);
  });

  test('Period selection includes range and resets it when month changes', () {
    final selection = PeriodoNotifier();
    selection.selecionarIntervalo(DateTime(2026, 8, 2), DateTime(2026, 8, 4));
    expect(selection.value, Periodo.personalizado);
    expect(selection.parametros, {'mes': '2026-08', 'inicio': '2026-08-02', 'fim': '2026-08-04'});
    var notifications = 0;
    selection.addListener(() => notifications++);
    selection.recarregar();
    selection.selecionarMes('2026-09');
    expect(notifications, 2);
    expect(selection.value, Periodo.mes);
    expect(selection.parametros, {'mes': '2026-09'});
    selection.dispose();
  });

  testWidgets('Settings verifies backend, validates month and logs out', (tester) async {
    final client = MockClient((request) async => http.Response(jsonEncode({
      'paths': {'/financeiro/overview': {}}
    }), 200));
    final router = GoRouter(initialLocation: '/', routes: [
      GoRoute(path: '/', builder: (context, state) => const Scaffold(body: ConfiguracoesPage())),
      GoRoute(path: '/login', builder: (context, state) => const Scaffold(body: Text('Login de teste'))),
    ]);
    authNotifier.value = true;
    await http.runWithClient(() async {
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();
      expect(find.text('Servidor conectado. Financeiro disponível.'), findsOneWidget);
      await tester.enterText(find.byType(TextField), '2026-13');
      await tester.tap(find.text('Aplicar mês'));
      await tester.pumpAndSettle();
      expect(find.text('Informe um mês no formato AAAA-MM.'), findsOneWidget);
      await tester.enterText(find.byType(TextField), '2026-09');
      await tester.tap(find.text('Aplicar mês'));
      await tester.pumpAndSettle();
      expect(periodoNotifier.mesReferencia, '2026-09');
      await tester.ensureVisible(find.text('Sair da conta'));
      await tester.tap(find.text('Sair da conta'));
      await tester.pumpAndSettle();
      expect(authNotifier.value, false);
      expect(find.text('Login de teste'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
    }, () => client);
    periodoNotifier.selecionarMes('2026-08');
    router.dispose();
  });
}
