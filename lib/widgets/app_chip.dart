import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../utils/app_icons.dart';

class AppChip extends StatelessWidget {
  final String label;
  final FaIconData? icon;
  final Color? iconColor;
  final bool selected;
  final VoidCallback onTap;
  const AppChip({super.key, required this.label, this.icon, this.iconColor, this.selected = false, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(color: selected ? AppColors.pur : Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: selected ? AppColors.pur : AppColors.line)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[FaIcon(icon, size: AppIconSize.xs, color: selected ? Colors.white : (iconColor ?? AppColors.pur)), const SizedBox(width: 6)],
            Flexible(child: Text(label, style: AppText.sans(11.5, w: FontWeight.w500, c: selected ? Colors.white : AppColors.chipText))),
          ],
        ),
      ),
    );
  }
}
