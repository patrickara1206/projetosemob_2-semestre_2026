import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:semob_dashboard/pages/importacao_page.dart';
import 'package:semob_dashboard/services/importacao_service.dart';

class ImportacaoFake extends ImportacaoService {
  ImportacaoFake(this.resultado);

  final Map<String, dynamic> resultado;

  @override
  Future<Map<String, dynamic>> enviarZip({
    required String mes,
    required String tipoPeriodo,
  }) async => resultado;
}

void main() {
  testWidgets('ZIP parcial mostra caminho e falha de cada arquivo', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ImportacaoPage(
            service: ImportacaoFake({
              'status': 'parcial',
              'arquivos_importados': 1,
              'arquivos_com_erro': 1,
              'arquivos_ignorados': 0,
              'total_registros': 31,
              'resultados': [
                {
                  'arquivo': 'Agosto/Mensal/operacao.html',
                  'status': 'sucesso',
                  'registros': 31,
                  'mes_referencia': '2026-08',
                  'tipo_periodo': 'mensal',
                },
                {
                  'arquivo': 'Setembro/Quinzenal/viagens.html',
                  'status': 'erro',
                  'mensagem': 'Arquivo com CRC inválido.',
                },
              ],
            }),
          ),
        ),
      ),
    );
    final botao = find.text('Selecionar e importar ZIP');
    await tester.ensureVisible(botao);
    await tester.tap(botao);
    await tester.pumpAndSettle();
    expect(find.textContaining('ZIP com pendências.'), findsOneWidget);
    expect(find.text('Setembro/Quinzenal/viagens.html'), findsOneWidget);
    expect(find.text('Arquivo com CRC inválido.'), findsOneWidget);
    expect(find.text('Agosto/Mensal/operacao.html'), findsOneWidget);
    expect(
      find.textContaining('31 registro(s) · 2026-08 · mensal'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('ZIP já importado informa que não duplicou registros', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ImportacaoPage(
            service: ImportacaoFake({
              'status': 'sucesso',
              'arquivos_importados': 0,
              'arquivos_ja_importados': 1,
              'arquivos_com_erro': 0,
              'total_registros': 0,
              'resultados': [
                {
                  'arquivo': 'Agosto/Mensal/operacao.html',
                  'status': 'ja_importado',
                },
              ],
            }),
          ),
        ),
      ),
    );
    final botao = find.text('Selecionar e importar ZIP');
    await tester.ensureVisible(botao);
    await tester.tap(botao);
    await tester.pumpAndSettle();
    expect(
      find.textContaining('1 já importado(s) anteriormente'),
      findsOneWidget,
    );
    await tester.ensureVisible(find.text('Resultado por arquivo'));
    await tester.tap(find.text('Resultado por arquivo'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Nenhum registro duplicado.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
