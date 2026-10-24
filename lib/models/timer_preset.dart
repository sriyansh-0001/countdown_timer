import 'dart:convert';

import 'package:flutter/material.dart';

/// Model representing a timer preset (e.g., 25m Pomodoro, 5m Break, etc.)
class TimerPreset {
  final String id;
  final String title;
  final int durationInSeconds;
  final bool isCustom;
  final String iconName;

  const TimerPreset({
    required this.id,
    required this.title,
    required this.durationInSeconds,
    this.isCustom = false,
    this.iconName = 'timer',
  });

  /// Factory constructor taking a Duration directly
  factory TimerPreset.fromDuration({
    required String id,
    required String title,
    required Duration duration,
    bool isCustom = false,
    String iconName = 'timer',
  }) {
    return TimerPreset(
      id: id,
      title: title,
      durationInSeconds: duration.inSeconds,
      isCustom: isCustom,
      iconName: iconName,
    );
  }

  Duration get duration => Duration(seconds: durationInSeconds);

  /// Readable duration string like "1m", "25m", "1h 1m 5s"
  String get formattedDuration {
    final hours = durationInSeconds ~/ 3600;
    final minutes = (durationInSeconds % 3600) ~/ 60;
    final seconds = durationInSeconds % 60;

    final parts = <String>[];
    if (hours > 0) parts.add('${hours}h');
    if (minutes > 0) parts.add('${minutes}m');
    if (seconds > 0) parts.add('${seconds}s');
    if (parts.isEmpty) return '0s';
    return parts.join(' ');
  }

  /// Exact HH:MM:SS duration string
  String get digitalFormat {
    final hours = durationInSeconds ~/ 3600;
    final minutes = (durationInSeconds % 3600) ~/ 60;
    final seconds = durationInSeconds % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Alias for formatted digital duration
  String get formattedDigitalDuration => digitalFormat;

  /// Material icon mapping based on iconName
  IconData get icon {
    switch (iconName) {
      case 'bolt':
        return Icons.bolt_rounded;
      case 'coffee':
        return Icons.coffee_rounded;
      case 'local_cafe':
        return Icons.local_cafe_rounded;
      case 'bed':
        return Icons.bed_rounded;
      case 'school':
        return Icons.school_rounded;
      case 'fitness_center':
        return Icons.fitness_center_rounded;
      case 'menu_book':
        return Icons.menu_book_rounded;
      case 'psychology':
        return Icons.psychology_rounded;
      case 'timer':
      default:
        return Icons.timer_outlined;
    }
  }

  TimerPreset copyWith({
    String? id,
    String? title,
    int? durationInSeconds,
    bool? isCustom,
    String? iconName,
  }) {
    return TimerPreset(
      id: id ?? this.id,
      title: title ?? this.title,
      durationInSeconds: durationInSeconds ?? this.durationInSeconds,
      isCustom: isCustom ?? this.isCustom,
      iconName: iconName ?? this.iconName,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'durationInSeconds': durationInSeconds,
      'isCustom': isCustom,
      'iconName': iconName,
    };
  }

  factory TimerPreset.fromMap(Map<String, dynamic> map) {
    return TimerPreset(
      id: map['id'] as String,
      title: map['title'] as String,
      durationInSeconds: map['durationInSeconds'] as int,
      isCustom: map['isCustom'] as bool? ?? false,
      iconName: map['iconName'] as String? ?? 'timer',
    );
  }

  String toJson() => jsonEncode(toMap());

  factory TimerPreset.fromJson(String source) =>
      TimerPreset.fromMap(jsonDecode(source) as Map<String, dynamic>);

  /// Default presets recommended in prompt
  static const List<TimerPreset> defaultPresets = [
    TimerPreset(
      id: 'p_1m',
      title: 'Quick Test',
      durationInSeconds: 60,
      iconName: 'bolt',
    ),
    TimerPreset(
      id: 'p_5m',
      title: 'Short Break',
      durationInSeconds: 300,
      iconName: 'coffee',
    ),
    TimerPreset(
      id: 'p_10m',
      title: 'Tea Break',
      durationInSeconds: 600,
      iconName: 'local_cafe',
    ),
    TimerPreset(
      id: 'p_15m',
      title: 'Power Nap',
      durationInSeconds: 900,
      iconName: 'bed',
    ),
    TimerPreset(
      id: 'p_25m',
      title: 'Study Session',
      durationInSeconds: 1500,
      iconName: 'school',
    ),
    TimerPreset(
      id: 'p_30m',
      title: 'Workout',
      durationInSeconds: 1800,
      iconName: 'fitness_center',
    ),
    TimerPreset(
      id: 'p_45m',
      title: 'Reading Time',
      durationInSeconds: 2700,
      iconName: 'menu_book',
    ),
    TimerPreset(
      id: 'p_60m',
      title: 'Deep Work',
      durationInSeconds: 3600,
      iconName: 'psychology',
    ),
  ];
}
