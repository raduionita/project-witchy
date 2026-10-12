import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

class AppRouteParser extends RouteInformationParser<String> {
  const AppRouteParser();

  @override
  Future<String> parseRouteInformation(RouteInformation routeInformation) {
    final uri = routeInformation.uri;
    // Keep the query: /webview carries title+url and would deep-link to nothing without it.
    final path = uri.hasQuery ? '${uri.path}?${uri.query}' : uri.path;
    return SynchronousFuture(path.isEmpty ? '/' : path);
  }

  @override
  RouteInformation? restoreRouteInformation(String configuration) => RouteInformation(uri: Uri.parse(configuration));
}
