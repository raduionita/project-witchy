import 'dart:math' as math;

import 'package:flutter/material.dart';

/// WCAG contrast helpers for picking readable text on colored fills.
abstract class ColorUtils {
  /// Relative luminance of [color] (0.0 .. 1.0).
  static double luminance(Color color) {
    double linear(double channel) => channel <= 0.04045
        ? channel / 12.92
        : math.pow((channel + 0.055) / 1.055, 2.4).toDouble();
    return (0.2126 * linear(color.r) +
        0.7152 * linear(color.g) +
        0.0722 * linear(color.b));
  }

  /// WCAG contrast ratio between [a] and [b] (1.0 .. 21.0).
  static double contrast(Color a, Color b) {
    final double l1 = luminance(a);
    final double l2 = luminance(b);
    final double lighter = math.max(l1, l2);
    final double darker = math.min(l1, l2);
    return (lighter + 0.05) / (darker + 0.05);
  }

  /// Picks the candidate ([lightText] or [darkText]) with the better contrast
  /// ratio against [background].
  static Color readableText(Color background, {required Color lightText, required Color darkText}) {
    return contrast(lightText, background) >= contrast(darkText, background)
        ? lightText
        : darkText;
  }
}