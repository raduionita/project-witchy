import '../../models/cycle.dart';
import '../storage_service.dart';
import 'store_list_mixin.dart';

/// Persists the list of [Cycle] records.
class CycleRepository with PersistedListMixin<Cycle> {
  CycleRepository(this._storage);

  final StorageService _storage;

  @override
  StorageService get storage => _storage;

  @override
  String get key => 'cycles';

  @override
  Cycle Function(Map<String, dynamic> json) get fromJson => Cycle.fromJson;

  /// All cycles ordered newest-first.
  List<Cycle> get cyclesSorted =>
      List<Cycle>.from(items)..sort((Cycle a, Cycle b) => b.startDate.compareTo(a.startDate));

  /// The most recent cycle, or null when none exist.
  Cycle? get latest => cyclesSorted.isEmpty ? null : cyclesSorted.first;
}