import 'dart:convert';

import 'package:http/http.dart' as http;

import 'dashboard_service.dart';

class AuthService {
  Future<Map<String, dynamic>> login({
    required String email,
    required String senha,
  }) async {
    final uri = Uri.parse('${DashboardService.baseUrl}/auth/login');

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'senha': senha}),
    );

    final corpo = jsonDecode(response.body);

    if (response.statusCode != 200) {
      final mensagem = corpo['detail'] ?? 'Não foi possível realizar o login.';

      throw Exception(mensagem.toString());
    }

    return Map<String, dynamic>.from(corpo);
  }
}
