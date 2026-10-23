import 'package:flutter_test/flutter_test.dart';
import 'package:witchy/models/day_log.dart';
import 'package:witchy/models/period_span.dart';
import 'package:witchy/models/trend_direction.dart';
import 'package:witchy/services/trend_analyzer.dart';

void main() {
  PeriodSpan span(DateTime start, int days) => PeriodSpan(
    start: start,
    end: DateTime(start.year, start.month, start.day + days - 1),
  );

  group('TrendAnalyzer cycle length', () {
    test('needs six completed cycles', () {
      final trend = TrendAnalyzer.cycleLength([28, 28, 28, 28, 28]);

      expect(trend.direction, TrendDirection.insufficient);
      expect(trend.detail, 'Log six completed cycles');
    });

    test('compares the last three cycles with the three before them', () {
      final trend = TrendAnalyzer.cycleLength([28, 28, 28, 30, 30, 30]);

      expect(trend.label, 'Cycle length');
      expect(trend.direction, TrendDirection.up);
      expect(trend.detail, '28 -> 30 days');
    });

    test('reports shorter cycles as down and one-day shifts as stable', () {
      expect(TrendAnalyzer.cycleLength([30, 30, 30, 28, 28, 28]).direction, TrendDirection.down);
      expect(TrendAnalyzer.cycleLength([28, 28, 28, 29, 29, 29]).direction, TrendDirection.stable);
    });
  });

  group('TrendAnalyzer bleed length', () {
    test('needs six measured periods', () {
      final trend = TrendAnalyzer.bleedLength([
        for (var i = 0; i < 5; i++) span(DateTime(2025, 1 + i, 1), 3),
      ]);

      expect(trend.direction, TrendDirection.insufficient);
      expect(trend.detail, 'Log six measured periods');
    });

    test('compares measured periods and ignores estimated spans', () {
      final spans = [
        for (var i = 0; i < 3; i++) span(DateTime(2025, 1 + i, 1), 3),
        for (var i = 0; i < 3; i++) span(DateTime(2025, 4 + i, 1), 5),
        PeriodSpan(
          start: DateTime(2025, 7, 1),
          end: DateTime(2025, 7, 9),
          estimated: true,
        ),
      ];

      final trend = TrendAnalyzer.bleedLength(spans);

      expect(trend.direction, TrendDirection.up);
      expect(trend.detail, '3 -> 5 days');
    });
  });

  group('TrendAnalyzer symptoms', () {
    final today = DateTime(2026, 1, 31);

    test('reports the top symptom count over two 30-day windows', () {
      final logs = {
        DateTime(2026, 1, 10): DayLog(symptoms: {'Cramps'}),
        DateTime(2026, 1, 20): DayLog(symptoms: {'Cramps'}),
        DateTime(2026, 1, 25): DayLog(symptoms: {'Cramps'}),
        DateTime(2025, 12, 20): DayLog(symptoms: {'Cramps'}),
      };

      final trend = TrendAnalyzer.symptoms(logs, today: today);

      expect(trend.direction, TrendDirection.up);
      expect(trend.detail, 'Cramps: 3 days, was 1');
    });

    test('a one-day change stays stable', () {
      final logs = {
        DateTime(2026, 1, 10): DayLog(symptoms: {'Bloating'}),
        DateTime(2026, 1, 20): DayLog(symptoms: {'Bloating'}),
        DateTime(2025, 12, 20): DayLog(symptoms: {'Bloating'}),
      };

      expect(TrendAnalyzer.symptoms(logs, today: today).direction, TrendDirection.stable);
    });

    test('returns the empty state when both windows are empty', () {
      final trend = TrendAnalyzer.symptoms(const {}, today: today);

      expect(trend.direction, TrendDirection.insufficient);
      expect(trend.detail, 'Log symptoms for a few weeks');
    });

    test('summaries returns cycle, bleed and symptom rows', () {
      final rows = TrendAnalyzer.summaries(
        observedCycleLengths: const [],
        spans: const [],
        logs: const {},
        today: today,
      );

      expect(rows.map((row) => row.label), ['Cycle length', 'Bleed length', 'Symptoms']);
    });
  });
}
