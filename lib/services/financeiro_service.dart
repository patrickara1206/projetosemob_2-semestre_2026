import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/financeiro_overview.dart';
import 'dashboard_service.dart';

class FinanceiroService {
  Future<FinanceiroOverview> getOverview({
    required String periodo,
    String? concessionaria,
    String busca = '',
    int pagina = 1,
  }) async {
    // Mesma chave das outras telas: true = sem backend (mostra "--")
    if (DashboardService.usarVazio) {
      await Future.delayed(const Duration(milliseconds: 300));
      return FinanceiroOverview.empty();
    }

    final uri = Uri.parse('${DashboardService.baseUrl}/financeiro/overview')
        .replace(queryParameters: {
      'periodo': periodo,
      if (concessionaria != null) 'concessionaria': concessionaria,
      if (busca.isNotEmpty) 'busca': busca,
      'pagina': '$pagina',
    });

    final res = await http.get(uri);

    if (res.statusCode != 200) {
      throw Exception('Erro ao carregar dados (${res.statusCode})');
    }
    return FinanceiroOverview.fromJson(
      jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>,
    );
  }
}