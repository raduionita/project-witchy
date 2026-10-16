import 'package:flutter_test/flutter_test.dart';
import 'package:witchy/services/bbt_analyzer.dart';

void main() {
  Map<DateTime, double?> temps(Map<DateTime, double?> entries) => entries;

  group('BbtAnalyzer.analyze', () {
    test('empty input yields no outputs', () {
      final result = BbtAnalyzer.analyze(temps: {}, bleedStarts: [], today: DateTime(2026, 10, 15));
      expect(result.confirmedOvulation, isNull);
      expect(result.personalLutealLength, isNull);
    });

    test('fewer than 10 readings yields no outputs', () {
      final entries = {for (var i = 0; i < 9; i++) DateTime(2026, 9, 20 + i): 36.5};
      final result = BbtAnalyzer.analyze(temps: temps(entries), bleedStarts: [], today: DateTime(2026, 10, 15));
      expect(result.confirmedOvulation, isNull);
      expect(result.personalLutealLength, isNull);
    });

    test('flat temperatures yield no shift', () {
      final entries = {for (var i = 0; i < 14; i++) DateTime(2026, 9, 25 + i): 36.5};
      final result = BbtAnalyzer.analyze(temps: temps(entries), bleedStarts: [], today: DateTime(2026, 10, 15));
      expect(result.confirmedOvulation, isNull);
      expect(result.personalLutealLength, isNull);
    });

    test('sustained rise confirms ovulation the day before the rise', () {
      // Low phase Sep 25-30, rise from Oct 1 on.
      final entries = <DateTime, double?>{
        for (var i = 0; i < 6; i++) DateTime(2026, 9, 25 + i): 36.4,
        for (var i = 0; i < 8; i++) DateTime(2026, 10, 1 + i): 36.8,
      };
      final result = BbtAnalyzer.analyze(temps: temps(entries), bleedStarts: [], today: DateTime(2026, 10, 15));
      expect(result.confirmedOvulation, DateTime(2026, 9, 30));
      // No following bleed, so no personal luteal length.
      expect(result.personalLutealLength, isNull);
    });

    test('single spike without sustained rise is ignored', () {
      final entries = <DateTime, double?>{
        for (var i = 0; i < 12; i++) DateTime(2026, 9, 25 + i): 36.4,
        DateTime(2026, 10, 7): 37.1,
      };
      final result = BbtAnalyzer.analyze(temps: temps(entries), bleedStarts: [], today: DateTime(2026, 10, 15));
      expect(result.confirmedOvulation, isNull);
      expect(result.personalLutealLength, isNull);
    });

    test('shift plus following bleed measures the luteal length', () {
      final entries = <DateTime, double?>{
        for (var i = 0; i < 6; i++) DateTime(2026, 8, 20 + i): 36.4,
        for (var i = 0; i < 12; i++) DateTime(2026, 8, 26 + i): 36.8,
      };
      // Rise Oct... shift detected at Aug 26 means ovulation Aug 25; bleed Sep 8 -> 14 days.
      final result = BbtAnalyzer.analyze(
        temps: temps(entries),
        bleedStarts: [DateTime(2026, 9, 8)],
        today: DateTime(2026, 9, 20),
      );
      expect(result.confirmedOvulation, DateTime(2026, 8, 25));
      expect(result.personalLutealLength, 14);
    });

    test('implausible luteal lengths clamp to 10..18', () {
      final entries = <DateTime, double?>{
        for (var i = 0; i < 6; i++) DateTime(2026, 8, 20 + i): 36.4,
        for (var i = 0; i < 12; i++) DateTime(2026, 8, 26 + i): 36.8,
      };
      // Ovulation Aug 25, next bleed Sep 19 -> 25 days -> clamps to 18.
      final result = BbtAnalyzer.analyze(
        temps: temps(entries),
        bleedStarts: [DateTime(2026, 9, 19)],
        today: DateTime(2026, 9, 25),
      );
      expect(result.personalLutealLength, 18);
    });

    test('null readings are skipped without breaking detection', () {
      final entries = <DateTime, double?>{
        for (var i = 0; i < 6; i++) DateTime(2026, 9, 25 + i): 36.4,
        DateTime(2026, 10, 1): null,
        for (var i = 1; i < 8; i++) DateTime(2026, 10, 1 + i): 36.8,
      };
      final result = BbtAnalyzer.analyze(temps: temps(entries), bleedStarts: [], today: DateTime(2026, 10, 15));
      expect(result.confirmedOvulation, DateTime(2026, 9, 30));
    });
  });
}
