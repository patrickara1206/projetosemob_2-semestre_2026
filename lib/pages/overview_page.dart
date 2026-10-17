import 'package:flutter/material.dart';

import '../core/formatters.dart';
import '../core/state.dart';
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

  Future<DashboardOverview> _fetch() {
    return _service.getOverview(
      periodo: periodoNotifier.value.api,
      mes: periodoNotifier.mesReferencia,
    );
  }

  void _reload() {
    setState(() => _future = _fetch());
  }

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
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.error_outline,
                    color: Theme.of(context).colorScheme.error,
                    size: 40,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${snap.error}',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: _reload,
                    child: const Text('Tentar novamente'),
                  ),
                ],
              ),
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
    final esquema = Theme.of(context).colorScheme;

    return LayoutBuilder(
      builder: (context, box) {
        final largura = box.maxWidth;
        final wide = largura >= 1100;
        final padding = largura < 700 ? 16.0 : 24.0;
        const gap = 16.0;

        final colunas = largura >= 1100
            ? 5
            : largura >= 700
                ? 3
                : largura >= 400
                    ? 2
                    : 1;

        final larguraCartao =
            (largura - padding * 2 - gap * (colunas - 1)) / colunas;

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

        final grafico = VolumeChart(serie: data.serie);

        final lateral = Column(
          children: [
            IntelligenceCard(data: data.inteligencia),
            const SizedBox(height: 16),
            AnomalyPanel(
              anomalias: data.anomalias,
              onTapItem: (anomalia) {
                showDialog<void>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text(anomalia.titulo),
                    content: Text(
                      'Observado: ${anomalia.observado}\n'
                      'Esperado: ${anomalia.esperado}\n'
                      'Desvio: ${fmtPercent(anomalia.desvio)}',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Fechar'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        );

        return SingleChildScrollView(
          padding: EdgeInsets.all(padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 16,
                runSpacing: 12,
                children: [
                  Text(
                    'Visão Geral da Operação',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: esquema.onSurface,
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'A exportação ainda não está disponível.',
                          ),
                        ),
                      );
                    },
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
                  for (final kpi in kpis)
                    SizedBox(
                      width: larguraCartao,
                      child: kpi,
                    ),
                ],
              ),
              const SizedBox(height: 20),
              if (wide)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 3, child: grafico),
                    const SizedBox(width: 20),
                    Expanded(flex: 2, child: lateral),
                  ],
                )
              else ...[
                grafico,
                const SizedBox(height: 16),
                lateral,
              ],
            ],
          ),
        );
      },
    );
  }
}