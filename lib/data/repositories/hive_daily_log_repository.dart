import 'package:witchy/domain/models/daily_log.dart';
import 'package:witchy/domain/repositories/daily_log_repository.dart';
import 'package:witchy/data/services/local_database_service.dart';

class HiveDailyLogRepository implements DailyLogRepository {
  final LocalDatabaseService _databaseService;

  HiveDailyLogRepository(this._databaseService);

  @override
  Future<List<DailyLog>> getAllLogs() async {
    return _databaseService.dailyLogsBox.values.toList();
  }

  @override
  Future<void> saveLog(DailyLog log) async {
    await _databaseService.dailyLogsBox.put(log.id, log);
  }

  @override
  Future<void> deleteLog(String id) async {
    await _databaseService.dailyLogsBox.delete(id);
  }
}
