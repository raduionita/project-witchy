import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../models/tracking_mode.dart';
import '../theme/app_icons.dart';
import 'app_chip.dart';

class TrackingModeChips extends StatelessWidget {
  final Set<TrackingMode> selected;
  final ValueChanged<TrackingMode> onToggle;
  const TrackingModeChips({super.key, required this.selected, required this.onToggle});

  static const Map<TrackingMode, FaIconData> _icons = {
    TrackingMode.cycle: AppIcons.drop,
    TrackingMode.pregnancy: FontAwesomeIcons.personPregnant,
    TrackingMode.perimenopause: AppIcons.moon,
  };

  @override
  Widget build(BuildContext context) {
    final modes = TrackingMode.values;
    return Row(
      children: [
        for (var i = 0; i < modes.length; i++) ...[
          if (i > 0) const SizedBox(width: 8),
          Expanded(
            child: AppChip(
              label: modes[i].label,
              icon: _icons[modes[i]],
              selected: selected.contains(modes[i]),
              onTap: () => onToggle(modes[i]),
            ),
          ),
        ],
      ],
    );
  }
}
