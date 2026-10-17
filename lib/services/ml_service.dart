import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/ml_overview.dart';
import 'dashboard_service.dart';

class MlService {
  Future<MlOverview> getOverview({required String periodo}) async {
    if (DashboardService.usarVazio) {
      await Future.delayed(const Duration(milliseconds: 300));
      return MlOverview.empty();
    }

    final uri = Uri.parse(
      '${DashboardService.baseUrl}/ml/overview',
    ).replace(queryParameters: {'periodo': periodo});
    final res = await http.get(uri);

    if (res.statusCode != 200) {
      throw Exception('Erro ao carregar dados (${res.statusCode})');
    }
    return MlOverview.fromJson(
      jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>,
    );
  }
}
