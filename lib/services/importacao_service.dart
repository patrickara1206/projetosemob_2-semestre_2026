import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;

import 'dashboard_service.dart';

class ImportacaoService {
  Future<Map<String, dynamic>> enviarArquivo({
    required String tipo,
    required String mes,
    required String tipoPeriodo,
  }) async {
    final arquivo = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: ['html', 'htm'],
    );

    if (arquivo == null) {
      throw Exception('Nenhum arquivo selecionado.');
    }

    final bytes = await arquivo.readAsBytes();

    final uri = Uri.parse(
      '${DashboardService.baseUrl}/importacao/$tipo',
    ).replace(queryParameters: {'mes': mes, 'tipo_periodo': tipoPeriodo});

    final request = http.MultipartRequest('POST', uri);

    request.files.add(
      http.MultipartFile.fromBytes('arquivo', bytes, filename: arquivo.name),
    );

    final response = await request.send();

    final corpo = await response.stream.bytesToString();

    Map<String, dynamic>? json;

    try {
      json = jsonDecode(corpo);
    } catch (_) {
      json = null;
    }

    if (response.statusCode != 200) {
      if (json != null && json['detail'] != null) {
        throw Exception(json['detail'].toString());
      }

      throw Exception('Erro ao importar o arquivo.');
    }

    if (json == null) {
      throw Exception('Resposta inválida do servidor.');
    }

    return json;
  }
}
