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

  /// Width reserved for each step button and its matching min/max label.
  static const double _stepExtent = 40;

  const AppSliderRow({super.key, required this.label, required this.value, required this.min, required this.max, required this.current, required this.onChanged, this.hint});

  void _step(int delta) {
    final next = (current + delta).clamp(min, max);
    if (next != current) onChanged(next);
  }

  /// Types an exact value instead of hunting for a thumb position; the entered
  /// number is clamped into the range the same way the steppers are.
  Future<void> _type(BuildContext context) async {
    final entered = await showDialog<int>(context: context, builder: (_) => NumberEntryDialog(title: label, initial: current.round(), min: min.round(), max: max.round(), hint: hint));
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
            children: [Text(value, style: AppText.serif(13.5, c: AppColors.pur)), const SizedBox(width: 5), Icon(Icons.edit_outlined, size: 11, color: AppColors.pur)],
          ),
        ),
      ),
    );
  }

  Widget _buildStep({
    required int delta,
    required bool enabled,
    required IconData icon,
    required String tooltip,
    required String label,
  }) {
    return SizedBox(
      width: _stepExtent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: enabled ? () => _step(delta) : null,
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: _stepExtent, minHeight: 28),
            icon: Icon(icon, size: 24, color: enabled ? AppColors.pur : AppColors.line),
            tooltip: tooltip,
          ),
          Text(label, style: AppText.sans(9.5, c: AppColors.muted)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final divisions = (max - min).round();
    return Column(
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Flexible(child: Text(label, style: AppText.sec, overflow: TextOverflow.ellipsis)), _buildValue(context)]),
        Row(
          children: [
            _buildStep(delta: -1, enabled: current > min, icon: Icons.remove_circle_outline, tooltip: 'Decrease', label: '${min.round()}'),
            Expanded(
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: AppColors.pur,
                  inactiveTrackColor: AppColors.sliderTrack,
                  thumbColor: Colors.white,
                  overlayShape: SliderComponentShape.noOverlay,
                  trackHeight: 8,
                  activeTickMarkColor: Colors.white,
                  inactiveTickMarkColor: AppColors.muted,
                  tickMarkShape: const RoundSliderTickMarkShape(tickMarkRadius: 1),
                ),
                child: Slider(min: min, max: max, divisions: divisions, value: current.clamp(min, max), onChanged: onChanged),
              ),
            ),
            _buildStep(delta: 1, enabled: current < max, icon: Icons.add_circle_outline, tooltip: 'Increase', label: '${max.round()}'),
          ],
        ),
        if (hint != null) ...[const SizedBox(height: 2), Align(alignment: Alignment.centerLeft, child: Text(hint!, style: AppText.sans(10, c: AppColors.muted)))],
      ],
    );
  }
}
