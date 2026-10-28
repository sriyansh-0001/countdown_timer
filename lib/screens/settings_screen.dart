import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/audio_service.dart';
import '../services/storage_service.dart';
import '../services/timer_service.dart';
import '../theme/app_theme.dart';

/// Settings and academic project info screen.
class SettingsScreen extends StatelessWidget {
  static const routeName = '/settings';

  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final storageService = context.watch<StorageService>();
    final timerService = context.watch<TimerService>();

    return Scaffold(
      appBar: AppBar(title: const Text('Settings & Info')),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        children: [
          // Section: Appearance
          _buildSectionHeader(context, 'Appearance'),
          Card(
            elevation: 0,
            color: isDark ? AppTheme.darkCardColor : AppTheme.lightCardColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: isDark ? Colors.white10 : Colors.black12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Theme Mode',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SegmentedButton<ThemeMode>(
                    segments: const [
                      ButtonSegment(
                        value: ThemeMode.system,
                        label: Text('System'),
                        icon: Icon(Icons.brightness_auto_rounded),
                      ),
                      ButtonSegment(
                        value: ThemeMode.light,
                        label: Text('Light'),
                        icon: Icon(Icons.light_mode_rounded),
                      ),
                      ButtonSegment(
                        value: ThemeMode.dark,
                        label: Text('Dark'),
                        icon: Icon(Icons.dark_mode_rounded),
                      ),
                    ],
                    selected: {storageService.themeMode},
                    onSelectionChanged: (newSelection) {
                      storageService.setThemeMode(newSelection.first);
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Section: Sound & Haptics
          _buildSectionHeader(context, 'Alerts & Feedback'),
          Card(
            elevation: 0,
            color: isDark ? AppTheme.darkCardColor : AppTheme.lightCardColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: isDark ? Colors.white10 : Colors.black12),
            ),
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Sound Alert'),
                  subtitle: const Text('Play chime when countdown finishes'),
                  secondary: const Icon(Icons.volume_up_rounded),
                  value: storageService.soundEnabled,
                  onChanged: (val) {
                    storageService.setSoundEnabled(val);
                  },
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text('Vibration Feedback'),
                  subtitle: const Text('Vibrate device on timer completion'),
                  secondary: const Icon(Icons.vibration_rounded),
                  value: storageService.vibrationEnabled,
                  onChanged: (val) {
                    storageService.setVibrationEnabled(val);
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  title: const Text('Test Alert'),
                  subtitle: const Text('Preview sound and vibration alert'),
                  leading: const Icon(Icons.play_circle_outline_rounded),
                  trailing: OutlinedButton(
                    onPressed: () async {
                      await AudioService().playAlert(
                        soundEnabled: storageService.soundEnabled,
                        vibrationEnabled: storageService.vibrationEnabled,
                      );
                      await Future.delayed(const Duration(seconds: 2));
                      await AudioService().stopAlert();
                    },
                    child: const Text('Test'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Section: Data & Storage
          _buildSectionHeader(context, 'Data Management'),
          Card(
            elevation: 0,
            color: isDark ? AppTheme.darkCardColor : AppTheme.lightCardColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: isDark ? Colors.white10 : Colors.black12),
            ),
            child: ListTile(
              leading: Icon(
                Icons.delete_outline_rounded,
                color: AppTheme.dangerRed,
              ),
              title: const Text('Clear All Session History'),
              subtitle: Text('${timerService.history.length} logged sessions'),
              onTap: () {
                _confirmClearHistory(context, timerService);
              },
            ),
          ),
          const SizedBox(height: 24),

          // Section: Academic Profile (ACE Engineering College)
          _buildSectionHeader(context, 'Academic Project Information'),
          Card(
            elevation: 0,
            color: (isDark ? AppTheme.darkPrimary : AppTheme.lightPrimary)
                .withValues(alpha: isDark ? 0.15 : 0.08),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: (isDark ? AppTheme.darkPrimary : AppTheme.lightPrimary)
                    .withValues(alpha: 0.3),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppTheme.darkPrimary
                              : AppTheme.lightPrimary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.school_rounded,
                          color: Colors.white,
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'ACE Engineering College',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Department of Computer Science & Engineering',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.textTheme.bodySmall?.color
                                    ?.withValues(alpha: 0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  _buildInfoRow('Student Name', 'Sriyansh'),
                  _buildInfoRow('Roll Number', '24AG1A05585'),
                  _buildInfoRow('Academic Level', 'B.Tech 3rd Year, Sem 1'),
                  _buildInfoRow('Project', 'Modern Flutter Countdown Timer'),
                  _buildInfoRow(
                    'Architecture',
                    'Provider + Service-Oriented (M3)',
                  ),
                  _buildInfoRow('Academic Year', '2026'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          Center(
            child: Text(
              'Countdown Timer App • Version 1.0.0\nBuilt with Flutter & Material 3',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.5),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
        ],
      ),
    );
  }

  void _confirmClearHistory(BuildContext context, TimerService timerService) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear All Session History?'),
        content: const Text(
          'Are you sure you want to delete all saved timer records? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.dangerRed,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              timerService.clearHistory();
              Navigator.of(ctx).pop();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
