import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/timer_history_item.dart';
import '../models/timer_preset.dart';
import 'audio_service.dart';
import 'storage_service.dart';

enum TimerStatus {
  ready('Ready'),
  running('Running'),
  paused('Paused'),
  completed('Completed');

  final String label;
  const TimerStatus(this.label);
}

/// Main Timer ChangeNotifier that provides precise time-based countdown calculations,
/// app lifecycle synchronization, preset selection, and alarm triggers.
class TimerService extends ChangeNotifier {
  final StorageService _storageService;
  final AudioService _audioService;

  TimerStatus _status = TimerStatus.ready;
  Duration _totalDuration = const Duration(minutes: 5);
  Duration _remainingDuration = const Duration(minutes: 5);
  DateTime? _targetEndTime;
  Timer? _ticker;

  String _currentPresetTitle = 'Short Break';
  String? _selectedPresetId = 'p_5m';

  List<TimerPreset> _customPresets = [];
  List<TimerHistoryItem> _history = [];

  bool _alertTriggered = false;

  TimerService(this._storageService, [AudioService? audioService])
    : _audioService = audioService ?? AudioService() {
    _loadInitialData();
  }

  TimerService.withServices({
    required StorageService storageService,
    required AudioService audioService,
  }) : this(storageService, audioService);

  // --- Getters & Aliases ---
  TimerStatus get status => _status;
  Duration get totalDuration => _totalDuration;
  Duration get initialDuration => _totalDuration;
  Duration get remainingDuration => _remainingDuration;
  String get currentPresetTitle => _currentPresetTitle;
  String get title => _currentPresetTitle;
  String? get selectedPresetId => _selectedPresetId;
  DateTime? get targetEndTime => _targetEndTime;
  bool get isPlayingAlert => _audioService.isPlayingAlert;
  bool get isAlarmRinging => _audioService.isPlayingAlert;

  List<TimerPreset> get allPresets => [
    ...TimerPreset.defaultPresets,
    ..._customPresets,
  ];
  List<TimerPreset> get customPresets => List.unmodifiable(_customPresets);
  List<TimerHistoryItem> get history => List.unmodifiable(_history);

  /// Progress fraction from 0.0 to 1.0 (1.0 = full time remaining, 0.0 = completed)
  double get progress {
    if (_totalDuration.inMilliseconds == 0) return 0.0;
    final fraction =
        _remainingDuration.inMilliseconds / _totalDuration.inMilliseconds;
    return fraction.clamp(0.0, 1.0);
  }

  /// Formatted digital countdown string: "HH:MM:SS"
  String get formattedRemainingTime => formattedTime(_remainingDuration);

  /// Helper to format any Duration to "HH:MM:SS"
  String formattedTime(Duration duration) {
    final totalSec = duration.inSeconds;
    final hours = totalSec ~/ 3600;
    final minutes = (totalSec % 3600) ~/ 60;
    final seconds = totalSec % 60;

    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String get statusLabel => _status.label;

  void _loadInitialData() {
    _customPresets = _storageService.getCustomPresets();
    _history = _storageService.getTimerHistory();
    _restoreActiveTimerIfAny();
  }

  /// Restores active countdown if app was killed or closed while running/paused
  void _restoreActiveTimerIfAny() {
    final active = _storageService.getActiveTimerState();
    if (active == null) return;

    final statusStr = active['status'] as String?;
    final totalSec = active['totalSeconds'] as int;
    final remainingSec = active['remainingSeconds'] as int;
    final target = active['targetEndTime'] as DateTime?;
    final title = active['presetTitle'] as String;

    if (totalSec <= 0) return;

    _totalDuration = Duration(seconds: totalSec);
    _currentPresetTitle = title;

    if (statusStr == 'running' && target != null) {
      final now = DateTime.now();
      if (target.isAfter(now)) {
        // Still has time remaining
        _targetEndTime = target;
        _remainingDuration = target.difference(now);
        _status = TimerStatus.running;
        _startTicker();
      } else {
        // Time expired while app was inactive
        _remainingDuration = Duration.zero;
        _status = TimerStatus.completed;
        _onFinished();
      }
    } else if (statusStr == 'paused') {
      _remainingDuration = Duration(seconds: remainingSec);
      _status = TimerStatus.paused;
    }
    notifyListeners();
  }

  /// Recalculates time upon app lifecycle resume (foreground wakeup)
  void handleLifecycleResume() {
    if (_status == TimerStatus.running && _targetEndTime != null) {
      _updateTick();
    }
  }

  void handleAppResume() => handleLifecycleResume();

  // --- Timer Controls ---

  /// Starts the countdown with high-precision time calculation
  void start() {
    if (_remainingDuration <= Duration.zero) return;
    _audioService.triggerClickFeedback(
      vibrationEnabled: _storageService.isVibrationEnabled(),
    );

    _ticker?.cancel();
    _targetEndTime = DateTime.now().add(_remainingDuration);
    _status = TimerStatus.running;
    _alertTriggered = false;

    _persistCurrentState();
    _startTicker();
    notifyListeners();
  }

  void startTimer() => start();

  /// Pauses the countdown and preserves exact remaining time
  void pause() {
    if (_status != TimerStatus.running) return;
    _audioService.triggerClickFeedback(
      vibrationEnabled: _storageService.isVibrationEnabled(),
    );

    _ticker?.cancel();
    _ticker = null;

    if (_targetEndTime != null) {
      final diff = _targetEndTime!.difference(DateTime.now());
      _remainingDuration = diff > Duration.zero ? diff : Duration.zero;
    }

    _targetEndTime = null;
    _status = TimerStatus.paused;

    _persistCurrentState();
    notifyListeners();
  }

  void pauseTimer() => pause();

  /// Resumes countdown from current remaining time
  void resume() {
    if (_status != TimerStatus.paused) return;
    start();
  }

  void resumeTimer() => resume();

  /// Resets countdown back to total initial duration
  void reset() {
    _audioService.triggerClickFeedback(
      vibrationEnabled: _storageService.isVibrationEnabled(),
    );
    _ticker?.cancel();
    _ticker = null;
    _targetEndTime = null;
    _status = TimerStatus.ready;
    _remainingDuration = _totalDuration;
    _alertTriggered = false;

    _audioService.stopAlert();
    _storageService.clearActiveTimerState();
    notifyListeners();
  }

  void resetTimer() => reset();

  /// Adds extra time (e.g., +1 min or +5 min) during countdown
  void addDuration(Duration delta) {
    if (_status == TimerStatus.completed) return;
    _audioService.triggerClickFeedback(
      vibrationEnabled: _storageService.isVibrationEnabled(),
    );

    _remainingDuration += delta;
    _totalDuration += delta;

    if (_status == TimerStatus.running && _targetEndTime != null) {
      _targetEndTime = _targetEndTime!.add(delta);
    }

    _persistCurrentState();
    notifyListeners();
  }

  void addSeconds(int seconds) => addDuration(Duration(seconds: seconds));

  /// Selects a duration preset
  void selectPreset(TimerPreset preset) {
    if (_status == TimerStatus.running) {
      pause();
    }
    _audioService.triggerClickFeedback(
      vibrationEnabled: _storageService.isVibrationEnabled(),
    );

    _selectedPresetId = preset.id;
    _currentPresetTitle = preset.title;
    _totalDuration = preset.duration;
    _remainingDuration = preset.duration;
    _status = TimerStatus.ready;
    _targetEndTime = null;

    _audioService.stopAlert();
    _storageService.clearActiveTimerState();
    notifyListeners();
  }

  /// Sets a custom user duration
  void setCustomDuration(Duration duration, {String title = 'Custom Timer'}) {
    if (duration <= Duration.zero) return;
    if (_status == TimerStatus.running) {
      pause();
    }

    _selectedPresetId = null;
    _currentPresetTitle = title;
    _totalDuration = duration;
    _remainingDuration = duration;
    _status = TimerStatus.ready;
    _targetEndTime = null;

    _audioService.stopAlert();
    _storageService.clearActiveTimerState();
    notifyListeners();
  }

  /// Dismisses alarm sound and vibration
  void dismissAlert() {
    _audioService.stopAlert();
    notifyListeners();
  }

  void dismissAlarm() => dismissAlert();

  // --- Internal Timer Engine ---

  void _startTicker() {
    // 200ms periodic timer gives smooth visual feedback without CPU overhead
    _ticker = Timer.periodic(const Duration(milliseconds: 200), (_) {
      _updateTick();
    });
  }

  void _updateTick() {
    if (_status != TimerStatus.running || _targetEndTime == null) return;

    final now = DateTime.now();
    final difference = _targetEndTime!.difference(now);

    if (difference <= Duration.zero) {
      _remainingDuration = Duration.zero;
      _ticker?.cancel();
      _ticker = null;
      _targetEndTime = null;
      _status = TimerStatus.completed;
      _onFinished();
    } else {
      _remainingDuration = difference;
    }
    notifyListeners();
  }

  void _onFinished() {
    if (_alertTriggered) return; // Prevent duplicate alerts
    _alertTriggered = true;

    // Record in history
    final historyItem = TimerHistoryItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _currentPresetTitle,
      durationInSeconds: _totalDuration.inSeconds,
      completedAt: DateTime.now(),
    );
    _history.insert(0, historyItem);
    _storageService.addHistoryItem(historyItem);
    _storageService.clearActiveTimerState();

    // Trigger audible and haptic alert
    _audioService.startCompletionAlert(
      soundEnabled: _storageService.isSoundEnabled(),
      vibrationEnabled: _storageService.isVibrationEnabled(),
    );

    notifyListeners();
  }

  void _persistCurrentState() {
    _storageService.saveActiveTimerState(
      targetEndTime: _targetEndTime,
      totalSeconds: _totalDuration.inSeconds,
      remainingSeconds: _remainingDuration.inSeconds,
      status: _status.name,
      presetTitle: _currentPresetTitle,
    );
  }

  // --- Custom Presets Management ---

  Future<void> addCustomPreset(TimerPreset preset) async {
    _customPresets.add(preset);
    await _storageService.saveCustomPresets(_customPresets);
    notifyListeners();
  }

  Future<void> updateCustomPreset(TimerPreset updated) async {
    final index = _customPresets.indexWhere((p) => p.id == updated.id);
    if (index != -1) {
      _customPresets[index] = updated;
      await _storageService.saveCustomPresets(_customPresets);
      if (_selectedPresetId == updated.id) {
        _currentPresetTitle = updated.title;
      }
      notifyListeners();
    }
  }

  Future<void> deleteCustomPreset(String id) async {
    _customPresets.removeWhere((p) => p.id == id);
    await _storageService.saveCustomPresets(_customPresets);
    if (_selectedPresetId == id) {
      _selectedPresetId = null;
    }
    notifyListeners();
  }

  // --- History Management ---

  Future<void> clearHistory() async {
    _history.clear();
    await _storageService.clearTimerHistory();
    notifyListeners();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _ticker = null;
    super.dispose();
  }
}
