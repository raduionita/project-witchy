import 'package:flutter/material.dart';
import '../theme/app_icons.dart';
import 'alert_item.dart';
import 'article.dart';
import 'coven_post.dart';
import 'reminder_item.dart';

abstract final class MockData {
  static List<ReminderItem> reminders() => [
        ReminderItem(title: 'Log Period Commencing', subtitle: 'Magical bell for predicted first flow', time: '09:00 AM', freq: 'Daily during peak', icon: AppIcons.drop, badgeBg: const Color(0xFFFCE7EF), badgeFg: const Color(0xFFE0517F), enabled: true),
        ReminderItem(title: 'Take Cosmic Pill', subtitle: 'Daily supplements timer', time: '08:30 AM', freq: 'Every day', icon: AppIcons.star, badgeBg: const Color(0xFFF3EAF9), badgeFg: const Color(0xFF7B2CBF), enabled: true),
        ReminderItem(title: 'Fertility Window Alert', subtitle: 'Reminder of peak biological phase', time: '07:00 AM', freq: 'Window start', icon: AppIcons.moon, badgeBg: const Color(0xFFF8EED9), badgeFg: const Color(0xFFD9A036), enabled: false),
        ReminderItem(title: 'PMS Warning', subtitle: 'Prepare your temple for mood shifts', time: '06:00 PM', freq: '3 days prior', icon: AppIcons.zap, badgeBg: const Color(0xFFF3EAF9), badgeFg: const Color(0xFF7B2CBF), enabled: true),
        ReminderItem(title: 'Somatic Hydration', subtitle: 'Sip restorative botanical water', time: 'Hourly', freq: 'Daytime', icon: AppIcons.drop, badgeBg: const Color(0xFFE3EEF9), badgeFg: const Color(0xFF3E7BC0), enabled: false),
      ];

  static List<AlertItem> alerts() => const [
        AlertItem(title: 'Period Commencing', body: 'Your bleeding phase is predicted to begin in 2 days. Prepare your herbal tea blends.', time: '2 hours ago', icon: AppIcons.drop, badgeBg: Color(0xFFFCE7EF), badgeFg: Color(0xFFE0517F)),
        AlertItem(title: 'Fertility Window Peak', body: 'Your cosmic fertility peaks today under the fertile crescent. High chance of ovulation.', time: '1 day ago', icon: AppIcons.moon, badgeBg: Color(0xFFF8EED9), badgeFg: Color(0xFFD9A036)),
        AlertItem(title: 'Magical Log Missing', body: 'Remember to log your somatic echoes, cramps and emotional currents for cycle day 14.', time: '2 days ago', icon: AppIcons.quill, badgeBg: Color(0xFFF3EAF9), badgeFg: Color(0xFF7B2CBF)),
        AlertItem(title: 'Astrological Milestone', body: 'Full Moon summits in Scorpio. Perfect alignment for meditative reflection.', time: '3 days ago', icon: AppIcons.star, badgeBg: Color(0xFFF3EAF9), badgeFg: Color(0xFF7B2CBF)),
      ];

  static List<CovenPost> posts() => const [
        CovenPost(initials: 'MC', author: 'MoonChild99', meta: 'Anonymously synced · 2h ago', tag: 'Herbal Remedies', body: 'Logged heavy cramps today. Sipping raspberry leaf infusion. If anyone is in their luteal stage, please rest up tonight with a cozy ritual! ✨', likes: 24, comments: 8),
        CovenPost(initials: 'CS', author: 'CrystalSeer', meta: 'Anonymously synced · 6h ago', tag: 'Dream Work', body: 'Is it just me, or does your dream state become incredibly vivid and almost prophetic during the Full Moon / Ovulation Peak? Truly enchanted.', likes: 42, comments: 15),
        CovenPost(initials: 'LG', author: 'LunarGlow', meta: 'Anonymously synced · 1d ago', tag: 'Cosmic Cycle', body: 'Started Bleeding Phase 2 days earlier than estimated cycle clock. Must be the recent Scorpio lunar eclipse affecting my patterns.', likes: 18, comments: 3),
      ];

  static List<Article> articles() => const [
        Article(id: 'luteal-phase', category: 'ANATOMY', readTime: '5 min read', title: 'Understanding Your Luteal Phase', excerpt: 'The autumn of your biology. Why emotions dip and energy turns inward.', thumb: [Color(0xFF7FB2E5), Color(0xFFF3B8D8), Color(0xFFA07FE0)]),
        Article(id: 'cramp-herbs', category: 'BOTANICAL', readTime: '8 min read', title: 'Herbs for Somatic Cramp Relief', excerpt: 'Sip Mugwort, Raspberry Leaf and Ginger through the shedding phase.', thumb: [Color(0xFFC98D4E), Color(0xFF6B3F2A)]),
        Article(id: 'moon-meditation', category: 'MINDFULNESS', readTime: '12 min read', title: 'Moon Cycle Meditation', excerpt: 'Deep meditative practice to align your rhythm with the lunar tide.', thumb: [Color(0xFF8FA6F0), Color(0xFF4A3AA0)]),
        Article(id: 'fertility-window', category: 'LUNAR CYCLE', readTime: '6 min read', title: 'Fertility Window Explained', excerpt: 'Deciphering the peak hormonal flow and ovulation signals.', thumb: [Color(0xFFCAA04A), Color(0xFF6B4A1A)]),
      ];

  static Article? articleById(String id) {
    for (final a in articles()) {
      if (a.id == id) return a;
    }
    return null;
  }
}
