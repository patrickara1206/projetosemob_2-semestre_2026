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
    return Container(
      decoration: cardDecoration(context),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Detalhamento de Categorias',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Estrutura para perfis tarifários',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: onVerRelatorio,
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.symmetric(horizontal: 8),
                  ),
                  child: Text(
                    'RELATÓRIO →',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          ),
          LayoutBuilder(
            builder: (context, box) {
              final isMobile = box.maxWidth < 600;

              if (categorias.isEmpty) {
                return Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text(
                      'Nenhuma categoria no período',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                );
              }

              if (isMobile) {
                return ListView.separated(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: categorias.length,
                  separatorBuilder: (_, __) =>
                      Divider(height: 1, color: AppColors.border),
                  itemBuilder: (context, i) =>
                      _MobileCategoryCard(item: categorias[i], zebra: i.isOdd),
                );
              }

              final width = math.max(box.maxWidth, 600.0);
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: width,
                  child: Column(
                    children: [
                      _Header(),
                      for (var i = 0; i < categorias.length; i++)
                        _DataRow(item: categorias[i], zebra: i.isOdd),
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
    Widget cell(String t, int flex, Alignment a) => Expanded(
      flex: flex,
      child: Align(
        alignment: a,
        child: Text(
          t,
          style: TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );

    return Container(
      color: Theme.of(context).colorScheme.onSurface,
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          cell('CATEGORIA', _flex[0], Alignment.centerLeft),
          cell('VOLUME (DIA)', _flex[1], Alignment.centerRight),
          cell('% DO TOTAL', _flex[2], Alignment.centerRight),
          cell('STATUS OPERACIONAL', _flex[3], Alignment.center),
        ],
      ),
    );
  }
}

class _DataRow extends StatelessWidget {
  final CategoriaTarifaria item;
  final bool zebra;
  const _DataRow({required this.item, required this.zebra});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: zebra ? Color(0xFFF8F9FC) : Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          Expanded(
            flex: _flex[0],
            child: Text(
              item.nome,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
          Expanded(
            flex: _flex[1],
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                fmtInt(item.volume),
                style: TextStyle(fontSize: 12, color: AppColors.text),
              ),
            ),
          ),
          Expanded(
            flex: _flex[2],
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                '${fmtDec(item.percentual)}%',
                style: TextStyle(fontSize: 12, color: AppColors.text),
              ),
            ),
          ),
          Expanded(
            flex: _flex[3],
            child: Align(
              alignment: Alignment.center,
              child: _StatusBadge(status: item.status),
            ),
          ),
        ],
      ),
    );
  }
}

class _MobileCategoryCard extends StatelessWidget {
  final CategoriaTarifaria item;
  final bool zebra;

  const _MobileCategoryCard({required this.item, required this.zebra});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: zebra ? Color(0xFFF8F9FC) : Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  item.nome,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
              _StatusBadge(status: item.status),
            ],
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Volume: ${fmtInt(item.volume)}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.text,
                ),
              ),
              Text(
                '${fmtDec(item.percentual)}% do total',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final ativo = status == 'ativo';

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: ativo ? AppColors.greenSoft : AppColors.border,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        ativo ? 'ATIVO' : 'INATIVO',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: ativo
              ? AppColors.green
              : Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
