import 'package:flutter/widgets.dart';

import 'app_route_path.dart';

/// Maps a [RouteInformation] URI to an [AppRoutePath] and back.
///
/// This is the "configuration -> path" half of Navigator 2.0. Currently the
/// app is state-driven (paths are pushed by [AppRouterDelegate]), but parsing
/// lets the OS deep links / browser URLs select a destination.
class AppRouteInformationParser extends RouteInformationParser<AppRoutePath> {
  const AppRouteInformationParser();

  @override
  Future<AppRoutePath> parseRouteInformation(
    RouteInformation routeInformation,
  ) async {
    final Uri uri = Uri.parse(routeInformation.uri.toString());
    return switch (uri.path) {
      '/onboarding' => const AppOnboardingRoute(),
      '/shell' => const AppShellRoute(),
      _ => const AppSplashRoute(),
    };
  }

  @override
  RouteInformation restoreRouteInformation(AppRoutePath configuration) {
    final String path = switch (configuration.location) {
      AppRouteLocation.splash => '/',
      AppRouteLocation.onboarding => '/onboarding',
      AppRouteLocation.shell => '/shell',
    };
    return RouteInformation(uri: Uri.parse(path));
  }
}
