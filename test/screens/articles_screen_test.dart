import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:witchy/navigation/app_router_delegate.dart';
import 'package:witchy/navigation/app_router_scope.dart';
import 'package:witchy/screens/articles_screen.dart';
import 'package:witchy/services/feed_service.dart';
import 'package:witchy/services/prefs_service.dart';

List<Map<String, Object?>> _cacheJson() => [
      {'title': 'Understanding Your Luteal Phase', 'link': 'https://qvonyx.com/witchy/articles/luteal-phase.html', 'description': 'The autumn of your biology.', 'category': 'ANATOMY', 'pubDate': '2026-10-05T08:00:00.000Z'},
      {'title': 'Herbs for Somatic Cramp Relief', 'link': 'https://qvonyx.com/witchy/articles/cramp-herbs.html', 'description': 'Sip Mugwort and Raspberry Leaf.', 'category': 'BOTANICAL', 'pubDate': null},
    ];

Future<AppRouterDelegate> _pumpFeed(WidgetTester tester, {Map<String, Object>? initial}) async {
  SharedPreferences.setMockInitialValues(initial ?? {'witchy_feed_cache': jsonEncode(_cacheJson())});
  final prefs = PrefsService();
  final delegate = AppRouterDelegate();
  await tester.pumpWidget(
    MultiProvider(
      providers: [Provider<PrefsService>.value(value: prefs)],
      child: AppRouterScope(
        delegate: delegate,
        child: MaterialApp(home: ArticlesScreen(feed: FeedService(prefs))),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return delegate;
}

void main() {
  testWidgets('renders cached feed articles without tabs or a FAB', (WidgetTester tester) async {
    await _pumpFeed(tester);

    expect(find.text('Understanding Your Luteal Phase'), findsOneWidget);
    expect(find.text('Herbs for Somatic Cramp Relief'), findsOneWidget);
    expect(find.text('ANATOMY'), findsOneWidget);
    expect(find.text('BOTANICAL'), findsOneWidget);
    expect(find.text('Recent Whispers'), findsNothing);
    expect(find.text("Ancients' Wisdom"), findsNothing);
    expect(find.byType(FloatingActionButton), findsNothing);
  });

  testWidgets('tapping an article navigates to the webview route', (WidgetTester tester) async {
    final delegate = await _pumpFeed(tester);

    await tester.tap(find.text('Understanding Your Luteal Phase'));
    await tester.pumpAndSettle();

    final route = delegate.currentConfiguration;
    expect(route, startsWith('/webview?'));
    expect(route, contains(Uri.encodeComponent('Understanding Your Luteal Phase')));
    expect(route, contains(Uri.encodeComponent('https://qvonyx.com/witchy/articles/luteal-phase.html')));
  });

  testWidgets('shows the empty state when the feed cannot be loaded', (WidgetTester tester) async {
    await _pumpFeed(tester, initial: {});

    expect(find.text('No articles yet'), findsOneWidget);
    expect(find.textContaining('Articles could not be loaded'), findsOneWidget);
    expect(find.text('Try again'), findsOneWidget);
    // The local about card still gives the screen at least one entry.
    expect(find.text('Witchy'), findsOneWidget);
  });

  testWidgets('local about card is always last and never opens an article', (WidgetTester tester) async {
    final delegate = await _pumpFeed(tester);

    expect(find.text('Witchy'), findsOneWidget);
    final texts = tester.widgetList<Text>(find.byType(Text)).map((t) => t.data).toList();
    expect(texts.indexOf('Witchy'), greaterThan(texts.indexOf('Herbs for Somatic Cramp Relief')));

    await tester.tap(find.text('Witchy'));
    await tester.pumpAndSettle();
    expect(delegate.currentConfiguration, isNot(startsWith('/webview')));
  });
}
