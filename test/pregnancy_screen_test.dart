import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:witchy/features/pregnancy/pregnancy_screen.dart';
import 'package:witchy/l10n/app_localizations.dart';
import 'package:witchy/models/user_profile.dart';
import 'package:witchy/providers/app_state_provider.dart';
import 'package:witchy/providers/cycle_provider.dart';
import 'package:witchy/services/storage_service.dart';

void main() {
  Future<(AppStateProvider, CycleProvider)> pumpPregnancy(
    WidgetTester tester,
  ) async {
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
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(body: PregnancyScreen()),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return (state, cycle);
  }

  testWidgets('shows the setup card when no last period date is set',
      (WidgetTester tester) async {
    await pumpPregnancy(tester);

    expect(find.text('Pregnancy'), findsOneWidget);
    expect(find.text('Set your last period date'), findsOneWidget);
    expect(find.text('Choose date'), findsOneWidget);
    expect(find.text('Today'), findsNothing);
  });

  testWidgets('choosing a date saves the LMP and shows the status cards',
      (WidgetTester tester) async {
    final (AppStateProvider state, _) = await pumpPregnancy(tester);

    await tester.tap(find.text('Choose date'));
    await tester.pumpAndSettle();
    expect(find.byType(DatePickerDialog), findsOneWidget);

    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    expect(state.profile.profile?.pregnancyLmp, isNotNull);
    expect(find.text('Set your last period date'), findsNothing);
    expect(find.text('Today'), findsOneWidget);
    expect(find.textContaining('weeks and'), findsOneWidget);
    expect(find.textContaining('Estimated due date'), findsOneWidget);
  });
}