import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// One-line medical disclaimer under prediction surfaces (B1).
class DisclaimerText extends StatelessWidget {
  const DisclaimerText({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Text(
        'Predictions are estimates - not a contraceptive and not medical advice.',
        textAlign: TextAlign.center,
        style: AppText.sans(10.5, c: AppColors.muted, h: 1.5),
      ),
    );
  }
}
