import 'package:flutter/material.dart';

import '../core/formatters.dart';
import '../core/state.dart';
import '../core/theme.dart';
import '../models/financeiro_overview.dart';
import '../services/financeiro_service.dart';
import '../widgets/financeiro_detalhes.dart';

class FinanceiroPage extends StatefulWidget {
  const FinanceiroPage({super.key});

  @override
  State<FinanceiroPage> createState() => _FinanceiroPageState();
}

class _FinanceiroPageState extends State<FinanceiroPage> {
  final _service = FinanceiroService();

  FinanceiroOverview? _data;
  String? _erro;
  bool _carregando = false;
  int _req = 0;

  @override
  void initState() {
    super.initState();
    _load();
    periodoNotifier.addListener(_onPeriodo);
  }

  @override
  void dispose() {
    periodoNotifier.removeListener(_onPeriodo);
    super.dispose();
  }

  void _onPeriodo() {
    _load();
  }

  Future<void> _load() async {
    final id = ++_req;

    setState(() {
      _erro = null;
      _carregando = true;
    });

    try {
      final dados = await _service.getOverview(
        periodo: 'mes',
        mes: '2026-08',
      );

      if (!mounted || id != _req) return;

      setState(() => _data = dados);
    } catch (erro) {
      if (!mounted || id != _req) return;

      setState(() {
        _erro = erro.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted && id == _req) {
        setState(() => _carregando = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dados = _data;

    if (dados == null) {
      if (_erro == null) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      }

      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                color: AppColors.red,
                size: 40,
              ),
              const SizedBox(height: 12),
              Text(
                _erro!,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _carregando ? null : _load,
                child: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, box) {
        final largura = box.maxWidth;
        final padding = largura < 700 ? 16.0 : 24.0;
        const gap = 16.0;
        final colunas = largura >= 800 ? 3 : 1;
        final larguraCartao =
            (largura - padding * 2 - gap * (colunas - 1)) / colunas;

        return SingleChildScrollView(
          padding: EdgeInsets.all(padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _header(),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: cardDecoration(),
                child: const Text(
                  'Mês de referência: agosto de 2026 • Totais mensais',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.muted,
                  ),
                ),
              ),
              if (_carregando) ...[
                const SizedBox(height: 12),
                const LinearProgressIndicator(),
              ],
              if (_erro != null) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.redSoft,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _erro!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.red,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 16),
              Wrap(
                spacing: gap,
                runSpacing: gap,
                children: [
                  SizedBox(
                    width: larguraCartao,
                    child: _Kpi(
                      title: 'VENDAS DE CRÉDITOS',
                      icon: Icons.payments_outlined,
                      iconColor: AppColors.primary,
                      iconBg: const Color(0xFFE3EEFB),
                      value: fmtMoney(dados.totalVendas),
                      note: 'Total de vendas no mês selecionado',
                    ),
                  ),
                  SizedBox(
                    width: larguraCartao,
                    child: _Kpi(
                      title: 'UTILIZAÇÃO DE CRÉDITOS',
                      icon: Icons.directions_bus_outlined,
                      iconColor: AppColors.navy,
                      iconBg: const Color(0xFFE3E8FA),
                      value: fmtMoney(dados.totalUtilizacao),
                      note: 'Total utilizado no mês selecionado',
                    ),
                  ),
                  SizedBox(
                    width: larguraCartao,
                    child: _Kpi(
                      title: 'CRÉDITO CIRCULANTE',
                      icon: Icons.account_balance_wallet_outlined,
                      iconColor: AppColors.green,
                      iconBg: AppColors.greenSoft,
                      value: fmtMoney(dados.creditoCirculante),
                      note: 'Soma dos valores diários do mês selecionado',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              FinanceiroDetalhes(
                dias: dados.diasFinanceiros,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _header() {
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 16,
      runSpacing: 12,
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'FINANCEIRO / SEMOB-SCS',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
            SizedBox(height: 6),
            Text(
              'Gestão Financeira',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: AppColors.navy,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Vendas, utilização e crédito circulante '
              'dos relatórios importados.',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.muted,
              ),
            ),
          ],
        ),
        OutlinedButton.icon(
          onPressed: _carregando ? null : _load,
          icon: const Icon(Icons.refresh, size: 18),
          label: const Text('Atualizar dados'),
        ),
      ],
    );
  }
}

class _Kpi extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String value;
  final String note;

  const _Kpi({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.value,
    required this.note,
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
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF374151),
                  ),
                ),
              ),
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  size: 16,
                  color: iconColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: AppColors.navy,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            note,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.muted,
            ),
          ),
        ],
      ),
    );
  }
}