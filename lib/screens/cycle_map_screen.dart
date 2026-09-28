import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../utils/app_icons.dart';
import '../widgets/log_bottom_sheet.dart';
import '../widgets/cycle_calendar.dart';
import '../widgets/app_card.dart';
import '../widgets/app_tag.dart';

class CycleMapScreen extends StatelessWidget {
  const CycleMapScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 14),
      children: [
        GestureDetector(
          onTap: () => Navigator.pushNamed(context, '/chart'),
          child: AppCard(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const FaIcon(AppIcons.left, size: AppIconSize.head, color: AppColors.muted),
                    Text('October 2026', style: AppText.serif(13.5)),
                    const FaIcon(AppIcons.right, size: AppIconSize.head, color: AppColors.muted),
                  ],
                ),
                const SizedBox(height: 12),
                CycleCalendar(onDayTap: (day) => showLogSheet(context, DateTime(2026, 10, day))),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        AppCard(
          child: Column(
            children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('October 15, 2026', style: AppText.serif(13.5)), AppTag.pink('Period Day 2')]),
              const SizedBox(height: 8),
              Row(
                children: [
                  const FaIcon(AppIcons.drop, size: AppIconSize.row, color: AppColors.pink),
                  const SizedBox(width: 8),
                  Text('Medium bleed flow intensity', style: AppText.sans(11.5, c: AppColors.chipText)),
                ],
              ),
              const SizedBox(height: 5),
              Row(
                children: [
                  const FaIcon(AppIcons.heart, size: AppIconSize.row, color: AppColors.pur),
                  const SizedBox(width: 8),
                  Text('Intuitive, reflective mood', style: AppText.sans(11.5, c: AppColors.chipText)),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
