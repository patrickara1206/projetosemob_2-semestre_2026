/// 42500 -> "42.500". Se for nulo -> "--".
String fmtInt(num? v) {
  if (v == null) return '--';
  return v
      .round()
      .toString()
      .replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => '.');
}

/// 2.4 -> "+2,4%". Se for nulo -> "--".
String fmtPercent(double? v, {bool sign = true}) {
  if (v == null) return '--';
  final s = v.abs().toStringAsFixed(1).replaceAll('.', ',');
  final prefix = v > 0 ? '+' : (v < 0 ? '-' : '');
  return '${sign ? prefix : ''}$s%';
}

String fmtDateTime(DateTime d) {
  String two(int n) => n.toString().padLeft(2, '0');
  return '${two(d.day)}/${two(d.month)}/${d.year}\n${two(d.hour)}:${two(d.minute)}';
}
/// 88.4 -> "88,4". Se for nulo -> "--".
String fmtDec(num? v, {int digits = 1}) {
  if (v == null) return '--';
  return v.toStringAsFixed(digits).replaceAll('.', ',');
}

/// 142500 -> "142,5K" | 1200000 -> "1,2M". Se for nulo -> "--".
String fmtCompact(num? v) {
  if (v == null) return '--';
  final a = v.abs();
  if (a >= 1000000) return '${fmtDec(v / 1000000)}M';
  if (a >= 1000) return '${fmtDec(v / 1000)}K';
  return fmtInt(v);
}