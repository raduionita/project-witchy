import 'package:flutter_test/flutter_test.dart';

import 'package:witchy/models/article.dart';
import 'package:witchy/models/cycle.dart';
import 'package:witchy/models/flow_intensity.dart';
import 'package:witchy/models/period_log.dart';
import 'package:witchy/models/reminder.dart';
import 'package:witchy/models/reminder_type.dart';
import 'package:witchy/models/symptom_log.dart';
import 'package:witchy/models/time_of_day_model.dart';
import 'package:witchy/models/user_profile.dart';

void main() {
  group('UserProfile', () {
    test('round-trips through JSON', () {
      const UserProfile profile = UserProfile(
        id: 'p1',
        averageCycleLength: 29,
        averagePeriodLength: 5,
        lutealPhaseLength: 14,
        onboarded: true,
      );

      final UserProfile restored = UserProfile.fromJson(profile.toJson());

      expect(restored, profile);
    });

    test('applies defaults when fields are absent', () {
      final UserProfile restored = UserProfile.fromJson(<String, dynamic>{'id': 'p2'});

      expect(restored.averageCycleLength, 28);
      expect(restored.averagePeriodLength, 5);
      expect(restored.lutealPhaseLength, 14);
      expect(restored.onboarded, isFalse);
    });
  });

  group('PeriodLog', () {
    test('round-trips through JSON including enums', () {
      final PeriodLog log = PeriodLog(
        id: 'pl1',
        date: DateTime(2026, 1, 5),
        intensity: FlowIntensity.heavy,
        symptoms: const ['cramps', 'bloating'],
        mood: 'irritable',
        notes: 'bad night',
      );

      final PeriodLog restored = PeriodLog.fromJson(log.toJson());

      expect(restored, log);
      expect(restored.intensity, FlowIntensity.heavy);
    });
  });

  group('Cycle', () {
    test('round-trips through JSON', () {
      final Cycle cycle = Cycle(
        id: 'c1',
        startDate: DateTime(2026, 1, 1),
        endDate: DateTime(2026, 1, 29),
        length: 28,
      );

      expect(Cycle.fromJson(cycle.toJson()), cycle);
    });
  });

  group('SymptomLog', () {
    test('round-trips through JSON', () {
      final SymptomLog log = SymptomLog(
        id: 's1',
        date: DateTime(2026, 1, 6),
        symptoms: const ['headache'],
        mood: 'calm',
      );

      expect(SymptomLog.fromJson(log.toJson()), log);
    });
  });

  group('Reminder', () {
    test('round-trips through JSON', () {
      final Reminder reminder = Reminder(
        id: 'r1',
        type: ReminderType.medication,
        title: 'Take pill',
        time: const TimeOfDayModel(hour: 9, minute: 0),
        weekday: const [1, 3, 5],
        body: 'Daily reminder',
      );

      expect(Reminder.fromJson(reminder.toJson()), reminder);
    });
  });

  group('Article', () {
    test('round-trips through JSON', () {
      final Article article = Article(
        id: 'a1',
        title: 'Understanding cycles',
        category: 'education',
        body: 'Long body text.',
      );

      expect(Article.fromJson(article.toJson()), article);
    });
  });
}
