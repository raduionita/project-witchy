import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../models/tracking_mode.dart';
import '../theme/app_icons.dart';
import 'app_chip.dart';

class TrackingModeChips extends StatelessWidget {
  final TrackingMode value;
  final ValueChanged<TrackingMode> onChanged;
  const TrackingModeChips({super.key, required this.value, required this.onChanged});

  static const Map<TrackingMode, FaIconData> _icons = {
    TrackingMode.cycle: AppIcons.drop,
    TrackingMode.pregnancy: FontAwesomeIcons.personPregnant,
    TrackingMode.perimenopause: AppIcons.moon,
  };

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final mode in TrackingMode.values)
          AppChip(
            label: mode.label,
            icon: _icons[mode],
            selected: value == mode,
            onTap: () => onChanged(mode),
          ),
      ],
    );
  }
}
