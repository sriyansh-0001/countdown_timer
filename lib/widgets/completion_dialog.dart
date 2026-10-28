import 'package:flutter/material.dart';

import '../services/timer_service.dart';
import '../theme/app_theme.dart';

/// Modal dialog presented when a countdown timer successfully completes,
/// providing auditory/haptic dismissal and options to restart or finish.
class CompletionDialog extends StatelessWidget {
  final TimerService timerService;

  const CompletionDialog({super.key, required this.timerService});

  static Future<void> show(BuildContext context, TimerService timerService) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => CompletionDialog(timerService: timerService),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          timerService.dismissAlarm();
          Navigator.of(context).pop();
        }
      },
      child: AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        contentPadding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Animated Icon with Pulse Circle
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppTheme.successGreen.withValues(alpha: 0.15),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppTheme.successGreen.withValues(alpha: 0.4),
                  width: 2,
                ),
              ),
              child: Icon(
                Icons.alarm_on_rounded,
                size: 44,
                color: AppTheme.successGreen,
              ),
            ),
            const SizedBox(height: 20),

            // Completion Headline
            Text(
              'Time is Up!',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            // Preset / Session info
            Text(
              'Your timer for "${timerService.title}" (${timerService.formattedTime(timerService.initialDuration)}) has completed.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.textTheme.bodyMedium?.color?.withValues(
                  alpha: 0.8,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Dismiss Alarm Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  timerService.dismissAlarm();
                  Navigator.of(context).pop();
                },
                icon: const Icon(Icons.notifications_off_rounded),
                label: const Text('Dismiss Alert'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.successGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Restart Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  timerService.dismissAlarm();
                  Navigator.of(context).pop();
                  timerService.resetTimer();
                  timerService.startTimer();
                },
                icon: const Icon(Icons.replay_rounded),
                label: const Text('Restart Timer'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
