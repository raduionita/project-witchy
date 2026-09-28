import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ReminderItem {
  final String title;
  final String subtitle;
  final String time;
  final String freq;
  final FaIconData icon;
  final Color badgeBg;
  final Color badgeFg;
  bool enabled;
  ReminderItem({required this.title, required this.subtitle, required this.time, required this.freq, required this.icon, required this.badgeBg, required this.badgeFg, this.enabled = true});
}
