import 'dart:convert';
import '../core/state.dart';
import 'package:http/http.dart' as http;

import '../models/passageiros_overview.dart';
import 'dashboard_service.dart';

class PassageirosService {
  Future<PassageirosOverview> getOverview({required String periodo}) async {
    // Mesma chave das outras telas: true = sem backend (mostra "--")
    if (DashboardService.usarVazio) {
      await Future.delayed(const Duration(milliseconds: 300));
      return PassageirosOverview.empty();
    }

    final uri = Uri.parse('${DashboardService.baseUrl}/passageiros/overview')
        .replace(queryParameters: {...periodoNotifier.parametros, 'periodo': periodo});
    final res = await http.get(uri).timeout(const Duration(seconds: 20));

    if (res.statusCode != 200) {
      throw Exception('Erro ao carregar dados (${res.statusCode})');
    }
    return PassageirosOverview.fromJson(
      jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>,
    );
  }
}