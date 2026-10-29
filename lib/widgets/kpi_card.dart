import 'package:flutter/material.dart';

import '../core/formatters.dart';
import '../core/theme.dart';

class KpiCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final String value; // já formatado (ex.: "42.500" ou "--")
  final String? unit; // "km"
  final String? prefix; // "R$"
  final double? variation; // %

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
    return Container(
      padding: EdgeInsets.all(16),
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
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              SizedBox(width: 4),
              Icon(
                icon,
                size: 18,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ],
          ),
          SizedBox(height: 10),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                if (prefix != null)
                  Text(
                    '$prefix ',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                if (unit != null)
                  Text(
                    ' $unit',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(height: 6),
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
    if (v == null) {
      return Text(
        '--',
        style: TextStyle(
          fontSize: 11,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      );
    }
    if (v == 0) {
      return Text(
        '— Estável',
        style: TextStyle(
          fontSize: 11,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      );
    }
    final up = v! > 0;
    final color = up ? AppColors.green : AppColors.red;
    return Row(
      children: [
        Icon(
          up ? Icons.arrow_upward : Icons.arrow_downward,
          size: 12,
          color: color,
        ),
        SizedBox(width: 2),
        Expanded(
          child: Text(
            '${fmtPercent(v)} vs anterior',
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 11, color: color),
          ),
        ),
      ],
    );
  }
}
