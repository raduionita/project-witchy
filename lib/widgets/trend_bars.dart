import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class TrendBars extends StatelessWidget {
  final List<double> heights = const [0.58, 0.72, 0.62, 0.78, 0.94, 0.68, 0.74];
  const TrendBars({super.key});
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 112,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (var i = 0; i < heights.length; i++)
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Expanded(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: FractionallySizedBox(
                        heightFactor: heights[i],
                        widthFactor: 1,
                        child: Container(margin: const EdgeInsets.symmetric(horizontal: 5), decoration: BoxDecoration(borderRadius: BorderRadius.circular(6), gradient: AppColors.barGradient)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text('M${i + 1}', style: AppText.sans(8.5, c: AppColors.muted)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
