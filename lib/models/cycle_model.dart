/// Represents a single menstrual cycle with all its metadata.
class CycleModel {
  final int id;
  final DateTime startDate;
  final DateTime? endDate;
  final int cycleLength;
  final int lutealPhase;
  final List<SymptomEntry> symptoms;
  final bool isPredicted;

  const CycleModel({
    required this.id,
    required this.startDate,
    this.endDate,
    this.cycleLength = 28,
    this.lutealPhase = 14,
    this.symptoms = const [],
    this.isPredicted = false,
  });

  /// The first day of the next predicted cycle.
  DateTime get nextCycleStart => startDate.add(Duration(days: cycleLength));

  /// The estimated ovulation day (midpoint between cycle start and period end).
  DateTime get ovulationDay => startDate.add(Duration(
        days: cycleLength - lutealPhase,
      ));

  /// The fertile window — 5 days before ovulation to 1 day after.
  Range<DateTime> get fertileWindow => Range(
        startDate.add(Duration(days: cycleLength - lutealPhase - 5)),
        startDate.add(Duration(days: cycleLength - lutealPhase + 1)),
      );

  /// Whether a given date falls within the fertile window.
  bool isFertile(DateTime date) => date.isAfter(fertileWindow.start) &&
      date.isBefore(fertileWindow.end);

  /// Whether a given date is an ovulation day.
  bool isOvulationDay(DateTime date) =>
      date.year == ovulationDay.year &&
      date.month == ovulationDay.month &&
      date.day == ovulationDay.day;

  /// Whether a given date falls within the predicted period window.
  bool isPeriodDay(DateTime date) {
    if (endDate == null) return false;
    final diff = date.difference(startDate).inDays;
    return diff >= 0 && (endDate!.difference(startDate).inDays >= 0
        ? diff <= endDate!.difference(startDate).inDays
        : false);
  }

  CycleModel copyWith({
    int? id,
    DateTime? startDate,
    DateTime? endDate,
    int? cycleLength,
    int? lutealPhase,
    List<SymptomEntry>? symptoms,
    bool? isPredicted,
  }) {
    return CycleModel(
      id: id ?? this.id,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      cycleLength: cycleLength ?? this.cycleLength,
      lutealPhase: lutealPhase ?? this.lutealPhase,
      symptoms: symptoms ?? this.symptoms,
      isPredicted: isPredicted ?? this.isPredicted,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate?.toIso8601String(),
        'cycleLength': cycleLength,
        'lutealPhase': lutealPhase,
        'isPredicted': isPredicted,
      };

  factory CycleModel.fromMap(Map<String, dynamic> map) => CycleModel(
        id: map['id'] as int,
        startDate: DateTime.parse(map['startDate'] as String),
        endDate: map['endDate'] != null
            ? DateTime.parse(map['endDate'] as String)
            : null,
        cycleLength: map['cycleLength'] as int? ?? 28,
        lutealPhase: map['lutealPhase'] as int? ?? 14,
        isPredicted: map['isPredicted'] as bool? ?? false,
      );
}

/// A date range used for fertile window calculations.
class Range<T> {
  final T start;
  final T end;
  const Range(this.start, this.end);
}

/// Represents a symptom entry recorded during a cycle.
class SymptomEntry {
  final int id;
  final DateTime date;
  final SymptomType type;
  final double severity; // 1-5 scale
  final String? note;

  const SymptomEntry({
    required this.id,
    required this.date,
    required this.type,
    this.severity = 3,
    this.note,
  });

  SymptomEntry copyWith({
    int? id,
    DateTime? date,
    SymptomType? type,
    double? severity,
    String? note,
  }) {
    return SymptomEntry(
      id: id ?? this.id,
      date: date ?? this.date,
      type: type ?? this.type,
      severity: severity ?? this.severity,
      note: note ?? this.note,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'date': date.toIso8601String(),
        'type': type.index,
        'severity': severity,
        'note': note,
      };

  factory SymptomEntry.fromMap(Map<String, dynamic> map) => SymptomEntry(
        id: map['id'] as int,
        date: DateTime.parse(map['date'] as String),
        type: SymptomType.values[map['type'] as int],
        severity: (map['severity'] as num?)?.toDouble() ?? 3,
        note: map['note'] as String?,
      );
}

/// The symptom types tracked by the app.
enum SymptomType {
  cramps,
  headache,
  bloating,
  breastTenderness,
  fatigue,
  moodSwings,
  acne,
  backache,
  nausea,
  heavyFlow,
  lightFlow,
  spotting,
  ovulationPain,
  libido,
  temperature,
  cervicalMucus,
}