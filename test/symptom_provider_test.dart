import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:witchy/models/cycle_phase.dart';
import 'package:witchy/models/symptom_insights.dart';
import 'package:witchy/models/symptom_log.dart';
import 'package:witchy/models/user_profile.dart';
import 'package:witchy/providers/app_state_provider.dart';
import 'package:witchy/providers/cycle_provider.dart';
import 'package:witchy/providers/symptom_provider.dart';
import 'package:witchy/services/storage_service.dart';
import 'package:witchy/services/symptom_pattern_service.dart';

void main() {
  late AppStateProvider state;
  late CycleProvider cycleProvider;
  late SymptomProvider symptomProvider;

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final StorageService storage =
        StorageService(await SharedPreferences.getInstance());
    state = AppStateProvider(storage);
    state.load();
    cycleProvider = CycleProvider(
      state,
      now: () => DateTime(2026, 1, 15),
    );
    symptomProvider = SymptomProvider(state, cycleProvider);

    await state.profile.save(
      const UserProfile(
        id: 'p1',
        averageCycleLength: 28,
        averagePeriodLength: 5,
        lutealPhaseLength: 14,
      ),
    );
    cycleProvider.recompute();
  });

  test('logSymptoms records a day and recomputes insights', () async {
    expect(symptomProvider.insights, SymptomInsights.empty);
    expect(symptomProvider.recentLogs, isEmpty);

    await symptomProvider.logSymptoms(
      DateTime(2026, 1, 10),
      symptoms: const ['cramps', 'headache'],
    );

    expect(symptomProvider.isSymptomDay(DateTime(2026, 1, 10)), isTrue);
    expect(symptomProvider.insights.totalLogs, 1);
    expect(symptomProvider.insights.totalSymptomCount, 2);
    expect(symptomProvider.insights.topSymptoms.first.symptom, 'cramps');
    expect(symptomProvider.recentLogs.single.symptoms, hasLength(2));
  });

  test('logSymptoms updates an existing day instead of duplicating', () async {
    await symptomProvider.logSymptoms(
      DateTime(2026, 1, 10),
      symptoms: const ['cramps'],
    );
    await symptomProvider.logSymptoms(
      DateTime(2026, 1, 10),
      mood: 'tired',
      notes: 'extra',
    );

    expect(symptomProvider.recentLogs, hasLength(1));
    final SymptomLog log = state.logs.symptomLogs.items.single;
    expect(log.symptoms, ['cramps']);
    expect(log.mood, 'tired');
    expect(log.notes, 'extra');
  });

  test('removeLog clears the day', () async {
    await symptomProvider.logSymptoms(DateTime(2026, 1, 10));
    await symptomProvider.removeLog(DateTime(2026, 1, 10));

    expect(state.logs.symptomLogs.items, isEmpty);
    expect(symptomProvider.insights, SymptomInsights.empty);
  });

  test('analyze aggregates counts and ranks by frequency', () async {
    await symptomProvider.logSymptoms(
      DateTime(2026, 1, 5),
      symptoms: const ['cramps'],
    );
    await symptomProvider.logSymptoms(
      DateTime(2026, 1, 6),
      symptoms: const ['cramps', 'bloating'],
    );
    await symptomProvider.logSymptoms(
      DateTime(2026, 1, 7),
      symptoms: const ['headache'],
    );

    expect(symptomProvider.insights.totalLogs, 3);
    expect(symptomProvider.insights.topSymptoms[0].symptom, 'cramps');
    expect(symptomProvider.insights.topSymptoms[0].count, 2);
    expect(symptomProvider.insights.topSymptoms[1].symptom, 'bloating');
  });

  test('breakdownFor maps logs into the correct cycle phase', () async {
    // A 28-day cycle starting Jan 1: ovulation on day 14 (Jan 15).
    await cycleProvider.logPeriodDay(DateTime(2026, 1, 1));

    // Day 3 (Jan 3) falls in menstruation (period length 5).
    await symptomProvider.logSymptoms(
      DateTime(2026, 1, 3),
      symptoms: const ['cramps'],
    );
    // Day 8 (Jan 8) falls in the follicular phase.
    await symptomProvider.logSymptoms(
      DateTime(2026, 1, 8),
      symptoms: const ['bloating'],
    );

    final breakdown = symptomProvider.breakdownFor('cramps');
    expect(breakdown.total, 1);
    expect(breakdown.byPhase, {CyclePhase.menstruation: 1});

    final follicular = symptomProvider.breakdownFor('bloating');
    expect(follicular.byPhase, {CyclePhase.follicular: 1});
  });

  test('dayIndexesFor returns 1-based cycle-relative days', () async {
    await cycleProvider.logPeriodDay(DateTime(2026, 1, 1));

    await symptomProvider.logSymptoms(
      DateTime(2026, 1, 3),
      symptoms: const ['cramps'],
    );
    await symptomProvider.logSymptoms(
      DateTime(2026, 1, 10),
      symptoms: const ['cramps'],
    );

    expect(symptomProvider.dayIndexesFor('cramps'), [3, 10]);
  });

  test('trendFor is insufficient with too few logs', () async {
    await symptomProvider.logSymptoms(DateTime(2026, 1, 3),
        symptoms: const ['cramps']);
    await symptomProvider.logSymptoms(DateTime(2026, 1, 4),
        symptoms: const ['cramps']);

    expect(symptomProvider.trendFor('cramps'), SymptomTrend.insufficient);
  });

  test('trendFor detects an increasing trend', () async {
    // Older half: no cramps. Newer half: cramps on most days.
    for (final int day in [1, 2, 3, 4]) {
      await symptomProvider.logSymptoms(DateTime(2026, 1, day),
          symptoms: const ['fatigue']);
    }
    for (final int day in [11, 12, 13, 14, 15, 16, 17]) {
      await symptomProvider.logSymptoms(DateTime(2026, 1, day),
          symptoms: const ['cramps']);
    }

    expect(symptomProvider.trendFor('cramps'), SymptomTrend.increasing);
  });
}
