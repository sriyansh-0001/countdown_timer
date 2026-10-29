import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:countdown_timer/models/timer_history_item.dart';
import 'package:countdown_timer/models/timer_preset.dart';

void main() {
  group('TimerPreset Model Tests', () {
    test('Default presets list contains valid entries', () {
      expect(TimerPreset.defaultPresets.isNotEmpty, true);
      expect(TimerPreset.defaultPresets.length, 8);

      final p25 = TimerPreset.defaultPresets.firstWhere((p) => p.id == 'p_25m');
      expect(p25.title, 'Study Session');
      expect(p25.durationInSeconds, 1500);
      expect(p25.formattedDuration, '25m');
      expect(p25.digitalFormat, '00:25:00');
    });

    test('Json serialization and deserialization works correctly', () {
      const preset = TimerPreset(
        id: 'test_1',
        title: 'Custom Deep Work',
        durationInSeconds: 3665,
        isCustom: true,
        iconName: 'bolt',
      );

      final json = preset.toJson();
      final restored = TimerPreset.fromJson(json);

      expect(restored.id, 'test_1');
      expect(restored.title, 'Custom Deep Work');
      expect(restored.durationInSeconds, 3665);
      expect(restored.isCustom, true);
      expect(restored.iconName, 'bolt');
      expect(restored.formattedDuration, '1h 1m 5s');
      expect(restored.digitalFormat, '01:01:05');
      expect(restored.icon, Icons.bolt_rounded);
    });

    test('fromDuration factory creates expected object', () {
      final preset = TimerPreset.fromDuration(
        id: 'p_10',
        title: 'Break',
        duration: const Duration(minutes: 10),
      );
      expect(preset.durationInSeconds, 600);
      expect(preset.duration.inMinutes, 10);
    });
  });

  group('TimerHistoryItem Model Tests', () {
    test('Json serialization and formatting works correctly', () {
      final now = DateTime.now();
      final item = TimerHistoryItem(
        id: 'hist_1',
        title: 'Focus Sprint',
        durationInSeconds: 1500,
        completedAt: now,
      );

      final json = item.toJson();
      final restored = TimerHistoryItem.fromJson(json);

      expect(restored.id, 'hist_1');
      expect(restored.title, 'Focus Sprint');
      expect(restored.durationInSeconds, 1500);
      expect(restored.formattedDuration, '25m');
      expect(
        restored.completedAt.millisecondsSinceEpoch,
        now.millisecondsSinceEpoch,
      );
      expect(restored.formattedDate, 'Just now');

      final pastItem = TimerHistoryItem(
        id: 'hist_2',
        title: 'Past Sprint',
        durationInSeconds: 1500,
        completedAt: DateTime(2025, 1, 1, 10, 0),
      );
      expect(pastItem.formattedDate.contains('2025'), true);
    });
  });
}
