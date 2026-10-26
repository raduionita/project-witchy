import 'package:flutter/material.dart';

import '../models/tracking_mode.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'app_chip.dart';

class TrackingModeChips extends StatelessWidget {
  final Set<TrackingMode> selected;
  final ValueChanged<TrackingMode> onToggle;
  const TrackingModeChips({super.key, required this.selected, required this.onToggle});

  static const EdgeInsets _padding = EdgeInsets.symmetric(horizontal: 10, vertical: 6);
  static const double _gap = 8;

  /// Flex proportional to the visible content, so longer labels get more of
  /// the row without forcing every chip to an equal width.
  int _contentFlex(TrackingMode mode, TextScaler scaler) {
    final painter = TextPainter(
      text: TextSpan(text: mode.label, style: AppText.sans(12.5, w: FontWeight.w500, c: AppColors.chipText)),
      textDirection: TextDirection.ltr,
      textScaler: scaler,
      maxLines: 1,
    )..layout();
    final width = painter.width + _padding.horizontal;
    painter.dispose();
    return width.ceil();
  }

  @override
  Widget build(BuildContext context) {
    final modes = TrackingMode.values;
    final scaler = MediaQuery.textScalerOf(context);
    return Row(
      children: [
        for (var i = 0; i < modes.length; i++) ...[
          if (i > 0) const SizedBox(width: _gap),
          Expanded(
            flex: _contentFlex(modes[i], scaler),
            child: AppChip(
              label: modes[i].label,
              selected: selected.contains(modes[i]),
              singleLine: true,
              padding: _padding,
              onTap: () => onToggle(modes[i]),
            ),
          ),
        ],
      ],
    );
  }
}
