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
      : _storage = storage,
        profile = ProfileRepository(storage),
        cycles = CycleRepository(storage),
        logs = LogsRepository(storage),
        reminders = ReminderRepository(storage);

  final StorageService _storage;

  /// Underlying storage, shared by feature services that persist directly.
  StorageService get storage => _storage;

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

  /// Permanently removes every stored value and empties the in-memory caches.
  ///
  /// Used by the "clear all data" action in Settings. Clears the raw storage
  /// prefixes first, then resets each repository so subsequent reads observe
  /// a fresh, empty state.
  Future<void> clearAll() async {
    await _storage.clearAll();
    profile.clear();
    await cycles.clear();
    await logs.periodLogs.clear();
    await logs.symptomLogs.clear();
    await reminders.clear();
    notifyListeners();
  }
}