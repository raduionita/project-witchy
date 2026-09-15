import '../../models/biometric_log.dart';
import '../storage_service.dart';
import 'store_list_mixin.dart';

/// Persists per-day biometric & fertility logs.
class BiometricRepository {
  BiometricRepository(this._storage);

  final StorageService _storage;

  late final BiometricLogsStore _biometricLogs =
      BiometricLogsStore(_storage);

  BiometricLogsStore get biometricLogs => _biometricLogs;

  /// Loads the biometric log store into memory.
  void load() {
    _biometricLogs.load();
  }
}

class BiometricLogsStore with PersistedListMixin<BiometricLog> {
  BiometricLogsStore(this._storage);

  final StorageService _storage;

  @override
  StorageService get storage => _storage;

  @override
  String get key => 'biometric_logs';

  @override
  BiometricLog Function(Map<String, dynamic> json) get fromJson =>
      BiometricLog.fromJson;

  @override
  Object? idOf(BiometricLog item) => item.id;
}
