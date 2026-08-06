import 'package:flutter_test/flutter_test.dart';

import 'package:witchy/main.dart';
import 'package:witchy/services/storage_service.dart';
import 'package:witchy/services/cycle_service.dart';
import 'package:witchy/services/notification_service.dart';

void main() {
  testWidgets('App initialization test', (WidgetTester tester) async {
    final storageService = StorageService();
    final cycleService = CycleService();
    final notificationService = NotificationService();

    await tester.pumpWidget(
      WitchyApp(
        storageService: storageService,
        cycleService: cycleService,
        notificationService: notificationService,
      ),
    );

    expect(find.byType(WitchyApp), findsOneWidget);
  });
}
