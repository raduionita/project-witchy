/// Symptom chip widget for Witchy.
/// Reusable selectable chip for displaying and selecting symptoms.
library;

import 'package:flutter/material.dart';

/// A selectable symptom chip with icon and label.
class SymptomChipWidget extends StatelessWidget {
  const SymptomChipWidget({super.key, required this.label, required this.isSelected, required this.onSelected});

  /// The symptom label text.
  final String label;

  /// Whether the chip is currently selected.
  final bool isSelected;

  /// Callback when the chip is tapped (toggles selection).
  final ValueChanged<bool> onSelected;

  /// Returns an icon for a given symptom label.
  IconData _getIcon(String label) {
    switch (label.toLowerCase()) {
      case 'cramps':
        return Icons.self_improvement;
      case 'headache':
        return Icons.psychology;
      case 'bloating':
        return Icons.expand;
      case 'breast tenderness':
        return Icons.favorite_border;
      case 'fatigue':
        return Icons.battery_alert;
      case 'acne':
        return Icons.face;
      case 'cravings':
        return Icons.restaurant;
      default:
        return Icons.circle;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_getIcon(label), size: 16),
          const SizedBox(width: 4),
          Text(label),
        ],
      ),
      selected: isSelected,
      onSelected: (selected) => onSelected(selected),
    );
  }
}
