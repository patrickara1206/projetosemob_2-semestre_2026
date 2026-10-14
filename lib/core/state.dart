import 'package:flutter/foundation.dart';

enum Periodo {
  hoje('Hoje', 'hoje'),
  semana('Semana', 'semana'),
  mes('Mês', 'mes'),
  personalizado('Personalizado', 'personalizado');

  final String label;
  final String api;
  const Periodo(this.label, this.api);
}

class PeriodoNotifier extends ValueNotifier<Periodo> {
  PeriodoNotifier() : super(Periodo.hoje);

  void atualizar() => notifyListeners();
}

final periodoNotifier = PeriodoNotifier();
