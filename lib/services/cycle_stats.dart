import 'period_history.dart';

/// Rolling statistics over observed cycle lengths (oldest first).
///
/// Predictions use the last-12 median, displayed averages use the last-6
/// median, and irregularity status uses the last-6 spread - ancient cycles
/// age out instead of dragging every number forever.
class CycleStats {
  const CycleStats(this.lengths);

  /// Observed completed cycle lengths, oldest first.
  final List<int> lengths;

  /// How many recent cycles feed averages and spread.
  static const int recentCount = 6;

  /// How many recent cycles feed predictions.
  static const int windowCount = 12;

  /// Slider-range clamp, mirroring OnboardingProvider.min/maxCycleLength.
  static const int minLength = 15;
  static const int maxLength = 60;

  /// Last-[recentCount] lengths (or everything when fewer), oldest first.
  List<int> get recent => lengths.length <= recentCount ? List.of(lengths) : lengths.sublist(lengths.length - recentCount);

  /// Last-[windowCount] lengths (or everything when fewer), oldest first.
  List<int> get window => lengths.length <= windowCount ? List.of(lengths) : lengths.sublist(lengths.length - windowCount);

  /// Median of the last 6 lengths, clamped to the slider range.
  int? get medianRecent => PeriodHistory.median(recent)?.clamp(minLength, maxLength);

  /// Median of the last 12 lengths, clamped to the slider range.
  /// Null until 2+ cycles are observed (a single length is not a pattern).
  int? get medianWindow {
    if (lengths.length < 2) return null;
    return PeriodHistory.median(window)?.clamp(minLength, maxLength);
  }

  /// Spread of the last 6 lengths; null until 2+ cycles are observed.
  int? get spreadRecent {
    if (recent.length < 2) return null;
    var min = recent.first;
    var max = recent.first;
    for (final value in recent) {
      if (value < min) min = value;
      if (value > max) max = value;
    }
    return max - min;
  }

  /// Longest of the last 6 lengths; null with no observations.
  int? get longestRecent => recent.isEmpty ? null : recent.reduce((a, b) => a > b ? a : b);

  /// Shortest of the last 6 lengths; null with no observations.
  int? get shortestRecent => recent.isEmpty ? null : recent.reduce((a, b) => a < b ? a : b);
}
