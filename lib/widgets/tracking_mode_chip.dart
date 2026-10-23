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
    // Wrap instead of a single equal-width row so the three labels keep their
    // full text at narrow widths.
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final mode in modes)
          AppChip(
            label: mode.label,
            icon: _icons[mode],
            selected: selected.contains(mode),
            singleLine: true,
            onTap: () => onToggle(mode),
          ),
      ],
    );
  }
}
