import 'package:flutter/material.dart';

/// Shared visual shell; chart scales, values and interactions stay unchanged.
class FuturisticChartPanel extends StatelessWidget {
  final EdgeInsetsGeometry padding;
  final Widget child;
  const FuturisticChartPanel({
    super.key,
    required this.padding,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final accent = dark ? const Color(0xFF54DFFF) : const Color(0xFF1677DF);
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: dark
              ? const [Color(0xFF13243E), Color(0xFF101B2E), Color(0xFF142841)]
              : const [Color(0xFFFFFFFF), Color(0xFFF6FAFF), Color(0xFFECF6FF)],
          stops: const [0, 0.65, 1],
        ),
        border: Border.all(color: accent.withValues(alpha: dark ? 0.28 : 0.19)),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.08),
            blurRadius: 28,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: CustomPaint(
          painter: _PanelEtching(accent, dark),
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

class _PanelEtching extends CustomPainter {
  final Color accent;
  final bool dark;
  const _PanelEtching(this.accent, this.dark);

  @override
  void paint(Canvas canvas, Size size) {
    final grid = Paint()
      ..color = accent.withValues(alpha: dark ? 0.07 : 0.045)
      ..strokeWidth = 0.6;
    // Sparse instrumentation lattice, behind all text and interactive controls.
    for (double x = 24; x < size.width; x += 32) {
      for (double y = 116; y < size.height - 30; y += 32) {
        canvas.drawCircle(Offset(x, y), 0.8, grid);
      }
    }
    final rail = Paint()
      ..shader = LinearGradient(
        colors: [
          accent.withValues(alpha: 0),
          accent.withValues(alpha: 0.8),
          const Color(0xFF5BE8EC),
          accent.withValues(alpha: 0),
        ],
      ).createShader(Rect.fromLTWH(16, 0, size.width - 32, 2))
      ..strokeWidth = 2;
    canvas.drawLine(const Offset(24, 1), Offset(size.width - 24, 1), rail);
    final corners = Paint()
      ..color = accent.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    final path = Path()
      ..moveTo(size.width - 52, size.height - 10)
      ..lineTo(size.width - 22, size.height - 10)
      ..lineTo(size.width - 10, size.height - 22)
      ..lineTo(size.width - 10, size.height - 52);
    canvas.drawPath(path, corners);
  }

  @override
  bool shouldRepaint(covariant _PanelEtching oldDelegate) =>
      accent != oldDelegate.accent || dark != oldDelegate.dark;
}

LinearGradient chartLineGradient(Color color) => LinearGradient(
  colors: [color, Color.lerp(color, const Color(0xFF36DDE7), 0.5)!, color],
  stops: const [0, 0.55, 1],
);

LinearGradient chartAreaGradient(Color color) => LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [
    color.withValues(alpha: 0.22),
    color.withValues(alpha: 0.06),
    color.withValues(alpha: 0),
  ],
);

Shadow chartLineGlow(Color color) =>
    Shadow(color: color.withValues(alpha: 0.28), blurRadius: 7);

LinearGradient chartBarGradient(Color color) => LinearGradient(
  begin: Alignment.bottomCenter,
  end: Alignment.topCenter,
  colors: [color, Color.lerp(color, const Color(0xFF75EAFF), 0.6)!],
);

const chartTooltipBackground = Color(0xEB0A2351);
