
class CycleSettings {
  final DateTime lastPeriodStart;
  final int cycleLength;
  final int bleedLength;
  const CycleSettings({required this.lastPeriodStart, this.cycleLength = 28, this.bleedLength = 5});

  CycleSettings copyWith({DateTime? lastPeriodStart, int? cycleLength, int? bleedLength}) => CycleSettings(
        lastPeriodStart: lastPeriodStart ?? this.lastPeriodStart,
        cycleLength: cycleLength ?? this.cycleLength,
        bleedLength: bleedLength ?? this.bleedLength,
      );
}
