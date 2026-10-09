import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../theme/app_colors.dart';

/// Multi-toggle entry: label + optional FA icon + color (null inherits the section color).
/// [iconCount] renders the icon overlapped N times (e.g. flow droplets).
class LogOption {
  final String name;
  final FaIconData? icon;
  final Color? color;
  final int iconCount;
  const LogOption(this.name, {this.icon, this.color, this.iconCount = 1});
}

/// One log-sheet category: verbatim title from resources/log_bottom_sheet.txt
/// plus its entries; every category is a multi-toggle in a 2-col grid.
/// [icon] is the category glyph used by quick-action shortcuts.
/// [color] gives the section its identity: title tint, selected chips,
/// and option icons that don't set their own color.
class LogCategory {
  final String title;
  final List<LogOption> options;
  final FaIconData? icon;
  final Color color;
  const LogCategory(this.title, this.options, {this.icon, this.color = AppColors.pur});
}

/// Cycle-tracking data for the log sheet — all categories in one place.
abstract final class LogData {
  static const flows = LogCategory('Period and bleeding', [
    LogOption('Light', icon: FontAwesomeIcons.droplet, color: AppColors.pink),
    LogOption('Medium', icon: FontAwesomeIcons.droplet, color: AppColors.pink, iconCount: 2),
    LogOption('Heavy', icon: FontAwesomeIcons.droplet, color: AppColors.pinkDark, iconCount: 3),
    LogOption('Spotting', icon: FontAwesomeIcons.circleDot, color: AppColors.pur),
  ], icon: FontAwesomeIcons.droplet, color: AppColors.red);

  static const collectionMethods = LogCategory('Collection method', [
    LogOption('Tampon'),
    LogOption('Pad'),
    LogOption('Cup'),
    LogOption('Period underwear'),
  ], color: AppColors.blue);

  static const painSymptoms = LogCategory('Pain and body symptoms', [
    LogOption('Cramps', icon: FontAwesomeIcons.fire, color: AppColors.pink),
    LogOption('Abdominal pain'),
    LogOption('Headache', icon: FontAwesomeIcons.brain),
    LogOption('Migraine'),
    LogOption('Backache', icon: FontAwesomeIcons.bone),
    LogOption('Joint pain', icon: FontAwesomeIcons.bone),
    LogOption('Ovulation pain', icon: FontAwesomeIcons.egg, color: AppColors.pink),
    LogOption('Tender breasts', icon: FontAwesomeIcons.heart, color: AppColors.pink),
    LogOption('Swelling'),
    LogOption('Bloating'),
    LogOption('Fatigue', icon: FontAwesomeIcons.faceTired, color: AppColors.gold),
    LogOption('Dizziness', icon: FontAwesomeIcons.faceDizzy, color: AppColors.gold),
    LogOption('Hot flashes', icon: FontAwesomeIcons.fire, color: AppColors.pinkDark),
    LogOption('Night sweats', icon: FontAwesomeIcons.cloudRain, color: AppColors.blue),
  ], icon: FontAwesomeIcons.fire, color: AppColors.orange);

  static const digestion = LogCategory('Digestion and stool', [
    LogOption('Normal stool', icon: FontAwesomeIcons.circleCheck, color: AppColors.green),
    LogOption('Nausea', icon: FontAwesomeIcons.faceFrownOpen),
    LogOption('Constipation'),
    LogOption('Diarrhea', icon: FontAwesomeIcons.dropletSlash, color: AppColors.blue),
    LogOption('Gas'),
    LogOption('Stool changes'),
  ], color: AppColors.green);

  static const skinHair = LogCategory('Skin and hair', [
    LogOption('Acne'),
    LogOption('Oily skin', icon: FontAwesomeIcons.droplet, color: AppColors.gold),
    LogOption('Dry skin'),
    LogOption('Good skin', icon: FontAwesomeIcons.faceSmile, color: AppColors.green),
    LogOption('Hair changes', icon: FontAwesomeIcons.scissors),
    LogOption('Oily hair', icon: FontAwesomeIcons.droplet, color: AppColors.gold),
    LogOption('Dry hair'),
  ], color: AppColors.teal);

  static const moods = LogCategory('Mood and emotions', [
    LogOption('Happy', icon: FontAwesomeIcons.faceGrinBeam, color: AppColors.green),
    LogOption('Calm', icon: FontAwesomeIcons.faceSmile, color: AppColors.blue),
    LogOption('Energetic', icon: FontAwesomeIcons.bolt, color: AppColors.gold),
    LogOption('Frisky', icon: FontAwesomeIcons.faceGrinWink, color: AppColors.pink),
    LogOption('Sensitive', icon: FontAwesomeIcons.heart, color: AppColors.pink),
    LogOption('Sad', icon: FontAwesomeIcons.faceSadTear, color: AppColors.blue),
    LogOption('Depressed', icon: FontAwesomeIcons.faceFrown, color: AppColors.blue),
    LogOption('Anxious', icon: FontAwesomeIcons.faceFrownOpen),
    LogOption('Irritable', icon: FontAwesomeIcons.faceAngry, color: AppColors.pink),
    LogOption('Mood swings', icon: FontAwesomeIcons.faceDizzy),
    LogOption('Guilty'),
    LogOption('Self-critical'),
    LogOption('Obsessive thoughts', icon: FontAwesomeIcons.brain),
    LogOption('Apathetic', icon: FontAwesomeIcons.faceMeh),
    LogOption('Confused', icon: FontAwesomeIcons.faceMehBlank),
    LogOption('PMS', icon: FontAwesomeIcons.venus, color: AppColors.pink),
  ], icon: FontAwesomeIcons.heart, color: AppColors.gold);

  static const cravings = LogCategory('Cravings and appetite', [
    LogOption('Sweet cravings', icon: FontAwesomeIcons.cookie, color: AppColors.pink),
    LogOption('Salty cravings'),
    LogOption('Carb cravings', icon: FontAwesomeIcons.pizzaSlice, color: AppColors.gold),
    LogOption('Chocolate cravings', icon: FontAwesomeIcons.iceCream, color: AppColors.pink),
    LogOption('Increased appetite', icon: FontAwesomeIcons.arrowTrendUp, color: AppColors.green),
    LogOption('Decreased appetite', icon: FontAwesomeIcons.arrowTrendDown, color: AppColors.blue),
  ], color: AppColors.brown);

  static const discharge = LogCategory('Vaginal discharge and cervical fluid', [
    LogOption('None or dry'),
    LogOption('Sticky', icon: FontAwesomeIcons.droplet, color: AppColors.gold),
    LogOption('Creamy', icon: FontAwesomeIcons.droplet, color: AppColors.gold),
    LogOption('Watery', icon: FontAwesomeIcons.droplet, color: AppColors.blue),
    LogOption('Egg white', icon: FontAwesomeIcons.egg, color: AppColors.green),
    LogOption('Unusual discharge', icon: FontAwesomeIcons.circleExclamation, color: AppColors.pink),
  ], color: AppColors.pur);

  static const sex = LogCategory('Sex and sex drive', [
    LogOption('Protected sex', icon: FontAwesomeIcons.shield, color: AppColors.green),
    LogOption('Unprotected sex', icon: FontAwesomeIcons.shieldHalved, color: AppColors.pink),
    LogOption('High sex drive', icon: FontAwesomeIcons.fire, color: AppColors.pink),
    LogOption('Low sex drive', icon: FontAwesomeIcons.snowflake, color: AppColors.blue),
    LogOption('Masturbation'),
    LogOption('Orgasm', icon: FontAwesomeIcons.faceGrinStars, color: AppColors.gold),
  ], color: AppColors.pink);

  static const sleep = LogCategory('Sleep', [
    LogOption('Good sleep', icon: FontAwesomeIcons.moon, color: AppColors.green),
    LogOption('Restless sleep', icon: FontAwesomeIcons.bed, color: AppColors.gold),
    LogOption('Insomnia', icon: FontAwesomeIcons.faceTired, color: AppColors.pink),
    LogOption('Woke up at night', icon: FontAwesomeIcons.eye, color: AppColors.blue),
    LogOption('Woke up early', icon: FontAwesomeIcons.clock, color: AppColors.blue),
    LogOption('Vivid dreams', icon: FontAwesomeIcons.cloudMoon),
    LogOption('Nightmares', icon: FontAwesomeIcons.cloudBolt),
    LogOption('Napped', icon: FontAwesomeIcons.couch, color: AppColors.gold),
  ], icon: FontAwesomeIcons.moon, color: AppColors.indigo);
}
