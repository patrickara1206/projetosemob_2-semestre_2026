import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _authKey = 'semob_usuario_logado';

final authNotifier = ValueNotifier<bool>(false);

Future<void> carregarEstadoLogin() async {
  final prefs = await SharedPreferences.getInstance();

  authNotifier.value =
      prefs.getBool(_authKey) ?? false;
}

Future<void> definirUsuarioLogado(
  bool logado,
) async {
  final prefs = await SharedPreferences.getInstance();

  if (logado) {
    await prefs.setBool(_authKey, true);
  } else {
    await prefs.remove(_authKey);
  }

  authNotifier.value = logado;
}