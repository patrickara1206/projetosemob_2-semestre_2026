import 'package:flutter/material.dart';

class ConfiguracoesPage extends StatelessWidget {
  const ConfiguracoesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          'Configurações',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}