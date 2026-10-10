import 'dart:async';
import 'package:flutter/material.dart';
import '../core/formatters.dart';
import '../core/theme.dart';
import '../models/financeiro_overview.dart';
import '../services/financeiro_service.dart';
import '../widgets/revenue_subsidy_chart.dart';

class FinanceiroPage extends StatefulWidget {
  const FinanceiroPage({super.key});
  @override
  State<FinanceiroPage> createState() => _FinanceiroPageState();
}

class _FinanceiroPageState extends State<FinanceiroPage> {
  final _service = FinanceiroService();
  final _mesCtrl = TextEditingController(text: '2026-08');
  final _buscaCtrl = TextEditingController();
  FinanceiroDashboard? _data;
  String _mes = '2026-08', _periodo = 'mes', _busca = '';
  int _pagina = 1, _request = 0;
  bool _loading = true;
  String? _error;
  Timer? _debounce;
  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _mesCtrl.dispose();
    _buscaCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final id = ++_request;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final result = await _service.getOverview(
        mes: _mes,
        periodo: _periodo,
        busca: _busca,
        pagina: _pagina,
      );
      if (!mounted || id != _request) return;
      setState(() {
        _data = result;
        _pagina = result.pagina;
      });
    } catch (e) {
      if (mounted && id == _request) {
        setState(() {
          _data = null;
          _error = e.toString().replaceFirst('Exception: ', '');
        });
      }
    } finally {
      if (mounted && id == _request) setState(() => _loading = false);
    }
  }

  void _applyMonth() {
    final month = _mesCtrl.text.trim();
    if (!RegExp(r'^\d{4}-(0[1-9]|1[0-2])$').hasMatch(month)) {
      setState(
        () => _error = 'Informe o mês no formato AAAA-MM, por exemplo 2026-08.',
      );
      return;
    }
    _mes = month;
    _pagina = 1;
    _load();
  }

  String _date(String? raw) {
    if (raw == null) return '—';
    final d = DateTime.parse(raw);
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    final d = _data;
    if (d == null && _loading)
      return const Center(child: CircularProgressIndicator());
    if (d == null)
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_error ?? 'Não foi possível carregar os dados.'),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: _load,
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      );
    return LayoutBuilder(
      builder: (context, box) {
        final wide = box.maxWidth >= 1000;
        final cards = [
          _FinancialKpi(
            title: 'VENDAS DE CRÉDITOS',
            value: fmtMoney(d.vendas),
            note: 'Total de vendas no período',
            icon: Icons.payments_outlined,
          ),
          _FinancialKpi(
            title: 'UTILIZAÇÃO DE CRÉDITOS',
            value: fmtMoney(d.utilizacao),
            note: 'Total utilizado no período',
            icon: Icons.directions_bus_outlined,
          ),
          _FinancialKpi(
            title: 'CRÉDITO CIRCULANTE',
            value: fmtMoney(d.creditoCirculante),
            note: 'Soma dos saldos registrados no período',
            icon: Icons.account_balance_wallet_outlined,
          ),
        ];
        final width = box.maxWidth - (box.maxWidth < 700 ? 32 : 48);
        final columns = width >= 700 ? 3 : 1;
        final cardWidth = (width - 16 * (columns - 1)) / columns;
        final chart = SizedBox(
          height: 400,
          child: RevenueSubsidyChart(serie: d.evolucao),
        );
        final unavailable = Container(
          height: 400,
          padding: const EdgeInsets.all(20),
          decoration: cardDecoration(),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Informações complementares',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppColors.navy,
                ),
              ),
              SizedBox(height: 24),
              Icon(Icons.info_outline, color: AppColors.primary, size: 32),
              SizedBox(height: 16),
              Text(
                'Subsídios, custos operacionais e repasses por linha ainda não estão disponíveis na base de dados.',
                style: TextStyle(color: AppColors.muted, height: 1.5),
              ),
              SizedBox(height: 16),
              Text(
                'Os indicadores ao lado utilizam os registros de vendas, utilização e crédito circulante.',
                style: TextStyle(color: AppColors.muted, height: 1.5),
              ),
            ],
          ),
        );
        return SingleChildScrollView(
          padding: EdgeInsets.all(box.maxWidth < 700 ? 16 : 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Gestão Financeira',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: AppColors.navy,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Vendas, utilização e crédito circulante dos relatórios importados.',
                style: TextStyle(fontSize: 12, color: AppColors.muted),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: cardDecoration(),
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    SizedBox(
                      width: 150,
                      child: TextField(
                        controller: _mesCtrl,
                        onSubmitted: (_) => _applyMonth(),
                        decoration: const InputDecoration(
                          labelText: 'Mês • AAAA-MM',
                          isDense: true,
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    OutlinedButton(
                      onPressed: _loading ? null : _applyMonth,
                      child: const Text('Aplicar'),
                    ),
                    for (final choice in [
                      (key: 'mes', label: 'Mês completo'),
                      (key: 'semana', label: 'Últimos 7 dias'),
                      (key: 'hoje', label: 'Último dia'),
                    ])
                      ChoiceChip(
                        label: Text(choice.label),
                        selected: _periodo == choice.key,
                        onSelected: _loading
                            ? null
                            : (_) {
                                _periodo = choice.key;
                                _pagina = 1;
                                _load();
                              },
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Text(
                d.dias == 0
                    ? 'Sem registros para o mês selecionado.'
                    : '${_date(d.inicio)} a ${_date(d.fim)} • ${d.dias} dias com registros',
                style: const TextStyle(fontSize: 12, color: AppColors.muted),
              ),
              if (_loading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: LinearProgressIndicator(),
                ),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    _error!,
                    style: const TextStyle(color: AppColors.red),
                  ),
                ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  for (final card in cards)
                    SizedBox(width: cardWidth, child: card),
                ],
              ),
              const SizedBox(height: 20),
              if (wide)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 3, child: chart),
                    const SizedBox(width: 20),
                    Expanded(flex: 2, child: unavailable),
                  ],
                )
              else ...[
                chart,
                const SizedBox(height: 16),
                unavailable,
              ],
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: cardDecoration(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Movimentos financeiros por dia',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.navy,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: 260,
                      child: TextField(
                        controller: _buscaCtrl,
                        onChanged: (value) {
                          _debounce?.cancel();
                          _debounce = Timer(
                            const Duration(milliseconds: 400),
                            () {
                              _busca = value.trim();
                              _pagina = 1;
                              _load();
                            },
                          );
                        },
                        decoration: const InputDecoration(
                          hintText: 'Buscar data • DD/MM/AAAA',
                          prefixIcon: Icon(Icons.search),
                          isDense: true,
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (d.movimentos.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(20),
                        child: Text(
                          'Nenhum movimento encontrado.',
                          style: TextStyle(color: AppColors.muted),
                        ),
                      )
                    else
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          columns: const [
                            DataColumn(label: Text('Data')),
                            DataColumn(label: Text('Vendas'), numeric: true),
                            DataColumn(
                              label: Text('Utilização'),
                              numeric: true,
                            ),
                            DataColumn(
                              label: Text('Crédito circulante'),
                              numeric: true,
                            ),
                          ],
                          rows: [
                            for (final row in d.movimentos)
                              DataRow(
                                cells: [
                                  DataCell(Text(_date(row.data))),
                                  DataCell(Text(fmtMoney(row.vendas))),
                                  DataCell(Text(fmtMoney(row.utilizacao))),
                                  DataCell(
                                    Text(fmtMoney(row.creditoCirculante)),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          '${d.totalRegistros} registros • Página ${d.pagina} de ${d.totalPaginas}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.muted,
                          ),
                        ),
                        IconButton(
                          tooltip: 'Página anterior',
                          onPressed: _loading || d.pagina <= 1
                              ? null
                              : () {
                                  _pagina--;
                                  _load();
                                },
                          icon: const Icon(Icons.chevron_left),
                        ),
                        IconButton(
                          tooltip: 'Próxima página',
                          onPressed: _loading || d.pagina >= d.totalPaginas
                              ? null
                              : () {
                                  _pagina++;
                                  _load();
                                },
                          icon: const Icon(Icons.chevron_right),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _FinancialKpi extends StatelessWidget {
  final String title, value, note;
  final IconData icon;
  const _FinancialKpi({
    required this.title,
    required this.value,
    required this.note,
    required this.icon,
  });
  @override
  Widget build(BuildContext context) => Container(
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
                  color: AppColors.muted,
                ),
              ),
            ),
            Icon(icon, color: AppColors.primary, size: 22),
          ],
        ),
        const SizedBox(height: 16),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: AppColors.navy,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          note,
          style: const TextStyle(fontSize: 11, color: AppColors.muted),
        ),
      ],
    ),
  );
}
