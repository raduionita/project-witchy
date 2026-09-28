import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AlertItem {
  final String title;
  final String body;
  final String time;
  final FaIconData icon;
  final Color badgeBg;
  final Color badgeFg;
  const AlertItem({required this.title, required this.body, required this.time, required this.icon, required this.badgeBg, required this.badgeFg});
}
