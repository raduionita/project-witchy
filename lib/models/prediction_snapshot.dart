/// A saved prediction for one cycle. The values are frozen when the cycle is
/// first seen so later logs cannot rewrite what the app previously showed.
class PredictionSnapshot {
  const PredictionSnapshot({
    required this.cycleStart,
    required this.earliest,
    required this.latest,
    required this.recordedAt,
    this.peak,
    this.fertileStart,
    this.fertileEnd,
  });

  final DateTime cycleStart;
  final DateTime earliest;
  final DateTime latest;
  final DateTime recordedAt;
  final DateTime? peak;
  final DateTime? fertileStart;
  final DateTime? fertileEnd;

  Map<String, dynamic> toJson() => {
    'cycleStart': cycleStart.toIso8601String(),
    'earliest': earliest.toIso8601String(),
    'latest': latest.toIso8601String(),
    'recordedAt': recordedAt.toIso8601String(),
    if (peak != null) 'peak': peak!.toIso8601String(),
    if (fertileStart != null) 'fertileStart': fertileStart!.toIso8601String(),
    if (fertileEnd != null) 'fertileEnd': fertileEnd!.toIso8601String(),
  };

  factory PredictionSnapshot.fromJson(Map<String, dynamic> json) {
    DateTime? parse(Object? raw) => raw is String ? DateTime.tryParse(raw) : null;
    final cycleStart = parse(json['cycleStart']);
    final earliest = parse(json['earliest']);
    final latest = parse(json['latest']);
    final recordedAt = parse(json['recordedAt']);
    if (cycleStart == null || earliest == null || latest == null || recordedAt == null) {
      throw const FormatException('Prediction snapshot is missing dates');
    }
    return PredictionSnapshot(
      cycleStart: cycleStart,
      earliest: earliest,
      latest: latest,
      recordedAt: recordedAt,
      peak: parse(json['peak']),
      fertileStart: parse(json['fertileStart']),
      fertileEnd: parse(json['fertileEnd']),
    );
  }
}
