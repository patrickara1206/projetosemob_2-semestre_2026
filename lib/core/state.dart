import 'package:flutter/foundation.dart';

enum Periodo {
  hoje('Dia', 'dia'),
  semana('Semana', 'semana'),
  mes('Mês', 'mes'),
  personalizado('Personalizado', 'personalizado');

  final String label;
  final String api; // valor enviado ao backend
  const Periodo(this.label, this.api);
}

/// Período selecionado na barra superior. As telas escutam este notifier
/// e recarregam os dados quando ele muda.
class FilterState extends ValueNotifier<Periodo> {
  FilterState() : super(Periodo.mes);
  String mes = '2026-08';
  String referencia = '2026-08-31';
  String? inicio;
  String? fim;
  String? linha;
  Map<String,dynamic>? metadata;
  Map<String,String> get query => {
    'periodo':value.api,'mes':mes,'referencia':referencia,
    'inicio':?inicio, 'fim':?fim,
    'linha':?linha,
  };
  void refresh() => notifyListeners();
}

final periodoNotifier = FilterState();
