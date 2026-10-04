import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/dashboard_overview.dart';

class DashboardService {
  /// Web/desktop: http://localhost:8000
  /// Emulador Android: http://10.0.2.2:8000
  static const String baseUrl = 'http://localhost:8000';

  /// Enquanto o backend não existe, deixe true (tela mostra "--").
  /// Quando o FastAPI estiver pronto, troque para false.
  static const bool usarVazio = false;

  Future<DashboardOverview> getOverview({
    required String periodo,
    required String mes,
  }) async {
    if (usarVazio) {
      await Future.delayed(
        const Duration(milliseconds: 300),
      );

      return DashboardOverview.empty();
    }

    final uri = Uri.parse(
      '$baseUrl/dashboard/overview',
    ).replace(
      queryParameters: {
        'periodo': periodo,
        'mes': mes,
      },
    );

    final res = await http.get(uri);

    if (res.statusCode != 200) {
      throw Exception(
        'Erro ao carregar dados (${res.statusCode})',
      );
    }

    return DashboardOverview.fromJson(
      jsonDecode(
        utf8.decode(res.bodyBytes),
      ) as Map<String, dynamic>,
    );
  }
}