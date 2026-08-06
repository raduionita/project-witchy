import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app/app_bootstrap.dart';
import 'app/app_router.dart';
import 'utils/app_theme.dart';

/// Root widget for Witchy.
///
/// Owns the app-wide providers and wires the Navigator 2.0 router into
/// [MaterialApp].
class WitchyApp extends StatelessWidget {
  const WitchyApp({super.key, required this.bootstrap});

  /// Shared bootstrap state used to derive the initial route.
  final AppBootstrap bootstrap;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AppBootstrap>.value(
      value: bootstrap,
      child: MaterialApp.router(
        title: 'Witchy',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        routerDelegate: AppRouterDelegate(bootstrap: bootstrap),
        routeInformationParser: const AppRouteInformationParser(),
      ),
    );
  }
}
