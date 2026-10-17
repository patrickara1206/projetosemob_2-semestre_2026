import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import '../core/auth_state.dart';
import '../core/theme.dart';
import '../core/state.dart';
import '../services/dashboard_service.dart';

class ConfiguracoesPage extends StatefulWidget {
  const ConfiguracoesPage({super.key});
  @override
  State<ConfiguracoesPage> createState() => _ConfiguracoesPageState();
}

class _ConfiguracoesPageState extends State<ConfiguracoesPage> {
  late Future<String> _status;
  final _mes = TextEditingController(text: periodoNotifier.mesReferencia);
  String? _erroMes;
  @override
  void initState() {
    super.initState();
    _status = _verificar();
  }

  @override
  void dispose() {
    _mes.dispose();
    super.dispose();
  }

  void _aplicarMes() {
    final mes = _mes.text.trim();
    if (!RegExp(r'^\d{4}-(0[1-9]|1[0-2])$').hasMatch(mes)) {
      setState(() => _erroMes = 'Informe um mês no formato AAAA-MM.');
      return;
    }
    setState(() => _erroMes = null);
    periodoNotifier.selecionarMes(mes);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mês dos indicadores atualizado.')));
  }

  Future<String> _verificar() async {
    try {
      final result = await http.get(Uri.parse('${DashboardService.baseUrl}/openapi.json'))
          .timeout(const Duration(seconds: 10));
      if (result.statusCode != 200) return 'Não foi possível verificar o servidor.';
      final paths = jsonDecode(result.body)['paths'] as Map<String, dynamic>;
      return paths.containsKey('/financeiro/overview')
          ? 'Servidor conectado. Financeiro disponível.'
          : 'Servidor conectado, mas a versão não possui o Financeiro. Inicie o backend de aprimoramentos.';
    } catch (_) {
      return 'Servidor indisponível. Verifique se o backend está iniciado.';
    }
  }

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.all(24),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Configurações', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: Theme.of(context).colorScheme.onSurface)),
      const SizedBox(height: 20),
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: cardDecoration(context),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Conexão com o servidor', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          SelectableText(DashboardService.baseUrl),
          const SizedBox(height: 16),
          FutureBuilder<String>(future: _status, builder: (context, snapshot) =>
            Text(snapshot.data ?? 'Verificando conexão...')),
          const SizedBox(height: 16),
          OutlinedButton(onPressed: () => setState(() => _status = _verificar()), child: const Text('Verificar novamente')),
        ]),
      ),
      const SizedBox(height: 20),
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: cardDecoration(context),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Mês dos indicadores', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          SizedBox(width: 200, child: TextField(controller: _mes,
            decoration: InputDecoration(labelText: 'AAAA-MM', errorText: _erroMes, border: const OutlineInputBorder()))),
          const SizedBox(height: 12),
          OutlinedButton(onPressed: _aplicarMes, child: const Text('Aplicar mês')),
        ]),
      ),
      const SizedBox(height: 20),
      FilledButton.icon(onPressed: () {
        authNotifier.value = false;
        context.go('/login');
      }, icon: const Icon(Icons.logout), label: const Text('Sair da conta')),
    ]),
  );
}
