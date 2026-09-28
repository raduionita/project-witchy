import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool busy;
  const AppButton({super.key, required this.label, this.onTap, this.busy = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: busy ? null : onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), gradient: AppColors.plumGradient, boxShadow: const [AppColors.primaryShadow]),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [if (busy) const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.gold)), Text(label, style: AppText.btn)],
        ),
      ),
    );
  }
}
