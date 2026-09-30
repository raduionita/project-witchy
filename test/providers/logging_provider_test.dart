import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:witchy/providers/logging_provider.dart';
import 'package:witchy/services/prefs_service.dart';

void main() {
  late PrefsService prefs;
  late LoggingProvider provider;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = PrefsService();
    provider = await LoggingProvider.load(prefs);
  });

  test('peekDay does not materialize an entry for an unlogged day', () {
    final day = DateTime(2026, 9, 20);
    expect(provider.peekDay(day), isNull);
    expect(provider.hasLog(day), isFalse);
    expect(provider.snapshot(), isEmpty);
  });

  test('mutators create the entry with flow None default', () {
    final day = DateTime(2026, 9, 20);
    provider.toggleMood(day, 'Enchanted');
    final entry = provider.peekDay(day);
    expect(entry, isNotNull);
    expect(entry!.flow, 'None');
    expect(entry.moods, {'Enchanted'});
  });

  test('deleteDay removes the entry entirely', () async {
    final day = DateTime(2026, 9, 20);
    provider.setFlow(day, 'Heavy');
    expect(provider.hasLog(day), isTrue);
    provider.deleteDay(day);
    expect(provider.hasLog(day), isFalse);
    expect(provider.peekDay(day), isNull);
    await Future<void>.delayed(const Duration(milliseconds: 20));
    final restored = await LoggingProvider.load(prefs);
    expect(restored.hasLog(day), isFalse);
  });

  test('snapshot returns date-keyed entries round-tripping keyFor', () {
    final day = DateTime(2026, 9, 5);
    provider.setFlow(day, 'Light');
    final snap = provider.snapshot();
    expect(snap.keys, contains(DateTime(2026, 9, 5)));
    expect(snap[DateTime(2026, 9, 5)]!.flow, 'Light');
  });

  test('restoreDay reverts mutations to the original snapshot copy', () async {
    final day = DateTime(2026, 9, 20);
    provider.setFlow(day, 'Heavy');
    provider.toggleMood(day, 'Enchanted');
    provider.setNotes(day, 'before');
    final original = provider.peekDay(day)!.copy();

    // Simulate edits made while the sheet is open.
    provider.setFlow(day, 'Light');
    provider.toggleMood(day, 'Restless');
    provider.setPain(day, 2);
    provider.setNotes(day, 'after');

    provider.restoreDay(day, original);
    final entry = provider.peekDay(day)!;
    expect(entry.flow, 'Heavy');
    expect(entry.moods, {'Enchanted'});
    expect(entry.pain, 6);
    expect(entry.notes, 'before');
    await Future<void>.delayed(const Duration(milliseconds: 20));
    final restored = await LoggingProvider.load(prefs);
    expect(restored.peekDay(day)!.flow, 'Heavy');
  });

  test('restoreDay with null removes an entry created during editing', () {
    final day = DateTime(2026, 9, 20);
    expect(provider.hasLog(day), isFalse);

    // No log existed when editing started; edits create one.
    provider.setFlow(day, 'Heavy');
    provider.setNotes(day, 'new entry');
    provider.restoreDay(day, null);

    expect(provider.hasLog(day), isFalse);
    expect(provider.peekDay(day), isNull);
  });
}
