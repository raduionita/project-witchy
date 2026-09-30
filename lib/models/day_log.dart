class DayLog {
  String flow;
  final Set<String> moods;
  final Set<String> symptoms;
  double pain;
  String notes;
  DayLog({this.flow = 'None', Set<String>? moods, Set<String>? symptoms, this.pain = 6, this.notes = ''})
    : moods = moods ?? {},
      symptoms = symptoms ?? {};

  Map<String, dynamic> toJson() => {'flow': flow, 'moods': moods.toList(), 'symptoms': symptoms.toList(), 'pain': pain, 'notes': notes};

  /// Deep copy — mutating the copy never affects the original entry.
  DayLog copy() => DayLog.fromJson(toJson());

  factory DayLog.fromJson(Map<String, dynamic> json) => DayLog(
    flow: json['flow'] as String? ?? 'None',
    moods: (json['moods'] as List?)?.cast<String>().toSet(),
    symptoms: (json['symptoms'] as List?)?.cast<String>().toSet(),
    pain: (json['pain'] as num?)?.toDouble() ?? 6,
    notes: json['notes'] as String? ?? '',
  );
}
