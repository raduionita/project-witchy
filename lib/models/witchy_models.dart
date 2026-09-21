import 'package:flutter/material.dart';

class CycleSettings {
  final DateTime lastPeriodStart;
  final int cycleLength;
  final int bleedLength;
  const CycleSettings({required this.lastPeriodStart, this.cycleLength = 28, this.bleedLength = 5});

  CycleSettings copyWith({DateTime? lastPeriodStart, int? cycleLength, int? bleedLength}) => CycleSettings(
        lastPeriodStart: lastPeriodStart ?? this.lastPeriodStart,
        cycleLength: cycleLength ?? this.cycleLength,
        bleedLength: bleedLength ?? this.bleedLength,
      );
}

class ReminderItem {
  final String title;
  final String subtitle;
  final String time;
  final String freq;
  final IconData icon;
  final Color badgeBg;
  final Color badgeFg;
  bool enabled;
  ReminderItem({required this.title, required this.subtitle, required this.time, required this.freq, required this.icon, required this.badgeBg, required this.badgeFg, this.enabled = true});
}

class AlertItem {
  final String title;
  final String body;
  final String time;
  final IconData icon;
  final Color badgeBg;
  final Color badgeFg;
  const AlertItem({required this.title, required this.body, required this.time, required this.icon, required this.badgeBg, required this.badgeFg});
}

class CovenPost {
  final String initials;
  final String author;
  final String meta;
  final String tag;
  final String body;
  final int likes;
  final int comments;
  const CovenPost({required this.initials, required this.author, required this.meta, required this.tag, required this.body, required this.likes, required this.comments});
}

class Article {
  final String category;
  final String readTime;
  final String title;
  final String excerpt;
  final List<Color> thumb;
  const Article({required this.category, required this.readTime, required this.title, required this.excerpt, required this.thumb});
}

abstract final class MockData {
  static List<ReminderItem> reminders() => [
        ReminderItem(title: 'Log Period Commencing', subtitle: 'Magical bell for predicted first flow', time: '09:00 AM', freq: 'Daily during peak', icon: Icons.water_drop_outlined, badgeBg: const Color(0xFFFCE7EF), badgeFg: const Color(0xFFE0517F), enabled: true),
        ReminderItem(title: 'Take Cosmic Pill', subtitle: 'Daily supplements timer', time: '08:30 AM', freq: 'Every day', icon: Icons.star_border, badgeBg: const Color(0xFFF3EAF9), badgeFg: const Color(0xFF7B2CBF), enabled: true),
        ReminderItem(title: 'Fertility Window Alert', subtitle: 'Reminder of peak biological phase', time: '07:00 AM', freq: 'Window start', icon: Icons.dark_mode_outlined, badgeBg: const Color(0xFFF8EED9), badgeFg: const Color(0xFFD9A036), enabled: false),
        ReminderItem(title: 'PMS Warning', subtitle: 'Prepare your temple for mood shifts', time: '06:00 PM', freq: '3 days prior', icon: Icons.bolt_outlined, badgeBg: const Color(0xFFF3EAF9), badgeFg: const Color(0xFF7B2CBF), enabled: true),
        ReminderItem(title: 'Somatic Hydration', subtitle: 'Sip restorative botanical water', time: 'Hourly', freq: 'Daytime', icon: Icons.water_drop_outlined, badgeBg: const Color(0xFFE3EEF9), badgeFg: const Color(0xFF3E7BC0), enabled: false),
      ];

  static List<AlertItem> alerts() => const [
        AlertItem(title: 'Period Commencing', body: 'Your bleeding phase is predicted to begin in 2 days. Prepare your herbal tea blends.', time: '2 hours ago', icon: Icons.water_drop_outlined, badgeBg: Color(0xFFFCE7EF), badgeFg: Color(0xFFE0517F)),
        AlertItem(title: 'Fertility Window Peak', body: 'Your cosmic fertility peaks today under the fertile crescent. High chance of ovulation.', time: '1 day ago', icon: Icons.dark_mode_outlined, badgeBg: Color(0xFFF8EED9), badgeFg: Color(0xFFD9A036)),
        AlertItem(title: 'Magical Log Missing', body: 'Remember to log your somatic echoes, cramps and emotional currents for cycle day 14.', time: '2 days ago', icon: Icons.edit_note_outlined, badgeBg: Color(0xFFF3EAF9), badgeFg: Color(0xFF7B2CBF)),
        AlertItem(title: 'Astrological Milestone', body: 'Full Moon summits in Scorpio. Perfect alignment for meditative reflection.', time: '3 days ago', icon: Icons.star_border, badgeBg: Color(0xFFF3EAF9), badgeFg: Color(0xFF7B2CBF)),
      ];

  static List<CovenPost> posts() => const [
        CovenPost(initials: 'MC', author: 'MoonChild99', meta: 'Anonymously synced · 2h ago', tag: 'Herbal Remedies', body: 'Logged heavy cramps today. Sipping raspberry leaf infusion. If anyone is in their luteal stage, please rest up tonight with a cozy ritual! ✨', likes: 24, comments: 8),
        CovenPost(initials: 'CS', author: 'CrystalSeer', meta: 'Anonymously synced · 6h ago', tag: 'Dream Work', body: 'Is it just me, or does your dream state become incredibly vivid and almost prophetic during the Full Moon / Ovulation Peak? Truly enchanted.', likes: 42, comments: 15),
        CovenPost(initials: 'LG', author: 'LunarGlow', meta: 'Anonymously synced · 1d ago', tag: 'Cosmic Cycle', body: 'Started Bleeding Phase 2 days earlier than estimated cycle clock. Must be the recent Scorpio lunar eclipse affecting my patterns.', likes: 18, comments: 3),
      ];

  static List<Article> articles() => const [
        Article(category: 'ANATOMY', readTime: '5 min read', title: 'Understanding Your Luteal Phase', excerpt: 'The autumn of your biology. Why emotions dip and energy turns inward.', thumb: [Color(0xFF7FB2E5), Color(0xFFF3B8D8), Color(0xFFA07FE0)]),
        Article(category: 'BOTANICAL', readTime: '8 min read', title: 'Herbs for Somatic Cramp Relief', excerpt: 'Sip Mugwort, Raspberry Leaf and Ginger through the shedding phase.', thumb: [Color(0xFFC98D4E), Color(0xFF6B3F2A)]),
        Article(category: 'MINDFULNESS', readTime: '12 min read', title: 'Moon Cycle Meditation', excerpt: 'Deep meditative practice to align your rhythm with the lunar tide.', thumb: [Color(0xFF8FA6F0), Color(0xFF4A3AA0)]),
        Article(category: 'LUNAR CYCLE', readTime: '6 min read', title: 'Fertility Window Explained', excerpt: 'Deciphering the peak hormonal flow and ovulation signals.', thumb: [Color(0xFFCAA04A), Color(0xFF6B4A1A)]),
      ];
}
