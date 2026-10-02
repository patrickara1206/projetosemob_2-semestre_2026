import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../core/state.dart';

class ApiService {
  static const baseUrl = String.fromEnvironment('API_BASE_URL', defaultValue: 'http://127.0.0.1:8001');
  static http.Client client = http.Client();
  static Uri uri(String path, {bool filtered = true, Map<String, String> extra = const {}}) =>
      Uri.parse('$baseUrl$path').replace(queryParameters: {...(filtered ? periodoNotifier.query : <String,String>{}), ...extra});

  static Future<Map<String,dynamic>> get(String path, {bool filtered = true, Map<String,String> extra = const {}}) async {
    try {
      final response = await client.get(uri(path,filtered:filtered,extra:extra)).timeout(const Duration(seconds:30));
      if (response.statusCode != 200) {
        final message = jsonDecode(utf8.decode(response.bodyBytes));
        throw Exception(message['detail'] ?? 'Falha ao consultar os dados.');
      }
      return jsonDecode(utf8.decode(response.bodyBytes)) as Map<String,dynamic>;
    } on http.ClientException {
      throw Exception('Não foi possível acessar a API. Inicie o backend e tente novamente.');
    }
  }

  static Future<void> export() async {
    if (!await launchUrl(uri('/export.csv'),mode:LaunchMode.externalApplication)) {
      throw Exception('Não foi possível abrir a exportação.');
    }
  }
}
