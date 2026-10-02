import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/formatters.dart';
import '../core/theme.dart';
import '../models/ml_overview.dart';

class FeatureImportanceTable extends StatelessWidget {
  final List<FeatureImportance> features;
  const FeatureImportanceTable({super.key, required this.features});

  @override
  Widget build(BuildContext context) {
    final maxPeso = features.isEmpty
        ? 0.0
        : features.map((f) => f.peso).reduce(math.max);

    return Container(
      decoration: cardDecoration(),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: Text('EXPLICAÇÃO GLOBAL (FEATURE IMPORTANCE)',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF374151))),
                ),
                Text('Top 5 Fatores',
                    style: TextStyle(fontSize: 11, color: AppColors.muted)),
              ],
            ),
          ),
          LayoutBuilder(builder: (context, box) {
            final width = math.max(box.maxWidth, 560.0);
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: width,
                child: Column(
                  children: [
                    const _Header(),
                    if (features.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(24),
                        child: Text('Sem dados do modelo',
                            style: TextStyle(color: AppColors.muted)),
                      )
                    else
                      for (var i = 0; i < features.length; i++)
                        _DataRow(
                          item: features[i],
                          maxPeso: maxPeso,
                          color: _barColors[math.min(i, _barColors.length - 1)],
                          zebra: i.isOdd,
                        ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

const _flex = [3, 2, 5, 1];

const _barColors = [
  Color(0xFF0B5FB0),
  Color(0xFF0B5FB0),
  Color(0xFF2196F3),
  Color(0xFF42A5F5),
  Color(0xFFB0B7C3),
];

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    Widget cell(String t, int flex, Alignment a) => Expanded(
          flex: flex,
          child: Align(
            alignment: a,
            child: Text(t,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700)),
          ),
        );

    return Container(
      color: AppColors.navy,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          cell('Feature', _flex[0], Alignment.centerLeft),
          cell('Categoria', _flex[1], Alignment.centerLeft),
          cell('Impacto no Modelo (SHAP Value)', _flex[2], Alignment.centerLeft),
          cell('Peso', _flex[3], Alignment.centerRight),
        ],
      ),
    );
  }
}

class _DataRow extends StatelessWidget {
  final FeatureImportance item;
  final double maxPeso;
  final Color color;
  final bool zebra;

  const _DataRow({
    required this.item,
    required this.maxPeso,
    required this.color,
    required this.zebra,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: zebra ? const Color(0xFFF8F9FC) : Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          Expanded(
            flex: _flex[0],
            child: Text(item.nome,
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.navy)),
          ),
          Expanded(
            flex: _flex[1],
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F3F6),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(item.categoria,
                    style: const TextStyle(
                        fontSize: 10, color: AppColors.muted)),
              ),
            ),
          ),
          Expanded(
            flex: _flex[2],
            child: Padding(
              padding: const EdgeInsets.only(right: 24),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: maxPeso == 0 ? null : item.peso / maxPeso,
                  minHeight: 6,
                  color: color,
                  backgroundColor: const Color(0xFFF1F3F6),
                ),
              ),
            ),
          ),
          Expanded(
            flex: _flex[3],
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(fmtDec(item.peso, digits: 2),
                  style:
                      const TextStyle(fontSize: 12, color: AppColors.text)),
            ),
          ),
        ],
      ),
    );
  }
}