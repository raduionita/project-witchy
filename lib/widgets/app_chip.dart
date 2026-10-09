import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_icons.dart';

class AppChip extends StatelessWidget {
  final String label;
  final FaIconData? icon;
  final Color? iconColor;
  final int iconCount;
  final bool selected;
  final Color? selectedColor;
  final VoidCallback onTap;
  const AppChip({super.key, required this.label, this.icon, this.iconColor, this.iconCount = 1, this.selected = false, this.selectedColor, required this.onTap});

  Widget _icon(Color active) {
    final color = selected ? active : (iconColor ?? AppColors.pur);
    if (iconCount == 1) return FaIcon(icon, size: AppIconSize.sm, color: color);
    const step = 7.0;
    return SizedBox(
      width: AppIconSize.sm + step * (iconCount - 1),
      height: AppIconSize.sm,
      child: Stack(children: [for (var i = 0; i < iconCount; i++) Positioned(left: step * i, child: FaIcon(icon, size: AppIconSize.sm, color: color))]),
    );
  }

  @override
  Widget build(BuildContext context) {
    final active = selectedColor ?? AppColors.pur;
    final fg = AppColors.onColor(active);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(color: selected ? active : Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: selected ? active : AppColors.line)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[_icon(active), const SizedBox(width: 5)],
            Flexible(child: Text(label, style: AppText.sans(12.5, w: FontWeight.w500, c: selected ? fg : AppColors.chipText))),
          ],
        ),
      ),
    );
  }
}
