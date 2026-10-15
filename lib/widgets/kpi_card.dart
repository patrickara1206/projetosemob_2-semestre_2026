import 'package:flutter/material.dart';

import '../core/formatters.dart';
import '../core/theme.dart';

class KpiCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final String value;
  final String? unit;
  final String? prefix;
  final double? variation;

  const KpiCard({
    super.key,
    required this.title,
    required this.icon,
    required this.value,
    this.unit,
    this.prefix,
    this.variation,
  });

  @override
  Widget build(BuildContext context) {
    final esquema = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: cardDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  title.toUpperCase(),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: esquema.onSurfaceVariant,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                icon,
                size: 20,
                color: esquema.onSurfaceVariant,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              if (prefix != null)
                Text(
                  '$prefix ',
                  style: TextStyle(
                    fontSize: 13,
                    color: esquema.onSurface,
                  ),
                ),
              Flexible(
                child: Text(
                  value,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: esquema.onSurface,
                  ),
                ),
              ),
              if (unit != null)
                Text(
                  ' $unit',
                  style: TextStyle(
                    fontSize: 13,
                    color: esquema.onSurfaceVariant,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          _Variation(variation),
        ],
      ),
    );
  }
}

class _Variation extends StatelessWidget {
  final double? v;

  const _Variation(this.v);

  @override
  Widget build(BuildContext context) {
    final esquema = Theme.of(context).colorScheme;
    final escuro = Theme.of(context).brightness == Brightness.dark;

    if (v == null || v == 0) {
      return Text(
        v == null ? '--' : '— Estável',
        style: TextStyle(
          fontSize: 11,
          color: esquema.onSurfaceVariant,
        ),
      );
    }

    final up = v! > 0;
    final color = up
        ? (escuro ? const Color(0xFF86EFAC) : AppColors.green)
        : (escuro ? const Color(0xFFFCA5A5) : AppColors.red);

    return Row(
      children: [
        Icon(
          up ? Icons.arrow_upward : Icons.arrow_downward,
          size: 12,
          color: color,
        ),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            '${fmtPercent(v)} vs anterior',
            style: TextStyle(fontSize: 11, color: color),
          ),
        ),
      ],
    );
  }
}