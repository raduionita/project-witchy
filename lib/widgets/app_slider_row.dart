import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class AppSliderRow extends StatelessWidget {
  final String label;
  final String value;
  final double min;
  final double max;
  final double current;
  final ValueChanged<double> onChanged;
  const AppSliderRow({super.key, required this.label, required this.value, required this.min, required this.max, required this.current, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(label, style: AppText.sec), Text(value, style: AppText.serif(13.5, c: AppColors.pur))]),
        SliderTheme(
          data: SliderTheme.of(
            context,
          ).copyWith(activeTrackColor: AppColors.pur, inactiveTrackColor: AppColors.sliderTrack, thumbColor: Colors.white, overlayShape: SliderComponentShape.noOverlay, trackHeight: 4),
          child: Slider(min: min, max: max, value: current, onChanged: onChanged),
        ),
      ],
    );
  }
}
