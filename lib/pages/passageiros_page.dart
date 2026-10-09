import 'package:flutter/material.dart';

import '../core/formatters.dart';
import '../core/state.dart';
import '../core/theme.dart';
import '../models/passageiros_overview.dart';
import '../services/passageiros_service.dart';
import '../widgets/category_table.dart';
import '../widgets/demand_chart.dart';
import '../widgets/tariff_donut.dart';

class PassageirosPage extends StatefulWidget {
  const PassageirosPage({super.key});

  @override
  State<PassageirosPage> createState() => _PassageirosPageState();
}

class _PassageirosPageState extends State<PassageirosPage> {
  final _service = PassageirosService();
  late Future<PassageirosOverview> _future;

  @override
  void initState() {
    super.initState();
    _future = _fetch();
    periodoNotifier.addListener(_reload);
  }

  @override
  void dispose() {
    periodoNotifier.removeListener(_reload);
    super.dispose();
  }

  Future<PassageirosOverview> _fetch() =>
      _service.getOverview(periodo: periodoNotifier.value.api);

  void _reload() => setState(() => _future = _fetch());

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PassageirosOverview>(
      future: _future,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.hasError) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, color: AppColors.red, size: 40),
                const SizedBox(height: 8),
                Text('${snap.error}'),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: _reload,
                  child: const Text('Tentar novamente'),
                ),
              ],
            ),
          );
        }
        return _Content(data: snap.data!);
      },
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

class _Content extends StatelessWidget {
  final PassageirosOverview data;
  const _Content({required this.data});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, box) {
        final w = box.maxWidth;
        final pad = w < 700 ? 16.0 : 24.0;
        const gap = 16.0;
        final cols = w >= 1000 ? 4 : (w >= 500 ? 2 : 1);
        final itemW = (w - pad * 2 - gap * (cols - 1)) / cols;
        final wide = w >= 1000;

        final chart = DemandChart(serie: data.serie);
        final donut = TariffDonut(pctPagantes: data.pctPagantes);

        final cards = [
          ValueListenableBuilder<Periodo>(
            valueListenable: periodoNotifier,
            builder: (_, p, _) => _Kpi(
              title: 'TOTAL DE PASSAGEIROS',
              icon: Icons.more_vert,
              iconColor: AppColors.muted,
              value: fmtCompact(data.totalPassageiros),
              footer: _variacao(data.totalVariacao, _refAnterior(p)),
            ),
          ),
          _Kpi(
            title: '% PAGANTES',
            icon: Icons.payments_outlined,
            iconColor: AppColors.primary,
            value: data.pctPagantes == null
                ? '--'
                : '${fmtDec(data.pctPagantes)}%',
            footer: _nota(
              '${fmtCompact(data.qtdPagantes)} passagens registradas',
            ),
          ),
          _Kpi(
            title: '% GRATUIDADES',
            icon: Icons.confirmation_number_outlined,
            iconColor: AppColors.primary,
            value: data.pctGratuidades == null
                ? '--'
                : '${fmtDec(data.pctGratuidades)}%',
            footer: _nota('${fmtCompact(data.qtdGratuidades)} acessos livres'),
          ),
          _Kpi(
            title: 'PICO DE DEMANDA',
            icon: Icons.schedule,
            iconColor: AppColors.orange,
            value: data.picoFaixa ?? '--',
            footer: _nota('Média de ${fmtCompact(data.picoMediaHora)} p/ hora'),
          ),
        ];

        return SingleChildScrollView(
          padding: EdgeInsets.all(pad),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Demanda e Perfil de Passageiros',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: AppColors.navy,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Monitoramento de fluxo diário e distribuição de '
                          'categorias tarifárias.',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.download, size: 16),
                    label: const Text('Exportar Relatório'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: gap,
                runSpacing: gap,
                children: [
                  for (final c in cards) SizedBox(width: itemW, child: c),
                ],
              ),
              const SizedBox(height: 20),
              if (wide)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 5,
                      child: SizedBox(height: 440, child: chart),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      flex: 3,
                      child: SizedBox(height: 440, child: donut),
                    ),
                  ],
                )
              else ...[
                SizedBox(height: 400, child: chart),
                const SizedBox(height: 16),
                SizedBox(height: 400, child: donut),
              ],
              const SizedBox(height: 20),
              CategoryTable(categorias: data.categorias, onVerRelatorio: () {}),
            ],
          ),
        );
      },
    );
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
      Icon(
        up ? Icons.trending_up : Icons.trending_down,
        size: 14,
        color: color,
      ),
      const SizedBox(width: 4),
      Flexible(
        child: Text(
          '${fmtPercent(v)} vs $ref',
          style: TextStyle(fontSize: 11, color: color),
        ),
      ),
    ],
  );
}

class _Kpi extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final String value;
  final Widget footer;

  const _Kpi({
    required this.title,
    required this.icon,
    required this.iconColor,
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
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF374151),
                  ),
                ),
              ),
              Icon(icon, size: 20, color: iconColor),
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
          footer,
        ],
      ),
    );
  }
}
