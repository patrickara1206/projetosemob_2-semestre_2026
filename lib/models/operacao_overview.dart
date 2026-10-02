class KmMes {
  final String rotulo; // ex.: "Set"
  final double produtiva;
  final double morta;

  const KmMes(
      {required this.rotulo, required this.produtiva, required this.morta});

  factory KmMes.fromJson(Map<String, dynamic> j) => KmMes(
        rotulo: j['rotulo'] as String,
        produtiva: (j['produtiva'] as num).toDouble(),
        morta: (j['morta'] as num).toDouble(),
      );
}

class ViagensHora {
  final String rotulo; // ex.: "08:00"
  final double viagens;
  final bool pico;

  const ViagensHora(
      {required this.rotulo, required this.viagens, this.pico = false});

  factory ViagensHora.fromJson(Map<String, dynamic> j) => ViagensHora(
        rotulo: j['rotulo'] as String,
        viagens: (j['viagens'] as num).toDouble(),
        pico: j['pico'] as bool? ?? false,
      );
}

class AnomaliaOp {
  final String idRota; // "L-102 (Norte)"
  final String tipo; // "Viagem não iniciada (Atraso > 15m)"
  final String veiculo; // "BR-4452" ou "Múltiplos"
  final String severidade; // 'alta' | 'media'
  final String acao; // 'investigar' | 'notificar' | 'ajustar'

  const AnomaliaOp({
    required this.idRota,
    required this.tipo,
    required this.veiculo,
    required this.severidade,
    required this.acao,
  });

  factory AnomaliaOp.fromJson(Map<String, dynamic> j) => AnomaliaOp(
        idRota: j['id_rota'] as String,
        tipo: j['tipo'] as String,
        veiculo: j['veiculo'] as String,
        severidade: j['severidade'] as String? ?? 'media',
        acao: j['acao'] as String? ?? 'investigar',
      );
}

class OperacaoOverview {
  final Map<String,dynamic>? meta;
  final int? viagensRealizadas;
  final int? viagensProgramadas;
  final double? pontualidade; // %
  final double? pontualidadeVariacao; // % vs mês anterior
  final double? metaPontualidade; // %
  final double? kmProdutiva;
  final double? kmMorta;
  final List<KmMes> kmMensal;
  final List<ViagensHora> viagensHora;
  final List<AnomaliaOp> anomalias;

  const OperacaoOverview({
    this.meta,
    this.viagensRealizadas,
    this.viagensProgramadas,
    this.pontualidade,
    this.pontualidadeVariacao,
    this.metaPontualidade,
    this.kmProdutiva,
    this.kmMorta,
    this.kmMensal = const [],
    this.viagensHora = const [],
    this.anomalias = const [],
  });

  factory OperacaoOverview.empty() => const OperacaoOverview();

  /// 0 a 1. Nulo se não houver dados.
  double? get execucao {
    final r = viagensRealizadas;
    final p = viagensProgramadas;
    if (r == null || p == null || p == 0) return null;
    return r / p;
  }

  factory OperacaoOverview.fromJson(Map<String, dynamic> j) {
    final viagens = j['total_viagens'] as Map<String, dynamic>?;
    final pont = j['pontualidade'] as Map<String, dynamic>?;
    final km = j['quilometragem'] as Map<String, dynamic>?;

    return OperacaoOverview(
      meta: j['meta'] as Map<String,dynamic>?,
      viagensRealizadas: viagens?['realizado'] as int?,
      viagensProgramadas: viagens?['programado'] as int?,
      pontualidade: (pont?['valor'] as num?)?.toDouble(),
      pontualidadeVariacao: (pont?['variacao'] as num?)?.toDouble(),
      metaPontualidade: (pont?['meta'] as num?)?.toDouble(),
      kmProdutiva: (km?['produtiva'] as num?)?.toDouble(),
      kmMorta: (km?['morta'] as num?)?.toDouble(),
      kmMensal: ((j['km_mensal'] as List?) ?? [])
          .map((e) => KmMes.fromJson(e))
          .toList(),
      viagensHora: ((j['viagens_por_hora'] as List?) ?? [])
          .map((e) => ViagensHora.fromJson(e))
          .toList(),
      anomalias: ((j['anomalias'] as List?) ?? [])
          .map((e) => AnomaliaOp.fromJson(e))
          .toList(),
    );
  }
}
