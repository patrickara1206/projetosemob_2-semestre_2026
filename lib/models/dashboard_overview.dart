class Kpi {
  final double? valor;
  final double? variacao;

  const Kpi({this.valor, this.variacao});

  factory Kpi.fromJson(Map<String, dynamic>? j) => Kpi(
    valor: (j?['valor'] as num?)?.toDouble(),
    variacao: (j?['variacao'] as num?)?.toDouble(),
  );
}

class SeriePonto {
  final String rotulo;
  final double realizado;
  final double esperado;
  final bool anomalia;

  const SeriePonto({
    required this.rotulo,
    required this.realizado,
    required this.esperado,
    this.anomalia = false,
  });

  factory SeriePonto.fromJson(Map<String, dynamic> j) => SeriePonto(
    rotulo: j['rotulo'] as String,
    realizado: (j['realizado'] as num).toDouble(),
    esperado: (j['esperado'] as num).toDouble(),
    anomalia: j['anomalia'] as bool? ?? false,
  );
}

class Anomalia {
  final String titulo;
  final String observado;
  final String esperado;
  final double desvio;
  final double score;
  final String severidade;

  const Anomalia({
    required this.titulo,
    required this.observado,
    required this.esperado,
    required this.desvio,
    required this.score,
    required this.severidade,
  });

  factory Anomalia.fromJson(Map<String, dynamic> j) => Anomalia(
    titulo: j['titulo'] as String,
    observado: j['observado'].toString(),
    esperado: j['esperado'].toString(),
    desvio: (j['desvio'] as num).toDouble(),
    score: (j['score'] as num).toDouble(),
    severidade: j['severidade'] as String? ?? 'media',
  );
}

class InteligenciaOperacional {
  final double? cumprimentoProgramacao;
  final int? viagensNaoRealizadas;
  final int? diasComDesvio;
  final int? diasAnalisados;

  const InteligenciaOperacional({
    this.cumprimentoProgramacao,
    this.viagensNaoRealizadas,
    this.diasComDesvio,
    this.diasAnalisados,
  });

  factory InteligenciaOperacional.fromJson(Map<String, dynamic>? j) {
    return InteligenciaOperacional(
      cumprimentoProgramacao: (j?['cumprimento_programacao'] as num?)
          ?.toDouble(),
      viagensNaoRealizadas: (j?['viagens_nao_realizadas'] as num?)?.toInt(),
      diasComDesvio: (j?['dias_com_desvio'] as num?)?.toInt(),
      diasAnalisados: (j?['dias_analisados'] as num?)?.toInt(),
    );
  }
}

class DashboardOverview {
  final Kpi quilometragem;
  final Kpi viagens;
  final Kpi passageirosPagantes;
  final Kpi passageirosNaoPagantes;
  final Kpi financeiro;
  final List<SeriePonto> serie;
  final List<Anomalia> anomalias;
  final InteligenciaOperacional inteligencia;
  final String? statusModelo;

  const DashboardOverview({
    this.quilometragem = const Kpi(),
    this.viagens = const Kpi(),
    this.passageirosPagantes = const Kpi(),
    this.passageirosNaoPagantes = const Kpi(),
    this.financeiro = const Kpi(),
    this.serie = const [],
    this.anomalias = const [],
    this.inteligencia = const InteligenciaOperacional(),
    this.statusModelo,
  });

  factory DashboardOverview.empty() => const DashboardOverview();

  factory DashboardOverview.fromJson(Map<String, dynamic> j) =>
      DashboardOverview(
        quilometragem: Kpi.fromJson(j['quilometragem']),
        viagens: Kpi.fromJson(j['viagens']),
        passageirosPagantes: Kpi.fromJson(j['passageiros_pagantes']),
        passageirosNaoPagantes: Kpi.fromJson(j['passageiros_nao_pagantes']),
        financeiro: Kpi.fromJson(j['financeiro']),
        serie: ((j['serie'] as List?) ?? [])
            .map((e) => SeriePonto.fromJson(e))
            .toList(),
        anomalias: ((j['anomalias'] as List?) ?? [])
            .map((e) => Anomalia.fromJson(e))
            .toList(),
        inteligencia: InteligenciaOperacional.fromJson(j['inteligencia']),
        statusModelo: j['status_modelo'] as String?,
      );
}
