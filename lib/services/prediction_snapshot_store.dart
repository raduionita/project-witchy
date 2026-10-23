import '../models/prediction_snapshot.dart';
import 'prefs_service.dart';

/// Persists the first prediction seen for each cycle. Snapshots are append-only
/// by cycle start: a later visit or a changed prediction does not replace the
/// original record.
class PredictionSnapshotStore {
  PredictionSnapshotStore(this._prefs, [Iterable<PredictionSnapshot> initial = const []]) {
    _snapshots.addAll(initial);
    _snapshots.sort((a, b) => a.cycleStart.compareTo(b.cycleStart));
  }

  static const int maxSnapshots = 24;

  final PrefsService _prefs;
  final List<PredictionSnapshot> _snapshots = [];

  static Future<PredictionSnapshotStore> load(PrefsService prefs) async {
    final saved = await prefs.predictionSnapshots();
    return PredictionSnapshotStore(prefs, saved);
  }

  List<PredictionSnapshot> get snapshots => List.unmodifiable(_snapshots);

  Future<void> record(PredictionSnapshot snapshot) async {
    final cycleStart = _day(snapshot.cycleStart);
    if (_snapshots.any((saved) => _sameDay(saved.cycleStart, cycleStart))) return;
    _snapshots.add(snapshot);
    _snapshots.sort((a, b) => a.cycleStart.compareTo(b.cycleStart));
    if (_snapshots.length > maxSnapshots) {
      _snapshots.removeRange(0, _snapshots.length - maxSnapshots);
    }
    await _prefs.savePredictionSnapshots(_snapshots);
  }

  static DateTime _day(DateTime date) => DateTime(date.year, date.month, date.day);

  static bool _sameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;
}
