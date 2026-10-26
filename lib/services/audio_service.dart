import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Audio and Vibration Service for timer alarms and tactile feedback.
class AudioService {
  AudioPlayer? _player;
  bool _isPlayingAlert = false;
  Timer? _vibrationLoopTimer;

  bool get isPlayingAlert => _isPlayingAlert;

  AudioService({bool enableAudio = true}) {
    if (enableAudio) {
      _initPlayer();
    }
  }

  void _initPlayer() {
    try {
      _player = AudioPlayer();
    } catch (e) {
      debugPrint('AudioPlayer initialization skipped: $e');
    }
  }

  /// Triggers recurring alarm sound and periodic haptic vibration
  Future<void> startCompletionAlert({
    required bool soundEnabled,
    required bool vibrationEnabled,
  }) async {
    if (_isPlayingAlert) return; // Prevent duplicate alerts
    _isPlayingAlert = true;

    // Trigger Sound
    if (soundEnabled && _player != null) {
      try {
        await _player!.setReleaseMode(ReleaseMode.loop);
        await _player!.play(AssetSource('sounds/timer_beep.wav'));
      } catch (e) {
        debugPrint('Audio alert playback error (fallback applied): $e');
      }
    }

    // Trigger Vibration
    if (vibrationEnabled) {
      triggerVibration();
      // Periodically vibrate every 1.5s while alert is active
      _vibrationLoopTimer?.cancel();
      _vibrationLoopTimer = Timer.periodic(const Duration(milliseconds: 1500), (
        _,
      ) {
        if (_isPlayingAlert && vibrationEnabled) {
          triggerVibration();
        } else {
          _vibrationLoopTimer?.cancel();
        }
      });
    }
  }

  /// Convenience alias for previewing or triggering alarm
  Future<void> playAlert({
    required bool soundEnabled,
    required bool vibrationEnabled,
  }) async {
    await startCompletionAlert(
      soundEnabled: soundEnabled,
      vibrationEnabled: vibrationEnabled,
    );
  }

  /// Stops any playing alarm sound and vibration loops
  Future<void> stopAlert() async {
    _isPlayingAlert = false;
    _vibrationLoopTimer?.cancel();
    _vibrationLoopTimer = null;

    if (_player != null) {
      try {
        await _player!.stop();
      } catch (e) {
        debugPrint('Error stopping audio alert: $e');
      }
    }
  }

  /// Single tactile feedback vibration
  void triggerVibration() {
    try {
      HapticFeedback.vibrate();
    } catch (_) {}
  }

  /// Subtle click feedback for UI button taps
  void triggerClickFeedback({bool vibrationEnabled = true}) {
    if (vibrationEnabled) {
      try {
        HapticFeedback.selectionClick();
      } catch (_) {}
    }
  }

  void dispose() {
    stopAlert();
    _player?.dispose();
    _player = null;
  }
}
