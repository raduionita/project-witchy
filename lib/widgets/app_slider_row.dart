import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'number_entry_dialog.dart';

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

  /// Types an exact value instead of hunting for a thumb position; the entered
  /// number is clamped into the range the same way the steppers are.
  Future<void> _type(BuildContext context) async {
    final entered = await showDialog<int>(
      context: context,
      builder: (_) => NumberEntryDialog(title: label, initial: current.round(), min: min.round(), max: max.round(), hint: hint),
    );
    if (entered == null) return;
    final next = entered.toDouble().clamp(min, max);
    if (next != current) onChanged(next);
  }

  Widget _buildValue(BuildContext context) {
    return Tooltip(
      message: 'Tap to type a number',
      child: InkWell(
        onTap: () => _type(context),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(value, style: AppText.serif(13.5, c: AppColors.pur)),
              const SizedBox(width: 5),
              Icon(Icons.edit_outlined, size: 11, color: AppColors.pur),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final divisions = (max - min).round();
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [Flexible(child: Text(label, style: AppText.sec, overflow: TextOverflow.ellipsis)), _buildValue(context)],
        ),
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
