import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:witchy/models/prediction_snapshot.dart';
import 'package:witchy/services/prediction_snapshot_store.dart';
import 'package:witchy/services/prefs_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late PrefsService prefs;
  late PredictionSnapshotStore store;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = PrefsService();
    store = await PredictionSnapshotStore.load(prefs);
  });

  PredictionSnapshot snapshot(DateTime cycleStart, {DateTime? earliest}) => PredictionSnapshot(
    cycleStart: cycleStart,
    earliest: earliest ?? DateTime(cycleStart.year, cycleStart.month, cycleStart.day + 28),
    latest: DateTime(cycleStart.year, cycleStart.month, cycleStart.day + 30),
    recordedAt: DateTime(cycleStart.year, cycleStart.month, cycleStart.day + 1),
    peak: DateTime(cycleStart.year, cycleStart.month, cycleStart.day + 14),
    fertileStart: DateTime(cycleStart.year, cycleStart.month, cycleStart.day + 9),
    fertileEnd: DateTime(cycleStart.year, cycleStart.month, cycleStart.day + 15),
  );

  test('records a snapshot and reloads it from prefs', () async {
    await store.record(snapshot(DateTime(2026, 9, 20)));

    final reloaded = await PredictionSnapshotStore.load(prefs);

    expect(reloaded.snapshots, hasLength(1));
    expect(reloaded.snapshots.single.cycleStart, DateTime(2026, 9, 20));
    expect(reloaded.snapshots.single.peak, DateTime(2026, 10, 4));
  });

  test('keeps the first snapshot for a cycle and ignores a later one', () async {
    await store.record(snapshot(DateTime(2026, 9, 20), earliest: DateTime(2026, 10, 18)));
    await store.record(snapshot(DateTime(2026, 9, 20), earliest: DateTime(2026, 10, 20)));

    expect(store.snapshots, hasLength(1));
    expect(store.snapshots.single.earliest, DateTime(2026, 10, 18));
  });

  test('treats different times on the same day as the same cycle', () async {
    await store.record(snapshot(DateTime(2026, 9, 20, 8)));
    await store.record(snapshot(DateTime(2026, 9, 20, 21)));

    expect(store.snapshots, hasLength(1));
  });

  test('caps history at 24 snapshots and drops the oldest', () async {
    for (var i = 0; i < 26; i++) {
      await store.record(snapshot(DateTime(2025, 1, 1 + i * 30)));
    }

    expect(store.snapshots, hasLength(PredictionSnapshotStore.maxSnapshots));
    expect(store.snapshots.first.cycleStart, DateTime(2025, 3, 2));
    expect(store.snapshots.last.cycleStart, DateTime(2027, 1, 21));
  });
}
