import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/alert_item.dart';
import '../providers/alert_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/icon_badge.dart';
import '../widgets/app_top_bar.dart';
import '../widgets/app_card.dart';

class AlertsScreen extends StatelessWidget {
  const AlertsScreen({super.key});

  String _ago(DateTime t, DateTime now) {
    final diff = now.difference(t);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inHours < 1) return '${diff.inMinutes} min ago';
    if (diff.inDays < 1) return '${diff.inHours} h ago';
    if (diff.inDays == 1) return 'yesterday';
    return DateFormat('d MMM').format(t);
  }

  Widget _buildEmpty() => AppCard(
    child: Column(
      children: [
        Text('No whispers yet', style: AppText.serif(13)),
        const SizedBox(height: 6),
        Text(
          'The cosmos is quiet right now. Alerts appear as your cycle nears a milestone.',
          textAlign: TextAlign.center,
          style: AppText.sans(11, h: 1.5, c: AppColors.muted),
        ),
      ],
    ),
  );

  Widget _buildAlert(AlertProvider provider, AlertItem a, DateTime now) {
    final unread = !a.read;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => provider.markRead(a.id),
      child: AppCard(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IconBadge(icon: a.icon, bg: a.badgeBg, fg: a.badgeFg),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (unread) ...[
                        Container(
                          width: 6,
                          height: 6,
                          margin: const EdgeInsets.only(right: 6),
                          decoration: const BoxDecoration(color: AppColors.pink, shape: BoxShape.circle),
                        ),
                      ],
                      Expanded(
                        child: Text(
                          a.title,
                          style: unread
                              ? AppText.serif(12.5)
                              : AppText.serif(12.5, c: AppColors.muted),
                        ),
                      ),
                      Text(_ago(a.createdAt, now), style: AppText.sans(9, c: AppColors.muted)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    a.body,
                    style: AppText.sans(11, h: 1.55, c: unread ? AppColors.body : AppColors.muted),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AlertProvider>();
    final alerts = provider.items;
    final now = DateTime.now();
    return Scaffold(
      appBar: const AppTopBar(title: 'Celestial Alerts'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 6, 16, 14),
        children: [
          Text('Whispers Received', style: AppText.sec),
          const SizedBox(height: 8),
          Text('The cosmos whispers its reminders. Align your biological temple.', style: AppText.sub),
          const SizedBox(height: 12),
          if (alerts.isEmpty)
            _buildEmpty()
          else
            for (final a in alerts) ...[
              _buildAlert(provider, a, now),
              const SizedBox(height: 12),
            ],
        ],
      ),
    );
  }
}
