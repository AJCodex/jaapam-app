import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';

/// Sadhana-style circular progress ring.
/// Renders a track + an arc from 12 o'clock for the given progress (0..1).
class JaapRing extends StatelessWidget {
  const JaapRing({
    super.key,
    required this.progress,
    required this.child,
    this.size = 240,
    this.strokeWidth = 14,
  });

  final double progress;
  final Widget child;
  final double size;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _RingPainter(
          progress: progress.clamp(0.0, 1.0),
          stroke: strokeWidth,
          track: scheme.brightness == Brightness.dark
              ? const Color(0xFF3A332C)
              : AppTheme.ringTrack,
          fill: scheme.primary,
        ),
        child: Center(child: child),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.progress,
    required this.stroke,
    required this.track,
    required this.fill,
  });

  final double progress;
  final double stroke;
  final Color track;
  final Color fill;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.shortestSide - stroke) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final trackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..color = track;
    canvas.drawCircle(center, radius, trackPaint);

    if (progress > 0) {
      final fillPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = stroke
        ..color = fill;
      // Start at -90 deg (12 o'clock); sweep clockwise.
      const start = -1.5707963267948966; // -pi/2
      final sweep = 6.283185307179586 * progress; // 2pi * progress
      canvas.drawArc(rect, start, sweep, false, fillPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) =>
      old.progress != progress ||
      old.stroke != stroke ||
      old.track != track ||
      old.fill != fill;
}
