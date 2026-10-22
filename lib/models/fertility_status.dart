/// Where today sits relative to this cycle's ovulation.
///
/// Derived from the ovulation date rather than from the fertile window, so
/// copy can say "ovulation passed" once the peak is behind us.
enum FertilityStatus {
  beforeWindow,
  windowOpen,
  peakToday,
  windowClosing,
  passed,
  overdue,
}

extension FertilityStatusLabel on FertilityStatus {
  String get label => switch (this) {
        FertilityStatus.beforeWindow => 'Before window',
        FertilityStatus.windowOpen => 'Window open',
        FertilityStatus.peakToday => 'Peak today',
        FertilityStatus.windowClosing => 'Window closing',
        FertilityStatus.passed => 'Peak passed',
        FertilityStatus.overdue => 'Overdue',
      };
}
