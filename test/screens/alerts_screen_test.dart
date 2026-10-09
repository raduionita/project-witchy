import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:witchy/models/alert_item.dart';
import 'package:witchy/models/alert_type.dart';
import 'package:witchy/providers/alert_provider.dart';
import 'package:witchy/screens/alerts_screen.dart';
import 'package:witchy/services/prefs_service.dart';

void main() {
  late PrefsService prefs;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    prefs = PrefsService();
  });

  AlertItem item(String id, {bool read = false, Duration ago = const Duration(hours: 2)}) => AlertItem(
    id: id,
    type: AlertType.periodPredicted,
    title: 'Period Approaching $id',
    body: 'Body for $id',
    createdAt: DateTime.now().subtract(ago),
    eventDate: DateTime.now(),
    read: read,
  );

  Future<AlertProvider> pumpScreen(WidgetTester tester, AlertProvider provider) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<PrefsService>.value(value: prefs),
          ChangeNotifierProvider<AlertProvider>.value(value: provider),
        ],
        child: const MaterialApp(home: AlertsScreen()),
      ),
    );
    await tester.pumpAndSettle();
    return provider;
  }

  testWidgets('renders alert titles with relative time', (tester) async {
    final provider = AlertProvider(prefs, items: [item('a'), item('b', read: true, ago: const Duration(hours: 3))]);
    await pumpScreen(tester, provider);

    expect(find.text('Period Approaching a'), findsOneWidget);
    expect(find.text('Period Approaching b'), findsOneWidget);
    expect(find.text('2 h ago'), findsOneWidget);
    expect(find.text('3 h ago'), findsOneWidget);
    expect(find.text('No whispers yet'), findsNothing);
  });

  testWidgets('tapping an alert marks it read', (tester) async {
    final provider = AlertProvider(prefs, items: [item('a')]);
    await pumpScreen(tester, provider);
    expect(provider.unreadCount, 1);

    await tester.tap(find.text('Period Approaching a'));
    await tester.pumpAndSettle();
    expect(provider.unreadCount, 0);
    expect(provider.items.single.read, isTrue);
  });

  testWidgets('empty inbox shows the empty state', (tester) async {
    final provider = AlertProvider(prefs);
    await pumpScreen(tester, provider);

    expect(find.text('No whispers yet'), findsOneWidget);
    expect(find.text('Period Approaching'), findsNothing);
  });
}
