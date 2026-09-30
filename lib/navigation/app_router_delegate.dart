import 'package:flutter/material.dart';

import '../models/mock_data.dart';
import '../screens/alerts_screen.dart';
import '../screens/article_detail_screen.dart';
import '../screens/binding_screen.dart';
import '../screens/blood_screen.dart';
import '../screens/chart_screen.dart';
import '../screens/fertility_screen.dart';
import '../screens/gestation_screen.dart';
import '../screens/join_screen.dart';
import '../screens/library_screen.dart';
import '../screens/main_screen.dart';
import '../screens/privacy_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/rhythms_screen.dart';
import '../screens/welcome_screen.dart';
import '../screens/webview_screen.dart';

class AppRouterDelegate extends RouterDelegate<String> with ChangeNotifier, PopNavigatorRouterDelegateMixin<String> {
  AppRouterDelegate();

  static const Set<String> shellRoutes = {'/dashboard', '/calendar', '/insights', '/coven'};

  @override
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  List<String> _stack = ['/'];

  @override
  String? get currentConfiguration => _stack.last;

  @override
  Future<void> setNewRoutePath(String configuration) async {
    if (configuration == _stack.last) return;
    // Browser/platform navigation back onto a known stack entry truncates instead of resetting.
    final knownAt = _stack.lastIndexOf(configuration);
    _stack = knownAt >= 0 ? _stack.sublist(0, knownAt + 1) : [configuration];
    notifyListeners();
  }

  void go(String path) {
    if (shellRoutes.contains(path)) {
      reset(path);
      return;
    }
    if (_stack.last == path) return;
    _stack = [..._stack, path];
    notifyListeners();
  }

  void back() {
    if (_stack.length > 1) {
      _stack.removeLast();
    } else if (_stack.first != '/dashboard') {
      _stack = ['/dashboard'];
    } else {
      return;
    }
    notifyListeners();
  }

  void backOr(String fallback) {
    if (_stack.length > 1) {
      _stack.removeLast();
    } else {
      _stack = [fallback];
    }
    notifyListeners();
  }

  void reset(String path) {
    if (_stack.length == 1 && _stack.first == path) return;
    _stack = [path];
    notifyListeners();
  }

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      pages: [for (var i = 0; i < _stack.length; i++) _pageFor(_stack[i], i)],
      onDidRemovePage: _onDidRemovePage,
    );
  }

  void _onDidRemovePage(Page<Object?> page) {
    final path = page.name;
    if (path != null && _stack.length > 1 && _stack.last == path) {
      _stack.removeLast();
      notifyListeners();
    }
  }

  Page<Object?> _pageFor(String path, int index) {
    return MaterialPage<Object?>(key: ValueKey('$path@$index'), name: path, child: _childFor(path));
  }

  Widget _childFor(String path) {
    final segments = Uri.parse(path).pathSegments;
    // /library/<slug> dynamic segment; unknown slug falls back to the library list.
    if (segments.length == 2 && segments.first == 'library') {
      final article = MockData.articleById(segments[1]);
      if (article != null) return ArticleDetailScreen(article: article);
      return const LibraryScreen();
    }
    // /webview?url=…&title=… in-app legal pages (query carries the target).
    if (segments.isNotEmpty && segments.first == 'webview') {
      final uri = Uri.parse(path);
      return WebViewScreen(title: uri.queryParameters['title'] ?? 'Privacy', url: uri.queryParameters['url'] ?? '');
    }
    switch (path) {
      case '/auth':
        return const JoinScreen();
      case '/privacy':
        return const PrivacyScreen();
      case '/onboarding':
        return const RhythmsScreen();
      case '/dashboard':
        return const MainScreen(initialIndex: 0);
      case '/calendar':
        return const MainScreen(initialIndex: 1);
      case '/insights':
        return const MainScreen(initialIndex: 2);
      case '/coven':
        return const MainScreen(initialIndex: 3);
      case '/profile':
        return const ProfileScreen();
      case '/alerts':
        return const AlertsScreen();
      case '/cycle':
        return const BloodScreen();
      case '/fertility':
        return const FertilityScreen();
      case '/library':
        return const LibraryScreen();
      case '/pregnancy':
        return const GestationScreen();
      case '/chart':
        return const ChartScreen();
      case '/binding':
        return const BindingScreen();
      default:
        // '/' start route and any unknown path recover through the welcome redirect.
        return const WelcomeScreen();
    }
  }
}
