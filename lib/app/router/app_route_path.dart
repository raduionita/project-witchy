import 'package:flutter/foundation.dart';

/// The set of top-level destinations the app can navigate to.
enum AppRouteLocation { splash, onboarding, shell }

/// Deep-linkable URI fragments, kept in one-to-one parity with
/// [AppRouteLocation] so parsing and restoring routes always agree.
enum AppLinkKind {
  splash('/'),
  onboarding('/onboarding'),
  shell('/shell');

  const AppLinkKind(this.uri);

  /// URI path fragment for this destination.
  final String uri;

  /// Resolves a URI path fragment to its [AppLinkKind], or `null` when the
  /// path does not match any known destination.
  static AppLinkKind? fromUri(String path) {
    for (final AppLinkKind kind in AppLinkKind.values) {
      if (kind.uri == path) return kind;
    }
    return null;
  }
}

/// A parsed, immutable description of the app's navigation state.
///
/// The hierarchy is sealed: every concrete path extends [AppRoutePath].
@immutable
sealed class AppRoutePath {
  const AppRoutePath(this.location);

  /// Which top-level destination this path represents.
  final AppRouteLocation location;
}

/// Shown only while the app bootstraps stored data.
class AppSplashRoute extends AppRoutePath {
  const AppSplashRoute() : super(AppRouteLocation.splash);
}

/// First-run flow that collects baseline cycle data.
class AppOnboardingRoute extends AppRoutePath {
  const AppOnboardingRoute() : super(AppRouteLocation.onboarding);
}

/// The main app shell (bottom navigation).
class AppShellRoute extends AppRoutePath {
  const AppShellRoute() : super(AppRouteLocation.shell);
}
