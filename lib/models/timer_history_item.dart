import 'dart:convert';

/// Model representing a completed countdown session in timer history
class TimerHistoryItem {
  final String id;
  final String title;
  final int durationInSeconds;
  final DateTime completedAt;

  const TimerHistoryItem({
    required this.id,
    required this.title,
    required this.durationInSeconds,
    required this.completedAt,
  });

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

  String get formattedDate {
    final now = DateTime.now();
    final difference = now.difference(completedAt);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1 && now.day == completedAt.day) {
      return 'Today at ${completedAt.hour.toString().padLeft(2, '0')}:${completedAt.minute.toString().padLeft(2, '0')}';
    } else {
      return '${completedAt.day}/${completedAt.month}/${completedAt.year} ${completedAt.hour.toString().padLeft(2, '0')}:${completedAt.minute.toString().padLeft(2, '0')}';
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'durationInSeconds': durationInSeconds,
      'completedAt': completedAt.toIso8601String(),
    };
  }

  factory TimerHistoryItem.fromMap(Map<String, dynamic> map) {
    return TimerHistoryItem(
      id: map['id'] as String,
      title: map['title'] as String,
      durationInSeconds: map['durationInSeconds'] as int,
      completedAt: DateTime.parse(map['completedAt'] as String),
    );
  }

  String toJson() => jsonEncode(toMap());

  factory TimerHistoryItem.fromJson(String source) =>
      TimerHistoryItem.fromMap(jsonDecode(source) as Map<String, dynamic>);
}
