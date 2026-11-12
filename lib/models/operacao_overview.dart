
class KmMes {
  final String rotulo;
  final double produtiva;
  final double morta;

  const KmMes({
    required this.rotulo,
    required this.produtiva,
    required this.morta,
  });

  factory KmMes.fromJson(Map<String, dynamic> j) => KmMes(
        rotulo: j['rotulo']?.toString() ?? '--',
        produtiva: (j['produtiva'] as num?)?.toDouble() ?? 0,
        morta: (j['morta'] as num?)?.toDouble() ?? 0,
      );
}

class ViagensHora {
  final String rotulo;
  final double viagens;
  final bool pico;

  const ViagensHora({
    required this.rotulo,
    required this.viagens,
    this.pico = false,
  });

  factory ViagensHora.fromJson(Map<String, dynamic> j) => ViagensHora(
        rotulo: j['rotulo'] as String,
        viagens: (j['viagens'] as num).toDouble(),
        pico: j['pico'] as bool? ?? false,
      );
}

class AnomaliaOp {
  final String idRota;
  final String tipo;
  final String veiculo;
  final String severidade;
  final String acao;

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

class RegistroOperacao {
  final String data;
  final int? veiculos;
  final int? programadas;
  final int? realizadas;
  final double? kmProdutiva;
  final double? kmMorta;

  const RegistroOperacao({
    required this.data,
    this.veiculos,
    this.programadas,
    this.realizadas,
    this.kmProdutiva,
    this.kmMorta,
  });

  factory RegistroOperacao.fromJson(Map<String, dynamic> j) {
    return RegistroOperacao(
      data: j['data']?.toString() ?? '--',
      veiculos: (j['veiculos'] as num?)?.toInt(),
      programadas: (j['viagens_programadas'] as num?)?.toInt(),
      realizadas: (j['viagens_realizadas'] as num?)?.toInt(),
      kmProdutiva: (j['km_produtiva'] as num?)?.toDouble(),
      kmMorta: (j['km_morta'] as num?)?.toDouble(),
    );
  }
}

class OperacaoOverview {
  final int? viagensRealizadas;
  final int? viagensProgramadas;
  final double? pontualidade;
  final double? pontualidadeVariacao;
  final double? metaPontualidade;
  final double? kmProdutiva;
  final double? kmMorta;
  final List<KmMes> kmMensal;
  final List<ViagensHora> viagensHora;
  final List<AnomaliaOp> anomalias;
  final List<RegistroOperacao> registrosDiarios;

  const OperacaoOverview({
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
    this.registrosDiarios = const [],
  });

  factory OperacaoOverview.empty() => const OperacaoOverview();

  double? get execucao {
    final r = viagensRealizadas;
    final p = viagensProgramadas;

    if (r == null || p == null || p == 0) {
      return null;
    }

    return r / p;
  }

  factory OperacaoOverview.fromJson(Map<String, dynamic> j) {
    final viagens = j['total_viagens'] as Map<String, dynamic>?;
    final pont = j['pontualidade'] as Map<String, dynamic>?;
    final km = j['quilometragem'] as Map<String, dynamic>?;

    return OperacaoOverview(
      viagensRealizadas: (viagens?['realizado'] as num?)?.toInt(),
      viagensProgramadas: (viagens?['programado'] as num?)?.toInt(),
      pontualidade: (pont?['valor'] as num?)?.toDouble(),
      pontualidadeVariacao: (pont?['variacao'] as num?)?.toDouble(),
      metaPontualidade: (pont?['meta'] as num?)?.toDouble(),
      kmProdutiva: (km?['produtiva'] as num?)?.toDouble(),
      kmMorta: (km?['morta'] as num?)?.toDouble(),
      kmMensal: ((j['km_mensal'] as List?) ?? [])
          .map((e) => KmMes.fromJson(e as Map<String, dynamic>))
          .toList(),
      viagensHora: ((j['viagens_por_hora'] as List?) ?? [])
          .map((e) => ViagensHora.fromJson(e as Map<String, dynamic>))
          .toList(),
      anomalias: ((j['anomalias'] as List?) ?? [])
          .map((e) => AnomaliaOp.fromJson(e as Map<String, dynamic>))
          .toList(),
      registrosDiarios: ((j['registros_diarios'] as List?) ?? [])
          .map(
            (e) => RegistroOperacao.fromJson(
              e as Map<String, dynamic>,
            ),
          )
          .toList(),
    );
  }
}
