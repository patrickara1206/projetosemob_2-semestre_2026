class FinPonto {
  final String rotulo; // "MAI"
  final double receita;
  final double subsidio;
  final bool atual;

  const FinPonto({
    required this.rotulo,
    required this.receita,
    required this.subsidio,
    this.atual = false,
  });

  factory FinPonto.fromJson(Map<String, dynamic> j) => FinPonto(
        rotulo: j['rotulo'] as String,
        receita: (j['receita'] as num).toDouble(),
        subsidio: (j['subsidio'] as num).toDouble(),
        atual: j['atual'] as bool? ?? false,
      );
}

class CustoItem {
  final String nome; // "Pessoal & Encargos"
  final double percentual; // 0 a 100
  final double valor;

  const CustoItem(
      {required this.nome, required this.percentual, required this.valor});

  factory CustoItem.fromJson(Map<String, dynamic> j) => CustoItem(
        nome: j['nome'] as String,
        percentual: (j['percentual'] as num).toDouble(),
        valor: (j['valor'] as num).toDouble(),
      );
}

class RepasseLinha {
  final String linha; // "Linha 01 • Circular Centro/Bairro"
  final String operador; // "Viação Padre Anchieta"
  final double passageiros;
  final double custoOperacional;
  final double glosa; // valor positivo; o front mostra com sinal de menos
  final double valorLiquido;
  final String status; // 'liquidado' | 'auditoria' | 'retencao'

  const RepasseLinha({
    required this.linha,
    required this.operador,
    required this.passageiros,
    required this.custoOperacional,
    required this.glosa,
    required this.valorLiquido,
    required this.status,
  });

  factory RepasseLinha.fromJson(Map<String, dynamic> j) => RepasseLinha(
        linha: j['linha'] as String,
        operador: j['operador'] as String? ?? '',
        passageiros: (j['passageiros'] as num).toDouble(),
        custoOperacional: (j['custo_operacional'] as num).toDouble(),
        glosa: (j['glosa'] as num?)?.toDouble() ?? 0,
        valorLiquido: (j['valor_liquido'] as num).toDouble(),
        status: j['status'] as String? ?? 'liquidado',
      );
}

class FinanceiroOverview {
  final double? receita;
  final double? receitaVariacao; // % vs período anterior
  final double? subsidio;
  final double? saldoLiquido;
  final double? saldoPctLiquidado; // 0 a 100
  final double? conciliacao; // 0 a 100
  final List<String> concessionarias;
  final List<FinPonto> evolucao;
  final List<CustoItem> custos;
  final double? custoTotal;
  final List<RepasseLinha> repasses;
  final int pagina;
  final int totalPaginas;

  const FinanceiroOverview({
    this.receita,
    this.receitaVariacao,
    this.subsidio,
    this.saldoLiquido,
    this.saldoPctLiquidado,
    this.conciliacao,
    this.concessionarias = const [],
    this.evolucao = const [],
    this.custos = const [],
    this.custoTotal,
    this.repasses = const [],
    this.pagina = 1,
    this.totalPaginas = 1,
  });

  factory FinanceiroOverview.empty() => const FinanceiroOverview();

  factory FinanceiroOverview.fromJson(Map<String, dynamic> j) {
    final rec = j['receita_tarifaria'] as Map<String, dynamic>?;
    final sub = j['subsidio'] as Map<String, dynamic>?;
    final saldo = j['saldo_liquido'] as Map<String, dynamic>?;
    final custos = j['custos'] as Map<String, dynamic>?;
    final rep = j['repasses'] as Map<String, dynamic>?;

    return FinanceiroOverview(
      receita: (rec?['valor'] as num?)?.toDouble(),
      receitaVariacao: (rec?['variacao'] as num?)?.toDouble(),
      subsidio: (sub?['valor'] as num?)?.toDouble(),
      saldoLiquido: (saldo?['valor'] as num?)?.toDouble(),
      saldoPctLiquidado: (saldo?['percentual_liquidado'] as num?)?.toDouble(),
      conciliacao: (j['conciliacao'] as num?)?.toDouble(),
      concessionarias:
          ((j['concessionarias'] as List?) ?? []).map((e) => '$e').toList(),
      evolucao: ((j['evolucao'] as List?) ?? [])
          .map((e) => FinPonto.fromJson(e))
          .toList(),
      custos: ((custos?['itens'] as List?) ?? [])
          .map((e) => CustoItem.fromJson(e))
          .toList(),
      custoTotal: (custos?['total'] as num?)?.toDouble(),
      repasses: ((rep?['itens'] as List?) ?? [])
          .map((e) => RepasseLinha.fromJson(e))
          .toList(),
      pagina: rep?['pagina'] as int? ?? 1,
      totalPaginas: rep?['total_paginas'] as int? ?? 1,
    );
  }
}