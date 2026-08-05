import 'package:witchy/domain/models/daily_log.dart';

abstract class DailyLogRepository {
  Future<List<DailyLog>> getAllLogs();
  Future<void> saveLog(DailyLog log);
  Future<void> deleteLog(String id);
}
