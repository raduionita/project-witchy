import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../common/date_format.dart';
import '../models/alert_item.dart';
import '../navigation/app_nav.dart';
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
    return AppDate.dayMonth(t);
  }

  Widget _buildEmpty() => AppCard(
    child: Column(
      children: [
        Text('No alerts yet', style: AppText.serif(13)),
        const SizedBox(height: 6),
        Text(
          'Nothing new right now. Alerts appear as your cycle nears a milestone.',
          textAlign: TextAlign.center,
          style: AppText.sans(11, h: 1.5, c: AppColors.muted),
        ),
      ],
    ),
  );

  Widget _buildAlert(BuildContext context, AlertProvider provider, AlertItem a, DateTime now) {
    final unread = !a.read;
    return Dismissible(
      key: ValueKey(a.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) {
        provider.dismiss(a.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Alert dismissed', style: AppText.sans(12, c: Colors.white)),
            action: SnackBarAction(label: 'Undo', onPressed: () => provider.restore(a)),
          ),
        );
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 18),
        decoration: BoxDecoration(color: AppColors.pinkBg, borderRadius: BorderRadius.circular(18)),
        child: Text('Dismiss', style: AppText.sans(11, w: FontWeight.w600, c: AppColors.pinkDark)),
      ),
      child: GestureDetector(
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
                        Text(AppDate.short(a.eventDate), style: AppText.sans(9, w: FontWeight.w600, c: unread ? AppColors.pur : AppColors.muted)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      a.body,
                      style: AppText.sans(11, h: 1.55, c: unread ? AppColors.body : AppColors.muted),
                    ),
                    const SizedBox(height: 4),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(_ago(a.createdAt, now), style: AppText.sans(9, c: AppColors.muted)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AlertProvider>();
    final alerts = provider.items;
    final now = DateTime.now();
    final unread = provider.unreadCount;
    return Scaffold(
      appBar: const AppTopBar(title: 'Alerts'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 6, 16, 14),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Recent Alerts', style: AppText.sec),
              if (unread > 0)
                TextButton(
                  onPressed: provider.markAllRead,
                  style: TextButton.styleFrom(foregroundColor: AppColors.pur, padding: const EdgeInsets.symmetric(horizontal: 8), minimumSize: const Size(48, 36)),
                  child: Text('Mark all read', style: AppText.sans(11, w: FontWeight.w600, c: AppColors.pur)),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text('Based on your cycle. Tap to open alert settings.', style: AppText.sub),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: () => context.go('/profile'),
              style: TextButton.styleFrom(foregroundColor: AppColors.pur, padding: const EdgeInsets.symmetric(horizontal: 4), minimumSize: const Size(48, 32), tapTargetSize: MaterialTapTargetSize.shrinkWrap),
              child: Text('Alert settings', style: AppText.sans(11, w: FontWeight.w600, c: AppColors.pur).copyWith(decoration: TextDecoration.underline)),
            ),
          ),
          const SizedBox(height: 12),
          if (alerts.isEmpty)
            _buildEmpty()
          else
            for (final a in alerts) ...[
              _buildAlert(context, provider, a, now),
              const SizedBox(height: 12),
            ],
        ],
      ),
    );
  }
}
