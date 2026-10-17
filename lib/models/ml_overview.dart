class ScoreDia {
  final String rotulo;
  final double score;
  final bool destaque;

  const ScoreDia({
    required this.rotulo,
    required this.score,
    this.destaque = false,
  });

  factory ScoreDia.fromJson(Map<String, dynamic> j) => ScoreDia(
    rotulo: j['rotulo'] as String,
    score: (j['score'] as num).toDouble(),
    destaque: j['destaque'] as bool? ?? false,
  );
}

class FeatureImportance {
  final String nome;
  final String categoria;
  final double peso;

  const FeatureImportance({
    required this.nome,
    required this.categoria,
    required this.peso,
  });

  factory FeatureImportance.fromJson(Map<String, dynamic> j) =>
      FeatureImportance(
        nome: j['nome'] as String,
        categoria: j['categoria'] as String,
        peso: (j['peso'] as num).toDouble(),
      );
}

class LogIa {
  final String hora;
  final String mensagem;
  final String nivel;

  const LogIa({
    required this.hora,
    required this.mensagem,
    required this.nivel,
  });

  factory LogIa.fromJson(Map<String, dynamic> j) => LogIa(
    hora: j['hora'] as String,
    mensagem: j['mensagem'] as String,
    nivel: j['nivel'] as String? ?? 'info',
  );
}

class MlOverview {
  final double? previsoes;
  final double? previsoesVariacao;
  final int? anomalias24h;
  final double? scoreMedio;
  final double? scoreMeta;
  final DateTime? ultimoTreinamento;
  final String? statusModelo;
  final List<ScoreDia> scoreSerie;
  final List<FeatureImportance> features;
  final List<LogIa> logs;

  const MlOverview({
    this.previsoes,
    this.previsoesVariacao,
    this.anomalias24h,
    this.scoreMedio,
    this.scoreMeta,
    this.ultimoTreinamento,
    this.statusModelo,
    this.scoreSerie = const [],
    this.features = const [],
    this.logs = const [],
  });

  factory MlOverview.empty() => const MlOverview();

  factory MlOverview.fromJson(Map<String, dynamic> j) {
    final prev = j['previsoes'] as Map<String, dynamic>?;
    final anom = j['anomalias'] as Map<String, dynamic>?;
    final score = j['score'] as Map<String, dynamic>?;
    final treino = j['treinamento'] as Map<String, dynamic>?;

    return MlOverview(
      previsoes: (prev?['valor'] as num?)?.toDouble(),
      previsoesVariacao: (prev?['variacao'] as num?)?.toDouble(),
      anomalias24h: anom?['quantidade'] as int?,
      scoreMedio: (score?['valor'] as num?)?.toDouble(),
      scoreMeta: (score?['meta'] as num?)?.toDouble(),
      ultimoTreinamento: treino?['data'] == null
          ? null
          : DateTime.tryParse(treino!['data'] as String)?.toLocal(),
      statusModelo: treino?['status'] as String?,
      scoreSerie: ((j['score_serie'] as List?) ?? [])
          .map((e) => ScoreDia.fromJson(e))
          .toList(),
      features: ((j['features'] as List?) ?? [])
          .map((e) => FeatureImportance.fromJson(e))
          .toList(),
      logs: ((j['logs'] as List?) ?? []).map((e) => LogIa.fromJson(e)).toList(),
    );
  }
}
