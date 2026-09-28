
class DayLog {
  String flow;
  final Set<String> moods;
  final Set<String> symptoms;
  double pain;
  String notes;
  DayLog({this.flow = 'Medium', Set<String>? moods, Set<String>? symptoms, this.pain = 6, String? notes})
    : moods = moods ?? {},
      symptoms = symptoms ?? {'Uterine Cramps'},
      notes = notes ?? 'Drank chamomile raspberry leaf infusion. Felt waves of emotional clearing in the afternoon.';

  Map<String, dynamic> toJson() => {'flow': flow, 'moods': moods.toList(), 'symptoms': symptoms.toList(), 'pain': pain, 'notes': notes};

  factory DayLog.fromJson(Map<String, dynamic> json) => DayLog(
    flow: json['flow'] as String? ?? 'Medium',
    moods: (json['moods'] as List?)?.cast<String>().toSet(),
    symptoms: (json['symptoms'] as List?)?.cast<String>().toSet(),
    pain: (json['pain'] as num?)?.toDouble() ?? 6,
    notes: json['notes'] as String?,
  );
}
