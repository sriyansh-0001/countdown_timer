import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/timer_service.dart';
import '../theme/app_theme.dart';
import '../widgets/circular_timer_progress.dart';
import '../widgets/completion_dialog.dart';
import '../widgets/countdown_display.dart';
import '../widgets/preset_card.dart';
import '../widgets/timer_controls.dart';
import 'custom_timer_dialog.dart';
import 'history_screen.dart';
import 'settings_screen.dart';

/// Main home screen of the Modern Countdown Timer application.
/// Incorporates responsive layout design, lifecycle observation,
/// circular progress visualization, and quick preset selection.
class HomeScreen extends StatefulWidget {
  static const routeName = '/';

  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  bool _isDialogShowing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Re-synchronize time accurately from targetEndTime on app resume
      context.read<TimerService>().handleAppResume();
    }
  }

  void _checkAndShowCompletionDialog(TimerService timerService) {
    if (timerService.status == TimerStatus.completed &&
        timerService.isAlarmRinging &&
        !_isDialogShowing) {
      _isDialogShowing = true;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted) return;
        await CompletionDialog.show(context, timerService);
        _isDialogShowing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final timerService = context.watch<TimerService>();

    // Check if completion alert needs to be shown
    _checkAndShowCompletionDialog(timerService);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Countdown Timer',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            Text(
              'Make every second count.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                fontSize: 12,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history_rounded),
            tooltip: 'Session History',
            onPressed: () =>
                Navigator.of(context).pushNamed(HistoryScreen.routeName),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings',
            onPressed: () =>
                Navigator.of(context).pushNamed(SettingsScreen.routeName),
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isLandscape = constraints.maxWidth > constraints.maxHeight;

            if (isLandscape) {
              return _buildLandscapeLayout(context, timerService, constraints);
            } else {
              return _buildPortraitLayout(context, timerService, constraints);
            }
          },
        ),
      ),
    );
  }

  Widget _buildPortraitLayout(
    BuildContext context,
    TimerService timerService,
    BoxConstraints constraints,
  ) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: constraints.maxHeight - 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Alarm Ringing Banner (if active)
            if (timerService.isAlarmRinging)
              _buildAlarmBanner(context, timerService),

            // Top Space
            const SizedBox(height: 10),

            // Circular Progress Indicator with Center Countdown Digits
            SizedBox(
              height: constraints.maxHeight * 0.40,
              child: CircularTimerProgress(
                progress: timerService.progress,
                status: timerService.status,
                child: CountdownDisplay(
                  formattedTime: timerService.formattedRemainingTime,
                  status: timerService.status,
                  title: timerService.title,
                  totalDurationFormatted: timerService.formattedTime(
                    timerService.initialDuration,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Main Controls (Start, Pause, Resume, Reset, +1m, +5m)
            TimerControls(
              status: timerService.status,
              onStart: timerService.startTimer,
              onPause: timerService.pauseTimer,
              onResume: timerService.resumeTimer,
              onReset: timerService.resetTimer,
              onAddSeconds: timerService.addSeconds,
            ),

            const SizedBox(height: 24),

            // Presets and Custom Section
            _buildPresetsSection(context, timerService),

            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildLandscapeLayout(
    BuildContext context,
    TimerService timerService,
    BoxConstraints constraints,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          // Left: Circular Progress and Countdown
          Expanded(
            flex: 5,
            child: CircularTimerProgress(
              progress: timerService.progress,
              status: timerService.status,
              child: CountdownDisplay(
                formattedTime: timerService.formattedRemainingTime,
                status: timerService.status,
                title: timerService.title,
                totalDurationFormatted: timerService.formattedTime(
                  timerService.initialDuration,
                ),
              ),
            ),
          ),
          const SizedBox(width: 24),

          // Right: Controls and Presets
          Expanded(
            flex: 6,
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (timerService.isAlarmRinging)
                    _buildAlarmBanner(context, timerService),
                  const SizedBox(height: 12),
                  TimerControls(
                    status: timerService.status,
                    onStart: timerService.startTimer,
                    onPause: timerService.pauseTimer,
                    onResume: timerService.resumeTimer,
                    onReset: timerService.resetTimer,
                    onAddSeconds: timerService.addSeconds,
                  ),
                  const SizedBox(height: 24),
                  _buildPresetsSection(context, timerService),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlarmBanner(BuildContext context, TimerService timerService) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.successGreen.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.successGreen, width: 1.5),
      ),
      child: Row(
        children: [
          Icon(Icons.alarm_on_rounded, color: AppTheme.successGreen),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Timer completed! Alarm is sounding.',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          TextButton(
            onPressed: timerService.dismissAlarm,
            child: Text(
              'DISMISS',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppTheme.successGreen,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPresetsSection(BuildContext context, TimerService timerService) {
    final theme = Theme.of(context);
    final allPresets = timerService.allPresets;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                'Presets & Quick Durations',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            TextButton.icon(
              onPressed: () => CustomTimerDialog.show(context, timerService),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Custom'),
              style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Horizontal scrolling preset pills
        SizedBox(
          height: 68,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: allPresets.length,
            separatorBuilder: (context, index) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final preset = allPresets[index];
              final isSelected = timerService.selectedPresetId == preset.id;

              return PresetCard(
                preset: preset,
                isSelected: isSelected,
                onSelected: () => timerService.selectPreset(preset),
                onDelete: preset.isCustom
                    ? () => timerService.deleteCustomPreset(preset.id)
                    : null,
              );
            },
          ),
        ),
      ],
    );
  }
}
