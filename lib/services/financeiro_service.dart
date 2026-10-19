import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../core/state.dart';
import '../models/financeiro_overview.dart';
import 'dashboard_service.dart';

class FinanceiroService {
  Future<FinanceiroOverview> getOverview() async {
    if (DashboardService.usarVazio) {
      await Future.delayed(
        const Duration(milliseconds: 300),
      );

      return FinanceiroOverview.empty();
    }

    final uri = Uri.parse(
      '${DashboardService.baseUrl}/financeiro/overview',
    ).replace(
      queryParameters:
          periodoNotifier.parametros,
    );

    http.Response res;

    try {
      res = await http
          .get(uri)
          .timeout(
            const Duration(seconds: 20),
          );
    } on TimeoutException {
      throw Exception(
        'O servidor demorou a responder.',
      );
    } on http.ClientException {
      throw Exception(
        'Não foi possível conectar ao servidor.',
      );
    }

    if (res.statusCode != 200) {
      throw Exception(
        'Erro ao carregar dados (${res.statusCode})',
      );
    }

    return FinanceiroOverview.fromJson(
      jsonDecode(
        utf8.decode(res.bodyBytes),
      ) as Map<String, dynamic>,
    );
  }
}