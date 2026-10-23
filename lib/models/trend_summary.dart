import 'trend_direction.dart';

/// One directional insight with a short human-readable detail.
class TrendSummary {
  const TrendSummary({
    required this.label,
    required this.direction,
    required this.detail,
  });

  final String label;
  final TrendDirection direction;
  final String detail;
}
