import 'package:flutter/material.dart';
import '../models/period_cycle.dart';

class WitchyColors {
  static const Color primary = Color(0xFF8E44AD);
  static const Color primaryLight = Color(0xFF9B59B6);
  static const Color primaryDark = Color(0xFF7D3C98);
  static const Color secondary = Color(0xFF2ECC71);
  static const Color periodColor = Color(0xFFE74C3C);
  static const Color fertileColor = Color(0xFF3498DB);
  static const Color ovulationColor = Color(0xFF1ABC9C);
  static const Color predictedColor = Color(0xFF95A5A6);
  static const Color backgroundColor = Color(0xFFF8F9FA);
  static const Color cardColor = Colors.white;
  static const Color textColor = Color(0xFF2C3E50);
  static const Color lightText = Color(0xFF7F8C8D);
  static const Color borderColor = Color(0xFFECF0F1);

  static const Map<int, Color> flowColors = {
    1: Color(0xFFE8F8F5),
    2: Color(0xFFD5F5E3),
    3: Color(0xFFFDEBD0),
    4: Color(0xFFFADBD8),
    5: Color(0xFFE74C3C),
  };

  static Map<Mood, Color> get moodColors => {
    Mood.happy: const Color(0xFFF1C40F),
    Mood.sad: const Color(0xFF3498DB),
    Mood.irritable: const Color(0xFFE67E22),
    Mood.anxious: const Color(0xFF9B59B6),
    Mood.energetic: const Color(0xFF2ECC71),
    Mood.tired: const Color(0xFF95A5A6),
    Mood.focused: const Color(0xFF1ABC9C),
    Mood.crampy: const Color(0xFFE74C3C),
    Mood.bloated: const Color(0xFFE67E22),
    Mood.nauseous: const Color(0xFF16A085),
  };

  static const List<Color> cycleGradient = [
    Color(0xFF8E44AD),
    Color(0xFF3498DB),
    Color(0xFF2ECC71),
  ];
}

class WitchyConstants {
  static const double kDefaultCycleLength = 28.0;
  static const double kDefaultPeriodDuration = 5.0;
  static const double kDefaultCycleVariation = 7.0;
  static const double kMinCycleLength = 14.0;
  static const double kMaxCycleLength = 60.0;
  static const int kMinCyclesForPrediction = 2;
  static const double kFertilityThreshold = 0.3;
}
