import 'package:flutter/foundation.dart';

enum Periodo {
  hoje('Último dia', 'hoje'),
  semana('Últimos 7 dias', 'semana'),
  mes('Mês completo', 'mes'),
  personalizado('Personalizado', 'personalizado');

  final String label;
  final String api; // valor enviado ao backend
  const Periodo(this.label, this.api);
}

/// Período selecionado na barra superior. As telas escutam este notifier
/// e recarregam os dados quando ele muda.
class PeriodoNotifier extends ValueNotifier<Periodo> {
  PeriodoNotifier() : super(Periodo.mes);

  String mesReferencia = '2026-08';
  DateTime? inicio;
  DateTime? fim;

  void selecionarMes(String mes) {
    mesReferencia = mes;
    inicio = null;
    fim = null;
    if (value == Periodo.mes) {
      recarregar();
    } else {
      value = Periodo.mes;
    }
  }

  void selecionarIntervalo(DateTime primeiro, DateTime ultimo) {
    inicio = primeiro;
    fim = ultimo;
    if (value == Periodo.personalizado) {
      recarregar();
    } else {
      value = Periodo.personalizado;
    }
  }

  void recarregar() => notifyListeners();

  void atualizar() => recarregar();

  Map<String, String> get parametros => {
    'mes': mesReferencia,
    if (value == Periodo.personalizado && inicio != null && fim != null) ...{
      'inicio': inicio!.toIso8601String().substring(0, 10),
      'fim': fim!.toIso8601String().substring(0, 10),
    },
  };
}

final periodoNotifier = PeriodoNotifier();
