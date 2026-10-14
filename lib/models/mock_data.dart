import 'package:flutter/material.dart';
import '../theme/app_icons.dart';
import 'reminder_item.dart';

abstract final class MockData {
  static List<ReminderItem> reminders() => [
        ReminderItem(title: 'Period Reminder', subtitle: 'Bell for the predicted period start', time: '09:00 AM', freq: 'Each bleed day', icon: AppIcons.drop, badgeBg: const Color(0xFFFCE7EF), badgeFg: const Color(0xFFE0517F), enabled: true),
        ReminderItem(title: 'Take Supplements', subtitle: 'Daily supplements timer', time: '08:30 AM', freq: 'Every day', icon: AppIcons.star, badgeBg: const Color(0xFFF3EAF9), badgeFg: const Color(0xFF7B2CBF), enabled: true),
        ReminderItem(title: 'Fertility Window Alert', subtitle: 'Reminder of peak fertility days', time: '07:00 AM', freq: 'Window start', icon: AppIcons.moon, badgeBg: const Color(0xFFF8EED9), badgeFg: const Color(0xFFD9A036), enabled: false),
        ReminderItem(title: 'PMS Reminder', subtitle: 'Prepare for mood shifts', time: '06:00 PM', freq: '3 days prior', icon: AppIcons.zap, badgeBg: const Color(0xFFF3EAF9), badgeFg: const Color(0xFF7B2CBF), enabled: true),
        ReminderItem(title: 'Hydration Reminder', subtitle: 'Drink water regularly', time: '08:00 AM', freq: 'Hourly · 8 AM - 8 PM', icon: AppIcons.drop, badgeBg: const Color(0xFFE3EEF9), badgeFg: const Color(0xFF3E7BC0), enabled: false),
      ];
}
