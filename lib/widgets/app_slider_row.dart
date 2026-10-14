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

  /// Optional note under the track, e.g. "Calculated from your dates".
  final String? hint;
  const AppSliderRow({super.key, required this.label, required this.value, required this.min, required this.max, required this.current, required this.onChanged, this.hint});

  void _step(int delta) {
    final next = (current + delta).clamp(min, max);
    if (next != current) onChanged(next);
  }

  @override
  Widget build(BuildContext context) {
    final divisions = (max - min).round();
    return Column(
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(label, style: AppText.sec), Text(value, style: AppText.serif(13.5, c: AppColors.pur))]),
        Row(
          children: [
            IconButton(
              onPressed: current > min ? () => _step(-1) : null,
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
              icon: Icon(Icons.remove_circle_outline, size: 18, color: current > min ? AppColors.pur : AppColors.line),
              tooltip: 'Decrease',
            ),
            Expanded(
              child: SliderTheme(
                data: SliderTheme.of(
                  context,
                ).copyWith(activeTrackColor: AppColors.pur, inactiveTrackColor: AppColors.sliderTrack, thumbColor: Colors.white, overlayShape: SliderComponentShape.noOverlay, trackHeight: 4),
                child: Slider(min: min, max: max, divisions: divisions, value: current.clamp(min, max), onChanged: onChanged),
              ),
            ),
            IconButton(
              onPressed: current < max ? () => _step(1) : null,
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
              icon: Icon(Icons.add_circle_outline, size: 18, color: current < max ? AppColors.pur : AppColors.line),
              tooltip: 'Increase',
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [Text('${min.round()}', style: AppText.sans(9.5, c: AppColors.muted)), Text('${max.round()}', style: AppText.sans(9.5, c: AppColors.muted))],
        ),
        if (hint != null) ...[
          const SizedBox(height: 2),
          Align(alignment: Alignment.centerLeft, child: Text(hint!, style: AppText.sans(10, c: AppColors.muted))),
        ],
      ],
    );
  }
}
