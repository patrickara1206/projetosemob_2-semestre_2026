import 'package:flutter/material.dart';

import '../core/formatters.dart';
import '../core/state.dart';
import '../core/theme.dart';
import '../models/dashboard_overview.dart';
import '../services/dashboard_service.dart';
import '../widgets/anomaly_card.dart';
import '../widgets/intelligence_card.dart';
import '../widgets/kpi_card.dart';
import '../widgets/volume_chart.dart';

class OverviewPage extends StatefulWidget {
  const OverviewPage({super.key});

  @override
  State<OverviewPage> createState() => _OverviewPageState();
}

class _OverviewPageState extends State<OverviewPage> {
  final _service = DashboardService();
  late Future<DashboardOverview> _future;

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

  Future<DashboardOverview> _fetch() =>
      _service.getOverview(periodo: periodoNotifier.value.api, mes: '2026-08');

  void _reload() => setState(() => _future = _fetch());

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DashboardOverview>(
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

class _Content extends StatelessWidget {
  final DashboardOverview data;
  const _Content({required this.data});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, box) {
        final w = box.maxWidth;
        final wide = w >= 1100;

        final kpis = [
          KpiCard(
            title: 'Quilometragem',
            icon: Icons.route_outlined,
            value: fmtInt(data.quilometragem.valor),
            unit: 'km',
            variation: data.quilometragem.variacao,
          ),
          KpiCard(
            title: 'Viagens',
            icon: Icons.directions_bus_outlined,
            value: fmtInt(data.viagens.valor),
            variation: data.viagens.variacao,
          ),
          KpiCard(
            title: 'Passageiros\npagantes',
            icon: Icons.groups_outlined,
            value: fmtInt(data.passageirosPagantes.valor),
            variation: data.passageirosPagantes.variacao,
          ),
          KpiCard(
            title: 'Passageiros\nnão pagantes',
            icon: Icons.badge_outlined,
            value: fmtInt(data.passageirosNaoPagantes.valor),
            variation: data.passageirosNaoPagantes.variacao,
          ),
          KpiCard(
            title: 'Indicador\nfinanceiro',
            icon: Icons.payments_outlined,
            prefix: 'R\$',
            value: fmtInt(data.financeiro.valor),
            variation: data.financeiro.variacao,
          ),
        ];

        final cols = w >= 1100 ? 5 : (w >= 700 ? 3 : 2);
        const gap = 16.0;
        final pad = w < 700 ? 16.0 : 24.0;
        final itemW = (w - pad * 2 - gap * (cols - 1)) / cols;

        final chart = VolumeChart(serie: data.serie);
        final side = Column(
          children: [
            IntelligenceCard(data: data.inteligencia),
            const SizedBox(height: 16),
            AnomalyPanel(anomalias: data.anomalias, onTapItem: (a) {}),
          ],
        );

        return SingleChildScrollView(
          padding: EdgeInsets.all(pad),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Visão Geral da Operação',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: AppColors.navy,
                      ),
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
                  for (final k in kpis) SizedBox(width: itemW, child: k),
                ],
              ),
              const SizedBox(height: 20),
              if (wide)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 3, child: chart),
                    const SizedBox(width: 20),
                    Expanded(flex: 2, child: side),
                  ],
                )
              else ...[
                chart,
                const SizedBox(height: 16),
                side,
              ],
            ],
          ),
        );
      },
    );
  }
}
