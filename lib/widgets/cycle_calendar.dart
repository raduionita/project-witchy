import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class CycleCalendar extends StatelessWidget {
  final ValueChanged<int>? onDayTap;
  const CycleCalendar({super.key, this.onDayTap});
  @override
  Widget build(BuildContext context) {
    const fertile = {10, 11, 12, 13};
    const period = {14, 15, 16, 17, 18};
    return GridView.count(
      crossAxisCount: 7,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        for (final d in ['M', 'T', 'W', 'T', 'F', 'S', 'S']) Center(child: Text(d, style: AppText.sans(9, w: FontWeight.w600, c: AppColors.muted))),
        const SizedBox.shrink(),
        const SizedBox.shrink(),
        const SizedBox.shrink(),
        for (var day = 1; day <= 31; day++)
          Center(
            child: GestureDetector(
              onTap: onDayTap == null ? null : () => onDayTap!(day),
              child: Container(
                width: 34,
                height: 34,
                alignment: Alignment.center,
                decoration: BoxDecoration(shape: BoxShape.circle, color: period.contains(day) ? AppColors.pur : (fertile.contains(day) ? AppColors.fertileBg : null)),
                child: Text(
                  '$day',
                  style: AppText.sans(
                    11,
                    c: period.contains(day) ? Colors.white : (fertile.contains(day) ? AppColors.fertileText : AppColors.body),
                    w: (period.contains(day) || fertile.contains(day)) ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
            ),
          ),
        const SizedBox.shrink(),
      ],
    );
  }
}
