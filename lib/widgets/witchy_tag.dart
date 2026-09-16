import 'package:flutter/material.dart';

import '../utils/app_theme.dart';

/// Small status tag mirroring Qwen `.tag` (lavender, pink, gold variants).
class WitchyTag extends StatelessWidget {
  const WitchyTag({super.key, required this.label, this.variant = WitchyTagVariant.lavender});

  final String label;
  final WitchyTagVariant variant;

  @override
  Widget build(BuildContext context) {
    final (Color bg, Color fg) = switch (variant) {
      WitchyTagVariant.lavender => (AppColors.kLav, AppColors.kPurpleDark),
      WitchyTagVariant.pink => (const Color(0xFFFCE7EF), const Color(0xFFC2336B)),
      WitchyTagVariant.gold => (const Color(0x29D9A036), AppColors.kGold),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
      child: Text(label, style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w600, color: fg)),
    );
  }
}

enum WitchyTagVariant { lavender, pink, gold }
