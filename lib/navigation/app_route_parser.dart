import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

class AppRouteParser extends RouteInformationParser<String> {
  const AppRouteParser();

  @override
  Future<String> parseRouteInformation(RouteInformation routeInformation) {
    final path = routeInformation.uri.path;
    return SynchronousFuture(path.isEmpty ? '/' : path);
  }

  @override
  RouteInformation? restoreRouteInformation(String configuration) => RouteInformation(uri: Uri.parse(configuration));
}
