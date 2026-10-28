import 'package:flutter/material.dart';

import '../services/timer_service.dart';
import '../theme/app_theme.dart';

/// Control panel containing Start/Pause/Resume, Reset, and Quick bump (+1m, +5m) buttons.
class TimerControls extends StatelessWidget {
  final TimerStatus status;
  final VoidCallback onStart;
  final VoidCallback onPause;
  final VoidCallback onResume;
  final VoidCallback onReset;
  final void Function(int seconds) onAddSeconds;

  const TimerControls({
    super.key,
    required this.status,
    required this.onStart,
    required this.onPause,
    required this.onResume,
    required this.onReset,
    required this.onAddSeconds,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final isRunning = status == TimerStatus.running;
    final isPaused = status == TimerStatus.paused;
    final isCompleted = status == TimerStatus.completed;
    final isReady = status == TimerStatus.ready;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Quick Bump Buttons (+1m, +5m)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            OutlinedButton.icon(
              onPressed: isCompleted ? null : () => onAddSeconds(60),
              icon: const Icon(Icons.add, size: 16),
              label: const Text('+1 min'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
            const SizedBox(width: 12),
            OutlinedButton.icon(
              onPressed: isCompleted ? null : () => onAddSeconds(300),
              icon: const Icon(Icons.add, size: 16),
              label: const Text('+5 min'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Primary Control Row (Reset, Start/Pause/Resume, Stop/Clear)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Reset Button
            IconButton.filledTonal(
              onPressed: isReady ? null : onReset,
              tooltip: 'Reset Timer',
              iconSize: 26,
              style: IconButton.styleFrom(
                padding: const EdgeInsets.all(16),
                backgroundColor: isDark
                    ? AppTheme.darkSurfaceVariant
                    : AppTheme.lightSurfaceVariant,
              ),
              icon: const Icon(Icons.refresh_rounded),
            ),
            const SizedBox(width: 24),

            // Primary Action Button (Start / Pause / Resume / Restart)
            _buildPrimaryButton(context, isDark),

            const SizedBox(width: 24),

            // Stop / Complete dismiss button
            IconButton.filledTonal(
              onPressed: (isRunning || isPaused) ? onReset : null,
              tooltip: 'Cancel Timer',
              iconSize: 26,
              style: IconButton.styleFrom(
                padding: const EdgeInsets.all(16),
                backgroundColor: isDark
                    ? AppTheme.darkSurfaceVariant
                    : AppTheme.lightSurfaceVariant,
              ),
              icon: const Icon(Icons.stop_rounded),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPrimaryButton(BuildContext context, bool isDark) {
    if (status == TimerStatus.running) {
      return ElevatedButton.icon(
        onPressed: onPause,
        icon: const Icon(Icons.pause_rounded, size: 30),
        label: const Text(
          'Pause',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.warningAmber,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          elevation: 4,
        ),
      );
    } else if (status == TimerStatus.paused) {
      return ElevatedButton.icon(
        onPressed: onResume,
        icon: const Icon(Icons.play_arrow_rounded, size: 32),
        label: const Text(
          'Resume',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: isDark
              ? AppTheme.darkSecondary
              : AppTheme.lightPrimary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          elevation: 4,
        ),
      );
    } else if (status == TimerStatus.completed) {
      return ElevatedButton.icon(
        onPressed: onReset,
        icon: const Icon(Icons.replay_rounded, size: 30),
        label: const Text(
          'Restart',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.successGreen,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          elevation: 4,
        ),
      );
    } else {
      // Ready
      return ElevatedButton.icon(
        onPressed: onStart,
        icon: const Icon(Icons.play_arrow_rounded, size: 32),
        label: const Text(
          'Start',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: isDark
              ? AppTheme.darkPrimary
              : AppTheme.lightPrimary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          elevation: 4,
        ),
      );
    }
  }
}
