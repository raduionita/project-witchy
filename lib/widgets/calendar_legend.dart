import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class CalendarLegend extends StatelessWidget {
  const CalendarLegend({super.key});

  static const _items = [('period', _LegendDot.solid), ('predicted', _LegendDot.outline), ('fertile', _LegendDot.fertile), ('ovulation', _LegendDot.ovulation), ('logged', _LegendDot.logged)];

  @override
  Widget build(BuildContext context) {
    return Wrap(alignment: WrapAlignment.center, spacing: 12, runSpacing: 6, children: [for (final item in _items) _legendItem(item.$1, item.$2)]);
  }

  Widget _legendItem(String label, _LegendDot dot) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        dot == _LegendDot.solid
            ? Container(width: 10, height: 10, decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.pur))
            : dot == _LegendDot.outline
            ? Container(
              width: 10,
              height: 10,
              decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white, border: Border.fromBorderSide(BorderSide(color: AppColors.pur, width: 1.4))),
            )
            : dot == _LegendDot.fertile
            ? Container(width: 10, height: 10, decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.fertileBg))
            : Container(width: 6, height: 6, decoration: BoxDecoration(shape: BoxShape.circle, color: dot == _LegendDot.ovulation ? AppColors.pink : AppColors.blue)),
        const SizedBox(width: 5),
        Text(label, style: AppText.sans(9, w: FontWeight.w500, c: AppColors.muted)),
      ],
    );
  }
}

enum _LegendDot { solid, outline, fertile, ovulation, logged }
