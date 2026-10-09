class DayLog {
  final Set<String> flow;
  final Set<String> collection;
  final Set<String> symptoms;
  final Set<String> digestion;
  final Set<String> skinHair;
  final Set<String> moods;
  final Set<String> cravings;
  final Set<String> sex;
  final Set<String> sleep;
  final Set<String> discharge;
  double pain;
  double? temperature;
  String notes;
  DayLog({
    Set<String>? flow,
    Set<String>? collection,
    Set<String>? symptoms,
    Set<String>? digestion,
    Set<String>? skinHair,
    Set<String>? moods,
    Set<String>? cravings,
    Set<String>? sex,
    Set<String>? sleep,
    Set<String>? discharge,
    this.pain = 6,
    this.temperature,
    this.notes = '',
  }) : flow = flow ?? {},
       collection = collection ?? {},
       symptoms = symptoms ?? {},
       digestion = digestion ?? {},
       skinHair = skinHair ?? {},
       moods = moods ?? {},
       cravings = cravings ?? {},
       sex = sex ?? {},
       sleep = sleep ?? {},
       discharge = discharge ?? {};

  Map<String, dynamic> toJson() => {
    'flow': flow.toList(),
    'collection': collection.toList(),
    'symptoms': symptoms.toList(),
    'digestion': digestion.toList(),
    'skinHair': skinHair.toList(),
    'moods': moods.toList(),
    'cravings': cravings.toList(),
    'sex': sex.toList(),
    'sleep': sleep.toList(),
    'discharge': discharge.toList(),
    'pain': pain,
    'temperature': temperature,
    'notes': notes,
  };

  /// Deep copy — mutating the copy never affects the original entry.
  DayLog copy() => DayLog.fromJson(toJson());

  static Set<String> _set(Object? v) => (v as List?)?.cast<String>().toSet() ?? {};

  /// Accepts the list format plus the legacy single-string payload
  /// ('Light' → {'Light'}; 'None' / '' → empty set).
  static Set<String> _legacySet(Object? v) {
    if (v is String) return v.isEmpty || v == 'None' ? <String>{} : {v};
    return _set(v);
  }

  factory DayLog.fromJson(Map<String, dynamic> json) => DayLog(
    flow: _legacySet(json['flow']),
    collection: _set(json['collection']),
    symptoms: _set(json['symptoms']),
    digestion: _set(json['digestion']),
    skinHair: _set(json['skinHair']),
    moods: _set(json['moods']),
    cravings: _set(json['cravings']),
    sex: _set(json['sex']),
    sleep: _set(json['sleep']),
    discharge: _legacySet(json['discharge']),
    pain: (json['pain'] as num?)?.toDouble() ?? 6,
    temperature: (json['temperature'] as num?)?.toDouble(),
    notes: json['notes'] as String? ?? '',
  );
}
