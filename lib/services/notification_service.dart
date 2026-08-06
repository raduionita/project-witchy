import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import '../models/notification_model.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    await _plugin.initialize(settings);
  }

  Future<void> scheduleNotification(AppNotification notification) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'witchy_channel',
      'Witchy Notifications',
      channelDescription: 'Period tracker notifications',
      importance: Importance.high,
      priority: Priority.high,
    );
    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();
    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final tz.TZDateTime scheduledDate = tz.TZDateTime.from(
      notification.scheduledDate,
      tz.local,
    );

    await _plugin.zonedSchedule(
      notification.id.hashCode,
      notification.title,
      notification.body,
      scheduledDate,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  Future<void> scheduleAllNotifications(List<AppNotification> notifications) async {
    for (final notification in notifications.where((n) => n.isEnabled)) {
      await scheduleNotification(notification);
    }
  }

  Future<void> cancelNotification(String id) async {
    await _plugin.cancel(id.hashCode);
  }

  Future<void> cancelAllNotifications() async {
    await _plugin.cancelAll();
  }
}
