import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/operacao_overview.dart';
import 'dashboard_service.dart';

class OperacaoService {
  Future<OperacaoOverview> getOverview({required String periodo}) async {
    // Usa a mesma chave da tela inicial: true = sem backend (mostra "--")
    if (DashboardService.usarVazio) {
      await Future.delayed(const Duration(milliseconds: 300));
      return OperacaoOverview.empty();
    }

    final uri = Uri.parse('${DashboardService.baseUrl}/operacao/overview')
        .replace(queryParameters: {'periodo': periodo});
    final res = await http.get(uri);

    if (res.statusCode != 200) {
      throw Exception('Erro ao carregar dados (${res.statusCode})');
    }
    return OperacaoOverview.fromJson(
      jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>,
    );
  }
}