import '../../models/reminder.dart';
import '../storage_service.dart';
import 'store_list_mixin.dart';

/// Persists the list of [Reminder] records.
class ReminderRepository with PersistedListMixin<Reminder> {
  ReminderRepository(this._storage);

  final StorageService _storage;

  @override
  StorageService get storage => _storage;

  @override
  String get key => 'reminders';

  @override
  Reminder Function(Map<String, dynamic> json) get fromJson => Reminder.fromJson;

  /// Only reminders that are currently enabled.
  List<Reminder> get enabled =>
      items.where((Reminder r) => r.enabled).toList();
}