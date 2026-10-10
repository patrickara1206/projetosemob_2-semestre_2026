import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:semob_dashboard/pages/financeiro_page.dart';

Map<String, dynamic> _response({bool empty = false}) => {
  'total_vendas': empty ? null : 123.45,
  'total_utilizacao': empty ? null : 50.0,
  'credito_circulante': empty ? null : 73.45,
  'inicio': empty ? null : '2026-08-31',
  'fim': empty ? null : '2026-08-31',
  'dias': empty ? 0 : 1,
  'evolucao': empty
      ? []
      : [
          {'rotulo': '31/08', 'vendas': 123.45, 'utilizacao': 50.0},
        ],
  'movimentos': {
    'itens': empty
        ? []
        : [
            {
              'data': '2026-08-31',
              'vendas': 123.45,
              'utilizacao': 50.0,
              'credito_circulante': 73.45,
            },
          ],
    'pagina': 1,
    'total_paginas': 1,
    'total_registros': empty ? 0 : 1,
  },
};

void main() {
  testWidgets('Failed period change clears previous data and allows retry', (
    tester,
  ) async {
    final periods = <String?>[];
    final client = MockClient((request) async {
      periods.add(request.url.queryParameters['periodo']);
      if (periods.length == 2) return http.Response('{}', 500);
      return http.Response(jsonEncode(_response()), 200);
    });

    await http.runWithClient(() async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: FinanceiroPage())),
      );
      await tester.pumpAndSettle();
      expect(find.text(r'R$ 123,45'), findsWidgets);

      await tester.tap(find.text('Último dia'));
      await tester.pumpAndSettle();
      expect(periods, ['mes', 'hoje']);
      expect(find.text(r'R$ 123,45'), findsNothing);
      expect(find.text('Vendas e utilização de créditos'), findsNothing);
      expect(find.text('Tentar novamente'), findsOneWidget);
      expect(
        find.text('Não foi possível carregar o financeiro (500).'),
        findsOneWidget,
      );

      await tester.tap(find.text('Tentar novamente'));
      await tester.pumpAndSettle();
      expect(periods, ['mes', 'hoje', 'hoje']);
      expect(find.text(r'R$ 123,45'), findsWidgets);
      expect(tester.takeException(), isNull);
    }, () => client);
  });

  testWidgets('Empty month shows missing data and rejects invalid month', (
    tester,
  ) async {
    var requests = 0;
    final client = MockClient((request) async {
      requests++;
      return http.Response(jsonEncode(_response(empty: true)), 200);
    });

    await http.runWithClient(() async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: FinanceiroPage())),
      );
      await tester.pumpAndSettle();
      expect(
        find.text('Sem registros para o mês selecionado.'),
        findsOneWidget,
      );
      expect(find.text(r'R$ --'), findsNWidgets(3));

      await tester.enterText(find.byType(TextField).first, '2026-13');
      await tester.tap(find.text('Aplicar'));
      await tester.pumpAndSettle();
      expect(
        find.text('Informe o mês no formato AAAA-MM, por exemplo 2026-08.'),
        findsOneWidget,
      );
      expect(requests, 1);
      expect(tester.takeException(), isNull);
    }, () => client);
  });
}
