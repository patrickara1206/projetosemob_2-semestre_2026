import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/passageiros_overview.dart';
import 'dashboard_service.dart';

class PassageirosService {
  Future<PassageirosOverview> getOverview({required String periodo}) async {
    if (DashboardService.usarVazio) {
      await Future.delayed(const Duration(milliseconds: 300));
      return PassageirosOverview.empty();
    }

    final uri = Uri.parse(
      '${DashboardService.baseUrl}/passageiros/overview',
    ).replace(queryParameters: {'periodo': periodo});
    final res = await http.get(uri);

    if (res.statusCode != 200) {
      throw Exception('Erro ao carregar dados (${res.statusCode})');
    }
    return PassageirosOverview.fromJson(
      jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>,
    );
  }
}
