import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/financeiro_overview.dart';
import 'dashboard_service.dart';

class FinanceiroService {
  Future<FinanceiroDashboard> getOverview({
    required String mes,
    required String periodo,
    String busca = '',
    int pagina = 1,
  }) async {
    final uri = Uri.parse('${DashboardService.baseUrl}/financeiro/overview')
        .replace(
          queryParameters: {
            'mes': mes,
            'periodo': periodo,
            'busca': busca,
            'pagina': '$pagina',
          },
        );
    final res = await http.get(uri).timeout(const Duration(seconds: 20));
    if (res.statusCode != 200)
      throw Exception(
        'Não foi possível carregar o financeiro (${res.statusCode}).',
      );
    return FinanceiroDashboard.fromJson(
      jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>,
    );
  }
}
