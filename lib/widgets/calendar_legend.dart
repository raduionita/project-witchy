import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class CalendarLegend extends StatelessWidget {
  const CalendarLegend({super.key});

  static const _items = [('period', _LegendDot.solid), ('predicted', _LegendDot.outline), ('fertile', _LegendDot.fertile), ('ovulation', _LegendDot.ovulation), ('logged', _LegendDot.logged)];

  static String? _glyph(_LegendDot dot) => switch (dot) {
    _LegendDot.solid => 'assets/svgs/moon-period.svg',
    _LegendDot.outline => 'assets/svgs/moon-period-predicted.svg',
    _LegendDot.fertile => 'assets/svgs/moon-fertile.svg',
    _LegendDot.ovulation => 'assets/svgs/moon-ovulation.svg',
    _LegendDot.logged => null,
  };

  Widget _legendItem(String label, _LegendDot dot) {
    final glyph = _glyph(dot);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (glyph != null)
          SvgPicture.asset(glyph, width: 16, height: 16, excludeFromSemantics: true)
        else
          Container(width: 6, height: 6, decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.blue)),
        const SizedBox(width: 5),
        Text(label, style: AppText.sans(9, w: FontWeight.w500, c: AppColors.muted)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(alignment: WrapAlignment.center, spacing: 12, runSpacing: 6, children: [for (final item in _items) _legendItem(item.$1, item.$2)]);
  }
}

enum _LegendDot { solid, outline, fertile, ovulation, logged }
