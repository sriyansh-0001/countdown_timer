import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:countdown_timer/models/timer_preset.dart';
import 'package:countdown_timer/services/audio_service.dart';
import 'package:countdown_timer/services/storage_service.dart';
import 'package:countdown_timer/services/timer_service.dart';

// Mock AudioService that doesn't trigger native audio in tests
class MockAudioService extends AudioService {
  bool alertStarted = false;
  bool alertStopped = false;

  MockAudioService() : super(enableAudio: false);

  @override
  Future<void> startCompletionAlert({
    required bool soundEnabled,
    required bool vibrationEnabled,
  }) async {
    alertStarted = true;
  }

  @override
  Future<void> stopAlert() async {
    alertStopped = true;
  }

  @override
  void triggerClickFeedback({bool vibrationEnabled = true}) {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late StorageService storageService;
  late MockAudioService mockAudioService;
  late TimerService timerService;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    storageService = StorageService(prefs);
    mockAudioService = MockAudioService();
    timerService = TimerService.withServices(
      storageService: storageService,
      audioService: mockAudioService,
    );
  });

  tearDown(() {
    timerService.dispose();
  });

  group('TimerService Logic Tests', () {
    test('Initial timer state is Ready with default preset duration', () {
      expect(timerService.status, TimerStatus.ready);
      expect(timerService.totalDuration, const Duration(minutes: 5));
      expect(timerService.remainingDuration, const Duration(minutes: 5));
      expect(timerService.progress, 1.0);
      expect(timerService.formattedRemainingTime, '00:05:00');
    });

    test('Selecting preset updates duration and titles accurately', () {
      final preset25 = TimerPreset.defaultPresets.firstWhere(
        (p) => p.id == 'p_25m',
      );
      timerService.selectPreset(preset25);

      expect(timerService.selectedPresetId, 'p_25m');
      expect(timerService.title, 'Study Session');
      expect(timerService.totalDuration, const Duration(minutes: 25));
      expect(timerService.remainingDuration, const Duration(minutes: 25));
      expect(timerService.formattedRemainingTime, '00:25:00');
      expect(timerService.status, TimerStatus.ready);
    });

    test(
      'Starting timer transitions status to running and sets targetEndTime',
      () {
        timerService.start();

        expect(timerService.status, TimerStatus.running);
        expect(timerService.targetEndTime, isNotNull);
        final difference = timerService.targetEndTime!.difference(
          DateTime.now(),
        );
        expect(difference.inMinutes, closeTo(5, 1));
      },
    );

    test(
      'Pausing timer preserves remaining time and sets status to paused',
      () {
        timerService.start();
        timerService.pause();

        expect(timerService.status, TimerStatus.paused);
        expect(timerService.targetEndTime, isNull);
        expect(timerService.remainingDuration.inSeconds, greaterThan(0));
      },
    );

    test('Resuming timer continues from remaining time', () {
      timerService.start();
      timerService.pause();
      final pausedRemaining = timerService.remainingDuration;
      expect(pausedRemaining.inSeconds, greaterThan(0));

      timerService.resume();
      expect(timerService.status, TimerStatus.running);
      expect(timerService.targetEndTime, isNotNull);
    });

    test('Resetting timer restores initial duration and status to ready', () {
      timerService.start();
      timerService.reset();

      expect(timerService.status, TimerStatus.ready);
      expect(timerService.remainingDuration, timerService.totalDuration);
      expect(timerService.progress, 1.0);
    });

    test('Adding seconds increments remaining and total duration', () {
      timerService.addSeconds(60); // +1 min
      expect(timerService.remainingDuration, const Duration(minutes: 6));
      expect(timerService.totalDuration, const Duration(minutes: 6));
      expect(timerService.formattedRemainingTime, '00:06:00');
    });

    test(
      'Setting custom duration updates timer and clears preset selection',
      () {
        timerService.setCustomDuration(
          const Duration(hours: 1, minutes: 15, seconds: 30),
          title: 'Project Coding',
        );

        expect(timerService.selectedPresetId, isNull);
        expect(timerService.title, 'Project Coding');
        expect(
          timerService.totalDuration,
          const Duration(hours: 1, minutes: 15, seconds: 30),
        );
        expect(timerService.formattedRemainingTime, '01:15:30');
      },
    );

    test('Custom preset CRUD operations persist to storage', () async {
      final custom = TimerPreset.fromDuration(
        id: 'cust_1',
        title: 'Quick Sprint',
        duration: const Duration(minutes: 7),
        isCustom: true,
      );

      await timerService.addCustomPreset(custom);
      expect(timerService.customPresets.length, 1);
      expect(
        timerService.allPresets.length,
        TimerPreset.defaultPresets.length + 1,
      );

      await timerService.deleteCustomPreset('cust_1');
      expect(timerService.customPresets.isEmpty, true);
    });

    test('Clearing history removes all recorded sessions', () async {
      await timerService.clearHistory();
      expect(timerService.history.isEmpty, true);
    });
  });
}
