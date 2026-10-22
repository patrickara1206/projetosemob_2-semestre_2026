import 'package:flutter/material.dart';

import '../core/formatters.dart';
import '../core/state.dart';
import '../core/theme.dart';
import '../services/dashboard_service.dart';

class TopBar extends StatefulWidget {
  final bool compact;

  const TopBar({
    super.key,
    required this.compact,
  });

  @override
  State<TopBar> createState() =>
      _TopBarState();
}

class _TopBarState extends State<TopBar> {
  final _service = DashboardService();

  List<String> _meses = [];

  Map<String, List<String>>
      _periodosPorMes = {};

  bool _carregandoFiltros = true;

  @override
  void initState() {
    super.initState();

    periodoNotifier.addListener(
      _atualizar,
    );

    _carregarFiltros();
  }

  @override
  void dispose() {
    periodoNotifier.removeListener(
      _atualizar,
    );

    super.dispose();
  }

  void _atualizar() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _carregarFiltros() async {
    try {
      final dados =
          await _service
              .getFiltrosDisponiveis();

      final meses =
          ((dados['meses'] as List?) ?? [])
              .map(
                (item) =>
                    item.toString(),
              )
              .toList();

      final periodosJson =
          (dados['periodos']
                  as Map<String, dynamic>?) ??
              {};

      final periodos =
          <String, List<String>>{};

      for (final entry
          in periodosJson.entries) {
        periodos[entry.key] =
            ((entry.value as List?) ?? [])
                .map(
                  (item) =>
                      item.toString(),
                )
                .toList();
      }

      if (!mounted) {
        return;
      }

      setState(() {
        _meses = meses;
        _periodosPorMes = periodos;
        _carregandoFiltros = false;
      });

      if (meses.isNotEmpty &&
          !meses.contains(
            periodoNotifier
                .mesReferencia,
          )) {
        periodoNotifier.selecionarMes(
          meses.first,
        );
      }
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _carregandoFiltros = false;
      });
    }
  }

  List<Periodo> _periodosDisponiveis(
    String mes,
  ) {
    final periodos =
        _periodosPorMes[mes] ?? [];

    final resultado = <Periodo>[
      Periodo.total,
    ];

    if (periodos.contains('mensal')) {
      resultado.add(
        Periodo.mes,
      );
    }

    if (periodos.contains(
      'quinzenal',
    )) {
      resultado.add(
        Periodo.quinzena,
      );
    }

    return resultado;
  }

  String _nomeMes(String mes) {
    final partes = mes.split('-');

    if (partes.length != 2) {
      return mes;
    }

    const nomes = {
      '01': 'Janeiro',
      '02': 'Fevereiro',
      '03': 'Março',
      '04': 'Abril',
      '05': 'Maio',
      '06': 'Junho',
      '07': 'Julho',
      '08': 'Agosto',
      '09': 'Setembro',
      '10': 'Outubro',
      '11': 'Novembro',
      '12': 'Dezembro',
    };

    return '${nomes[partes[1]] ?? partes[1]}/${partes[0]}';
  }

  String _resumoFiltro() {
    if (periodoNotifier.value ==
        Periodo.total) {
      return 'Todos os dados';
    }

    return '${periodoNotifier.value.label} · '
        '${_nomeMes(periodoNotifier.mesReferencia)}';
  }

  Future<void> _abrirFiltro() async {
    var periodoSelecionado =
        periodoNotifier.value;

    var mesSelecionado =
        periodoNotifier.mesReferencia;

    if (_meses.isNotEmpty &&
        !_meses.contains(
          mesSelecionado,
        )) {
      mesSelecionado = _meses.first;
    }

    if (periodoSelecionado !=
        Periodo.total) {
      final disponiveis =
          _periodosDisponiveis(
        mesSelecionado,
      );

      if (!disponiveis.contains(
        periodoSelecionado,
      )) {
        if (disponiveis.contains(
          Periodo.mes,
        )) {
          periodoSelecionado =
              Periodo.mes;
        } else if (disponiveis.contains(
          Periodo.quinzena,
        )) {
          periodoSelecionado =
              Periodo.quinzena;
        }
      }
    }

    final resultado =
        await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (
            context,
            setDialogState,
          ) {
            final periodosDisponiveis =
                _periodosDisponiveis(
              mesSelecionado,
            );

            return AlertDialog(
              title: const Text(
                'Selecionar visualização',
              ),
              content: SizedBox(
                width: 360,
                child: Column(
                  mainAxisSize:
                      MainAxisSize.min,
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .stretch,
                  children: [
                    if (_carregandoFiltros)
                      const Center(
                        child:
                            CircularProgressIndicator(),
                      )
                    else ...[
                      if (periodoSelecionado !=
                          Periodo.total) ...[
                        DropdownButtonFormField<
                            String>(
                          value: _meses.contains(
                                  mesSelecionado,
                                )
                              ? mesSelecionado
                              : null,
                          decoration:
                              const InputDecoration(
                            labelText: 'Mês',
                            border:
                                OutlineInputBorder(),
                          ),
                          items: _meses
                              .map(
                                (mes) =>
                                    DropdownMenuItem<
                                        String>(
                                  value: mes,
                                  child: Text(
                                    _nomeMes(
                                      mes,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (novoMes) {
                            if (novoMes == null) {
                              return;
                            }

                            setDialogState(() {
                              mesSelecionado =
                                  novoMes;

                              final novosPeriodos =
                                  _periodosDisponiveis(
                                novoMes,
                              );

                              if (!novosPeriodos
                                  .contains(
                                periodoSelecionado,
                              )) {
                                if (novosPeriodos
                                    .contains(
                                  Periodo.mes,
                                )) {
                                  periodoSelecionado =
                                      Periodo.mes;
                                } else if (novosPeriodos
                                    .contains(
                                  Periodo.quinzena,
                                )) {
                                  periodoSelecionado =
                                      Periodo
                                          .quinzena;
                                }
                              }
                            });
                          },
                        ),
                        const SizedBox(
                          height: 16,
                        ),
                      ],

                      DropdownButtonFormField<
                          Periodo>(
                        value:
                            periodosDisponiveis
                                    .contains(
                              periodoSelecionado,
                            )
                                ? periodoSelecionado
                                : Periodo.total,
                        decoration:
                            const InputDecoration(
                          labelText:
                              'Visualização',
                          border:
                              OutlineInputBorder(),
                        ),
                        items:
                            periodosDisponiveis
                                .map(
                                  (periodo) =>
                                      DropdownMenuItem<
                                          Periodo>(
                                    value:
                                        periodo,
                                    child: Text(
                                      periodo
                                          .label,
                                    ),
                                  ),
                                )
                                .toList(),
                        onChanged: (periodo) {
                          if (periodo == null) {
                            return;
                          }

                          setDialogState(() {
                            periodoSelecionado =
                                periodo;
                          });
                        },
                      ),

                      if (periodoSelecionado ==
                          Periodo.total)
                        Padding(
                          padding:
                              const EdgeInsets.only(
                            top: 12,
                          ),
                          child: Text(
                            'Serão exibidos todos os '
                            'dados disponíveis.',
                            style: TextStyle(
                              fontSize: 12,
                              color:
                                  Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                            ),
                          ),
                        ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context)
                        .pop(false);
                  },
                  child: const Text(
                    'Cancelar',
                  ),
                ),
                FilledButton(
                  onPressed:
                      _carregandoFiltros ||
                              (periodoSelecionado !=
                                      Periodo
                                          .total &&
                                  _meses
                                      .isEmpty)
                          ? null
                          : () {
                              Navigator.of(
                                context,
                              ).pop(true);
                            },
                  child: const Text(
                    'Aplicar',
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    if (resultado != true) {
      return;
    }

    periodoNotifier.aplicarFiltro(
      periodoSelecionado,
      mes: periodoSelecionado ==
              Periodo.total
          ? null
          : mesSelecionado,
    );
  }

  @override
  Widget build(BuildContext context) {
    final esquema =
        Theme.of(context).colorScheme;

    final escuro =
        Theme.of(context).brightness ==
            Brightness.dark;

    return Container(
      height: 72,
      padding: EdgeInsets.symmetric(
        horizontal:
            widget.compact ? 8 : 16,
      ),
      decoration: BoxDecoration(
        color: esquema.surface,
        border: Border(
          bottom: BorderSide(
            color:
                esquema.outlineVariant,
          ),
        ),
      ),
      child: Row(
        children: [
          if (widget.compact)
            Builder(
              builder: (ctx) =>
                  IconButton(
                tooltip: 'Abrir menu',
                icon: const Icon(
                  Icons.menu,
                ),
                onPressed: () =>
                    Scaffold.of(ctx)
                        .openDrawer(),
              ),
            ),
          Text(
            'Dashboard Operacional',
            style: TextStyle(
              color: esquema.onSurface,
              fontWeight:
                  FontWeight.w800,
              fontSize:
                  widget.compact
                      ? 14
                      : 18,
              height: 1.1,
            ),
          ),
          const Spacer(),

          if (widget.compact)
            IconButton(
              tooltip:
                  'Selecionar período',
              icon: const Icon(
                Icons
                    .filter_alt_outlined,
              ),
              onPressed: _abrirFiltro,
            )
          else ...[
            OutlinedButton.icon(
              onPressed: _abrirFiltro,
              icon: const Icon(
                Icons
                    .filter_alt_outlined,
                size: 18,
              ),
              label: Text(
                _resumoFiltro(),
              ),
            ),
            const SizedBox(
              width: 16,
            ),
            const _StatusChip(),
            const SizedBox(
              width: 16,
            ),
            Icon(
              Icons
                  .calendar_today_outlined,
              size: 20,
              color:
                  esquema.onSurfaceVariant,
            ),
            const SizedBox(
              width: 8,
            ),
            Text(
              fmtDateTime(
                DateTime.now(),
              ),
              style: TextStyle(
                fontSize: 12,
                color:
                    esquema.onSurface,
              ),
            ),
            const SizedBox(
              width: 8,
            ),
            IconButton(
              tooltip:
                  'Atualizar dados',
              icon: const Icon(
                Icons.refresh,
              ),
              onPressed: () {
                periodoNotifier
                    .atualizar();

                _carregarFiltros();
              },
            ),
          ],

          IconButton(
            tooltip: escuro
                ? 'Ativar tema claro'
                : 'Ativar tema escuro',
            icon: Icon(
              escuro
                  ? Icons
                      .light_mode_outlined
                  : Icons
                      .dark_mode_outlined,
            ),
            onPressed: alternarTema,
          ),
        ],
      ),
    );
  }
}

class _StatusChip
    extends StatelessWidget {
  const _StatusChip();

  @override
  Widget build(
    BuildContext context,
  ) {
    final escuro =
        Theme.of(context).brightness ==
            Brightness.dark;

    final fundo = escuro
        ? const Color(0xFF15382A)
        : const Color(0xFFE8F5E9);

    final texto = escuro
        ? const Color(0xFF86EFAC)
        : AppColors.green;

    final borda = escuro
        ? const Color(0xFF166534)
        : const Color(0xFFA5D6A7);

    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: fundo,
        borderRadius:
            BorderRadius.circular(20),
        border: Border.all(
          color: borda,
        ),
      ),
      child: Row(
        mainAxisSize:
            MainAxisSize.min,
        children: [
          Icon(
            Icons.circle,
            size: 8,
            color: texto,
          ),
          const SizedBox(
            width: 6,
          ),
          Text(
            'Processamento do\nModelo: OK',
            style: TextStyle(
              fontSize: 10,
              color: texto,
            ),
          ),
        ],
      ),
    );
  }
}