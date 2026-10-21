import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// Mock icon scale from `resources/Qwen_html_*.html` (`.ic`, `.ic.s`, …).
abstract final class AppIconSize {
  static const double xs = 12; // .ic.xs
  static const double sm = 14; // .ic.s
  static const double row = 15; // .drow .ic
  static const double head = 16; // .mhead / .calhead .ic
  static const double base = 20; // .ic
  static const double mid = 22; // .ic
  static const double lg = 26; // .ic.l
  static const double xl = 42; // .ic.xl
}

/// Maps the HTML SVG symbols to Font Awesome icons.
/// Prefers Regular (outline) glyphs to match the mock's uniform stroke look;
/// falls back to Solid only where Font Awesome free has no outline variant.
abstract final class AppIcons {
  // structure / chrome
  static const menu = FontAwesomeIcons.bars; // i-menu (solid-only)
  static const filter = FontAwesomeIcons.sliders; // i-filter (solid-only)
  static const check = FontAwesomeIcons.check; // i-check (solid-only)
  static const plus = FontAwesomeIcons.plus; // i-plus (solid-only)
  static const back = FontAwesomeIcons.solidHandPointLeft; // i-cl (solid-only)
  // Material glyphs: FA chevron/chart/pregnancy render as tofu on web builds.
  static const left = Icons.chevron_left;
  static const right = Icons.chevron_right;
  static const arrow = Icons.arrow_back;
  static const gear = FontAwesomeIcons.gear; // i-gear (solid-only)
  static const cancel = FontAwesomeIcons.xmark; // sheet cancel (solid-only)
  static const approve = FontAwesomeIcons.check; // sheet approve (solid-only)

  // lunar / brand
  static const moon = FontAwesomeIcons.solidMoon; // i-moon (regular outline)
  static const logo = FontAwesomeIcons.moon; // i-ms emblem
  static const spark = FontAwesomeIcons.wandSparkles; // i-spark (solid-only)
  static const star = FontAwesomeIcons.solidStar; // i-star (regular outline)
  static const cal = FontAwesomeIcons.solidCalendarDays; // i-cal (regular outline)
  static const calendarAdd = FontAwesomeIcons.calendarPlus; // add-a-period action

  // actions / content
  static const quill = FontAwesomeIcons.feather; // i-quill (solid-only); FAB uses assets/icons/quill.svg; FAB uses assets/icons/quill.svg
  static const chart = Icons.insights; // i-chart (regular outline)
  static const pulse = FontAwesomeIcons.solidFaceSadTear; // i-pulse
  static const magic = FontAwesomeIcons.wandMagic; // i-magic (solid-only)
  static const heart = FontAwesomeIcons.solidHeart; // i-heart (regular outline)
  static const drop = FontAwesomeIcons.droplet; // i-drop (solid-only)
  static const pregnancy = Icons.pregnant_woman;
  static const thermometer = FontAwesomeIcons.thermometer; // BBT reading
  static const note = FontAwesomeIcons.solidFileLines; // i-note (regular outline)
  static const leaf = FontAwesomeIcons.leaf; // i-leaf (solid-only)
  static const zap = FontAwesomeIcons.bolt; // i-zap (solid-only)
  static const search = FontAwesomeIcons.magnifyingGlass; // i-search (solid-only)
  static const eye = FontAwesomeIcons.eyeSlash; // i-eye closed
  static const eyeOpen = FontAwesomeIcons.eye; // i-eye open (regular outline)
  static const clock = FontAwesomeIcons.clock; // i-clock (regular outline)
  static const chat = FontAwesomeIcons.solidComment; // i-chat (regular outline)
  static const mail = FontAwesomeIcons.envelope; // i-mail (regular outline)
  static const alert = FontAwesomeIcons.triangleExclamation; // i-alert (solid-only)

  // chrome not in mock symbols but used by the app shell
  static const user = Icons.person_outline;
  static const alerts = Icons.notifications_none;

  // brands
  static const apple = FontAwesomeIcons.apple;
  static const google = FontAwesomeIcons.google;

  // other
  static const phoenix = FontAwesomeIcons.phoenixFramework;
  static const handLeft = FontAwesomeIcons.solidHandPointLeft;
  static const gem = FontAwesomeIcons.solidGem;
  static const clover = FontAwesomeIcons.clover;
  static const sun = FontAwesomeIcons.solidSun;
}
