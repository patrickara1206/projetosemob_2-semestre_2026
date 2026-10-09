import 'dart:async';

import 'package:flutter/material.dart';

import '../core/formatters.dart';
import '../core/state.dart';
import '../core/theme.dart';
import '../models/financeiro_overview.dart';
import '../services/financeiro_service.dart';
import '../widgets/cost_distribution.dart';
import '../widgets/repasses_table.dart';
import '../widgets/revenue_subsidy_chart.dart';

class FinanceiroPage extends StatefulWidget {
  const FinanceiroPage({super.key});

  @override
  State<FinanceiroPage> createState() => _FinanceiroPageState();
}

class _FinanceiroPageState extends State<FinanceiroPage> {
  final _service = FinanceiroService();
  final _buscaCtrl = TextEditingController();
  Timer? _debounce;
  int _req = 0;

  FinanceiroOverview? _data;
  String? _erro;
  String? _concessionaria; // null = todas
  String _busca = '';
  int _pagina = 1;

  @override
  void initState() {
    super.initState();
    _load();
    periodoNotifier.addListener(_onPeriodo);
  }

  @override
  void dispose() {
    periodoNotifier.removeListener(_onPeriodo);
    _debounce?.cancel();
    _buscaCtrl.dispose();
    super.dispose();
  }

  void _onPeriodo() {
    _pagina = 1;
    _load();
  }

  Future<void> _load() async {
    final id = ++_req;
    setState(() => _erro = null);
    try {
      final d = await _service.getOverview(
        periodo: periodoNotifier.value.api,
        concessionaria: _concessionaria,
        busca: _busca,
        pagina: _pagina,
      );
      if (!mounted || id != _req) return;
      setState(() => _data = d);
    } catch (e) {
      if (!mounted || id != _req) return;
      setState(() => _erro = e.toString().replaceFirst('Exception: ', ''));
    }
  }

  void _onBusca(String v) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      _busca = v.trim();
      _pagina = 1;
      _load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final d = _data;

    if (d == null) {
      if (_erro != null) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: AppColors.red, size: 40),
              const SizedBox(height: 8),
              Text(_erro!),
              const SizedBox(height: 12),
              FilledButton(
                  onPressed: _load, child: const Text('Tentar novamente')),
            ],
          ),
        );
      }
      return const Center(child: CircularProgressIndicator());
    }

    return LayoutBuilder(builder: (context, box) {
      final w = box.maxWidth;
      final pad = w < 700 ? 16.0 : 24.0;
      const gap = 16.0;
      final cols = w >= 800 ? 3 : 1;
      final itemW = (w - pad * 2 - gap * (cols - 1)) / cols;
      final wide = w >= 1000;

      final chart = SizedBox(
          height: 380, child: RevenueSubsidyChart(serie: d.evolucao));
      final custos = SizedBox(
          height: 380,
          child: CostDistributionCard(itens: d.custos, total: d.custoTotal));

      return SingleChildScrollView(
        padding: EdgeInsets.all(pad),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_erro != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.redSoft,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(_erro!,
                    style:
                        const TextStyle(fontSize: 12, color: AppColors.red)),
              ),
              const SizedBox(height: 12),
            ],
            _header(),
            const SizedBox(height: 16),
            _filtros(d),
            const SizedBox(height: 16),
            ValueListenableBuilder<Periodo>(
              valueListenable: periodoNotifier,
              builder: (_, p, __) => Wrap(
                spacing: gap,
                runSpacing: gap,
                children: [
                  SizedBox(
                    width: itemW,
                    child: _Kpi(
                      title: 'RECEITA TARIFÁRIA',
                      icon: Icons.payments_outlined,
                      iconColor: AppColors.primary,
                      iconBg: const Color(0xFFE3EEFB),
                      value: fmtMoney(d.receita),
                      footer: _variacao(d.receitaVariacao, _refAnterior(p)),
                    ),
                  ),
                  SizedBox(
                    width: itemW,
                    child: _Kpi(
                      title: 'SUBSÍDIO COMPENSATÓRIO',
                      icon: Icons.account_balance_outlined,
                      iconColor: AppColors.navy,
                      iconBg: const Color(0xFFE3E8FA),
                      value: fmtMoney(d.subsidio),
                      footer: _nota('Gratuidades e equilíbrio tarifário'),
                    ),
                  ),
                  SizedBox(
                    width: itemW,
                    child: _Kpi(
                      title: 'SALDO LÍQUIDO DE REPASSE',
                      icon: Icons.check_circle_outline,
                      iconColor: AppColors.green,
                      iconBg: AppColors.greenSoft,
                      value: fmtMoney(d.saldoLiquido),
                      footer: d.saldoPctLiquidado == null
                          ? _nota('--')
                          : Row(
                              children: [
                                const Icon(Icons.check_circle_outline,
                                    size: 13, color: AppColors.green),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                      '${fmtDec(d.saldoPctLiquidado)}% liquidado e auditado',
                                      style: const TextStyle(
                                          fontSize: 11,
                                          color: AppColors.green)),
                                ),
                              ],
                            ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            if (wide)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 3, child: chart),
                  const SizedBox(width: 20),
                  Expanded(flex: 2, child: custos),
                ],
              )
            else ...[
              chart,
              const SizedBox(height: 16),
              custos,
            ],
            const SizedBox(height: 20),
            RepassesTable(
              linhas: d.repasses,
              pagina: d.pagina,
              totalPaginas: d.totalPaginas,
              buscaCtrl: _buscaCtrl,
              onBusca: _onBusca,
              onPagina: (p) {
                _pagina = p;
                _load();
              },
            ),
          ],
        ),
      );
    });
  }

  // ---------- Cabeçalho ----------

  Widget _header() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text.rich(
                TextSpan(children: [
                  TextSpan(
                      text: 'FINANCEIRO',
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary)),
                  TextSpan(
                      text: '  /  SEMOB-SCS',
                      style: TextStyle(color: AppColors.muted)),
                ]),
                style: TextStyle(fontSize: 10),
              ),
              const SizedBox(height: 6),
              const Text('Gestão Financeira',
                  style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: AppColors.navy)),
              const SizedBox(height: 4),
              const Text(
                'Visão consolidada de receitas tarifárias, subsídios '
                'municipais e repasses operacionais.',
                style: TextStyle(fontSize: 12, color: AppColors.muted),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        FilledButton.icon(
          onPressed: () {
            // TODO: exportar relatório (endpoint do backend)
          },
          style: FilledButton.styleFrom(backgroundColor: AppColors.navy),
          icon: const Icon(Icons.download, size: 16),
          label: const Text('Exportar Relatório'),
        ),
      ],
    );
  }

  // ---------- Barra de filtros ----------

  Widget _filtros(FinanceiroOverview d) {
    final valor = d.concessionarias.contains(_concessionaria)
        ? _concessionaria
        : null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: cardDecoration(),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 16,
        runSpacing: 12,
        children: [
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            runSpacing: 10,
            children: [
              ValueListenableBuilder<Periodo>(
                valueListenable: periodoNotifier,
                builder: (_, atual, __) => Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F3F6),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _seg('Hoje', Periodo.hoje, atual),
                      _seg('Semana', Periodo.semana, atual),
                      _seg('Mês atual', Periodo.mes, atual),
                    ],
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String?>(
                    value: valor,
                    isDense: true,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.text),
                    items: [
                      const DropdownMenuItem<String?>(
                          value: null,
                          child: Text('Todas as Concessionárias')),
                      for (final c in d.concessionarias)
                        DropdownMenuItem<String?>(value: c, child: Text(c)),
                    ],
                    onChanged: (v) {
                      _concessionaria = v;
                      _pagina = 1;
                      _load();
                    },
                  ),
                ),
              ),
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.circle, size: 7, color: AppColors.green),
              const SizedBox(width: 6),
              Text(
                d.conciliacao == null
                    ? 'Conciliação: --'
                    : 'Conciliação: ${fmtDec(d.conciliacao, digits: 0)}% conciliado',
                style: const TextStyle(fontSize: 11, color: AppColors.green),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _seg(String label, Periodo p, Periodo atual) {
    final ativo = p == atual;
    return InkWell(
      borderRadius: BorderRadius.circular(6),
      onTap: () => periodoNotifier.value = p,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: ativo ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          boxShadow: ativo
              ? const [
                  BoxShadow(
                      color: Color(0x14000000),
                      blurRadius: 4,
                      offset: Offset(0, 1))
                ]
              : null,
        ),
        child: Text(label,
            style: TextStyle(
                fontSize: 11,
                fontWeight: ativo ? FontWeight.w700 : FontWeight.w400,
                color: ativo ? AppColors.navy : AppColors.muted)),
      ),
    );
  }
}

String _refAnterior(Periodo p) {
  switch (p) {
    case Periodo.hoje:
      return 'dia anterior';
    case Periodo.semana:
      return 'semana anterior';
    case Periodo.mes:
      return 'mês anterior';
    case Periodo.personalizado:
      return 'período anterior';
  }
}

Widget _nota(String t) =>
    Text(t, style: const TextStyle(fontSize: 11, color: AppColors.muted));

Widget _variacao(double? v, String ref) {
  if (v == null) return _nota('--');
  final up = v >= 0;
  final color = up ? AppColors.green : AppColors.red;
  return Row(
    children: [
      Icon(up ? Icons.trending_up : Icons.trending_down,
          size: 14, color: color),
      const SizedBox(width: 4),
      Flexible(
        child: Text('${fmtPercent(v)} vs $ref',
            style: TextStyle(fontSize: 11, color: color)),
      ),
    ],
  );
}

class _Kpi extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String value;
  final Widget footer;

  const _Kpi({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.value,
    required this.footer,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(title,
                    style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF374151))),
              ),
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 16, color: iconColor),
              ),
            ],
          ),
          const SizedBox(height: 12),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(value,
                style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: AppColors.navy)),
          ),
          const SizedBox(height: 8),
          footer,
        ],
      ),
    );
  }
}