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
      decoration: cardDecoration(),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Detalhamento de Categorias',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF374151),
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Estrutura preparada para expansão de perfis tarifários',
                        style: TextStyle(fontSize: 11, color: AppColors.muted),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: onVerRelatorio,
                  child: const Text(
                    'VER RELATÓRIO COMPLETO →',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.navy,
                    ),
                  ),
                ),
              ],
            ),
          ),
          LayoutBuilder(
            builder: (context, box) {
              final width = math.max(box.maxWidth, 600.0);
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: width,
                  child: Column(
                    children: [
                      const _Header(),
                      if (categorias.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(24),
                          child: Text(
                            'Nenhuma categoria no período',
                            style: TextStyle(color: AppColors.muted),
                          ),
                        )
                      else
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
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );

    return Container(
      color: AppColors.navy,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
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
    final ativo = item.status == 'ativo';

    return Container(
      color: zebra ? const Color(0xFFF8F9FC) : Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          Expanded(
            flex: _flex[0],
            child: Text(
              item.nome,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.navy,
              ),
            ),
          ),
          Expanded(
            flex: _flex[1],
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                fmtInt(item.volume),
                style: const TextStyle(fontSize: 12, color: AppColors.text),
              ),
            ),
          ),
          Expanded(
            flex: _flex[2],
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                '${fmtDec(item.percentual)}%',
                style: const TextStyle(fontSize: 12, color: AppColors.text),
              ),
            ),
          ),
          Expanded(
            flex: _flex[3],
            child: Align(
              alignment: Alignment.center,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: ativo ? AppColors.greenSoft : AppColors.border,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  ativo ? 'ATIVO' : 'INATIVO',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: ativo ? AppColors.green : AppColors.muted,
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
