import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../theme/app_colors.dart';
import '../theme/app_icons.dart';

class IconBadge extends StatelessWidget {
  final FaIconData icon;
  final Color bg;
  final Color fg;
  final double size;
  const IconBadge({super.key, required this.icon, this.bg = AppColors.lav, this.fg = AppColors.pur, this.size = 34});

  @override
  Widget build(BuildContext context) {
    return Container(width: size, height: size, decoration: BoxDecoration(shape: BoxShape.circle, color: bg), alignment: Alignment.center, child: FaIcon(icon, size: AppIconSize.sm, color: fg));
  }
}
