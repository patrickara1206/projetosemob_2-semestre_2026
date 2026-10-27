import 'package:flutter/material.dart';

import '../core/exportacao.dart';
import '../core/formatters.dart';
import '../core/state.dart';
import '../core/theme.dart';
import '../models/operacao_overview.dart';
import '../services/operacao_service.dart';
import '../widgets/anomaly_table.dart';
import '../widgets/hourly_chart.dart';
import '../widgets/km_bar_chart.dart';
import '../widgets/page_header.dart';

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

  Future<OperacaoOverview> _fetch() {
    return _service.getOverview();
  }

  void _reload() {
    setState(() {
      _future = _fetch();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<OperacaoOverview>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.hasError) {
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
                    '${snapshot.error}',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: _reload,
                    child: const Text(
                      'Tentar novamente',
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return _Content(
          data: snapshot.data!,
          onRefresh: _reload,
        );
      },
    );
  }
}

class _Content extends StatelessWidget {
  final OperacaoOverview data;
  final VoidCallback onRefresh;

  const _Content({
    required this.data,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).colorScheme;

    final escuro =
        Theme.of(context).brightness == Brightness.dark;

    final verde = escuro
        ? const Color(0xFF86EFAC)
        : AppColors.green;

    return LayoutBuilder(
      builder: (context, box) {
        final largura = box.maxWidth;

        final padding = largura < 700
            ? 16.0
            : 24.0;

        const gap = 16.0;

        final colunas = largura >= 900
            ? 3
            : largura >= 600
                ? 2
                : 1;

        final larguraCartao =
            (
              largura
              - padding * 2
              - gap * (colunas - 1)
            ) /
            colunas;

        final execucao = data.execucao;

        final pontualidade =
            data.pontualidade;

        final meta =
            data.metaPontualidade;

        final variacao =
            data.pontualidadeVariacao;

        final negativa =
            (variacao ?? 0) < 0;

        final corVariacao = negativa
            ? (
                escuro
                    ? const Color(0xFFFCD34D)
                    : const Color(0xFF92400E)
              )
            : verde;

        final fundoVariacao = negativa
            ? (
                escuro
                    ? const Color(0xFF422E12)
                    : AppColors.orangeSoft
              )
            : (
                escuro
                    ? const Color(0xFF15382A)
                    : AppColors.greenSoft
              );

        String textoMeta = '--';

        if (
          pontualidade != null
          && meta != null
        ) {
          textoMeta =
              pontualidade >= meta
                  ? 'Meta atingida '
                      '(${fmtDec(meta, digits: 0)}%)'
                  : 'Abaixo da meta '
                      '(${fmtDec(meta, digits: 0)}%)';
        }

        final totalKm =
            (data.kmProdutiva ?? 0)
            +
            (data.kmMorta ?? 0);

        double? fracao(
          double? valor,
        ) {
          if (
            valor == null
            || totalKm == 0
          ) {
            return null;
          }

          return (
            valor / totalKm
          )
              .clamp(
                0.0,
                1.0,
              )
              .toDouble();
        }

        final cards = <Widget>[
          _CardBase(
            title: 'TOTAL DE VIAGENS',
            icon: Icons.route_outlined,
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  fmtInt(
                    data.viagensRealizadas,
                  ),
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight:
                        FontWeight.w800,
                    color:
                        cores.onSurface,
                  ),
                ),

                Text(
                  '${fmtInt(data.viagensProgramadas)} '
                  'viagens programadas',
                  style: TextStyle(
                    fontSize: 12,
                    color:
                        cores.onSurfaceVariant,
                  ),
                ),

                const SizedBox(
                  height: 12,
                ),

                ClipRRect(
                  borderRadius:
                      BorderRadius.circular(
                    4,
                  ),
                  child:
                      LinearProgressIndicator(
                    value: execucao
                        ?.clamp(
                          0.0,
                          1.0,
                        )
                        .toDouble(),
                    minHeight: 6,
                    color:
                        AppColors.cyan,
                    backgroundColor:
                        cores
                            .surfaceContainerHighest,
                  ),
                ),

                const SizedBox(
                  height: 8,
                ),

                Text(
                  execucao == null
                      ? '--'
                      : '${fmtDec(execucao * 100)}% Executado',
                  style: TextStyle(
                    fontSize: 11,
                    color: verde,
                  ),
                ),
              ],
            ),
          ),

          _CardBase(
            title:
                'ÍNDICE DE EXECUÇÃO',
            icon: Icons.schedule,
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  pontualidade == null
                      ? '--'
                      : '${fmtDec(pontualidade)}%',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight:
                        FontWeight.w800,
                    color:
                        cores.onSurface,
                  ),
                ),

                const SizedBox(
                  height: 12,
                ),

                Container(
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration:
                      BoxDecoration(
                    color:
                        fundoVariacao,
                    borderRadius:
                        BorderRadius.circular(
                      6,
                    ),
                  ),
                  child: Text(
                    variacao == null
                        ? '--'
                        : '${fmtPercent(variacao)} '
                            'vs mês ant.',
                    style: TextStyle(
                      fontSize: 11,
                      color:
                          corVariacao,
                    ),
                  ),
                ),

                const SizedBox(
                  height: 8,
                ),

                Text(
                  textoMeta,
                  style: TextStyle(
                    fontSize: 11,
                    color:
                        cores.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),

          _CardBase(
            title: 'QUILOMETRAGEM',
            icon: Icons.speed,
            child: Column(
              children: [
                _KmRow(
                  label:
                      'Produtiva',
                  value:
                      data.kmProdutiva,
                  fraction:
                      fracao(
                    data.kmProdutiva,
                  ),
                  color:
                      cores.primary,
                ),

                const SizedBox(
                  height: 18,
                ),

                _KmRow(
                  label:
                      'Morta (Deslocamento)',
                  value:
                      data.kmMorta,
                  fraction:
                      fracao(
                    data.kmMorta,
                  ),
                  color:
                      AppColors.cyan,
                ),
              ],
            ),
          ),
        ];

        final kmChart =
            KmBarChart(
          dados: data.kmMensal,
        );

        final viagensChart =
            HourlyChart(
          dados: data.viagensHora,
        );

        return SingleChildScrollView(
          padding:
              EdgeInsets.all(
            padding,
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              PageHeader(
                title:
                    'Desempenho da Operação',
                subtitle:
                    'Monitoramento de viagens, '
                    'execução e métricas de frota '
                    '(${periodoNotifier.value.label}).',

                onRefresh:
                    onRefresh,

                onExport: () {
                  exportarRelatorio(
                    context,
                    'operacao-'
                    '${periodoNotifier.mesReferencia}'
                    '.csv',
                    [
                      [
                        'Indicador',
                        'Valor',
                      ],
                      [
                        'Viagens realizadas',
                        data
                            .viagensRealizadas,
                      ],
                      [
                        'Viagens programadas',
                        data
                            .viagensProgramadas,
                      ],
                      [
                        'Índice de execução (%)',
                        data
                            .pontualidade,
                      ],
                      [
                        'Quilometragem produtiva',
                        data
                            .kmProdutiva,
                      ],
                      [
                        'Quilometragem morta',
                        data
                            .kmMorta,
                      ],

                      [],
                      [
                        'Faixa horária',
                        'Média de viagens',
                      ],

                      for (
                        final hora
                        in data.viagensHora
                      )
                        [
                          hora.rotulo,
                          hora.viagens,
                        ],
                    ],
                  );
                },
              ),

              const SizedBox(
                height: 20,
              ),

              Wrap(
                spacing: gap,
                runSpacing: gap,
                children: [
                  for (
                    final card
                    in cards
                  )
                    SizedBox(
                      width:
                          larguraCartao,
                      child:
                          card,
                    ),
                ],
              ),

              const SizedBox(
                height: 20,
              ),

              if (largura >= 900)
                Row(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child:
                          kmChart,
                    ),

                    const SizedBox(
                      width: 20,
                    ),

                    Expanded(
                      child:
                          viagensChart,
                    ),
                  ],
                )
              else ...[
                kmChart,

                const SizedBox(
                  height: 16,
                ),

                viagensChart,
              ],

              const SizedBox(
                height: 20,
              ),

              AnomalyTable(
                anomalias:
                    data.anomalias,
                onAction:
                    (anomalia) {},
                onVerTodas:
                    () {},
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CardBase extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _CardBase({
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    final cores =
        Theme.of(context).colorScheme;

    return Container(
      padding:
          const EdgeInsets.all(
        20,
      ),
      decoration:
          cardDecoration(
        context,
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style:
                      TextStyle(
                    fontSize: 11,
                    fontWeight:
                        FontWeight.w700,
                    color:
                        cores
                            .onSurfaceVariant,
                  ),
                ),
              ),

              Icon(
                icon,
                size: 20,
                color:
                    cores
                        .onSurfaceVariant,
              ),
            ],
          ),

          const SizedBox(
            height: 12,
          ),

          child,
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

  const _KmRow({
    required this.label,
    required this.value,
    required this.fraction,
    required this.color,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    final cores =
        Theme.of(context).colorScheme;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style:
                    TextStyle(
                  fontSize: 12,
                  color:
                      cores.onSurface,
                ),
              ),
            ),

            const SizedBox(
              width: 8,
            ),

            Text(
              '${fmtInt(value)} km',
              style: TextStyle(
                fontSize: 12,
                fontWeight:
                    FontWeight.w700,
                color:
                    cores.onSurface,
              ),
            ),
          ],
        ),

        const SizedBox(
          height: 8,
        ),

        ClipRRect(
          borderRadius:
              BorderRadius.circular(
            4,
          ),
          child:
              LinearProgressIndicator(
            value: fraction,
            minHeight: 5,
            color: color,
            backgroundColor:
                cores
                    .surfaceContainerHighest,
          ),
        ),
      ],
    );
  }
}