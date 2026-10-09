import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'icon_badge.dart';

class QuickAction extends StatelessWidget {
  final FaIconData icon;
  final String label;
  final VoidCallback onTap;

  /// Solid purple state for a category that already has entries logged today.
  final bool filled;
  const QuickAction({super.key, required this.icon, required this.label, required this.onTap, this.filled = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
        decoration: BoxDecoration(
          color: filled ? AppColors.pur : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: filled ? AppColors.pur : AppColors.line),
        ),
        child: Column(
          children: [
            IconBadge(icon: icon, bg: filled ? Colors.white : AppColors.lav, fg: AppColors.pur),
            const SizedBox(height: 8),
            Text(label, style: AppText.sans(10, w: FontWeight.w500, c: filled ? Colors.white : AppColors.chipText)),
          ],
        ),
      ),
    );
  }
}
