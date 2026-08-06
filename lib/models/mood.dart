import 'dart:convert';

enum MoodType {
  happy,
  energetic,
  calm,
  stressed,
  anxious,
  sad,
  irritable,
  tired,
  neutral,
}

class MoodEntry {
  final String id;
  final MoodType type;
  final DateTime date;
  final String? notes;

  const MoodEntry({
    required this.id,
    required this.type,
    required this.date,
    this.notes,
  });

  MoodEntry copyWith({
    String? id,
    MoodType? type,
    DateTime? date,
    String? notes,
  }) {
    return MoodEntry(
      id: id ?? this.id,
      type: type ?? this.type,
      date: date ?? this.date,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type.index,
      'date': date.toIso8601String(),
      'notes': notes,
    };
  }

  factory MoodEntry.fromMap(Map<String, dynamic> map) {
    return MoodEntry(
      id: map['id'] as String,
      type: MoodType.values[map['type'] as int],
      date: DateTime.parse(map['date'] as String),
      notes: map['notes'] as String?,
    );
  }

  String toJson() => json.encode(toMap());

  factory MoodEntry.fromJson(String source) =>
      MoodEntry.fromMap(json.decode(source) as Map<String, dynamic>);

  String get displayName {
    switch (type) {
      case MoodType.happy:
        return 'Happy';
      case MoodType.energetic:
        return 'Energetic';
      case MoodType.calm:
        return 'Calm';
      case MoodType.stressed:
        return 'Stressed';
      case MoodType.anxious:
        return 'Anxious';
      case MoodType.sad:
        return 'Sad';
      case MoodType.irritable:
        return 'Irritable';
      case MoodType.tired:
        return 'Tired';
      case MoodType.neutral:
        return 'Neutral';
    }
  }
}
