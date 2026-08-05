import 'package:witchy/domain/models/period_cycle.dart';

abstract class PeriodCycleRepository {
  Future<List<PeriodCycle>> getAllCycles();
  Future<void> saveCycle(PeriodCycle cycle);
  Future<void> deleteCycle(String id);
}
