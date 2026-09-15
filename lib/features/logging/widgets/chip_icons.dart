import 'package:flutter/material.dart';

import '../../../models/flow_intensity.dart';

IconData logFlowIcon(FlowIntensity intensity) => switch (intensity) {
  FlowIntensity.light => Icons.water_drop,
  FlowIntensity.medium => Icons.water,
  FlowIntensity.heavy => Icons.waves,
};

/// Icon for a symptom chip, keyed by its (localized) label.
IconData logSymptomIcon(String label) => switch (label) {
  'Cramps' || 'Calambres' => Icons.healing,
  'Headache' || 'Dolor de cabeza' => Icons.psychology,
  'Back pain' || 'Dolor de espalda' => Icons.accessibility_new,
  'Bloating' || 'Hinchazón' => Icons.air,
  'Nausea' || 'Náuseas' => Icons.sick,
  'Tender breasts' || 'Pechos sensibles' => Icons.favorite,
  'Acne' || 'Acné' => Icons.spa,
  'Fatigue' || 'Fatiga' => Icons.battery_alert,
  _ => Icons.science,
};

/// Icon for a mood chip, keyed by its (localized) label.
IconData logMoodIcon(String label) => switch (label) {
  'Happy' || 'Feliz' => Icons.sentiment_satisfied_alt,
  'Calm' || 'Tranquila' => Icons.self_improvement,
  'Anxious' || 'Ansiosa' => Icons.sentiment_neutral,
  'Irritable' => Icons.sentiment_very_dissatisfied,
  'Sad' || 'Triste' => Icons.sentiment_dissatisfied,
  'Energetic' || 'Enérgica' => Icons.bolt,
  _ => Icons.mood,
};
