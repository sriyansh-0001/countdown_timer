import 'package:flutter/material.dart';

import '../services/timer_service.dart';
import '../theme/app_theme.dart';

/// Displays the prominent digital HH:MM:SS countdown, active status pill,
/// and preset label inside the circular timer gauge.
class CountdownDisplay extends StatelessWidget {
  final String formattedTime;
  final TimerStatus status;
  final String title;
  final String totalDurationFormatted;

  const CountdownDisplay({
    super.key,
    required this.formattedTime,
    required this.status,
    required this.title,
    required this.totalDurationFormatted,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final statusColor = AppTheme.statusColor(status, isDark);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Status Badge Pill
        AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(16.0),
            border: Border.all(
              color: statusColor.withValues(alpha: 0.4),
              width: 1.0,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  color: statusColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                status.label.toUpperCase(),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: statusColor,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.1,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),

        // HH:MM:SS Digits with tabular layout to prevent jittering
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            formattedTime,
            style: theme.textTheme.displayLarge?.copyWith(
              fontFamily: 'monospace',
              letterSpacing: 1.5,
              fontWeight: FontWeight.w800,
              color: status == TimerStatus.completed
                  ? statusColor
                  : theme.textTheme.displayLarge?.color,
            ),
          ),
        ),
        const SizedBox(height: 6),

        // Preset / Timer Label
        Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.85),
          ),
        ),
        const SizedBox(height: 2),

        // Total Duration Indicator
        Text(
          'Total: $totalDurationFormatted',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }
}
