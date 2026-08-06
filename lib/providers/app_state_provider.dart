import 'package:flutter/foundation.dart';

import '../services/repositories/cycle_repository.dart';
import '../services/repositories/logs_repository.dart';
import '../services/repositories/profile_repository.dart';
import '../services/repositories/reminder_repository.dart';
import '../services/storage_service.dart';

/// App-wide data facade.
///
/// Owns the [StorageService] and every repository, and exposes them to the
/// widget tree through [ChangeNotifierProvider]. Feature providers consume
/// these repositories rather than touching storage directly.
class AppStateProvider extends ChangeNotifier {
  AppStateProvider(StorageService storage)
      : profile = ProfileRepository(storage),
        cycles = CycleRepository(storage),
        logs = LogsRepository(storage),
        reminders = ReminderRepository(storage);

  final ProfileRepository profile;
  final CycleRepository cycles;
  final LogsRepository logs;
  final ReminderRepository reminders;

  /// Loads all repositories into memory.
  void load() {
    profile.load();
    cycles.load();
    logs.load();
    reminders.load();
  }
}