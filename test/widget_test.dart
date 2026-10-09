import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:semob_dashboard/core/state.dart';
import 'package:semob_dashboard/main.dart';
import 'package:semob_dashboard/pages/login_page.dart';

void main() {
  testWidgets('App abre na tela de login', (WidgetTester tester) async {
    await tester.pumpWidget(const SemobApp());
    await tester.pumpAndSettle();

    expect(find.byType(LoginPage), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(2));
  });

  test('Atualizar notifica sem alterar o periodo selecionado', () {
    final notifier = PeriodoNotifier();
    addTearDown(notifier.dispose);
    var notificacoes = 0;
    notifier.addListener(() => notificacoes++);

    notifier.atualizar();

    expect(notificacoes, 1);
    expect(notifier.value, Periodo.hoje);
  });
}
