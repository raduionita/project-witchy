import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'navigation/app_route_parser.dart';
import 'navigation/app_router_delegate.dart';
import 'navigation/app_router_scope.dart';
import 'providers/alert_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/cycle_provider.dart';
import 'providers/gestation_provider.dart';
import 'providers/logging_provider.dart';
import 'providers/onboarding_provider.dart';
import 'providers/reminders_provider.dart';
import 'providers/settings_provider.dart';
import 'services/notification_service.dart';
import 'services/prefs_service.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = PrefsService();
  final auth = await AuthProvider.load(prefs);
  final onboarding = await OnboardingProvider.load(prefs);
  final logging = await LoggingProvider.load(prefs);
  final settings = await SettingsProvider.load(prefs);
  final reminders = await RemindersProvider.load(prefs);
  final alerts = await AlertProvider.load(prefs);
  final gestation = await GestationProvider.load(prefs);
  final cycle = CycleProvider(onboarding, logging);
  alerts.bind(cycle, logging);
  await NotificationService.init();
  await NotificationService.syncAll(reminders.items);
  await NotificationService.syncPeriodPrediction(
    enabled: settings.lunarNotifications,
    predictedStart: cycle.nextPeriodStart(),
  );
  runApp(App(prefs: prefs, auth: auth, onboarding: onboarding, logging: logging, settings: settings, reminders: reminders, cycle: cycle, alerts: alerts, gestation: gestation));
}

class App extends StatefulWidget {
  const App({
    super.key,
    required this.prefs,
    required this.auth,
    required this.onboarding,
    required this.logging,
    required this.settings,
    required this.reminders,
    required this.cycle,
    required this.alerts,
    required this.gestation,
  });

  final PrefsService prefs;
  final AuthProvider auth;
  final OnboardingProvider onboarding;
  final LoggingProvider logging;
  final SettingsProvider settings;
  final RemindersProvider reminders;
  final CycleProvider cycle;
  final AlertProvider alerts;
  final GestationProvider gestation;

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  late final AppRouterDelegate _delegate = AppRouterDelegate();

  @override
  void dispose() {
    _delegate.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<PrefsService>.value(value: widget.prefs),
        ChangeNotifierProvider.value(value: widget.auth),
        ChangeNotifierProvider.value(value: widget.onboarding),
        ChangeNotifierProvider.value(value: widget.logging),
        ChangeNotifierProvider.value(value: widget.settings),
        ChangeNotifierProvider.value(value: widget.reminders),
        ChangeNotifierProvider.value(value: widget.cycle),
        ChangeNotifierProvider.value(value: widget.alerts),
        ChangeNotifierProvider.value(value: widget.gestation),
      ],
      child: AppRouterScope(
        delegate: _delegate,
        child: MaterialApp.router(
          title: 'Witchy',
          theme: buildAppTheme(),
          debugShowCheckedModeBanner: false,
          routerDelegate: _delegate,
          routeInformationParser: const AppRouteParser(),
        ),
      ),
    );
  }
}
