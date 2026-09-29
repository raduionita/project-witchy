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
}
