import 'period_history.dart';

/// Rolling statistics over observed cycle lengths (oldest first).
///
/// Predictions, displayed averages and irregularity all use the last-6
/// cycles, so ancient cycles age out instead of dragging every number forever.
class CycleStats {
  const CycleStats(this.lengths);

  /// Observed completed cycle lengths, oldest first.
  final List<int> lengths;

  /// How many recent cycles feed averages, predictions and spread.
  static const int recentCount = 6;

  /// Slider-range clamp, mirroring OnboardingProvider.min/maxCycleLength.
  static const int minLength = 15;
  static const int maxLength = 60;

  /// Last-[recentCount] lengths (or everything when fewer), oldest first.
  List<int> get recent => lengths.length <= recentCount ? List.of(lengths) : lengths.sublist(lengths.length - recentCount);

  /// Median of the last 6 lengths, clamped to the slider range.
  int? get medianRecent => PeriodHistory.median(recent)?.clamp(minLength, maxLength);

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

  /// Last-6 lengths with one lowest and one highest value removed once four
  /// cycles exist, so a single outlier cannot widen the prediction range.
  /// With fewer than four cycles every observation is kept.
  List<int> get trimmedRecent {
    final sorted = [...recent]..sort();
    if (sorted.length >= 4) return sorted.sublist(1, sorted.length - 1);
    return sorted;
  }

  /// Shortest outlier-resistant recent length; null with no observations.
  int? get shortestTrimmed => trimmedRecent.isEmpty ? null : trimmedRecent.first;

  /// Longest outlier-resistant recent length; null with no observations.
  int? get longestTrimmed => trimmedRecent.isEmpty ? null : trimmedRecent.last;

  /// Spread of the outlier-resistant recent range; null until 2+ cycles.
  int? get spreadTrimmed => trimmedRecent.length < 2 ? null : longestTrimmed! - shortestTrimmed!;
}
