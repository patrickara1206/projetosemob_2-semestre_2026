import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Decorative ribbons painted independently of the navigation controls.
class SidebarWaves extends StatefulWidget {
  final bool horizontal;
  final bool lightBackground;
  const SidebarWaves({
    super.key,
    this.horizontal = false,
    this.lightBackground = false,
  });

  @override
  State<SidebarWaves> createState() => _SidebarWavesState();
}

class _SidebarWavesState extends State<SidebarWaves>
    with SingleTickerProviderStateMixin {
  late final AnimationController _motion = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 18),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context) || !TickerMode.of(context)) {
      _motion.stop();
    } else if (!_motion.isAnimating) {
      _motion.repeat();
    }
  }

  @override
  void dispose() {
    _motion.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: IgnorePointer(
        child: RepaintBoundary(
          child: CustomPaint(
            painter: _WavePainter(
              _motion,
              horizontal: widget.horizontal,
              lightBackground: widget.lightBackground,
            ),
          ),
        ),
      ),
    );
  }
}

class _WavePainter extends CustomPainter {
  final Animation<double> motion;
  final bool horizontal;
  final bool lightBackground;
  _WavePainter(
    this.motion, {
    required this.horizontal,
    required this.lightBackground,
  }) : super(repaint: motion);

  @override
  void paint(Canvas canvas, Size size) {
    final phase = motion.value * math.pi * 2;
    final bounds = Offset.zero & size;
    canvas.save();
    canvas.clipRect(bounds);

    // Each ribbon crosses the tall panel diagonally, with a seamless slow loop.
    for (var ribbon = 0; ribbon < 4; ribbon++) {
      final center = Path();
      final fill = Path();
      final points = <Offset>[];
      final width = lightBackground
          ? 20.0 + ribbon * 9
          : horizontal
          ? 5.0 + ribbon * 3
          : 14.0 + ribbon * 7;
      for (var step = 0; step <= 72; step++) {
        final t = step / 72;
        final y = horizontal
            ? size.height *
                      (lightBackground
                          ? 0.18 + t * 0.55 + ribbon * 0.10
                          : 0.05 + t * 0.75 + ribbon * 0.13) +
                  math.sin(t * math.pi * 2 + phase + ribbon * 0.7) *
                      (lightBackground ? size.height * 0.08 : 15)
            : size.height * (-0.15 + t * 1.3);
        final x = horizontal
            ? size.width * (-0.1 + t * 1.2)
            : size.width * (1.3 - t * 1.65 + ribbon * 0.17) +
                  math.sin(t * math.pi * 2 + phase + ribbon * 0.85) * 38 +
                  math.cos(t * math.pi * 3 - phase + ribbon) * 13;
        points.add(Offset(x, y));
        if (step == 0) {
          center.moveTo(x, y);
          fill.moveTo(horizontal ? x : x - width, horizontal ? y - width : y);
        } else {
          center.lineTo(x, y);
          fill.lineTo(
            horizontal ? x : x - width * math.sin(t * math.pi),
            horizontal ? y - width * math.sin(t * math.pi) : y,
          );
        }
      }
      for (var step = points.length - 1; step >= 0; step--) {
        final p = points[step];
        fill.lineTo(
          horizontal ? p.dx : p.dx + width,
          horizontal ? p.dy + width : p.dy,
        );
      }
      fill.close();
      canvas.drawPath(
        center,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 28 + ribbon * 9
          ..color = const Color(
            0xFF428AFF,
          ).withValues(alpha: lightBackground ? 0.045 : 0.055)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18),
      );
      canvas.drawPath(
        fill,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: lightBackground
                ? const [
                    Color(0x001977DD),
                    Color(0x192878DB),
                    Color(0x001977DD),
                  ]
                : const [
                    Color(0x001977DD),
                    Color(0x264DA6FF),
                    Color(0x001977DD),
                  ],
          ).createShader(bounds),
      );
      canvas.drawPath(
        center,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = ribbon.isEven ? 1.4 : 0.8
          ..color =
              (lightBackground
                      ? const Color(0xFF1976D2)
                      : const Color(0xFFB8E3FF))
                  .withValues(alpha: lightBackground ? 0.13 : 0.16),
      );
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _WavePainter oldDelegate) =>
      oldDelegate.motion != motion ||
      oldDelegate.horizontal != horizontal ||
      oldDelegate.lightBackground != lightBackground;
}
