import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:witchy/features/logging/log_biometrics_sheet.dart';
import 'package:witchy/features/logging/logging_screen.dart';
import 'package:witchy/features/logging/sovereign_blood_screen.dart';
import 'package:witchy/l10n/app_localizations.dart';
import 'package:witchy/models/biometric_log.dart';
import 'package:witchy/models/user_profile.dart';
import 'package:witchy/providers/app_state_provider.dart';
import 'package:witchy/providers/biometric_provider.dart';
import 'package:witchy/providers/cycle_provider.dart';
import 'package:witchy/services/storage_service.dart';
import 'package:witchy/utils/date_utils.dart';

void main() {
  Future<(AppStateProvider, CycleProvider)> pumpLogging(
    WidgetTester tester, {
    VoidCallback? onOpenCalendar,
  }) async {
    tester.view.physicalSize = const Size(800, 1600);
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

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AppStateProvider>.value(value: state),
          ChangeNotifierProvider<CycleProvider>.value(value: cycle),
          ChangeNotifierProvider<BiometricProvider>.value(
            value: BiometricProvider(state),
          ),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            appBar: AppBar(title: const Text('Logging')),
            body: LoggingScreen(onOpenCalendar: onOpenCalendar),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return (state, cycle);
  }

  testWidgets('shows the empty state when there are no logs',
      (WidgetTester tester) async {
    await pumpLogging(tester);

    expect(find.text('Logging'), findsOneWidget);
    expect(find.text('Recent logs'), findsOneWidget);
    expect(
      find.text('No logs yet. Tap "Log period" to get started.'),
      findsOneWidget,
    );
  });

  testWidgets('tapping "Log period" opens the Sovereign Blood screen and saving '
      'records the day', (WidgetTester tester) async {
    final (_, CycleProvider cycle) = await pumpLogging(tester);

    await tester.tap(find.text('Log period'));
    await tester.pumpAndSettle();
    expect(find.byType(SovereignBloodScreen), findsOneWidget);

    await tester.tap(find.text('Save Bleed Log'));
    await tester.pumpAndSettle();

    expect(cycle.isPeriodDay(dateOnly(DateTime.now())), isTrue);
    expect(find.text('No logs yet. Tap "Log period" to get started.'),
        findsNothing);
  });

  testWidgets('tapping "Log from calendar" shows a hint snackbar without a '
      'callback', (WidgetTester tester) async {
    await pumpLogging(tester);

    await tester.tap(find.text('Log from calendar'));
    await tester.pumpAndSettle();

    expect(find.text('Use the Calendar tab to pick a day.'), findsOneWidget);
  });

  testWidgets('tapping "Log from calendar" invokes the shell callback',
      (WidgetTester tester) async {
    bool called = false;
    await pumpLogging(tester, onOpenCalendar: () => called = true);

    await tester.tap(find.text('Log from calendar'));
    await tester.pumpAndSettle();

    expect(called, isTrue);
  });

  testWidgets(
      'tapping "Biometrics" opens the sheet and saving records BBT, mucus, LH, '
      'pregnancy test and intimacy for today', (WidgetTester tester) async {
    final (AppStateProvider state, _) = await pumpLogging(tester);

    await tester.tap(find.text('Biometrics'));
    await tester.pumpAndSettle();
    expect(find.byType(LogBiometricsSheet), findsOneWidget);

    await tester.enterText(find.byType(TextField).first, '36.45');
    await tester.tap(find.text('Eggwhite'));
    await tester.tap(find.text('Peak'));
    await tester.tap(find.text('Positive'));
    await tester.tap(find.text('I logged intimacy on this day'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save log'));
    await tester.pumpAndSettle();

    expect(find.byType(LogBiometricsSheet), findsNothing);

    final BiometricLog log = state.biometric.biometricLogs.items.single;
    expect(log.bbt!.tempC, 36.45);
    expect(log.mucus!.name, 'eggwhite');
    expect(log.ovulationTest!.name, 'peak');
    expect(log.pregnancyTest!.name, 'positive');
    expect(log.intercourse, isNotNull);
  });
}