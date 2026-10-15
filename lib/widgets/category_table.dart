import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/formatters.dart';
import '../core/theme.dart';
import '../models/passageiros_overview.dart';

class CategoryTable extends StatelessWidget {
  final List<CategoriaTarifaria> categorias;
  final VoidCallback onVerRelatorio;

  const CategoryTable({
    super.key,
    required this.categorias,
    required this.onVerRelatorio,
  });

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).colorScheme;

    return Container(
      decoration: cardDecoration(context),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 20,
              runSpacing: 8,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Detalhamento de Categorias',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: cores.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Distribuição dos passageiros por categoria tarifária',
                      style: TextStyle(
                        fontSize: 11,
                        color: cores.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: onVerRelatorio,
                  child: const Text(
                    'VER RELATÓRIO COMPLETO →',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          LayoutBuilder(
            builder: (context, box) {
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: math.max(box.maxWidth, 640.0),
                  child: Column(
                    children: [
                      const _Header(),
                      if (categorias.isEmpty)
                        Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text(
                            'Nenhuma categoria no período',
                            style: TextStyle(
                              color: cores.onSurfaceVariant,
                            ),
                          ),
                        )
                      else
                        for (var i = 0; i < categorias.length; i++)
                          _CategoryRow(
                            item: categorias[i],
                            zebra: i.isOdd,
                          ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

const _flex = [4, 2, 2, 3];

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).colorScheme;

    const titulos = [
      'CATEGORIA',
      'VOLUME',
      '% DO TOTAL',
      'STATUS OPERACIONAL',
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: cores.surfaceContainerHighest,
        border: Border(
          bottom: BorderSide(color: cores.outlineVariant),
        ),
      ),
      child: Row(
        children: [
          for (var i = 0; i < titulos.length; i++)
            Expanded(
              flex: _flex[i],
              child: Text(
                titulos[i],
                textAlign: i == 0
                    ? TextAlign.left
                    : (i == 3 ? TextAlign.center : TextAlign.right),
                style: TextStyle(
                  color: cores.onSurface,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  final CategoriaTarifaria item;
  final bool zebra;

  const _CategoryRow({
    required this.item,
    required this.zebra,
  });

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).colorScheme;
    final escuro = Theme.of(context).brightness == Brightness.dark;
    final ativo = item.status == 'ativo';

    final corStatus = ativo
        ? (escuro ? const Color(0xFF86EFAC) : AppColors.green)
        : cores.onSurfaceVariant;

    final fundoStatus = ativo
        ? (escuro ? const Color(0xFF15382A) : AppColors.greenSoft)
        : cores.surfaceContainerHighest;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: zebra ? cores.surfaceContainerHighest : cores.surface,
        border: Border(
          bottom: BorderSide(color: cores.outlineVariant),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: _flex[0],
            child: Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Text(
                item.nome,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: cores.onSurface,
                ),
              ),
            ),
          ),
          Expanded(
            flex: _flex[1],
            child: Text(
              fmtInt(item.volume),
              textAlign: TextAlign.right,
              style: TextStyle(fontSize: 12, color: cores.onSurface),
            ),
          ),
          Expanded(
            flex: _flex[2],
            child: Text(
              '${fmtDec(item.percentual)}%',
              textAlign: TextAlign.right,
              style: TextStyle(fontSize: 12, color: cores.onSurface),
            ),
          ),
          Expanded(
            flex: _flex[3],
            child: Align(
              alignment: Alignment.center,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: fundoStatus,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  ativo ? 'ATIVO' : 'INATIVO',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: corStatus,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}