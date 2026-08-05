import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:witchy/domain/models/daily_log.dart';
import 'package:witchy/domain/repositories/daily_log_repository.dart';
import 'package:witchy/domain/services/symptom_analyzer.dart';
import 'package:uuid/uuid.dart';

class DailyLogProvider extends ChangeNotifier {
  final DailyLogRepository _repository;
  final SymptomTrendAnalyzer _analyzer = SymptomTrendAnalyzer();
  List<DailyLog> _logs = [];

  DailyLogProvider({required DailyLogRepository repository})
      : _repository = repository;

  List<DailyLog> get logs => List.unmodifiable(_logs);
  Map<String, int> get frequentSymptoms => _analyzer.analyzeSymptomFrequency(_logs);

  Future<void> loadLogs() async {
    _logs = await _repository.getAllLogs();
    notifyListeners();
  }

  Future<void> addLog(DailyLog log) async {
    await _repository.saveLog(log);
    _logs.add(log);
    notifyListeners();
  }

  Future<void> deleteLog(String id) async {
    await _repository.deleteLog(id);
    _logs.removeWhere((l) => l.id == id);
    notifyListeners();
  }
}
