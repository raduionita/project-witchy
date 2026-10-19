import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_icons.dart';
import 'app_glyph.dart';

class AppChip extends StatelessWidget {
  final String label;
  final Object? icon;
  final Color? iconColor;
  final int iconCount;
  final bool selected;
  final Color? selectedColor;
  final VoidCallback onTap;

  /// Holds the label to one clipped line. Used by the equal-width tracking
  /// chips, where a wrapped label would make one chip taller than its siblings.
  final bool singleLine;
  const AppChip({super.key, required this.label, this.icon, this.iconColor, this.iconCount = 1, this.selected = false, this.selectedColor, this.singleLine = false, required this.onTap});

  Widget _icon(Color active, Color fg) {
    final color = selected ? fg : (iconColor ?? AppColors.pur);
    if (iconCount == 1) return AppGlyph(icon!, size: AppIconSize.sm, color: color);
    const step = 7.0;
    return SizedBox(
      width: AppIconSize.sm + step * (iconCount - 1),
      height: AppIconSize.sm,
      child: Stack(children: [for (var i = 0; i < iconCount; i++) Positioned(left: step * i, child: AppGlyph(icon!, size: AppIconSize.sm, color: color))]),
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
        decoration: BoxDecoration(color: selected ? active : AppColors.chipBg, borderRadius: BorderRadius.circular(8), border: Border.all(color: selected ? active : AppColors.line)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[_icon(active, fg), const SizedBox(width: 5)],
            Flexible(
              child: Text(
                label,
                textAlign: TextAlign.center,
                maxLines: singleLine ? 1 : 2,
                softWrap: !singleLine,
                overflow: singleLine ? TextOverflow.clip : null,
                style: AppText.sans(12.5, w: FontWeight.w500, c: selected ? fg : AppColors.chipText),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
