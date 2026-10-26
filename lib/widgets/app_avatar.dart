import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class AppAvatar extends StatelessWidget {
  final String initials;
  final String? emoji;
  final double size;
  final bool big;
  const AppAvatar({super.key, required this.initials, this.emoji, this.size = 40, this.big = false});

  @override
  Widget build(BuildContext context) {
    final s = big ? 84.0 : size;
    return Container(
      width: s,
      height: s,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: AppColors.avatarGradient,
        border: big ? Border.all(color: Colors.white, width: 2) : null,
        boxShadow: big ? [BoxShadow(color: AppColors.gold.withValues(alpha: .6), blurRadius: 0, spreadRadius: 1.5)] : null,
      ),
      alignment: Alignment.center,
      child: Text(emoji ?? initials, style: emoji != null ? TextStyle(fontSize: big ? 30 : 18) : AppText.serif(big ? 26 : 13, c: AppColors.avatarText)),
    );
  }
}
