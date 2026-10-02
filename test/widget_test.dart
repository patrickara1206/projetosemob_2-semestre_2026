import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:semob_dashboard/main.dart';
import 'package:semob_dashboard/services/api_service.dart';
import 'package:semob_dashboard/pages/financeiro_page.dart';

void main() {
  test('Valores monetários mantêm centavos e sinal', () {
    expect(money(668605.71),'R\$ 668.605,71');
    expect(money(-0.5),'R\$ -0,50');
    expect(money(1.999),'R\$ 2,00');
    expect(money(null),'--');
  });
  testWidgets('Dados reais, navegação e layout em desktop e celular', (tester) async {
    final fixture=jsonDecode(File('test/api_fixture.json').readAsStringSync()) as Map<String,dynamic>;
    ApiService.client=MockClient((request) async {
      return http.Response(jsonEncode(fixture[request.url.path]??{'alerts':[],'rules':[],'meta':fixture['/dashboard/overview']['meta'],'limitation':'Monitoramento por regras','total':0,'items':[]}),200,headers:{'content-type':'application/json; charset=utf-8'});
    });
    tester.view.devicePixelRatio=1;
    tester.view.physicalSize=const Size(1400,1000);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const SemobApp());
    await tester.pumpAndSettle();
    expect(find.text('288.378'),findsOneWidget);
    expect(find.text('34.994'),findsOneWidget);
    expect(tester.takeException(),isNull);
    await tester.tap(find.text('Operação'));
    await tester.pumpAndSettle();
    expect(find.text('Desempenho da Operação'),findsOneWidget);
    expect(tester.takeException(),isNull);
    await tester.tap(find.text('Passageiros'));
    await tester.pumpAndSettle();
    expect(find.text('1.050.248'),findsOneWidget);
    expect(tester.takeException(),isNull);
    await tester.tap(find.text('Financeiro'));
    await tester.pumpAndSettle();
    expect(find.text('Informações Financeiras'),findsOneWidget);
    expect(find.text('R\$ 668.605,71'),findsWidgets);
    expect(tester.takeException(),isNull);
    tester.view.physicalSize=const Size(390,844);
    await tester.pumpAndSettle();
    expect(tester.takeException(),isNull);
    tester.view.physicalSize=const Size(1400,1000);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Monitoramento'));
    await tester.pumpAndSettle();
    expect(find.text('Monitoramento e Anomalias'),findsOneWidget);
    expect(tester.takeException(),isNull);
    await tester.tap(find.text('Dados e Banco'));
    await tester.pumpAndSettle();
    expect(find.text('Banco local em uso'),findsOneWidget);
    expect(tester.takeException(),isNull);
    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
    ApiService.client.close();
  });
}
