import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:witchy/common/date_format.dart';
import 'package:witchy/providers/onboarding_provider.dart';
import 'package:witchy/screens/onboarding_screen.dart';
import 'package:witchy/services/prefs_service.dart';
import 'package:witchy/widgets/app_button.dart';

/// The month before the current one, so picked days are always in the past.
DateTime previousMonth() {
  final now = DateTime.now();
  return DateTime(now.year, now.month - 1);
}

void main() {
  late PrefsService prefs;
  late OnboardingProvider onboarding;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    prefs = PrefsService();
    onboarding = OnboardingProvider(prefs);
  });

  Future<void> pumpOnboarding(WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<PrefsService>.value(value: prefs),
          ChangeNotifierProvider<OnboardingProvider>.value(value: onboarding),
        ],
        child: const MaterialApp(home: OnboardingScreen()),
      ),
    );
    await tester.pumpAndSettle();
  }

  Key dayKey(DateTime month, int day) =>
      Key('period-day-${month.year}-${month.month}-$day');

  /// Opens the calendar sheet and picks the first two days of the previous
  /// month, which are always in the past.
  Future<void> pickPreviousMonthRange(WidgetTester tester) async {
    await tester.tap(find.text('Add past period').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('period-prev-month')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(dayKey(previousMonth(), 1)));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(dayKey(previousMonth(), 2)));
    await tester.pumpAndSettle();
  }

  Future<void> saveSheet(WidgetTester tester) async {
    await tester.ensureVisible(find.text('Save period'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save period'));
    await tester.pumpAndSettle();
  }

  testWidgets('keeps the tracking question and drops the goal question', (
    tester,
  ) async {
    await pumpOnboarding(tester);
    expect(find.text('What to track'), findsOneWidget);
    expect(find.text('Your goal'), findsNothing);
    expect(find.text('What brings you here?'), findsNothing);
  });

  testWidgets('the past periods card starts empty and blocks Get Started', (
    tester,
  ) async {
    await pumpOnboarding(tester);
    expect(find.text('Past periods'), findsOneWidget);
    expect(find.text('0 of 7 periods'), findsOneWidget);
    expect(find.text('Add past period'), findsOneWidget);
    final addPast = tester.widget<AppButton>(find.widgetWithText(AppButton, 'Add past period'));
    expect(addPast.compact, isTrue);
    expect(find.text('Estimated'), findsNothing);
    expect(find.text('Add at least one past period to continue.'), findsOneWidget);
    expect(find.text('Pick your last period date to continue.'), findsNothing);

    final button = tester.widget<AppButton>(
      find.widgetWithText(AppButton, 'Get Started'),
    );
    expect(button.onTap, isNull);
  });

  testWidgets('adds a period range and shows the full range', (tester) async {
    await pumpOnboarding(tester);
    await pickPreviousMonthRange(tester);
    await saveSheet(tester);

    final start = DateTime(previousMonth().year, previousMonth().month, 1);
    final end = DateTime(previousMonth().year, previousMonth().month, 2);
    expect(find.text(AppDate.longRange(start, end)), findsOneWidget);
    expect(find.text('1 of 7 periods'), findsOneWidget);
    expect(find.text('Estimated'), findsNothing);
    expect(onboarding.pastPeriods, hasLength(1));
    expect(onboarding.pastPeriods.single.start, start);
    expect(onboarding.pastPeriods.single.end, end);
    // The newest start anchors the cycle.
    expect(onboarding.lastPeriodStart, start);

    final button = tester.widget<AppButton>(
      find.widgetWithText(AppButton, 'Get Started'),
    );
    expect(button.onTap, isNotNull);
  });

  testWidgets('the sheet is cancelled without adding anything', (tester) async {
    await pumpOnboarding(tester);
    await tester.tap(find.text('Add past period').last);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Cancel'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(onboarding.pastPeriods, isEmpty);
    expect(find.text('0 of 7 periods'), findsOneWidget);
  });

  testWidgets('a period can be removed and restored with undo', (tester) async {
    await pumpOnboarding(tester);
    await pickPreviousMonthRange(tester);
    await saveSheet(tester);
    expect(onboarding.pastPeriods, hasLength(1));

    await tester.tap(find.byTooltip('Remove'));
    await tester.pumpAndSettle();
    expect(onboarding.pastPeriods, isEmpty);
    expect(find.text('0 of 7 periods'), findsOneWidget);

    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();
    expect(onboarding.pastPeriods, hasLength(1));
    expect(find.text('1 of 7 periods'), findsOneWidget);
  });

  testWidgets('a period can be edited from its row', (tester) async {
    await pumpOnboarding(tester);
    await pickPreviousMonthRange(tester);
    await saveSheet(tester);

    final start = DateTime(previousMonth().year, previousMonth().month, 1);
    final end = DateTime(previousMonth().year, previousMonth().month, 2);
    expect(find.text(AppDate.longRange(start, end)), findsOneWidget);

    await tester.tap(find.text(AppDate.longRange(start, end)));
    await tester.pumpAndSettle();
    // The sheet opens on the edited range.
    expect(find.text('Edit past period'), findsOneWidget);
    // A tap starts a new selection, so the first day is picked again.
    await tester.tap(find.byKey(dayKey(previousMonth(), 1)));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(dayKey(previousMonth(), 4)));
    await tester.pumpAndSettle();
    await saveSheet(tester);

    final newEnd = DateTime(previousMonth().year, previousMonth().month, 4);
    expect(find.text(AppDate.longRange(start, newEnd)), findsOneWidget);
    expect(onboarding.pastPeriods.single.end, newEnd);
  });

  testWidgets('a second period can be added and the list stays newest first', (
    tester,
  ) async {
    await pumpOnboarding(tester);
    await pickPreviousMonthRange(tester);
    await saveSheet(tester);

    // The second period is 20 days after the first one.
    final secondStart = DateTime(previousMonth().year, previousMonth().month, 21);
    final secondEnd = DateTime(previousMonth().year, previousMonth().month, 24);
    await tester.tap(find.text('Add past period').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('period-prev-month')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(dayKey(previousMonth(), 21)));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(dayKey(previousMonth(), 24)));
    await tester.pumpAndSettle();
    await saveSheet(tester);

    expect(onboarding.pastPeriods, hasLength(2));
    expect(onboarding.pastPeriods.first.start, secondStart);
    expect(onboarding.pastPeriods.last.start, DateTime(previousMonth().year, previousMonth().month, 1));
    expect(find.text('2 of 7 periods'), findsOneWidget);
    expect(find.text(AppDate.longRange(secondStart, secondEnd)), findsOneWidget);
  });

  testWidgets('the sheet blocks a range that is too close to another one', (
    tester,
  ) async {
    await pumpOnboarding(tester);
    await pickPreviousMonthRange(tester);
    await saveSheet(tester);

    await tester.tap(find.text('Add past period').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('period-prev-month')));
    await tester.pumpAndSettle();
    // Ten days after the first start is inside the 15 day window, so the day
    // cannot be picked at all.
    await tester.tap(find.byKey(dayKey(previousMonth(), 10)));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('period-range-summary')), findsOneWidget);
    expect(
      tester.widget<Text>(find.byKey(const Key('period-range-summary'))).data,
      'Tap a day to choose the first day.',
    );
  });
}
