import 'package:flutter/widgets.dart';

import 'app_router_delegate.dart';

class AppRouterScope extends InheritedWidget {
  const AppRouterScope({super.key, required this.delegate, required super.child});

  final AppRouterDelegate delegate;

  static AppRouterDelegate of(BuildContext context) {
    final scope = context.getInheritedWidgetOfExactType<AppRouterScope>();
    assert(scope != null, 'AppRouterScope not found above context');
    return scope!.delegate;
  }

  @override
  bool updateShouldNotify(AppRouterScope oldWidget) => delegate != oldWidget.delegate;
}
