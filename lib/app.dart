import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app/app_bootstrap.dart';
import 'app/app_router.dart';
import 'features/auth/auth_gateway.dart';
import 'features/auth/auth_provider.dart';
import 'features/auth/auth_service.dart';
import 'features/content/content_provider.dart';
import 'features/couples/couples_provider.dart';
import 'features/couples/couples_service.dart';
import 'features/reminders/reminder_provider.dart';
import 'features/reminders/reminder_scheduler.dart';
import 'features/settings/locale_provider.dart';
import 'features/settings/privacy_provider.dart';
import 'features/settings/theme_provider.dart';
import 'l10n/app_localizations.dart';
import 'providers/app_state_provider.dart';
import 'providers/cycle_provider.dart';
import 'providers/symptom_provider.dart';
import 'utils/app_theme.dart';

/// Root widget for Witchy.
///
/// Owns the app-wide providers and wires the Navigator 2.0 router into
/// [MaterialApp]. While [AppBootstrap] initializes storage the router shows
/// the splash screen; once repositories are ready they are provided to the
/// tree through [ChangeNotifierProvider].
class WitchyApp extends StatefulWidget {
  const WitchyApp({super.key, required this.bootstrap});

  /// Shared bootstrap state used to derive the initial route.
  final AppBootstrap bootstrap;

  @override
  State<WitchyApp> createState() => _WitchyAppState();
}

class _WitchyAppState extends State<WitchyApp> {
  late final AppRouterDelegate _routerDelegate;
  late final AppRouteInformationParser _routeInformationParser;

  AppStateProvider? _state;
  CycleProvider? _cycleProvider;
  SymptomProvider? _symptomProvider;
  ReminderProvider? _reminderProvider;
  AuthProvider? _authProvider;
  CouplesProvider? _couplesProvider;
  ThemeProvider? _themeProvider;
  ContentProvider? _contentProvider;
  PrivacyProvider? _privacyProvider;
  LocaleProvider? _localeProvider;

  @override
  void initState() {
    super.initState();
    _routerDelegate = AppRouterDelegate(bootstrap: widget.bootstrap);
    _routeInformationParser = const AppRouteInformationParser();
    widget.bootstrap.addListener(_onBootstrapChanged);
    // Adopt already-completed bootstrap (e.g. bootstrap awaited in tests).
    _adoptStateIfAvailable();
  }

  void _adoptStateIfAvailable() {
    final AppStateProvider? state = widget.bootstrap.state;
    if (state != null && _state == null) {
      _state = state;
      _cycleProvider = CycleProvider(state)..recompute();
      _symptomProvider =
          SymptomProvider(state, _cycleProvider!)..recompute();
      _reminderProvider = ReminderProvider(
        state,
        ReminderScheduler(),
        cycle: _cycleProvider,
      )
        ..load();
      _authProvider = AuthProvider(
        AuthService(storage: state.storage, gateway: NativeAuthGateway()),
      )
        ..load();
      _couplesProvider = CouplesProvider(CoupleService(state.storage))
        ..load();
      _themeProvider = ThemeProvider(state.storage)..load();
      _contentProvider = ContentProvider(state.storage)..load();
      _privacyProvider = PrivacyProvider(state.storage)..load();
      _localeProvider = LocaleProvider(state.storage)..load();
    }
  }

  void _onBootstrapChanged() {
    _adoptStateIfAvailable();
    setState(() {});
  }

  @override
  void dispose() {
    widget.bootstrap.removeListener(_onBootstrapChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppStateProvider? state = _state;
    final CycleProvider? cycleProvider = _cycleProvider;

    final Widget app = MaterialApp.router(
      title: 'Witchy',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: _themeProvider?.themeMode ?? ThemeMode.light,
      locale: _localeProvider?.locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerDelegate: _routerDelegate,
      routeInformationParser: _routeInformationParser,
    );

    if (state == null || cycleProvider == null) return app;
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AppStateProvider>.value(value: state),
        ChangeNotifierProvider<CycleProvider>.value(value: cycleProvider),
        ChangeNotifierProvider<SymptomProvider>.value(
          value: _symptomProvider!,
        ),
        ChangeNotifierProvider<ReminderProvider>.value(
          value: _reminderProvider!,
        ),
        ChangeNotifierProvider<AuthProvider>.value(value: _authProvider!),
        ChangeNotifierProvider<CouplesProvider>.value(
          value: _couplesProvider!,
        ),
        ChangeNotifierProvider<ThemeProvider>.value(value: _themeProvider!),
        ChangeNotifierProvider<ContentProvider>.value(
          value: _contentProvider!,
        ),
        ChangeNotifierProvider<PrivacyProvider>.value(
          value: _privacyProvider!,
        ),
        ChangeNotifierProvider<LocaleProvider>.value(value: _localeProvider!),
      ],
      child: app,
    );
  }
}