import 'dart:convert';

class PregnancyTracker {
  final String id;
  final DateTime lastPeriodDate;
  final int cycleLength;
  final int gestationalWeek;
  final int gestationalDay;
  final DateTime? dueDate;
  final String trimester;
  final List<PregnancyWeekInfo> weekInfo;

  const PregnancyTracker({
    required this.id,
    required this.lastPeriodDate,
    this.cycleLength = 28,
    this.gestationalWeek = 0,
    this.gestationalDay = 0,
    this.dueDate,
    this.trimester = 'First',
    this.weekInfo = const [],
  });

  PregnancyTracker copyWith({
    String? id,
    DateTime? lastPeriodDate,
    int? cycleLength,
    int? gestationalWeek,
    int? gestationalDay,
    DateTime? dueDate,
    String? trimester,
    List<PregnancyWeekInfo>? weekInfo,
  }) {
    return PregnancyTracker(
      id: id ?? this.id,
      lastPeriodDate: lastPeriodDate ?? this.lastPeriodDate,
      cycleLength: cycleLength ?? this.cycleLength,
      gestationalWeek: gestationalWeek ?? this.gestationalWeek,
      gestationalDay: gestationalDay ?? this.gestationalDay,
      dueDate: dueDate ?? this.dueDate,
      trimester: trimester ?? this.trimester,
      weekInfo: weekInfo ?? this.weekInfo,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'lastPeriodDate': lastPeriodDate.toIso8601String(),
      'cycleLength': cycleLength,
      'gestationalWeek': gestationalWeek,
      'gestationalDay': gestationalDay,
      'dueDate': dueDate?.toIso8601String(),
      'trimester': trimester,
      'weekInfo': weekInfo.map((info) => info.toMap()).toList(),
    };
  }

  factory PregnancyTracker.fromMap(Map<String, dynamic> map) {
    return PregnancyTracker(
      id: map['id'] as String,
      lastPeriodDate: DateTime.parse(map['lastPeriodDate'] as String),
      cycleLength: map['cycleLength'] as int? ?? 28,
      gestationalWeek: map['gestationalWeek'] as int? ?? 0,
      gestationalDay: map['gestationalDay'] as int? ?? 0,
      dueDate: map['dueDate'] != null ? DateTime.parse(map['dueDate'] as String) : null,
      trimester: map['trimester'] as String? ?? 'First',
      weekInfo: (map['weekInfo'] as List<dynamic>?)
              ?.map((info) => PregnancyWeekInfo.fromMap(Map<String, dynamic>.from(info)))
              .toList() ??
          [],
    );
  }

  String toJson() => json.encode(toMap());

  factory PregnancyTracker.fromJson(String source) =>
      PregnancyTracker.fromMap(json.decode(source) as Map<String, dynamic>);
}

class PregnancyWeekInfo {
  final int week;
  final String description;
  final String babySize;
  final double babySizeCm;

  const PregnancyWeekInfo({
    required this.week,
    required this.description,
    this.babySize = '',
    this.babySizeCm = 0.0,
  });

  PregnancyWeekInfo copyWith({
    int? week,
    String? description,
    String? babySize,
    double? babySizeCm,
  }) {
    return PregnancyWeekInfo(
      week: week ?? this.week,
      description: description ?? this.description,
      babySize: babySize ?? this.babySize,
      babySizeCm: babySizeCm ?? this.babySizeCm,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'week': week,
      'description': description,
      'babySize': babySize,
      'babySizeCm': babySizeCm,
    };
  }

  factory PregnancyWeekInfo.fromMap(Map<String, dynamic> map) {
    return PregnancyWeekInfo(
      week: map['week'] as int,
      description: map['description'] as String,
      babySize: map['babySize'] as String? ?? '',
      babySizeCm: (map['babySizeCm'] as num?)?.toDouble() ?? 0.0,
    );
  }

  String toJson() => json.encode(toMap());

  factory PregnancyWeekInfo.fromJson(String source) =>
      PregnancyWeekInfo.fromMap(json.decode(source) as Map<String, dynamic>);
}
