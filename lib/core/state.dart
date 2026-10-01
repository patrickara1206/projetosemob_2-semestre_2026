import 'package:flutter/foundation.dart';

enum Periodo {
  hoje('Hoje', 'hoje'),
  semana('Semana', 'semana'),
  mes('Mês', 'mes'),
  personalizado('Personalizado', 'personalizado');

  final String label;
  final String api; // valor enviado ao backend
  const Periodo(this.label, this.api);
}

/// Período selecionado na barra superior. As telas escutam este notifier
/// e recarregam os dados quando ele muda.
final ValueNotifier<Periodo> periodoNotifier = ValueNotifier(Periodo.hoje);