import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_icons.dart';
import 'app_glyph.dart';

class InfoPill extends StatelessWidget {
  final Object icon;
  final String label;
  const InfoPill({super.key, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(color: AppColors.pillBg, borderRadius: BorderRadius.circular(9), border: Border.all(color: AppColors.line)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [AppGlyph(icon, size: AppIconSize.xs, color: AppColors.pur), const SizedBox(width: 6), Text(label, style: AppText.sans(10, w: FontWeight.w500, c: AppColors.chipText))],
      ),
    );
  }
}
