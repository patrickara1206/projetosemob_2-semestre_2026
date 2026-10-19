import 'dart:convert';

import 'package:http/http.dart' as http;

import '../core/state.dart';
import '../models/dashboard_overview.dart';

class DashboardService {
  static const String baseUrl =
      String.fromEnvironment(
    'API_URL',
    defaultValue: 'http://127.0.0.1:8000',
  );

  static const bool usarVazio = false;

  Future<DashboardOverview> getOverview() async {
    if (usarVazio) {
      await Future.delayed(
        const Duration(milliseconds: 300),
      );

      return DashboardOverview.empty();
    }

    final uri = Uri.parse(
      '$baseUrl/dashboard/overview',
    ).replace(
      queryParameters:
          periodoNotifier.parametros,
    );

    final res = await http.get(uri);

    if (res.statusCode != 200) {
      throw Exception(
        'Erro ao carregar dados '
        '(${res.statusCode})',
      );
    }

    return DashboardOverview.fromJson(
      jsonDecode(
        utf8.decode(res.bodyBytes),
      ) as Map<String, dynamic>,
    );
  }

  Future<List<String>>
      getMesesDisponiveis() async {
    final dados =
        await getFiltrosDisponiveis();

    return ((dados['meses'] as List?) ?? [])
        .map(
          (item) => item.toString(),
        )
        .toList();
  }

  Future<Map<String, dynamic>>
      getFiltrosDisponiveis() async {
    final uri = Uri.parse(
      '$baseUrl/dashboard/meses',
    );

    final res = await http.get(uri);

    if (res.statusCode != 200) {
      throw Exception(
        'Erro ao carregar filtros '
        '(${res.statusCode})',
      );
    }

    return jsonDecode(
      utf8.decode(res.bodyBytes),
    ) as Map<String, dynamic>;
  }

  Future<Map<String, List<String>>>
      getPeriodosDisponiveis() async {
    final dados =
        await getFiltrosDisponiveis();

    final periodosJson =
        (dados['periodos']
                as Map<String, dynamic>?) ??
            {};

    final resultado =
        <String, List<String>>{};

    for (final entry
        in periodosJson.entries) {
      resultado[entry.key] =
          ((entry.value as List?) ?? [])
              .map(
                (item) => item.toString(),
              )
              .toList();
    }

    return resultado;
  }
}