import 'package:flutter/foundation.dart';

enum Periodo {
  total('Todos os dados', 'total'),
  mes('Mensal', 'mes'),
  quinzena('Quinzenal', 'quinzena');

  final String label;
  final String api;

  const Periodo(this.label, this.api);
}

class PeriodoNotifier extends ValueNotifier<Periodo> {
  PeriodoNotifier() : super(Periodo.mes);

  String mesReferencia = '2026-08';

  void aplicarFiltro(
    Periodo periodo, {
    String? mes,
  }) {
    if (mes != null) {
      mesReferencia = mes;
    }

    if (value != periodo) {
      value = periodo;
    } else {
      notifyListeners();
    }
  }

  void selecionarPeriodo(Periodo periodo) {
    aplicarFiltro(periodo);
  }

  void selecionarMes(String mes) {
    aplicarFiltro(
      value,
      mes: mes,
    );
  }

  void atualizar() {
    notifyListeners();
  }

  Map<String, String> get parametros {
    if (value == Periodo.total) {
      return {
        'escopo': 'total',
      };
    }

    return {
      'escopo': value.api,
      'mes': mesReferencia,
    };
  }
}

final periodoNotifier = PeriodoNotifier();