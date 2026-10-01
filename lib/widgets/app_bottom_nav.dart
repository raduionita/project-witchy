import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_icons.dart';

class AppBottomNav extends StatelessWidget {
  final int index;
  final ValueChanged<int> onTap;
  const AppBottomNav({super.key, required this.index, required this.onTap});

  @override
  Widget build(BuildContext context) {
    const items = [(AppIcons.moon, 'Today'), (AppIcons.cal, 'Calendar'), (AppIcons.chart, 'Insights'), (AppIcons.spark, 'Magic')];
    return Container(
      height: 78,
      decoration: const BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: AppColors.line))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          for (var i = 0; i < items.length; i++)
            GestureDetector(
              onTap: () => onTap(i),
              child: Container(
                width: 60,
                padding: const EdgeInsets.only(top: 10),
                child: Column(
                  children: [
                    const SizedBox(height: 4),
                    FaIcon(items[i].$1, size: AppIconSize.head, color: i == index ? AppColors.pur : AppColors.navInactive),
                    const SizedBox(height: 8),
                    Text(items[i].$2, style: AppText.sans(9.5, w: FontWeight.w500, c: i == index ? AppColors.pur : AppColors.navInactive)),
                    if (i == index) Container(margin: const EdgeInsets.only(top: 4), width: 18, height: 2.5, decoration: BoxDecoration(color: AppColors.pur, borderRadius: BorderRadius.circular(2))),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
