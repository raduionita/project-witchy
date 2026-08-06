import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:witchy/features/perimenopause/perimenopause_screen.dart';
import 'package:witchy/l10n/app_localizations.dart';
import 'package:witchy/models/user_profile.dart';
import 'package:witchy/providers/app_state_provider.dart';
import 'package:witchy/providers/cycle_provider.dart';
import 'package:witchy/providers/symptom_provider.dart';
import 'package:witchy/services/storage_service.dart';
import 'package:witchy/utils/date_utils.dart';

void main() {
  Future<SymptomProvider> pumpPerimenopause(WidgetTester tester) async {
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
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(body: PerimenopauseScreen()),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return symptom;
  }

  testWidgets('shows the stage-specific catalog and empty recent logs',
      (WidgetTester tester) async {
    await pumpPerimenopause(tester);

    expect(find.text('Perimenopause'), findsOneWidget);
    expect(find.text('No symptom logs yet in this stage.'), findsOneWidget);
    expect(find.text('Hot flashes'), findsWidgets);
  });

  testWidgets('tapping a symptom chip logs it for today and confirms it',
      (WidgetTester tester) async {
    final SymptomProvider symptom = await pumpPerimenopause(tester);

    await tester.tap(find.text('Hot flashes').last);
    await tester.pumpAndSettle();

    expect(find.text('"Hot flashes" logged for today.'), findsOneWidget);
    expect(symptom.recentLogs, isNotEmpty);
    expect(symptom.recentLogs.single.symptoms, contains('Hot flashes'));
    expect(symptom.recentLogs.single.date, dateOnly(DateTime.now()));
    expect(find.text('No symptom logs yet in this stage.'), findsNothing);
  });
}