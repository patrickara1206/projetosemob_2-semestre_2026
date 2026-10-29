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
                  child: Text(
                    'EXPLICAÇÃO GLOBAL (FEATURE IMPORTANCE)',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Text(
                  'Top 5 Fatores',
                  style: TextStyle(
                    fontSize: 11,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          LayoutBuilder(
            builder: (context, box) {
              final isMobile = box.maxWidth < 600;

              if (features.isEmpty) {
                return Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text(
                      'Sem dados do modelo',
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
                  itemCount: features.length,
                  separatorBuilder: (_, __) =>
                      Divider(height: 1, color: AppColors.border),
                  itemBuilder: (context, i) => _MobileFeatureCard(
                    item: features[i],
                    maxPeso: maxPeso,
                    color: _barColors[math.min(i, _barColors.length - 1)],
                    zebra: i.isOdd,
                  ),
                );
              }

              final width = math.max(box.maxWidth, 560.0);
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: width,
                  child: Column(
                    children: [
                      _Header(),
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
            },
          ),
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
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          cell('Feature', _flex[0], Alignment.centerLeft),
          cell('Categoria', _flex[1], Alignment.centerLeft),
          cell(
            'Impacto no Modelo (SHAP Value)',
            _flex[2],
            Alignment.centerLeft,
          ),
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
              alignment: Alignment.centerLeft,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Color(0xFFF1F3F6),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  item.categoria,
                  style: TextStyle(
                    fontSize: 10,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            flex: _flex[2],
            child: Padding(
              padding: EdgeInsets.only(right: 24),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: maxPeso == 0 ? null : item.peso / maxPeso,
                  minHeight: 6,
                  color: color,
                  backgroundColor: Color(0xFFF1F3F6),
                ),
              ),
            ),
          ),
          Expanded(
            flex: _flex[3],
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                fmtDec(item.peso, digits: 2),
                style: TextStyle(fontSize: 12, color: AppColors.text),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MobileFeatureCard extends StatelessWidget {
  final FeatureImportance item;
  final double maxPeso;
  final Color color;
  final bool zebra;

  const _MobileFeatureCard({
    required this.item,
    required this.maxPeso,
    required this.color,
    required this.zebra,
  });

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
              SizedBox(width: 8),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Color(0xFFF1F3F6),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  item.categoria,
                  style: TextStyle(
                    fontSize: 10,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              SizedBox(width: 8),
              Text(
                fmtDec(item.peso, digits: 2),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.text,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: maxPeso == 0 ? null : item.peso / maxPeso,
              minHeight: 6,
              color: color,
              backgroundColor: Color(0xFFF1F3F6),
            ),
          ),
        ],
      ),
    );
  }
}
