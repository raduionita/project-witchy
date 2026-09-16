import 'package:flutter/material.dart';

import '../utils/app_theme.dart';

/// Qwen slider card: label row with live value + styled range input.
class WitchySliderCard extends StatelessWidget {
  const WitchySliderCard({super.key, required this.label, required this.valueLabel, required this.value, required this.min, required this.max, required this.onChanged});

  final String label;
  final String valueLabel;
  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.kMd),
      decoration: BoxDecoration(color: Theme.of(context).brightness == Brightness.dark ? Theme.of(context).colorScheme.surfaceContainerLow : Colors.white, borderRadius: BorderRadius.circular(AppSpacing.kRadiusM), border: Border.all(color: AppColors.kLine)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Text(label, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: Color(0xFF3F2B52)))),
              Text(valueLabel, style: const TextStyle(fontFamily: AppTypography.kDisplayFont, fontSize: 13.5, fontWeight: FontWeight.w700, color: AppColors.kPurple)),
            ],
          ),
          const SizedBox(height: 12),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(trackHeight: 4, thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 9), overlayShape: const RoundSliderOverlayShape(overlayRadius: 18)),
            child: Slider(value: value, min: min, max: max, divisions: (max - min).round(), onChanged: onChanged),
          ),
        ],
      ),
    );
  }
}
