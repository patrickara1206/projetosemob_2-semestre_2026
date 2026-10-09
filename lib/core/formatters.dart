String fmtInt(num? v) {
  if (v == null) return '--';
  return v.round().toString().replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (_) => '.',
  );
}

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

String fmtDec(num? v, {int digits = 1}) {
  if (v == null) return '--';
  return v.toStringAsFixed(digits).replaceAll('.', ',');
}

String fmtCompact(num? v) {
  if (v == null) return '--';
  final a = v.abs();
  if (a >= 1000000) return '${fmtDec(v / 1000000)}M';
  if (a >= 1000) return '${fmtDec(v / 1000)}K';
  return fmtInt(v);
}

String fmtHa(DateTime? d) {
  if (d == null) return '--';
  final diff = DateTime.now().difference(d);
  if (diff.inMinutes < 1) return 'Agora há pouco';
  if (diff.inMinutes < 60) return 'Há ${diff.inMinutes} min';
  if (diff.inHours < 24) {
    return 'Há ${diff.inHours} ${diff.inHours == 1 ? 'hora' : 'horas'}';
  }
  return 'Há ${diff.inDays} ${diff.inDays == 1 ? 'dia' : 'dias'}';
}
