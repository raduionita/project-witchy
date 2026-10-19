import 'package:flutter/material.dart';

import '../models/tracking_mode.dart';
import '../theme/app_icons.dart';
import 'app_chip.dart';

class TrackingModeChips extends StatelessWidget {
  final Set<TrackingMode> selected;
  final ValueChanged<TrackingMode> onToggle;
  const TrackingModeChips({super.key, required this.selected, required this.onToggle});

  static const Map<TrackingMode, Object> _icons = {
    TrackingMode.cycle: AppIcons.drop,
    TrackingMode.pregnancy: AppIcons.pregnancy,
    TrackingMode.perimenopause: AppIcons.moon,
  };

  @override
  Widget build(BuildContext context) {
    final modes = TrackingMode.values;
    // One row of equal-width chips so the set reads as a single choice block.
    // Labels are clipped rather than wrapped: a wrapped "Perimenopause" used to
    // make that chip taller than its siblings.
    return Row(
      children: [
        for (var i = 0; i < modes.length; i++) ...[
          if (i > 0) const SizedBox(width: 8),
          Expanded(
            child: AppChip(
              label: modes[i].label,
              icon: _icons[modes[i]],
              selected: selected.contains(modes[i]),
              singleLine: true,
              onTap: () => onToggle(modes[i]),
            ),
          ),
        ],
      ],
    );
  }
}
