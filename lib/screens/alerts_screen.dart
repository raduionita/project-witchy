import 'package:flutter/material.dart';
import '../models/mock_data.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/icon_badge.dart';
import '../widgets/app_top_bar.dart';
import '../widgets/app_card.dart';

class AlertsScreen extends StatelessWidget {
  const AlertsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final alerts = MockData.alerts();
    return Scaffold(
      appBar: const AppTopBar(title: 'Celestial Alerts'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 6, 16, 14),
        children: [
          Text('Whispers Received', style: AppText.sec),
          const SizedBox(height: 8),
          Text('The cosmos whispers its reminders. Align your biological temple.', style: AppText.sub),
          const SizedBox(height: 12),
          for (final a in alerts) ...[
            AppCard(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconBadge(icon: a.icon, bg: a.badgeBg, fg: a.badgeFg),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [Expanded(child: Text(a.title, style: AppText.serif(12.5))), Text(a.time, style: AppText.sans(9, c: AppColors.muted))]),
                        const SizedBox(height: 4),
                        Text(a.body, style: AppText.sans(11, h: 1.55)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}
