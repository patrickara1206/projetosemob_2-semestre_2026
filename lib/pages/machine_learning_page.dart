import 'package:flutter/material.dart';

import '../core/formatters.dart';
import '../core/state.dart';
import '../core/theme.dart';
import '../models/ml_overview.dart';
import '../services/ml_service.dart';
import '../widgets/ai_logs_panel.dart';
import '../widgets/feature_importance_table.dart';
import '../widgets/ml_flow_card.dart';
import '../widgets/score_stability_chart.dart';

class MachineLearningPage extends StatefulWidget {
  const MachineLearningPage({super.key});

  @override
  State<MachineLearningPage> createState() => _MachineLearningPageState();
}

class _MachineLearningPageState extends State<MachineLearningPage> {
  final _service = MlService();
  late Future<MlOverview> _future;

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

  Future<MlOverview> _fetch() =>
      _service.getOverview(periodo: periodoNotifier.value.api);

  void _reload() => setState(() => _future = _fetch());

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<MlOverview>(
      future: _future,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return Center(child: CircularProgressIndicator());
        }
        if (snap.hasError) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error_outline, color: AppColors.red, size: 40),
                  SizedBox(height: 8),
                  Text('${snap.error}', textAlign: TextAlign.center),
                  SizedBox(height: 12),
                  FilledButton(
                    onPressed: _reload,
                    child: Text('Tentar novamente'),
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
  final MlOverview data;
  const _Content({required this.data});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, box) {
        final w = box.maxWidth;
        final isMobile = w < 600;
        final pad = isMobile ? 16.0 : 24.0;
        final gap = isMobile ? 12.0 : 16.0;
        final cols = w >= 1000 ? 4 : (w >= 540 ? 2 : 1);
        final availableWidth = w - (pad * 2);
        final itemW = cols == 1
            ? availableWidth
            : (availableWidth - (gap * (cols - 1))) / cols;
        final wide = w >= 1000;

        final cards = [
          _Kpi(
            title: 'PREVISÕES REALIZADAS',
            icon: Icons.bar_chart,
            iconColor: AppColors.primary,
            value: fmtCompact(data.previsoes),
            footer: _variacao(context, data.previsoesVariacao),
          ),
          _Kpi(
            title: 'ANOMALIAS IDENTIFICADAS',
            icon: Icons.warning_amber_rounded,
            iconColor: AppColors.red,
            value: fmtInt(data.anomalias24h),
            footer: _nota(context, 'Nas últimas 24 horas'),
          ),
          _Kpi(
            title: 'SCORE MÉDIO CONFIANÇA',
            icon: Icons.verified_outlined,
            iconColor: AppColors.primary,
            value: fmtDec(data.scoreMedio, digits: 2),
            footer: _nota(
              context,
              data.scoreMeta == null
                  ? '--'
                  : 'Target: > ${fmtDec(data.scoreMeta, digits: 2)}',
            ),
          ),
          _Kpi(
            title: 'ÚLTIMO TREINAMENTO',
            icon: Icons.sync,
            iconColor: AppColors.primary,
            value: fmtHa(data.ultimoTreinamento),
            footer: _StatusChip(status: data.statusModelo),
            tinted: true,
          ),
        ];

        final cardHeight = isMobile ? 280.0 : 320.0;
        final flow = SizedBox(height: cardHeight, child: MlFlowCard());
        final stability = SizedBox(
          height: cardHeight,
          child: ScoreStabilityChart(serie: data.scoreSerie),
        );
        final table = FeatureImportanceTable(features: data.features);
        final logs = AiLogsPanel(logs: data.logs);

        return SingleChildScrollView(
          padding: EdgeInsets.all(pad),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isMobile) ...[
                Text(
                  'Status do Motor de Inferência',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Monitoramento contínuo do pipeline de Machine Learning e saúde dos modelos preditivos.',
                  style: TextStyle(
                    fontSize: 11,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          // TODO: abrir histórico de treinamentos
                        },
                        icon: Icon(Icons.history, size: 16),
                        label: Text('Histórico'),
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () {
                          // TODO: chamar endpoint de re-treino (back end)
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: EdgeInsets.symmetric(horizontal: 8),
                        ),
                        icon: Icon(Icons.play_arrow, size: 16),
                        label: Text(
                          'Re-treinar',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ),
              ] else ...[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Status do Motor de Inferência',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Monitoramento contínuo do pipeline de Machine Learning '
                            'e saúde dos modelos preditivos.',
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        OutlinedButton.icon(
                          onPressed: () {
                            // TODO: abrir histórico de treinamentos
                          },
                          icon: Icon(Icons.history, size: 16),
                          label: Text('Histórico'),
                        ),
                        SizedBox(width: 10),
                        FilledButton.icon(
                          onPressed: () {
                            // TODO: chamar endpoint de re-treino (back end)
                          },
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.primary,
                          ),
                          icon: Icon(Icons.play_arrow, size: 16),
                          label: Text('Re-treinar Modelo'),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
              SizedBox(height: 20),
              Wrap(
                spacing: gap,
                runSpacing: gap,
                children: [
                  for (final c in cards) SizedBox(width: itemW, child: c),
                ],
              ),
              SizedBox(height: 20),
              if (wide)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: flow),
                    SizedBox(width: 20),
                    Expanded(child: stability),
                  ],
                )
              else ...[
                flow,
                SizedBox(height: 16),
                stability,
              ],
              SizedBox(height: 20),
              if (wide)
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(flex: 3, child: table),
                      SizedBox(width: 20),
                      Expanded(flex: 2, child: logs),
                    ],
                  ),
                )
              else ...[
                table,
                SizedBox(height: 16),
                logs,
              ],
            ],
          ),
        );
      },
    );
  }
}

Widget _nota(BuildContext context, String t) => Text(
  t,
  overflow: TextOverflow.ellipsis,
  style: TextStyle(
    fontSize: 11,
    color: Theme.of(context).colorScheme.onSurfaceVariant,
  ),
);

Widget _variacao(BuildContext context, double? v) {
  if (v == null) return _nota(context, '--');
  final up = v >= 0;
  final color = up ? AppColors.green : AppColors.red;
  return Row(
    children: [
      Icon(
        up ? Icons.trending_up : Icons.trending_down,
        size: 14,
        color: color,
      ),
      SizedBox(width: 4),
      Expanded(
        child: Text(
          '${fmtPercent(v)} vs semana anterior',
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 11, color: color),
        ),
      ),
    ],
  );
}

class _StatusChip extends StatelessWidget {
  final String? status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    if (status == null) return _nota(context, '--');

    late final String label;
    late final Color fg;
    late final Color bg;
    switch (status) {
      case 'saudavel':
        label = 'Status: Saudável';
        fg = AppColors.green;
        bg = AppColors.greenSoft;
        break;
      case 'atencao':
        label = 'Status: Atenção';
        fg = Color(0xFFB7791F);
        bg = AppColors.orangeSoft;
        break;
      default:
        label = 'Status: Crítico';
        fg = AppColors.red;
        bg = AppColors.redSoft;
    }

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check, size: 11, color: fg),
            SizedBox(width: 4),
            Text(label, style: TextStyle(fontSize: 10, color: fg)),
          ],
        ),
      ),
    );
  }
}

class _Kpi extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final String value;
  final Widget footer;
  final bool tinted;

  const _Kpi({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.footer,
    this.tinted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: cardDecoration(
        context,
      ).copyWith(color: tinted ? Color(0xFFEAF1FB) : AppColors.card),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              SizedBox(width: 4),
              Icon(icon, size: 18, color: iconColor),
            ],
          ),
          SizedBox(height: 10),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
          SizedBox(height: 6),
          footer,
        ],
      ),
    );
  }
}
