import '../../models/period_log.dart';
import '../../models/symptom_log.dart';
import '../storage_service.dart';
import 'store_list_mixin.dart';

/// Persists period and symptom logs together.
class LogsRepository {
  LogsRepository(this._storage);

  final StorageService _storage;

  late final PeriodLogsStore _periodLogs =
      PeriodLogsStore(_storage);
  late final SymptomLogsStore _symptomLogs =
      SymptomLogsStore(_storage);

  PeriodLogsStore get periodLogs => _periodLogs;
  SymptomLogsStore get symptomLogs => _symptomLogs;

  /// Loads both log stores into memory.
  void load() {
    _periodLogs.load();
    _symptomLogs.load();
  }
}

class PeriodLogsStore with PersistedListMixin<PeriodLog> {
  PeriodLogsStore(this._storage);

  final StorageService _storage;

  @override
  StorageService get storage => _storage;

  @override
  String get key => 'period_logs';

  @override
  PeriodLog Function(Map<String, dynamic> json) get fromJson => PeriodLog.fromJson;
}

class SymptomLogsStore with PersistedListMixin<SymptomLog> {
  SymptomLogsStore(this._storage);

  final StorageService _storage;

  @override
  StorageService get storage => _storage;

  @override
  String get key => 'symptom_logs';

  @override
  SymptomLog Function(Map<String, dynamic> json) get fromJson => SymptomLog.fromJson;
}