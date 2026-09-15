import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:witchy/app/router/app_route_information_parser.dart';
import 'package:witchy/app/router/app_route_path.dart';

void main() {
  const AppRouteInformationParser parser = AppRouteInformationParser();

  group('AppRouteInformationParser', () {
    test('parseRouteInformation maps known deep links to their route', () async {
      final AppRoutePath splash = await parser.parseRouteInformation(
        RouteInformation(uri: Uri.parse(AppLinkKind.splash.uri)),
      );
      final AppRoutePath onboarding = await parser.parseRouteInformation(
        RouteInformation(uri: Uri.parse(AppLinkKind.onboarding.uri)),
      );
      final AppRoutePath shell = await parser.parseRouteInformation(
        RouteInformation(uri: Uri.parse(AppLinkKind.shell.uri)),
      );

      expect(splash, isA<AppSplashRoute>());
      expect(onboarding, isA<AppOnboardingRoute>());
      expect(shell, isA<AppShellRoute>());
    });

    test('parseRouteInformation ignores query strings and trailing data', () async {
      final AppRoutePath shell = await parser.parseRouteInformation(
        RouteInformation(uri: Uri.parse('/shell?tab=calendar')),
      );
      expect(shell, isA<AppShellRoute>());
    });

    test('parseRouteInformation falls back to splash for unknown paths', () async {
      final AppRoutePath unknown = await parser.parseRouteInformation(
        RouteInformation(uri: Uri.parse('/nope')),
      );
      final AppRoutePath root = await parser.parseRouteInformation(
        RouteInformation(uri: Uri.parse('/')),
      );
      final AppRoutePath empty = await parser.parseRouteInformation(
        RouteInformation(uri: Uri.parse('')),
      );
      expect(unknown, isA<AppSplashRoute>());
      expect(root, isA<AppSplashRoute>());
      expect(empty, isA<AppSplashRoute>());
    });

    test('restoreRouteInformation round-trips every route to its URI', () async {
      for (final AppRoutePath path in const <AppRoutePath>[
        AppSplashRoute(),
        AppOnboardingRoute(),
        AppShellRoute(),
      ]) {
        final RouteInformation restored = parser.restoreRouteInformation(path);
        final AppRoutePath reparsed =
            await parser.parseRouteInformation(restored);
        expect(reparsed.runtimeType, path.runtimeType,
            reason: '${restored.uri} should restore the same route');
      }
    });

    test('AppLinkKind.fromUri has parity with AppRouteLocation', () {
      expect(AppLinkKind.values.map((AppLinkKind k) => k.uri).toList(),
          containsAll(<String>['/', '/onboarding', '/shell']));
      expect(AppLinkKind.values.map((AppLinkKind k) => k.name).toSet(),
          AppRouteLocation.values.map((AppRouteLocation l) => l.name).toSet());
      expect(AppLinkKind.fromUri('/unknown'), isNull);
      expect(AppLinkKind.fromUri('/onboarding'), AppLinkKind.onboarding);
    });
  });
}
