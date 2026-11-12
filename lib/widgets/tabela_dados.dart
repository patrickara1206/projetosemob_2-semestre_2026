import 'dart:ui' show FontFeature;

import 'package:flutter/material.dart';

import '../core/theme.dart';

class TabelaDados extends StatefulWidget {
  final String titulo;
  final List<String> colunas;
  final List<List<String>> linhas;

  const TabelaDados({
    super.key,
    required this.titulo,
    required this.colunas,
    required this.linhas,
  });

  @override
  State<TabelaDados> createState() => _TabelaDadosState();
}

class _TabelaDadosState extends State<TabelaDados> {
  final TextEditingController _pesquisa = TextEditingController();
  static const int _registrosPorPagina = 10;
  int _pagina = 0;
  String _termo = '';

  @override
  void didUpdateWidget(covariant TabelaDados oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.linhas != widget.linhas) {
      _pagina = 0;
    }
  }

  @override
  void dispose() {
    _pesquisa.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final cores = tema.colorScheme;
    final escuro = tema.brightness == Brightness.dark;
    final largura = MediaQuery.sizeOf(context).width;

    final linhasFiltradas = widget.linhas.where((linha) {
      if (_termo.isEmpty) return true;
      return linha.any(
        (valor) => valor.toLowerCase().contains(_termo),
      );
    }).toList();

    final totalPaginas = (linhasFiltradas.length / _registrosPorPagina).ceil();
    final paginaAtual = totalPaginas == 0
        ? 0
        : _pagina.clamp(0, totalPaginas - 1);
    final inicio = paginaAtual * _registrosPorPagina;
    final fim = (inicio + _registrosPorPagina).clamp(0, linhasFiltradas.length);
    final linhasPagina = linhasFiltradas.sublist(inicio, fim);

    return Container(
      width: double.infinity,
      decoration: cardDecoration(context),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            child: largura < 650
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _cabecalho(context, linhasFiltradas.length),
                      const SizedBox(height: 16),
                      _campoPesquisa(cores),
                    ],
                  )
                : Row(
                    children: [
                      Expanded(child: _cabecalho(context, linhasFiltradas.length)),
                      const SizedBox(width: 16),
                      SizedBox(width: 230, child: _campoPesquisa(cores)),
                    ],
                  ),
          ),
          Divider(height: 1, color: cores.outlineVariant),
          if (linhasFiltradas.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 46, horizontal: 20),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.table_rows_outlined,
                        size: 32, color: cores.onSurfaceVariant),
                    const SizedBox(height: 10),
                    Text(
                      _termo.isEmpty
                          ? 'Nenhum registro disponível para este período.'
                          : 'Nenhum resultado encontrado.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: cores.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            )
          else
            LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minWidth: constraints.maxWidth),
                    child: DataTable(
                      showCheckboxColumn: false,
                      headingRowHeight: 48,
                      dataRowMinHeight: 48,
                      dataRowMaxHeight: 58,
                      horizontalMargin: 20,
                      columnSpacing: 30,
                      dividerThickness: 0.6,
                      headingRowColor: WidgetStatePropertyAll(
                        cores.surfaceContainerHighest.withValues(alpha: 0.7),
                      ),
                      dataRowColor: WidgetStateProperty.resolveWith((states) {
                        if (states.contains(WidgetState.hovered)) {
                          return cores.primary.withValues(alpha: 0.07);
                        }
                        return null;
                      }),
                      columns: [
                        for (final coluna in widget.colunas)
                          DataColumn(
                            label: Text(
                              coluna.toUpperCase(),
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.4,
                                color: cores.onSurfaceVariant,
                              ),
                            ),
                          ),
                      ],
                      rows: [
                        for (var i = 0; i < linhasPagina.length; i++)
                          DataRow(
                            color: WidgetStatePropertyAll(
                              i.isOdd
                                  ? cores.surfaceContainerHighest.withValues(
                                      alpha: escuro ? 0.19 : 0.35,
                                    )
                                  : Colors.transparent,
                            ),
                            cells: [
                              for (var c = 0; c < widget.colunas.length; c++)
                                DataCell(
                                  Text(
                                    c < linhasPagina[i].length
                                        ? linhasPagina[i][c]
                                        : '--',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight:
                                          c == 0 ? FontWeight.w600 : FontWeight.w400,
                                      color: c == 0
                                          ? cores.onSurface
                                          : cores.onSurfaceVariant,
                                      fontFeatures: const [
                                        FontFeature.tabularFigures(),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          Divider(height: 1, color: cores.outlineVariant),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    linhasFiltradas.isEmpty
                        ? '0 registros'
                        : 'Mostrando ${inicio + 1}–$fim de ${linhasFiltradas.length}',
                    style: TextStyle(fontSize: 12, color: cores.onSurfaceVariant),
                  ),
                ),
                IconButton(
                  tooltip: 'Página anterior',
                  onPressed: paginaAtual > 0
                      ? () => setState(() => _pagina = paginaAtual - 1)
                      : null,
                  icon: const Icon(Icons.chevron_left),
                  iconSize: 20,
                ),
                Text(
                  '${totalPaginas == 0 ? 0 : paginaAtual + 1} / $totalPaginas',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: cores.onSurface,
                  ),
                ),
                IconButton(
                  tooltip: 'Próxima página',
                  onPressed: paginaAtual + 1 < totalPaginas
                      ? () => setState(() => _pagina = paginaAtual + 1)
                      : null,
                  icon: const Icon(Icons.chevron_right),
                  iconSize: 20,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _cabecalho(BuildContext context, int quantidade) {
    final cores = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: cores.primary.withValues(alpha: 0.09),
            borderRadius: BorderRadius.circular(9),
          ),
          child: Icon(Icons.table_chart_outlined, color: cores.primary, size: 20),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.titulo,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: cores.onSurface,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                '$quantidade ${quantidade == 1 ? 'registro' : 'registros'}',
                style: TextStyle(fontSize: 12, color: cores.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _campoPesquisa(ColorScheme cores) {
    return TextField(
      controller: _pesquisa,
      onChanged: (valor) {
        setState(() {
          _termo = valor.trim().toLowerCase();
          _pagina = 0;
        });
      },
      style: TextStyle(fontSize: 13, color: cores.onSurface),
      decoration: InputDecoration(
        hintText: 'Buscar na tabela',
        isDense: true,
        prefixIcon: const Icon(Icons.search, size: 19),
        suffixIcon: _termo.isEmpty
            ? null
            : IconButton(
                tooltip: 'Limpar busca',
                icon: const Icon(Icons.close, size: 18),
                onPressed: () {
                  _pesquisa.clear();
                  setState(() {
                    _termo = '';
                    _pagina = 0;
                  });
                },
              ),
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
        filled: true,
        fillColor: cores.surfaceContainerHighest.withValues(alpha: 0.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(9),
          borderSide: BorderSide(color: cores.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(9),
          borderSide: BorderSide(color: cores.outlineVariant),
        ),
      ),
    );
  }
}
