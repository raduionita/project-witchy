import 'package:flutter/material.dart';

import '../../features/onboarding/onboarding_screen.dart';
import '../../screens/splash_screen.dart';
import '../../screens/main_shell.dart';
import '../app_bootstrap.dart';
import 'app_route_path.dart';

/// RouterDelegate driving the Navigator 2.0 setup.
///
/// The active [AppRoutePath] is derived from app state (bootstrap status) and
/// pushed into a stateful [Navigator]. It also participates in pop handling
/// for platform back gestures.
class AppRouterDelegate extends RouterDelegate<AppRoutePath>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<AppRoutePath> {
  AppRouterDelegate({required AppBootstrap bootstrap})
      : _bootstrap = bootstrap,
        _currentPath = bootstrap.isBootstrapped
            ? const AppShellRoute()
            : const AppSplashRoute() {
    _bootstrap.addListener(_onBootstrapChanged);
  }

  final AppBootstrap _bootstrap;

  AppRoutePath _currentPath;

  @override
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  /// Programmatically navigate to a new route.
  void go(AppRoutePath path) {
    if (path.location == _currentPath.location) return;
    _currentPath = path;
    notifyListeners();
  }

  void _onBootstrapChanged() {
    if (_bootstrap.isBootstrapped && _currentPath is AppSplashRoute) {
      _currentPath = _destinationAfterBootstrap();
      notifyListeners();
    }
  }

  /// Where to land once bootstrap finishes (onboarding first-run, else shell).
  AppRoutePath _destinationAfterBootstrap() => _bootstrap.isFirstRun
      ? const AppOnboardingRoute()
      : const AppShellRoute();

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      onDidRemovePage: (Page<Object?> page) => notifyListeners(),
      pages: <Page<dynamic>>[
        MaterialPage<dynamic>(
          key: ValueKey<AppRoutePath>(_currentPath),
          child: switch (_currentPath) {
            AppSplashRoute() => const SplashScreen(),
            AppOnboardingRoute() => const OnboardingScreen(),
            AppShellRoute() => const MainShellScreen(),
          },
        ),
      ],
    );
  }

  @override
  AppRoutePath? get currentConfiguration => _currentPath;

  @override
  Future<void> setNewRoutePath(AppRoutePath configuration) async {
    _currentPath = configuration;
    notifyListeners();
  }

  @override
  Future<void> setInitialRoutePath(AppRoutePath configuration) async {
    _currentPath = _bootstrap.isBootstrapped
        ? _destinationAfterBootstrap()
        : configuration;
    notifyListeners();
  }

  @override
  void dispose() {
    _bootstrap.removeListener(_onBootstrapChanged);
    super.dispose();
  }
}
