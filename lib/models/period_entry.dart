/// Period entry model for Witchy.
/// Represents a single logged period with symptoms and mood data.
library;

enum FlowIntensity { light, moderate, heavy, spotting }

/// A single logged period entry with symptoms and mood.
class PeriodEntry {
  /// Creates a new period entry.
  const PeriodEntry({
    required this.id,
    required this.startDate,
    this.endDate,
    this.flow = FlowIntensity.moderate,
    this.symptoms = const <String>[],
    this.mood = Mood.neutral,
  });

  /// Unique identifier for this entry.
  final String id;

  /// The start date of the period.
  final DateTime startDate;

  /// The end date of the period (nullable if still ongoing).
  final DateTime? endDate;

  /// The flow intensity during this period.
  final FlowIntensity flow;

  /// List of symptoms experienced during this period.
  final List<String> symptoms;

  /// The predominant mood during this period.
  final Mood mood;

  /// Returns the duration of this period in days, or -1 if ongoing.
  int get durationDays {
    final end = endDate ?? DateTime.now();
    return end.difference(startDate).inDays;
  }

  /// Returns the formatted flow string for display.
  String get flowLabel {
    switch (flow) {
      case FlowIntensity.light:
        return 'Light';
      case FlowIntensity.moderate:
        return 'Moderate';
      case FlowIntensity.heavy:
        return 'Heavy';
      case FlowIntensity.spotting:
        return 'Spotting';
    }
  }

  /// Serializes the entry to a map for storage.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'flow': flow.name,
      'symptoms': symptoms,
      'mood': mood.name,
    };
  }

  /// Creates a PeriodEntry from a JSON map.
  factory PeriodEntry.fromJson(Map<String, dynamic> json) {
    return PeriodEntry(
      id: json['id'] as String,
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: json['end_date'] != null
          ? DateTime.parse(json['end_date'] as String)
          : null,
      flow: _parseFlow(json['flow'] as String?),
      symptoms: (json['symptoms'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
      mood: _parseMood(json['mood'] as String?),
    );
  }

  /// Parses a flow intensity string to the enum.
  static FlowIntensity _parseFlow(String? value) {
    switch (value) {
      case 'light':
        return FlowIntensity.light;
      case 'heavy':
        return FlowIntensity.heavy;
      case 'spotting':
        return FlowIntensity.spotting;
      default:
        return FlowIntensity.moderate;
    }
  }

  /// Parses a mood string to the enum.
  static Mood _parseMood(String? value) {
    return Mood.values.byName(value ?? 'neutral');
  }

  @override
  String toString() {
    return 'PeriodEntry(id: $id, start: ${startDate.toIso8601String()}, end: ${endDate?.toIso8601String()}, flow: $flow, symptoms: $symptoms)';
  }
}

/// Mood enum for logging emotional state during a cycle.
enum Mood {
  happy,
  sad,
  irritable,
  anxious,
  energetic,
  calm,
  tired,
  emotional,
  neutral,
}
