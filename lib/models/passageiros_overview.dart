class DemandaPonto {
  final String rotulo; // ex.: "08h"
  final double volume;
  final bool anomalia;
  final String? titulo; // ex.: "Queda Brusca"
  final String? detalhe; // ex.: "11:30 - Queda de 40% vs média móvel..."

  const DemandaPonto({
    required this.rotulo,
    required this.volume,
    this.anomalia = false,
    this.titulo,
    this.detalhe,
  });

  factory DemandaPonto.fromJson(Map<String, dynamic> j) => DemandaPonto(
        rotulo: j['rotulo'] as String,
        volume: (j['volume'] as num).toDouble(),
        anomalia: j['anomalia'] as bool? ?? false,
        titulo: j['titulo'] as String?,
        detalhe: j['detalhe'] as String?,
      );
}

class CategoriaTarifaria {
  final String nome; // "Comum (Integral)"
  final double volume;
  final double percentual; // 0 a 100
  final String status; // 'ativo' | 'inativo'

  const CategoriaTarifaria({
    required this.nome,
    required this.volume,
    required this.percentual,
    required this.status,
  });

  factory CategoriaTarifaria.fromJson(Map<String, dynamic> j) =>
      CategoriaTarifaria(
        nome: j['nome'] as String,
        volume: (j['volume'] as num).toDouble(),
        percentual: (j['percentual'] as num).toDouble(),
        status: j['status'] as String? ?? 'ativo',
      );
}

class PassageirosOverview {
  final Map<String,dynamic>? meta;
  final double? totalPassageiros;
  final double? totalVariacao; // % vs período anterior
  final double? pctPagantes; // 0 a 100
  final double? qtdPagantes;
  final double? pctGratuidades; // 0 a 100
  final double? qtdGratuidades;
  final String? picoFaixa; // "07:00 - 08:30"
  final double? picoMediaHora;
  final List<DemandaPonto> serie;
  final List<CategoriaTarifaria> categorias;

  const PassageirosOverview({
    this.meta,
    this.totalPassageiros,
    this.totalVariacao,
    this.pctPagantes,
    this.qtdPagantes,
    this.pctGratuidades,
    this.qtdGratuidades,
    this.picoFaixa,
    this.picoMediaHora,
    this.serie = const [],
    this.categorias = const [],
  });

  factory PassageirosOverview.empty() => const PassageirosOverview();

  factory PassageirosOverview.fromJson(Map<String, dynamic> j) {
    final total = j['total_passageiros'] as Map<String, dynamic>?;
    final pag = j['pagantes'] as Map<String, dynamic>?;
    final grat = j['gratuidades'] as Map<String, dynamic>?;
    final pico = j['pico_demanda'] as Map<String, dynamic>?;

    return PassageirosOverview(
      meta: j['meta'] as Map<String,dynamic>?,
      totalPassageiros: (total?['valor'] as num?)?.toDouble(),
      totalVariacao: (total?['variacao'] as num?)?.toDouble(),
      pctPagantes: (pag?['percentual'] as num?)?.toDouble(),
      qtdPagantes: (pag?['quantidade'] as num?)?.toDouble(),
      pctGratuidades: (grat?['percentual'] as num?)?.toDouble(),
      qtdGratuidades: (grat?['quantidade'] as num?)?.toDouble(),
      picoFaixa: pico?['faixa'] as String?,
      picoMediaHora: (pico?['media_hora'] as num?)?.toDouble(),
      serie: ((j['serie'] as List?) ?? [])
          .map((e) => DemandaPonto.fromJson(e))
          .toList(),
      categorias: ((j['categorias'] as List?) ?? [])
          .map((e) => CategoriaTarifaria.fromJson(e))
          .toList(),
    );
  }
}
