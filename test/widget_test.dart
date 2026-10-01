import 'package:flutter_test/flutter_test.dart';

import 'package:semob_dashboard/main.dart';

void main() {
  testWidgets('App abre e mostra a Visão Geral', (WidgetTester tester) async {
    await tester.pumpWidget(const SemobApp());
    await tester.pumpAndSettle();

    expect(find.text('Visão Geral da Operação'), findsOneWidget);
  });
}