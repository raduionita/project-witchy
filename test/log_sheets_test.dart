import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:witchy/features/logging/log_period_sheet.dart';
import 'package:witchy/features/logging/log_symptom_sheet.dart';
import 'package:witchy/models/user_profile.dart';
import 'package:witchy/providers/app_state_provider.dart';
import 'package:witchy/providers/cycle_provider.dart';
import 'package:witchy/providers/symptom_provider.dart';
import 'package:witchy/services/storage_service.dart';
import 'package:witchy/utils/date_utils.dart';

final DateTime _testDate = DateTime(2026, 1, 10);

/// Host widget that opens either sheet via their static `show` method, so the
/// sheets can be exercised through the real modal navigation.
class _SheetHost extends StatelessWidget {
  const _SheetHost();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () =>
                  LogPeriodSheet.show(context: context, date: _testDate),
              child: const Text('open period'),
            ),
            ElevatedButton(
              onPressed: () =>
                  LogSymptomSheet.show(context: context, date: _testDate),
              child: const Text('open symptom'),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  Future<(CycleProvider, SymptomProvider)> pumpSheets(
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    SharedPreferences.setMockInitialValues(<String, Object>{});
    final StorageService storage =
        StorageService(await SharedPreferences.getInstance());
    final AppStateProvider state = AppStateProvider(storage)..load();
    await state.profile.save(
      const UserProfile(
        id: 'p1',
        averageCycleLength: 28,
        averagePeriodLength: 5,
      ),
    );
    final CycleProvider cycle = CycleProvider(state)..recompute();
    final SymptomProvider symptom = SymptomProvider(state, cycle)..recompute();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AppStateProvider>.value(value: state),
          ChangeNotifierProvider<CycleProvider>.value(value: cycle),
          ChangeNotifierProvider<SymptomProvider>.value(value: symptom),
        ],
        child: const MaterialApp(home: _SheetHost()),
      ),
    );
    await tester.pumpAndSettle();
    return (cycle, symptom);
  }

  testWidgets(
      'period sheet lets you pick intensity, symptoms, mood and notes, then '
      'saves them', (WidgetTester tester) async {
    final (CycleProvider cycle, _) = await pumpSheets(tester);

    await tester.tap(find.text('open period'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('medium'));
    await tester.tap(find.text('Cramps'));
    await tester.tap(find.text('Happy'));
    await tester.enterText(find.byType(TextField), 'feeling rough');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save log'));
    await tester.pumpAndSettle();

    expect(find.byType(LogPeriodSheet), findsNothing);
    final log = cycle.recentPeriodLogs.single;
    expect(log.intensity!.name, 'medium');
    expect(log.symptoms, contains('Cramps'));
    expect(log.mood, 'Happy');
    expect(log.notes, 'feeling rough');
  });

  testWidgets('symptom sheet saves symptoms, mood and notes for the day',
      (WidgetTester tester) async {
    final (_, SymptomProvider symptom) = await pumpSheets(tester);

    await tester.tap(find.text('open symptom'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Symptoms ·'), findsOneWidget);

    await tester.tap(find.text('Bloating'));
    await tester.tap(find.text('Anxious'));
    await tester.enterText(find.byType(TextField), 'so far so good');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save log'));
    await tester.pumpAndSettle();

    expect(find.byType(LogSymptomSheet), findsNothing);
    final log = symptom.recentLogs.single;
    expect(log.date, dateOnly(_testDate));
    expect(log.symptoms, contains('Bloating'));
    expect(log.mood, 'Anxious');
    expect(log.notes, 'so far so good');
  });
}