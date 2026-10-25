import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/timer_history_item.dart';
import '../models/timer_preset.dart';

/// Service responsible for persisting presets, settings, history,
/// and active timer recovery state locally via SharedPreferences.
class StorageService extends ChangeNotifier {
  static const String _keyThemeMode = 'theme_mode';
  static const String _keySoundEnabled = 'sound_enabled';
  static const String _keyVibrationEnabled = 'vibration_enabled';
  static const String _keyCustomPresets = 'custom_presets';
  static const String _keyTimerHistory = 'timer_history';

  // Active timer state keys for crash recovery / lifecycle restore
  static const String _keyActiveTargetEndTime = 'active_target_end_time';
  static const String _keyActiveTotalSeconds = 'active_total_seconds';
  static const String _keyActiveRemainingSeconds = 'active_remaining_seconds';
  static const String _keyActiveStatus = 'active_status';
  static const String _keyActivePresetTitle = 'active_preset_title';

  late SharedPreferences _prefs;

  StorageService([SharedPreferences? prefs]) {
    if (prefs != null) {
      _prefs = prefs;
    }
  }

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static Future<StorageService> create() async {
    final prefs = await SharedPreferences.getInstance();
    final service = StorageService(prefs);
    return service;
  }

  // --- Theme Mode ---
  ThemeMode get themeMode => getThemeMode();

  ThemeMode getThemeMode() {
    final value = _prefs.getString(_keyThemeMode);
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    String value;
    switch (mode) {
      case ThemeMode.light:
        value = 'light';
        break;
      case ThemeMode.dark:
        value = 'dark';
        break;
      case ThemeMode.system:
        value = 'system';
        break;
    }
    await _prefs.setString(_keyThemeMode, value);
    notifyListeners();
  }

  // --- Sound & Vibration ---
  bool get soundEnabled => isSoundEnabled();
  bool isSoundEnabled() => _prefs.getBool(_keySoundEnabled) ?? true;
  Future<void> setSoundEnabled(bool enabled) async {
    await _prefs.setBool(_keySoundEnabled, enabled);
    notifyListeners();
  }

  bool get vibrationEnabled => isVibrationEnabled();
  bool isVibrationEnabled() => _prefs.getBool(_keyVibrationEnabled) ?? true;
  Future<void> setVibrationEnabled(bool enabled) async {
    await _prefs.setBool(_keyVibrationEnabled, enabled);
    notifyListeners();
  }

  // --- Custom Presets ---
  List<TimerPreset> getCustomPresets() {
    final list = _prefs.getStringList(_keyCustomPresets);
    if (list == null || list.isEmpty) return [];
    return list
        .map((jsonStr) {
          try {
            return TimerPreset.fromJson(jsonStr);
          } catch (_) {
            return null;
          }
        })
        .whereType<TimerPreset>()
        .toList();
  }

  Future<void> saveCustomPresets(List<TimerPreset> presets) async {
    final list = presets.map((p) => p.toJson()).toList();
    await _prefs.setStringList(_keyCustomPresets, list);
    notifyListeners();
  }

  // --- Timer History ---
  List<TimerHistoryItem> getTimerHistory() {
    final list = _prefs.getStringList(_keyTimerHistory);
    if (list == null || list.isEmpty) return [];
    return list
        .map((jsonStr) {
          try {
            return TimerHistoryItem.fromJson(jsonStr);
          } catch (_) {
            return null;
          }
        })
        .whereType<TimerHistoryItem>()
        .toList();
  }

  Future<void> addHistoryItem(TimerHistoryItem item) async {
    final current = getTimerHistory();
    // Prepend new item, keep latest 50 entries
    current.insert(0, item);
    if (current.length > 50) {
      current.removeRange(50, current.length);
    }
    final list = current.map((h) => h.toJson()).toList();
    await _prefs.setStringList(_keyTimerHistory, list);
    notifyListeners();
  }

  Future<void> clearTimerHistory() async {
    await _prefs.remove(_keyTimerHistory);
    notifyListeners();
  }

  // --- Active Timer State Recovery ---
  Future<void> saveActiveTimerState({
    required DateTime? targetEndTime,
    required int totalSeconds,
    required int remainingSeconds,
    required String status,
    required String presetTitle,
  }) async {
    if (targetEndTime != null) {
      await _prefs.setString(
        _keyActiveTargetEndTime,
        targetEndTime.toIso8601String(),
      );
    } else {
      await _prefs.remove(_keyActiveTargetEndTime);
    }
    await _prefs.setInt(_keyActiveTotalSeconds, totalSeconds);
    await _prefs.setInt(_keyActiveRemainingSeconds, remainingSeconds);
    await _prefs.setString(_keyActiveStatus, status);
    await _prefs.setString(_keyActivePresetTitle, presetTitle);
  }

  Map<String, dynamic>? getActiveTimerState() {
    final status = _prefs.getString(_keyActiveStatus);
    if (status == null) return null;

    final targetEndTimeStr = _prefs.getString(_keyActiveTargetEndTime);
    DateTime? targetEndTime;
    if (targetEndTimeStr != null) {
      try {
        targetEndTime = DateTime.parse(targetEndTimeStr);
      } catch (_) {}
    }

    final totalSeconds = _prefs.getInt(_keyActiveTotalSeconds) ?? 0;
    final remainingSeconds = _prefs.getInt(_keyActiveRemainingSeconds) ?? 0;
    final presetTitle =
        _prefs.getString(_keyActivePresetTitle) ?? 'Custom Timer';

    return {
      'targetEndTime': targetEndTime,
      'totalSeconds': totalSeconds,
      'remainingSeconds': remainingSeconds,
      'status': status,
      'presetTitle': presetTitle,
    };
  }

  Future<void> clearActiveTimerState() async {
    await _prefs.remove(_keyActiveTargetEndTime);
    await _prefs.remove(_keyActiveTotalSeconds);
    await _prefs.remove(_keyActiveRemainingSeconds);
    await _prefs.remove(_keyActiveStatus);
    await _prefs.remove(_keyActivePresetTitle);
  }
}
