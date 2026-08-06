import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../../l10n/app_localizations.dart';
import '../../models/reminder.dart';
import '../../models/reminder_type.dart';
import '../../providers/app_state_provider.dart';
import '../../providers/cycle_provider.dart';
import 'reminder_defaults.dart';
import 'reminder_scheduler.dart';

/// Reactive facade over persisted reminders and their device notifications.
///
/// Mutations persist through [AppStateProvider.reminders] and immediately
/// reschedule the platform notifications via [ReminderScheduler]. Period-based
/// reminders re-anchor whenever the cycle prediction changes.
class ReminderProvider extends ChangeNotifier {
  ReminderProvider(this._state, this._scheduler, {CycleProvider? cycle})
      : _cycle = cycle {
    _cycle?.addListener(_onCycleChanged);
  }

  final AppStateProvider _state;
  final ReminderScheduler _scheduler;
  final CycleProvider? _cycle;
  final Uuid _uuid = const Uuid();

  bool _loaded = false;
  bool _permissionGranted = true;
  bool _permissionRequested = false;

  /// Whether initial scheduling has run.
  bool get loaded => _loaded;

  /// Whether the platform is able to show notifications.
  bool get permissionGranted => _permissionGranted;

  /// All reminders, grouped by type for a stable display order.
  List<Reminder> get reminders {
    final List<Reminder> list = List<Reminder>.from(_state.reminders.items)
      ..sort((Reminder a, Reminder b) {
        final int byType = a.type.index.compareTo(b.type.index);
        return byType != 0 ? byType : a.title.compareTo(b.title);
      });
    return list;
  }

  DateTime? get _nextPeriodStart => _cycle?.prediction?.nextPeriodStart;

  int get _periodLength =>
      _state.profile.profile?.averagePeriodLength ?? 5;

  /// Loads persisted reminders and schedules their notifications.
  Future<void> load() async {
    _loaded = true;
    await rescheduleAll();
    notifyListeners();
  }

  /// Requests notification permission and records the outcome.
  Future<bool> requestPermissions() async {
    _permissionRequested = true;
    final bool granted = await _scheduler.requestPermissions();
    _permissionGranted = granted;
    notifyListeners();
    return granted;
  }

  /// Requests permission once per app session; returns the current status.
  Future<bool> ensurePermissions() {
    if (_permissionRequested) return Future.value(_permissionGranted);
    return requestPermissions();
  }

  /// Creates or updates [reminder] and schedules its notifications.
  Future<void> save(Reminder reminder) async {
    await _state.reminders.upsert(reminder);
    await _scheduleWithPrediction(reminder);
    notifyListeners();
  }

  /// Creates a new reminder pre-filled for [type] and saves it.
  Future<Reminder> create(AppLocalizations l10n, ReminderType type) async {
    final Reminder reminder = ReminderDefaults.forType(
      l10n,
      type,
      id: _uuid.v4(),
    );
    await save(reminder);
    return reminder;
  }

  /// Removes the reminder with [id] and cancels its notifications.
  Future<void> remove(String id) async {
    final Reminder? reminder = _byId(id);
    if (reminder == null) return;
    await _state.reminders.remove(reminder);
    await _scheduler.cancel(reminder);
    notifyListeners();
  }

  /// Enables/disables [id] and syncs notifications.
  Future<void> setEnabled(String id, bool enabled) async {
    final Reminder? reminder = _byId(id);
    if (reminder == null) return;
    final Reminder updated = reminder.copyWith(enabled: enabled);
    await _state.reminders.upsert(updated);
    await _scheduleWithPrediction(updated);
    notifyListeners();
  }

  /// Re-schedules every persisted reminder (used at load and mode changes).
  Future<void> rescheduleAll() async {
    await _scheduler.cancelAll();
    for (final Reminder reminder in _state.reminders.items) {
      await _scheduleWithPrediction(reminder);
    }
  }

  Future<void> _scheduleWithPrediction(Reminder reminder) =>
      _scheduler.schedule(
        reminder,
        nextPeriodStart: _nextPeriodStart,
        periodLength: _periodLength,
      );

  Future<void> _onCycleChanged() async {
    if (!_loaded) return;
    for (final Reminder reminder
        in _state.reminders.items.where(
            (Reminder r) => ReminderDefaults.isPeriodBased(r.type))) {
      await _scheduleWithPrediction(reminder);
    }
  }

  Reminder? _byId(String id) {
    for (final Reminder reminder in _state.reminders.items) {
      if (reminder.id == id) return reminder;
    }
    return null;
  }

  @override
  void dispose() {
    _cycle?.removeListener(_onCycleChanged);
    super.dispose();
  }
}
