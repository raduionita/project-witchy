import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:witchy/app/app_bootstrap.dart';
import 'package:witchy/app/app_router.dart';
import 'package:witchy/features/auth/auth_gateway.dart';
import 'package:witchy/features/auth/auth_provider.dart';
import 'package:witchy/features/auth/auth_screen.dart';
import 'package:witchy/features/auth/auth_service.dart';
import 'package:witchy/features/content/content_provider.dart';
import 'package:witchy/features/couples/couples_provider.dart';
import 'package:witchy/features/couples/couples_service.dart';
import 'package:witchy/features/onboarding/onboarding_screen.dart';
import 'package:witchy/features/reminders/reminder_provider.dart';
import 'package:witchy/features/reminders/reminder_scheduler.dart';
import 'package:witchy/features/settings/legal_document_screen.dart';
import 'package:witchy/features/settings/locale_provider.dart';
import 'package:witchy/features/settings/privacy_provider.dart';
import 'package:witchy/features/settings/settings_screen.dart';
import 'package:witchy/features/settings/theme_provider.dart';
import 'package:witchy/l10n/app_localizations.dart';
import 'package:witchy/models/reminder.dart';
import 'package:witchy/models/user_profile.dart';
import 'package:witchy/providers/app_state_provider.dart';
import 'package:witchy/providers/biometric_provider.dart';
import 'package:witchy/providers/cycle_provider.dart';
import 'package:witchy/providers/symptom_provider.dart';
import 'package:witchy/screens/main_shell.dart';
import 'package:witchy/services/storage_service.dart';

class FakeReminderScheduler extends ReminderScheduler {
  @override
  Future<bool> requestPermissions() async => true;

  @override
  Future<void> schedule(
    Reminder reminder, {
    DateTime? nextPeriodStart,
    int periodLength = 5,
  }) async {}

  @override
  Future<void> cancel(Reminder reminder) async {}

  @override
  Future<void> cancelAll() async {}
}

void main() {
  Future<void> pumpSettings(
    WidgetTester tester, {
    Map<String, Object> prefs = const <String, Object>{},
    Widget? probe,
  }) async {
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    SharedPreferences.setMockInitialValues(prefs);
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
    final ReminderProvider reminders =
        ReminderProvider(state, FakeReminderScheduler(), cycle: cycle)..load();
    final AuthProvider auth = AuthProvider(
      AuthService(storage: storage, gateway: NativeAuthGateway()),
    )..load();
    final CouplesProvider couples = CouplesProvider(CoupleService(storage))
      ..load();
    final ThemeProvider theme = ThemeProvider(storage)..load();
    final PrivacyProvider privacy = PrivacyProvider(storage)..load();
    final LocaleProvider locale = LocaleProvider(storage)..load();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AppStateProvider>.value(value: state),
          ChangeNotifierProvider<CycleProvider>.value(value: cycle),
          ChangeNotifierProvider<SymptomProvider>.value(value: symptom),
          ChangeNotifierProvider<ReminderProvider>.value(value: reminders),
          ChangeNotifierProvider<AuthProvider>.value(value: auth),
          ChangeNotifierProvider<CouplesProvider>.value(value: couples),
          ChangeNotifierProvider<ThemeProvider>.value(value: theme),
          ChangeNotifierProvider<PrivacyProvider>.value(value: privacy),
          ChangeNotifierProvider<LocaleProvider>.value(value: locale),
        ],
        child: Consumer<LocaleProvider>(
          builder: (BuildContext context, LocaleProvider locale, Widget? _) {
            return MaterialApp(
              locale: locale.option.locale,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: Scaffold(
                body: probe == null
                    ? const SettingsScreen()
                    : Column(
                        children: <Widget>[probe, const Expanded(child: SettingsScreen())],
                      ),
              ),
            );
          },
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('privacy policy tile opens the legal document screen',
      (WidgetTester tester) async {
    await pumpSettings(tester);

    await tester.scrollUntilVisible(find.text('Privacy Policy'), 300);
    await tester.tap(find.text('Privacy Policy'));
    await tester.pumpAndSettle();

    expect(find.byType(LegalDocumentScreen), findsOneWidget);
    expect(find.text('Your data stays on your device'), findsOneWidget);
  });

  testWidgets('terms of service tile opens the legal document screen',
      (WidgetTester tester) async {
    await pumpSettings(tester);

    await tester.scrollUntilVisible(find.text('Terms of Service'), 300);
    await tester.tap(find.text('Terms of Service'));
    await tester.pumpAndSettle();

    expect(find.byType(LegalDocumentScreen), findsOneWidget);
    expect(find.text('Acceptance of terms'), findsOneWidget);
  });

  testWidgets('about tile shows a coming-soon snackbar',
      (WidgetTester tester) async {
    await pumpSettings(tester);

    await tester.scrollUntilVisible(find.text('About'), 300);
    await tester.tap(find.text('About'));
    await tester.pumpAndSettle();
    expect(find.text('About is coming soon.'), findsOneWidget);
  });

  testWidgets('account tile navigates to the auth screen when signed out',
      (WidgetTester tester) async {
    await pumpSettings(tester);

    await tester.tap(find.text('Account'));
    await tester.pumpAndSettle();

    expect(find.byType(AuthScreen), findsOneWidget);
    expect(find.text('Sign in (optional)'), findsOneWidget);
  });

  testWidgets('language section sits above the theme card and switching to '
      'Español localizes the screen', (WidgetTester tester) async {
    await pumpSettings(tester);

    await tester.scrollUntilVisible(find.text('Theme'), 300);
    final double themeTop = tester.getTopLeft(find.text('Theme')).dy;
    await tester.scrollUntilVisible(find.text('Language'), -300);
    final double languageTop = tester.getTopLeft(find.text('Language')).dy;
    expect(languageTop, lessThan(themeTop));

    await tester.scrollUntilVisible(
      find.byType(DropdownButtonFormField<AppLocaleOption>),
      300,
    );
    await tester.tap(find.byType(DropdownButtonFormField<AppLocaleOption>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Español').last);
    await tester.pumpAndSettle();

    expect(find.text('Idioma'), findsOneWidget);

    final SharedPreferences stored = await SharedPreferences.getInstance();
    expect(stored.getString('witchy.appearance.locale'), '"es"');
  });

  testWidgets('changing the start-of-week day persists and defaults to Monday',
      (WidgetTester tester) async {
    await pumpSettings(tester);

    await tester.scrollUntilVisible(find.text('Start of week'), 300);
    expect(find.text('Monday'), findsOneWidget);

    await tester.tap(find.byType(DropdownButtonFormField<int>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sunday').last);
    await tester.pumpAndSettle();

    final AppStateProvider state = tester
        .element(find.byType(SettingsScreen))
        .read<AppStateProvider>();
    expect(state.profile.profile?.firstDayOfWeek, DateTime.sunday);

    // The calendar builds from CycleProvider's profile; changing the setting
    // must recompute/notify it so the calendar rebinds its week start.
    final CycleProvider cycle = tester
        .element(find.byType(SettingsScreen))
        .read<CycleProvider>();
    expect(cycle.profile?.firstDayOfWeek, DateTime.sunday);

    final SharedPreferences stored = await SharedPreferences.getInstance();
    final dynamic json =
        jsonDecode(stored.getString('witchy.profile') ?? '{}');
    expect(json['firstDayOfWeek'], DateTime.sunday);
  });

  testWidgets('a profile without a saved value defaults the week to Monday',
      (WidgetTester tester) async {
    await pumpSettings(tester);

    final AppStateProvider state = tester
        .element(find.byType(SettingsScreen))
        .read<AppStateProvider>();
    expect(state.profile.profile?.firstDayOfWeek, DateTime.monday);
  });

testWidgets("changing the start of week updates the calendar's data source live",
      (WidgetTester tester) async {
    await pumpSettings(
      tester,
      probe: Consumer<CycleProvider>(
        builder: (BuildContext context, CycleProvider cycle, Widget? _) =>
            Text('firstDay=${cycle.profile?.firstDayOfWeek}'),
      ),
    );

    expect(find.textContaining('firstDay'), findsOneWidget);
    expect(find.text('firstDay=1'), findsOneWidget);

    await tester.scrollUntilVisible(find.text('Start of week'), 300);
    await tester.tap(find.byType(DropdownButtonFormField<int>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sunday').last);
    await tester.pumpAndSettle();

    // The cycle provider consumed by the calendar reacted to the change.
    expect(find.text('firstDay=7'), findsOneWidget);
  });

  testWidgets('clearing all data wipes storage and returns to onboarding',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    const String profileKey = 'witchy.profile';
    SharedPreferences.setMockInitialValues(<String, Object>{
      profileKey: jsonEncode(<String, Object>{
        'id': 'p1',
        'averageCycleLength': 28,
        'averagePeriodLength': 5,
        'lutealPhaseLength': 14,
        'onboarded': true,
      }),
    });

    final StorageService storage =
        StorageService(await SharedPreferences.getInstance());
    final AppStateProvider state = AppStateProvider(storage)..load();
    final CycleProvider cycle = CycleProvider(state)..recompute();
    final SymptomProvider symptom = SymptomProvider(state, cycle)..recompute();
    final ReminderProvider reminders =
        ReminderProvider(state, FakeReminderScheduler(), cycle: cycle)..load();
    final AuthProvider auth = AuthProvider(
      AuthService(storage: storage, gateway: NativeAuthGateway()),
    )..load();
    final CouplesProvider couples = CouplesProvider(CoupleService(storage))
      ..load();
    final ThemeProvider theme = ThemeProvider(storage)..load();
    final PrivacyProvider privacy = PrivacyProvider(storage)..load();
    final LocaleProvider locale = LocaleProvider(storage)..load();
    final ContentProvider content = ContentProvider(storage)..load();

    final AppBootstrap bootstrap = AppBootstrap();
    await bootstrap.initialize();
    final AppRouterDelegate delegate = AppRouterDelegate(bootstrap: bootstrap);
    const AppRouteInformationParser parser = AppRouteInformationParser();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AppStateProvider>.value(value: state),
          ChangeNotifierProvider<CycleProvider>.value(value: cycle),
          ChangeNotifierProvider<SymptomProvider>.value(value: symptom),
          ChangeNotifierProvider<ReminderProvider>.value(value: reminders),
          ChangeNotifierProvider<AuthProvider>.value(value: auth),
          ChangeNotifierProvider<CouplesProvider>.value(value: couples),
          ChangeNotifierProvider<ThemeProvider>.value(value: theme),
          ChangeNotifierProvider<PrivacyProvider>.value(value: privacy),
          ChangeNotifierProvider<LocaleProvider>.value(value: locale),
          ChangeNotifierProvider<ContentProvider>.value(value: content),
          ChangeNotifierProvider<BiometricProvider>.value(
            value: BiometricProvider(state),
          ),
        ],
        child: MaterialApp.router(
          routerDelegate: delegate,
          routeInformationParser: parser,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(MainShellScreen), findsOneWidget);

    await tester.tap(find.byIcon(Icons.person_outline));
    await tester.pumpAndSettle();
    await tester.pumpAndSettle();
    expect(find.byType(SettingsScreen), findsOneWidget);

    await tester.scrollUntilVisible(find.text('Clear all data'), 300);
    await tester.tap(find.text('Clear all data'));
    await tester.pumpAndSettle();
    expect(find.text('Erase all data?'), findsOneWidget);

    await tester.tap(find.text('Clear'));
    await tester.pumpAndSettle();

    expect(find.byType(OnboardingScreen), findsOneWidget);

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    expect(prefs.containsKey(profileKey), isFalse);
  });
}