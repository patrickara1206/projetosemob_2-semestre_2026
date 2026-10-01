import 'package:flutter/material.dart';

import '../core/formatters.dart';
import '../core/state.dart';
import '../core/theme.dart';
import '../models/operacao_overview.dart';
import '../services/operacao_service.dart';
import '../widgets/anomaly_table.dart';
import '../widgets/hourly_chart.dart';
import '../widgets/km_bar_chart.dart';

class OperacaoPage extends StatefulWidget {
  const OperacaoPage({super.key});

  @override
  State<OperacaoPage> createState() => _OperacaoPageState();
}

class _OperacaoPageState extends State<OperacaoPage> {
  final _service = OperacaoService();
  late Future<OperacaoOverview> _future;

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

  Future<OperacaoOverview> _fetch() =>
      _service.getOverview(periodo: periodoNotifier.value.api);

  void _reload() => setState(() => _future = _fetch());

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<OperacaoOverview>(
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
                    onPressed: _reload, child: const Text('Tentar novamente')),
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
  final OperacaoOverview data;
  const _Content({required this.data});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, box) {
      final w = box.maxWidth;
      final pad = w < 700 ? 16.0 : 24.0;
      const gap = 16.0;
      final cols = w >= 900 ? 3 : (w >= 600 ? 2 : 1);
      final itemW = (w - pad * 2 - gap * (cols - 1)) / cols;
      final wide = w >= 900;

      final cards = [
        _ViagensCard(data: data),
        _PontualidadeCard(data: data),
        _QuilometragemCard(data: data),
      ];

      final charts = [
        KmBarChart(dados: data.kmMensal),
        HourlyChart(dados: data.viagensHora),
      ];

      return SingleChildScrollView(
        padding: EdgeInsets.all(pad),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Desempenho da Operação',
                          style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              color: AppColors.navy)),
                      const SizedBox(height: 4),
                      ValueListenableBuilder<Periodo>(
                        valueListenable: periodoNotifier,
                        builder: (_, p, __) => Text(
                          'Monitoramento de viagens, pontualidade e métricas '
                          'de frota (${p.label}).',
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.muted),
                        ),
                      ),
                    ],
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: () {
                    // TODO: exportar relatório (endpoint do backend)
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
                for (final c in cards) SizedBox(width: itemW, child: c),
              ],
            ),
            const SizedBox(height: 20),
            if (wide)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: charts[0]),
                  const SizedBox(width: 20),
                  Expanded(child: charts[1]),
                ],
              )
            else ...[
              charts[0],
              const SizedBox(height: 16),
              charts[1],
            ],
            const SizedBox(height: 20),
            AnomalyTable(
              anomalias: data.anomalias,
              onAction: (a) {
                // TODO: investigar / notificar / ajustar (endpoint do backend)
              },
              onVerTodas: () {
                // TODO: navegar para a lista completa de anomalias
              },
            ),
          ],
        ),
      );
    });
  }
}

// ---------- Cards de indicadores ----------

class _CardBase extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;
  const _CardBase(
      {required this.title, required this.icon, required this.child});

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
              Icon(icon, size: 20, color: AppColors.muted),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _ViagensCard extends StatelessWidget {
  final OperacaoOverview data;
  const _ViagensCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final exec = data.execucao;

    return _CardBase(
      title: 'TOTAL DE VIAGENS',
      icon: Icons.route_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(fmtInt(data.viagensRealizadas),
                  style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      color: AppColors.navy)),
              Text(' / ${fmtInt(data.viagensProgramadas)} prog.',
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.muted)),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: exec?.clamp(0.0, 1.0),
              minHeight: 6,
              color: AppColors.cyan,
              backgroundColor: AppColors.border,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.arrow_upward, size: 12, color: AppColors.green),
              const SizedBox(width: 2),
              Text(
                exec == null
                    ? '--'
                    : '${fmtDec(exec * 100)}% Executado',
                style: const TextStyle(fontSize: 11, color: AppColors.green),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PontualidadeCard extends StatelessWidget {
  final OperacaoOverview data;
  const _PontualidadeCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final v = data.pontualidadeVariacao;
    final meta = data.metaPontualidade;
    final p = data.pontualidade;
    final negativo = (v ?? 0) < 0;

    String metaTxt = '--';
    if (p != null && meta != null) {
      metaTxt = p >= meta
          ? 'Meta atingida (${fmtDec(meta, digits: 0)}%)'
          : 'Abaixo da meta (${fmtDec(meta, digits: 0)}%)';
    }

    return _CardBase(
      title: 'ÍNDICE DE PONTUALIDADE',
      icon: Icons.schedule,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(p == null ? '--' : '${fmtDec(p)}%',
              style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  color: AppColors.navy)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: negativo ? AppColors.orangeSoft : AppColors.greenSoft,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (v != null)
                      Icon(negativo ? Icons.arrow_downward : Icons.arrow_upward,
                          size: 12,
                          color: negativo
                              ? const Color(0xFFB7791F)
                              : AppColors.green),
                    const SizedBox(width: 2),
                    Text(v == null ? '--' : '${fmtPercent(v)} vs mês ant.',
                        style: TextStyle(
                            fontSize: 11,
                            color: negativo
                                ? const Color(0xFFB7791F)
                                : AppColors.green)),
                  ],
                ),
              ),
              Text(metaTxt,
                  style:
                      const TextStyle(fontSize: 11, color: AppColors.muted)),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuilometragemCard extends StatelessWidget {
  final OperacaoOverview data;
  const _QuilometragemCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final prod = data.kmProdutiva;
    final morta = data.kmMorta;
    final total = (prod ?? 0) + (morta ?? 0);

    double? frac(double? x) => (x == null || total == 0) ? null : x / total;

    return _CardBase(
      title: 'QUILOMETRAGEM',
      icon: Icons.speed,
      child: Column(
        children: [
          _KmRow(
            label: 'Produtiva',
            value: prod,
            fraction: frac(prod),
            color: AppColors.navy,
            strong: true,
          ),
          const SizedBox(height: 14),
          _KmRow(
            label: 'Morta (Deslocamento)',
            value: morta,
            fraction: frac(morta),
            color: AppColors.border,
            strong: false,
          ),
        ],
      ),
    );
  }
}

class _KmRow extends StatelessWidget {
  final String label;
  final double? value;
  final double? fraction;
  final Color color;
  final bool strong;
  const _KmRow({
    required this.label,
    required this.value,
    required this.fraction,
    required this.color,
    required this.strong,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Text(label,
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: strong ? FontWeight.w600 : FontWeight.w400,
                      color: strong ? AppColors.text : AppColors.muted)),
            ),
            Text('${fmtInt(value)} km',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: strong ? FontWeight.w800 : FontWeight.w400,
                    color: strong ? AppColors.navy : AppColors.muted)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: fraction,
            minHeight: 5,
            color: color,
            backgroundColor: const Color(0xFFF1F3F6),
          ),
        ),
      ],
    );
  }
}