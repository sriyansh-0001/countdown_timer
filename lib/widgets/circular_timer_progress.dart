import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../services/timer_service.dart';
import '../theme/app_theme.dart';

/// A modern circular progress indicator widget with custom painting,
/// smooth animated arc transitions, and state-aware color accents.
class CircularTimerProgress extends StatelessWidget {
  final double progress; // 0.0 to 1.0
  final TimerStatus status;
  final Widget child;
  final double strokeWidth;

  const CircularTimerProgress({
    super.key,
    required this.progress,
    required this.status,
    required this.child,
    this.strokeWidth = 14.0,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final trackColor = isDark
        ? AppTheme.darkTrackColor
        : AppTheme.lightTrackColor;

    final progressColor = AppTheme.statusColor(status, isDark);

    return LayoutBuilder(
      builder: (context, constraints) {
        // Compute diameter dynamically to fit container without overflowing
        final maxDiameter = math.min(
          constraints.maxWidth,
          constraints.maxHeight,
        );
        final diameter = maxDiameter > 0 ? math.min(maxDiameter, 320.0) : 260.0;

        return Center(
          child: SizedBox(
            width: diameter,
            height: diameter,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Animated progress arc
                TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: progress, end: progress),
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  builder: (context, animatedValue, _) {
                    return CustomPaint(
                      size: Size(diameter, diameter),
                      painter: _TimerProgressPainter(
                        progress: animatedValue.clamp(0.0, 1.0),
                        trackColor: trackColor,
                        progressColor: progressColor,
                        strokeWidth: strokeWidth,
                        status: status,
                      ),
                    );
                  },
                ),
                // Center content (timer digits, labels, etc.)
                Padding(
                  padding: EdgeInsets.all(strokeWidth + 16.0),
                  child: child,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _TimerProgressPainter extends CustomPainter {
  final double progress;
  final Color trackColor;
  final Color progressColor;
  final double strokeWidth;
  final TimerStatus status;

  _TimerProgressPainter({
    required this.progress,
    required this.trackColor,
    required this.progressColor,
    required this.strokeWidth,
    required this.status,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // 1. Draw Background Track
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    // 2. Draw Progress Arc if progress > 0
    if (progress > 0.0) {
      final sweepAngle = 2 * math.pi * progress;
      const startAngle = -math.pi / 2; // Start at 12 o'clock

      final progressPaint = Paint()
        ..color = progressColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      // Draw subtle glow if running or completed
      if (status == TimerStatus.running || status == TimerStatus.completed) {
        final glowPaint = Paint()
          ..color = progressColor.withValues(alpha: 0.25)
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth + 6.0
          ..strokeCap = StrokeCap.round
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

        canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius),
          startAngle,
          sweepAngle,
          false,
          glowPaint,
        );
      }

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _TimerProgressPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.trackColor != trackColor ||
        oldDelegate.progressColor != progressColor ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.status != status;
  }
}
