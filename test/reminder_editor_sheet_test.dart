import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:witchy/features/reminders/widgets/reminder_editor_sheet.dart';
import 'package:witchy/l10n/app_localizations.dart';
import 'package:witchy/models/reminder.dart';
import 'package:witchy/models/reminder_type.dart';
import 'package:witchy/models/time_of_day_model.dart';

/// Host that opens the editor sheet and shows the returned [Reminder].
class _EditorHost extends StatefulWidget {
  const _EditorHost({this.reminder});

  final Reminder? reminder;

  @override
  State<_EditorHost> createState() => _EditorHostState();
}

class _EditorHostState extends State<_EditorHost> {
  Reminder? _result;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () async {
                final Reminder? result = await ReminderEditorSheet.show(
                  context,
                  reminder: widget.reminder,
                );
                if (result == null) return;
                setState(() => _result = result);
              },
              child: const Text('open editor'),
            ),
            if (_result != null)
              Text('saved:${_result!.title}:${_result!.type.name}'),
          ],
        ),
      ),
    );
  }
}

void main() {
  Future<void> pumpEditor(
    WidgetTester tester, {
    Reminder? reminder,
  }) async {
    tester.view.physicalSize = const Size(800, 1800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: _EditorHost(reminder: reminder),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> openEditor(WidgetTester tester) async {
    await tester.tap(find.text('open editor'));
    await tester.pumpAndSettle();
  }

  testWidgets('switching to a period-based type hides weekdays and saves '
      'without them', (WidgetTester tester) async {
    await pumpEditor(tester);
    await openEditor(tester);

    expect(find.text('New reminder'), findsOneWidget);
    expect(find.byType(FilterChip), findsWidgets);

    await tester.tap(find.byType(DropdownButtonFormField<ReminderType>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Period start').last);
    await tester.pumpAndSettle();

    expect(find.byType(FilterChip), findsNothing);
    expect(
      find.text('This reminder follows your predicted period dates.'),
      findsOneWidget,
    );

    await tester.tap(find.text('Save reminder'));
    await tester.pumpAndSettle();

    expect(find.text('saved:Period coming up:periodStart'), findsOneWidget);
  });

  testWidgets('weekly reminders require at least one weekday',
      (WidgetTester tester) async {
    await pumpEditor(tester);
    await openEditor(tester);

    // Deselect every weekday for the default custom reminder.
    for (final String day in <String>[
      'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun',
    ]) {
      await tester.tap(find.text(day));
      await tester.pumpAndSettle();
    }

    await tester.tap(find.text('Save reminder'));
    await tester.pumpAndSettle();
    expect(find.text('Pick at least one day for this reminder.'),
        findsOneWidget);
    // The sheet stays open and nothing was saved.
    expect(find.text('saved:Reminder:custom'), findsNothing);

    await tester.tap(find.text('Mon'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save reminder'));
    await tester.pumpAndSettle();

    expect(find.text('saved:Reminder:custom'), findsOneWidget);
  });

  testWidgets('editing keeps the original type and hides the type picker',
      (WidgetTester tester) async {
    await pumpEditor(
      tester,
      reminder: Reminder(
        id: 'r1',
        type: ReminderType.water,
        title: 'Water',
        body: 'Drink up',
        time: const TimeOfDayModel(hour: 10, minute: 0),
        weekday: const <int>[1, 2, 3],
      ),
    );
    await openEditor(tester);

    expect(find.text('Edit reminder'), findsOneWidget);
    expect(
      find.byType(DropdownButtonFormField<ReminderType>),
      findsNothing,
    );

    await tester.enterText(find.byType(TextField).first, 'Hydrate');
    await tester.tap(find.text('Save reminder'));
    await tester.pumpAndSettle();

    expect(find.text('saved:Hydrate:water'), findsOneWidget);
  });

  testWidgets('tapping the time row opens the time picker',
      (WidgetTester tester) async {
    await pumpEditor(tester);
    await openEditor(tester);

    await tester.tap(find.text('Time'));
    await tester.pumpAndSettle();

    expect(find.text('OK'), findsOneWidget);

    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(find.byType(ReminderEditorSheet), findsOneWidget);
  });
}