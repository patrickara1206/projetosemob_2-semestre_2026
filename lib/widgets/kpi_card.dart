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
      padding: const EdgeInsets.all(16),
      decoration: cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  title.toUpperCase(),
                  style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF374151)),
                ),
              ),
              Icon(icon, size: 20, color: AppColors.muted),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              if (prefix != null)
                Text('$prefix ',
                    style: const TextStyle(
                        fontSize: 13, color: AppColors.navy)),
              Flexible(
                child: FittedBox(fit:BoxFit.scaleDown,alignment:Alignment.centerLeft,child: Text(value,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: AppColors.navy))),
              ),
              if (unit != null)
                Text(' $unit',
                    style: const TextStyle(
                        fontSize: 13, color: AppColors.navy)),
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
    if (v == null) {
      return const Text('--',
          style: TextStyle(fontSize: 11, color: AppColors.muted));
    }
    if (v == 0) {
      return const Text('— Estável',
          style: TextStyle(fontSize: 11, color: AppColors.muted));
    }
    final up = v! > 0;
    final color = up ? AppColors.green : AppColors.red;
    return Row(
      children: [
        Icon(up ? Icons.arrow_upward : Icons.arrow_downward,
            size: 12, color: color),
        const SizedBox(width: 2),
        Flexible(child: Text('${fmtPercent(v)} vs anterior',
            style: TextStyle(fontSize: 11, color: color))),
      ],
    );
  }
}