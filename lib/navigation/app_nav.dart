import 'package:flutter/widgets.dart';

import 'app_router_delegate.dart';
import 'app_router_scope.dart';

extension AppNav on BuildContext {
  AppRouterDelegate get _router => AppRouterScope.of(this);

  /// Forward navigation; shell routes switch the root stack entry instead of pushing.
  void go(String path) => _router.go(path);

  /// Pops the stack; at a single-entry stack falls back to the dashboard root.
  void back() => _router.back();

  /// Pops the stack, or resets to [fallback] when there is nothing beneath.
  void backOr(String fallback) => _router.backOr(fallback);

  /// Replaces the whole stack with [path] (post-auth entry points, sign-out).
  void reset(String path) => _router.reset(path);
}
