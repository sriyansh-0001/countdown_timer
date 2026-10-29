import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:countdown_timer/main.dart';
import 'package:countdown_timer/services/audio_service.dart';
import 'package:countdown_timer/services/storage_service.dart';
import 'package:countdown_timer/services/timer_service.dart';
import 'package:countdown_timer/widgets/countdown_display.dart';

// Test mock for AudioService to avoid native audio calls in headless tests
class TestMockAudioService extends AudioService {
  TestMockAudioService() : super(enableAudio: false);

  @override
  Future<void> startCompletionAlert({
    required bool soundEnabled,
    required bool vibrationEnabled,
  }) async {}

  @override
  Future<void> stopAlert() async {}

  @override
  void triggerClickFeedback({bool vibrationEnabled = true}) {}
}

Widget createTestApp({
  required StorageService storageService,
  required TimerService timerService,
}) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<StorageService>.value(value: storageService),
      ChangeNotifierProvider<TimerService>.value(value: timerService),
    ],
    child: const CountdownApp(),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late StorageService storageService;
  late TimerService timerService;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    storageService = StorageService(prefs);
    timerService = TimerService.withServices(
      storageService: storageService,
      audioService: TestMockAudioService(),
    );
  });

  tearDown(() {
    timerService.dispose();
  });

  group('Countdown Timer UI Widget Tests', () {
    testWidgets(
      'Home screen displays header, subtitle, countdown and controls',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          createTestApp(
            storageService: storageService,
            timerService: timerService,
          ),
        );
        await tester.pumpAndSettle();

        // Verify Header
        expect(find.text('Countdown Timer'), findsOneWidget);
        expect(find.text('Make every second count.'), findsOneWidget);

        // Verify Countdown display widget has 00:05:00
        expect(
          find.descendant(
            of: find.byType(CountdownDisplay),
            matching: find.text('00:05:00'),
          ),
          findsOneWidget,
        );

        // Verify Status Badge
        expect(find.text('READY'), findsOneWidget);

        // Verify Control Buttons
        expect(find.text('Start'), findsOneWidget);
        expect(find.text('+1 min'), findsOneWidget);
        expect(find.text('+5 min'), findsOneWidget);
      },
    );

    testWidgets(
      'Tapping Start transitions button to Pause and status to RUNNING',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          createTestApp(
            storageService: storageService,
            timerService: timerService,
          ),
        );
        await tester.pumpAndSettle();

        // Tap Start
        await tester.tap(find.text('Start'));
        await tester.pump();

        // Verify status and button updated
        expect(find.text('RUNNING'), findsOneWidget);
        expect(find.text('Pause'), findsOneWidget);

        // Tap Pause
        await tester.tap(find.text('Pause'));
        await tester.pump();

        expect(find.text('PAUSED'), findsOneWidget);
        expect(find.text('Resume'), findsOneWidget);
      },
    );

    testWidgets('Tapping +1 min bumps countdown by 60 seconds', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createTestApp(
          storageService: storageService,
          timerService: timerService,
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.descendant(
          of: find.byType(CountdownDisplay),
          matching: find.text('00:05:00'),
        ),
        findsOneWidget,
      );

      // Tap +1 min
      await tester.tap(find.text('+1 min'));
      await tester.pump();

      expect(
        find.descendant(
          of: find.byType(CountdownDisplay),
          matching: find.text('00:06:00'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('Selecting a preset updates the countdown display', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createTestApp(
          storageService: storageService,
          timerService: timerService,
        ),
      );
      await tester.pumpAndSettle();

      // Look for Quick Test (1 min preset)
      final quickPresetFinder = find.text('Quick Test');
      expect(quickPresetFinder, findsOneWidget);

      await tester.tap(quickPresetFinder);
      await tester.pump();

      // Display should update to 00:01:00
      expect(
        find.descendant(
          of: find.byType(CountdownDisplay),
          matching: find.text('00:01:00'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('Settings screen renders academic info for Sriyansh', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createTestApp(
          storageService: storageService,
          timerService: timerService,
        ),
      );
      await tester.pumpAndSettle();

      // Navigate to Settings
      final settingsIconFinder = find.byIcon(Icons.settings_outlined);
      expect(settingsIconFinder, findsOneWidget);
      await tester.tap(settingsIconFinder);
      await tester.pumpAndSettle();

      // Verify academic project details
      expect(find.text('Settings & Info'), findsOneWidget);

      // Scroll to ensure the academic project card is visible
      await tester.scrollUntilVisible(
        find.text('ACE Engineering College'),
        200,
        scrollable: find.byType(Scrollable).first,
      );

      expect(find.text('ACE Engineering College'), findsOneWidget);
      expect(find.text('Sriyansh'), findsOneWidget);
      expect(find.text('24AG1A05585'), findsOneWidget);
      expect(find.text('B.Tech 3rd Year, Sem 1'), findsOneWidget);
    });
  });
}
