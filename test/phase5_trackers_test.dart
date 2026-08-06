import 'package:flutter_test/flutter_test.dart';

import 'package:witchy/features/perimenopause/perimenopause_catalog.dart';
import 'package:witchy/features/pregnancy/pregnancy_guidance.dart';
import 'package:witchy/features/trackers/shared_tracker_text.dart';
import 'package:witchy/l10n/app_localizations_en.dart';
import 'package:witchy/models/pregnancy_status.dart';
import 'package:witchy/models/symptom_insights.dart';

void main() {
  final l10n = AppLocalizationsEn();

  group('PregnancyGuidance', () {
    test('trimester titles map all stages', () {
      expect(PregnancyGuidance.trimesterTitle(l10n, Trimester.first),
          'First trimester');
      expect(PregnancyGuidance.trimesterTitle(l10n, Trimester.second),
          'Second trimester');
      expect(PregnancyGuidance.trimesterTitle(l10n, Trimester.third),
          'Third trimester');
    });

    test('stage summaries and tips are non-empty for every trimester', () {
      for (final Trimester trimester in Trimester.values) {
        expect(PregnancyGuidance.stageSummary(l10n, trimester), isNotEmpty);
        expect(PregnancyGuidance.tipsFor(l10n, trimester), isNotEmpty);
      }
    });

    test('week headlines cover the full 0-40 range', () {
      expect(PregnancyGuidance.weekHeadline(l10n, 0), contains('Early pregnancy'));
      expect(PregnancyGuidance.weekHeadline(l10n, 4), contains('Early pregnancy'));
      expect(PregnancyGuidance.weekHeadline(l10n, 5), contains('First trimester'));
      expect(PregnancyGuidance.weekHeadline(l10n, 12), contains('First trimester'));
      expect(PregnancyGuidance.weekHeadline(l10n, 13), contains('Second trimester'));
      expect(PregnancyGuidance.weekHeadline(l10n, 26), contains('Second trimester'));
      expect(PregnancyGuidance.weekHeadline(l10n, 27), contains('Third trimester'));
      expect(PregnancyGuidance.weekHeadline(l10n, 40), contains('Third trimester'));
    });

    test('week headlines return null outside 0-40', () {
      expect(PregnancyGuidance.weekHeadline(l10n, -1), isNull);
      expect(PregnancyGuidance.weekHeadline(l10n, 41), isNull);
    });
  });

  group('Perimenopause catalog', () {
    test('categories are non-empty with titled, populated groups', () {
      expect(kPerimenopauseCategories(l10n), isNotEmpty);
      for (final PerimenopauseCategory category in kPerimenopauseCategories(l10n)) {
        expect(category.title, isNotEmpty);
        expect(category.symptoms, isNotEmpty);
        for (final String symptom in category.symptoms) {
          expect(symptom, isNotEmpty);
        }
      }
    });

    test('flattened list matches every catalog entry', () {
      final List<String> expected = <String>[
        for (final PerimenopauseCategory category in kPerimenopauseCategories(l10n))
          ...category.symptoms,
      ];
      expect(kAllPerimenopauseSymptoms(l10n), expected);
      expect(kAllPerimenopauseSymptoms(l10n), contains('Hot flashes'));
      expect(kAllPerimenopauseSymptoms(l10n), contains('Irregular periods'));
    });
  });

  group('TrackerInsightText', () {
    final PregnancyStatus status = PregnancyStatus(
      lmp: DateTime(2026, 1, 1),
      dueDate: DateTime(2026, 10, 8),
      weeks: 8,
      days: 3,
      trimester: Trimester.first,
    );

    test('pregnancy headline reports exact weeks and days', () {
      expect(TrackerInsightText.pregnancyHeadline(l10n, status),
          'You are 8 weeks and 3 days pregnant.');
    });

    test('pregnancy due line computes days-to-go from 40 weeks', () {
      // totalDays = 8*7 + 3 = 59 -> 280 - 59 = 221 days to go.
      expect(
        TrackerInsightText.pregnancyDueLine(l10n, status),
        'Estimated due date: October 8, 2026 (221 days to go based on your '
        'dates).',
      );
    });

    test('perimenopause summary handles an empty history', () {
      expect(TrackerInsightText.perimenopauseSummary(l10n, SymptomInsights.empty),
          'Log symptoms to see which ones are most frequent for you.');
    });

    test('perimenopause summary reports top symptom and day count', () {
      const SymptomInsights insights = SymptomInsights(
        totalLogs: 3,
        totalSymptomCount: 5,
        topSymptoms: <SymptomFrequency>[
          SymptomFrequency(symptom: 'Hot flashes', count: 3),
          SymptomFrequency(symptom: 'Fatigue', count: 2),
        ],
      );
      final String summary =
          TrackerInsightText.perimenopauseSummary(l10n, insights);
      expect(summary, contains('on 3 days'));
      expect(summary, contains('"Hot flashes"'));
    });

    test('disclaimer is always present', () {
      expect(TrackerInsightText.disclaimer(l10n), isNotEmpty);
    });
  });
}
