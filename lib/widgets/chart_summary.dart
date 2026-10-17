import 'package:flutter/material.dart';
import '../core/theme.dart';

class ChartSummary extends StatelessWidget {
  final List<({String label, String value})> items;
  const ChartSummary({super.key, required this.items});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 12),
    child: Row(children: [
      for (final item in items)
        Expanded(child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: BoxDecoration(color: const Color(0xFFF3F6FB), borderRadius: BorderRadius.circular(8)),
          margin: const EdgeInsets.only(right: 4),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(item.label, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 10, color: AppColors.muted)),
            const SizedBox(height: 4),
            FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerLeft, child: Text(item.value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.navy))),
          ]),
        )),
    ]),
  );
}
