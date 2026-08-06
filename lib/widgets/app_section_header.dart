import 'package:flutter/material.dart';

import '../utils/app_theme.dart';
import 'app_text.dart';

/// Section header with optional trailing action, used across feature screens.
class AppSectionHeader extends StatelessWidget {
  const AppSectionHeader({
    super.key,
    required this.title,
    this.trailing,
  });

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.kSm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          AppText(
            title,
            variant: AppTextVariant.title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}
