import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class AppTag extends StatelessWidget {
  final String label;
  final Color bg;
  final Color fg;
  const AppTag(this.label, {super.key, this.bg = AppColors.lav, this.fg = AppColors.purDark});
  factory AppTag.pink(String l) => AppTag(l, bg: AppColors.pinkBg, fg: AppColors.pinkDark);
  factory AppTag.gold(String l) => AppTag(l, bg: const Color(0x29D9A036), fg: AppColors.gold);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
      child: Text(label, style: AppText.sans(9.5, w: FontWeight.w600, c: fg)),
    );
  }
}
