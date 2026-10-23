enum TrackingMode {
  cycle('Cycle'),
  pregnancy('Pregnancy'),
  perimenopause('Perimenopause');

  const TrackingMode(this.label);
  final String label;

  static TrackingMode fromJson(Object? raw) => TrackingMode.values.firstWhere((m) => m.name == raw, orElse: () => TrackingMode.cycle);

  String toJson() => name;
}
