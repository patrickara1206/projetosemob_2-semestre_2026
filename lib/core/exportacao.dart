import 'package:flutter/material.dart';
import 'exportacao_stub.dart' if (dart.library.js_interop) 'exportacao_web.dart';

String gerarCsv(List<List<Object?>> linhas) {
  String celula(Object? valor) {
    var texto = valor == null ? '' : valor is num
        ? valor.toString().replaceAll('.', ',') : valor.toString();
    if (valor is String && RegExp(r'^\s*[=+\-@]').hasMatch(texto)) texto = "'$texto";
    return '"${texto.replaceAll('"', '""')}"';
  }
  return '\uFEFF${linhas.map((linha) => linha.map(celula).join(';')).join('\r\n')}\r\n';
}

void exportarRelatorio(BuildContext context, String nome, List<List<Object?>> linhas) {
  final salvo = salvarCsv(nome, gerarCsv(linhas));
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(salvo
      ? 'Relatório CSV gerado.' : 'Abra a versão web para baixar o relatório.')));
}
