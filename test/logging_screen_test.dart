import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:witchy/features/logging/log_period_sheet.dart';
import 'package:witchy/features/logging/logging_screen.dart';
import 'package:witchy/models/user_profile.dart';
import 'package:witchy/providers/app_state_provider.dart';
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
        ],
        child: MaterialApp(
          home: Scaffold(
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

  testWidgets('tapping "Log period" opens the period sheet and saving records '
      'the day', (WidgetTester tester) async {
    final (_, CycleProvider cycle) = await pumpLogging(tester);

    await tester.tap(find.text('Log period'));
    await tester.pumpAndSettle();
    expect(find.byType(LogPeriodSheet), findsOneWidget);

    await tester.tap(find.text('Save log'));
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
}