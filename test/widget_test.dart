import 'package:flutter_test/flutter_test.dart';

import 'package:semob_dashboard/main.dart';

void main() {
  testWidgets('App inicia no login antes da autenticação', (WidgetTester tester) async {
    await tester.pumpWidget(const SemobApp());
    await tester.pumpAndSettle();

    expect(find.text('E-mail'), findsOneWidget);
    expect(find.text('Senha'), findsOneWidget);
    expect(find.text('Entrar'), findsOneWidget);
  });
}