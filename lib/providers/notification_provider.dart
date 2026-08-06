import 'package:flutter/foundation.dart';
import '../models/notification_model.dart';
import '../services/storage_service.dart';
import '../services/notification_service.dart';

class NotificationProvider extends ChangeNotifier {
  final StorageService _storageService;
  final NotificationService _notificationService;
  List<AppNotification> _notifications = [];
  bool _isLoading = false;

  NotificationProvider(this._storageService, this._notificationService) {
    _loadNotifications();
  }

  List<AppNotification> get notifications => _notifications;
  bool get isLoading => _isLoading;

  Future<void> _loadNotifications() async {
    _isLoading = true;
    notifyListeners();

    _notifications = await _storageService.getNotifications();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addNotification(AppNotification notification) async {
    _notifications.add(notification);
    await _storageService.saveNotifications(_notifications);
    await _notificationService.scheduleNotification(notification);
    notifyListeners();
  }

  Future<void> updateNotification(AppNotification notification) async {
    final index = _notifications.indexWhere((n) => n.id == notification.id);
    if (index != -1) {
      _notifications[index] = notification;
      await _storageService.saveNotifications(_notifications);
      if (notification.isEnabled) {
        await _notificationService.scheduleNotification(notification);
      } else {
        await _notificationService.cancelNotification(notification.id);
      }
      notifyListeners();
    }
  }

  Future<void> deleteNotification(String id) async {
    _notifications.removeWhere((n) => n.id == id);
    await _storageService.saveNotifications(_notifications);
    await _notificationService.cancelNotification(id);
    notifyListeners();
  }

  Future<void> toggleNotification(String id, bool isEnabled) async {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isEnabled: isEnabled);
      await _storageService.saveNotifications(_notifications);
      if (isEnabled) {
        await _notificationService.scheduleNotification(_notifications[index]);
      } else {
        await _notificationService.cancelNotification(id);
      }
      notifyListeners();
    }
  }
}
