import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/period_cycle.dart';

class DataExportService {
  Future<String> exportCyclesToJson(List<PeriodCycle> cycles) async {
    final exportData = {
      'exportDate': DateTime.now().toIso8601String(),
      'appVersion': '1.0.0',
      'cycles': cycles.map((cycle) => cycle.toJson()).toList(),
    };

    final jsonString = const JsonEncoder.withIndent('  ').convert(exportData);
    return jsonString;
  }

  Future<File?> saveExportToFile(String jsonContent, String filename) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$filename');
      await file.writeAsString(jsonContent);
      return file;
    } catch (e) {
      return null;
    }
  }

  Future<String> generateExportFilename() async {
    final now = DateTime.now();
    return 'witchy_export_${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}.json';
  }

  Future<Map<String, dynamic>> importCyclesFromJson(String jsonString) async {
    try {
      final Map<String, dynamic> data = jsonDecode(jsonString);
      if (data['cycles'] is List) {
        final cycles = (data['cycles'] as List).map((json) {
          return PeriodCycle.fromJson(json as Map<String, dynamic>);
        }).toList();
        return {'success': true, 'cycles': cycles};
      }
      return {'success': false, 'error': 'Invalid format'};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }
}
