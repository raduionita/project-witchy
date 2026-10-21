import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class CalendarLegend extends StatelessWidget {
  const CalendarLegend({super.key});

  static const _items = [('Period', _LegendKind.period), ('Predicted', _LegendKind.predicted), ('Fertile', _LegendKind.fertile), ('Ovulation', _LegendKind.ovulation), ('Logged', _LegendKind.logged), ('Estimated', _LegendKind.estimated)];

  static String? _glyph(_LegendKind kind) => switch (kind) {
    _LegendKind.period => 'assets/svgs/moon-period.svg',
    _LegendKind.predicted => 'assets/svgs/moon-period-predicted.svg',
    _LegendKind.fertile => 'assets/svgs/moon-fertile.svg',
    _LegendKind.ovulation => 'assets/svgs/moon-ovulation.svg',
    _LegendKind.logged => null,
    _LegendKind.estimated => null,
  };

  Widget _legendItem(String label, _LegendKind kind) {
    final glyph = _glyph(kind);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (glyph != null)
          SvgPicture.asset(glyph, width: 16, height: 16, excludeFromSemantics: true)
        else
          Container(width: 8, height: 8, decoration: BoxDecoration(shape: BoxShape.circle, color: kind == _LegendKind.estimated ? AppColors.gold : AppColors.blue)),
        const SizedBox(width: 5),
        Text(label, style: AppText.sans(10, w: FontWeight.w500, c: AppColors.chipText)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Two rows of centered items; spacing leaves room for 3+2 wraps on narrow screens.
    return Wrap(alignment: WrapAlignment.center, spacing: 14, runSpacing: 8, children: [for (final item in _items) _legendItem(item.$1, item.$2)]);
  }
}

enum _LegendKind { period, predicted, fertile, ovulation, logged, estimated }
