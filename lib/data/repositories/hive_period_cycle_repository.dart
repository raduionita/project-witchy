import 'package:witchy/domain/models/period_cycle.dart';
import 'package:witchy/domain/repositories/period_cycle_repository.dart';
import 'package:witchy/data/services/local_database_service.dart';

class HivePeriodCycleRepository implements PeriodCycleRepository {
  final LocalDatabaseService _databaseService;

  HivePeriodCycleRepository(this._databaseService);

  @override
  Future<List<PeriodCycle>> getAllCycles() async {
    return _databaseService.periodCyclesBox.values.toList();
  }

  @override
  Future<void> saveCycle(PeriodCycle cycle) async {
    await _databaseService.periodCyclesBox.put(cycle.id, cycle);
  }

  @override
  Future<void> deleteCycle(String id) async {
    await _databaseService.periodCyclesBox.delete(id);
  }
}
