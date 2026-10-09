import 'package:flutter_test/flutter_test.dart';
import 'package:witchy/common/gestation_content.dart';

void main() {
  group('GestationContent', () {
    test('looks up week-range buckets', () {
      expect(GestationContent.forWeek(0).size, 'Poppy Seed');
      expect(GestationContent.forWeek(3).size, 'Poppy Seed');
      expect(GestationContent.forWeek(9).size, 'Lime Size');
      expect(GestationContent.forWeek(12).size, 'Apple Size');
      expect(GestationContent.forWeek(40).size, 'Watermelon Size');
    });

    test('buckets cover weeks 0 through 40 without gaps', () {
      for (var week = 0; week <= 40; week++) {
        final entry = GestationContent.forWeek(week);
        expect(entry.covers(week), isTrue, reason: 'week $week uncovered');
      }
    });

    test('past-term weeks fall back to the trimester entry', () {
      expect(GestationContent.forWeek(41).size, 'Full Term');
      expect(GestationContent.forWeek(99).size, 'Full Term');
    });

    test('negative weeks clamp to the first bucket', () {
      expect(identical(GestationContent.forWeek(-2), GestationContent.weeks.first), isTrue);
    });
  });
}
