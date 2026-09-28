import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../utils/app_icons.dart';

class InfoPill extends StatelessWidget {
  final FaIconData icon;
  final String label;
  const InfoPill({super.key, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(color: const Color(0xFFF6EEFB), borderRadius: BorderRadius.circular(9), border: Border.all(color: AppColors.line)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [FaIcon(icon, size: AppIconSize.xs, color: AppColors.pur), const SizedBox(width: 6), Text(label, style: AppText.sans(10, w: FontWeight.w500, c: AppColors.chipText))],
      ),
    );
  }
}
