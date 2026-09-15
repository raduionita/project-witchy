import 'package:flutter/widgets.dart';

import 'app_route_path.dart';

/// Maps a [RouteInformation] URI to an [AppRoutePath] and back.
///
/// This is the "configuration -> path" half of Navigator 2.0. Currently the
/// app is state-driven (paths are pushed by [AppRouterDelegate]), but parsing
/// lets the OS deep links / browser URLs select a destination.
///
/// Deep-link parity lives in [AppLinkKind]: every [AppRouteLocation] has a
/// matching URI fragment, and unknown paths fall back to the splash route.
class AppRouteInformationParser extends RouteInformationParser<AppRoutePath> {
  const AppRouteInformationParser();

  @override
  Future<AppRoutePath> parseRouteInformation(
    RouteInformation routeInformation,
  ) async {
    final Uri uri = Uri.parse(routeInformation.uri.toString());
    final String path = uri.path.isEmpty ? '/' : uri.path;
    return switch (AppLinkKind.fromUri(path)) {
      AppLinkKind.onboarding => const AppOnboardingRoute(),
      AppLinkKind.shell => const AppShellRoute(),
      _ => const AppSplashRoute(),
    };
  }

  @override
  RouteInformation restoreRouteInformation(AppRoutePath configuration) {
    final String path = switch (configuration.location) {
      AppRouteLocation.splash => AppLinkKind.splash.uri,
      AppRouteLocation.onboarding => AppLinkKind.onboarding.uri,
      AppRouteLocation.shell => AppLinkKind.shell.uri,
    };
    return RouteInformation(uri: Uri.parse(path));
  }
}
