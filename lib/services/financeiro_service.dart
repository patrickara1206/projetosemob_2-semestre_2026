import 'dart:convert';
import 'dart:async';
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
    http.Response res;
    try {
      res = await http.get(uri).timeout(const Duration(seconds: 20));
    } on TimeoutException {
      throw Exception('O servidor demorou a responder. Tente novamente.');
    } on http.ClientException {
      throw Exception('Não foi possível conectar ao servidor. Verifique se o backend está iniciado.');
    }
    if (res.statusCode == 404) {
      throw Exception('A versão do servidor não possui o Financeiro. Inicie o backend da branch aprimoramentos.');
    }
    if (res.statusCode != 200) {
      throw Exception(
        'Não foi possível carregar o financeiro (${res.statusCode}).',
      );
    }
    try {
      return FinanceiroDashboard.fromJson(
        jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>,
      );
    } on FormatException {
      throw Exception('O servidor retornou uma resposta inválida. Verifique a versão do backend.');
    } on TypeError {
      throw Exception('Os dados do Financeiro são incompatíveis. Atualize frontend e backend da mesma branch.');
    }
  }
}
