import 'package:flutter_test/flutter_test.dart';
import 'package:witchy/services/cycle_stats.dart';

void main() {
  group('CycleStats', () {
    test('empty history yields nulls', () {
      const stats = CycleStats([]);
      expect(stats.medianRecent, isNull);
      expect(stats.spreadRecent, isNull);
      expect(stats.longestRecent, isNull);
    });

    test('single cycle is an average but not a prediction basis', () {
      const stats = CycleStats([28]);
      expect(stats.medianRecent, 28);
      expect(stats.spreadRecent, isNull);
      expect(stats.longestRecent, 28);
    });

    test('even-count median rounds half up', () {
      expect(const CycleStats([28, 30]).medianRecent, 29);
      expect(const CycleStats([27, 28]).medianRecent, 28);
    });

    test('recent window ages out ancient cycles', () {
      final lengths = [45, 45, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28];
      final stats = CycleStats(lengths);
      expect(stats.recent, hasLength(6));
      expect(stats.medianRecent, 28);
      expect(stats.spreadRecent, 0);
      expect(stats.longestRecent, 28);
    });

    test('spread uses the last 6 and clamps the median to the slider range', () {
      expect(const CycleStats([24, 24, 33]).spreadRecent, 9);
      expect(const CycleStats([28]).spreadRecent, isNull);
      expect(const CycleStats([10, 10]).medianRecent, CycleStats.minLength);
      expect(const CycleStats([90, 90]).medianRecent, CycleStats.maxLength);
    });
  });
}
