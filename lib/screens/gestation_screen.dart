import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../common/gestation_content.dart';
import '../providers/gestation_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_icons.dart';
import '../widgets/icon_badge.dart';
import '../widgets/app_top_bar.dart';
import '../widgets/app_button.dart';
import '../widgets/app_card.dart';
import '../widgets/app_tag.dart';

class GestationScreen extends StatelessWidget {
  const GestationScreen({super.key});

  Future<void> _pickLmp(BuildContext context) async {
    final provider = context.read<GestationProvider>();
    final picked = await showDatePicker(
      context: context,
      initialDate: provider.lmpDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 300)),
      lastDate: DateTime.now(),
    );
    if (picked != null && context.mounted) await provider.setLmp(picked);
  }

  String _remainingCopy(GestationProvider g) {
    if (g.daysPastDue() > 0) return '${g.daysPastDue()} days past the due date';
    if (g.daysRemaining() == 0) return 'The arrival portal opens today';
    return '${g.daysRemaining()} days until arrival portal opens';
  }

  Widget _buildEmpty(BuildContext context) {
    return AppCard(
      child: Column(
        children: [
          Text('Your gestation journey awaits', style: AppText.serif(15)),
          const SizedBox(height: 8),
          Text(
            'Share the first day of your last bleeding phase and the sanctuary will chart every week of the path ahead.',
            textAlign: TextAlign.center,
            style: AppText.sans(11.5, h: 1.55, c: AppColors.muted),
          ),
          const SizedBox(height: 14),
          AppButton(label: 'Set last period date', onTap: () => _pickLmp(context)),
        ],
      ),
    );
  }

  Widget _buildHero(GestationProvider g) {
    final due = g.dueDate!;
    return AppCard(
      dark: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('GESTATION SANCTUARY', style: AppText.sans(9, w: FontWeight.w700, c: AppColors.gold).copyWith(letterSpacing: 1.2)),
          const SizedBox(height: 6),
          Text('Week ${g.week()} (Day ${g.dayOfWeek()})', style: AppText.serif(21, c: Colors.white)),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(value: g.progress(), minHeight: 6, backgroundColor: Colors.white.withValues(alpha: .22), valueColor: const AlwaysStoppedAnimation(AppColors.gold)),
          ),
          const SizedBox(height: 8),
          Text(_remainingCopy(g), style: AppText.sans(10.5, c: AppColors.orbSub)),
          const SizedBox(height: 3),
          Text('Due ${DateFormat('MMM d, yyyy').format(due)} · T${g.trimester()} Trimester', style: AppText.sans(9.5, c: AppColors.placeholder)),
        ],
      ),
    );
  }

  Widget _buildComparison(GestationProvider g) {
    final content = GestationContent.forWeek(g.week());
    return AppCard(
      child: Column(
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Spiritual Comparison', style: AppText.serif(12.5)), AppTag(content.size)]),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const IconBadge(icon: AppIcons.search),
              const SizedBox(width: 10),
              Expanded(child: Text(content.development, style: AppText.sans(11.5, h: 1.55))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTips(GestationProvider g) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Astral Gestation Tips', style: AppText.secIn),
          const SizedBox(height: 6),
          Text(GestationContent.forWeek(g.week()).tip, style: AppText.sans(11.5, h: 1.55)),
        ],
      ),
    );
  }

  Widget _buildLmpRow(BuildContext context, GestationProvider g) {
    return AppCard(
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () => _pickLmp(context),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Last bleeding phase', style: AppText.sans(11, c: AppColors.muted)),
                  const SizedBox(height: 3),
                  Text(DateFormat('MMMM d, yyyy').format(g.lmpDate!), style: AppText.serif(14)),
                ],
              ),
              const FaIcon(AppIcons.cal, size: AppIconSize.head, color: AppColors.muted),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final g = context.watch<GestationProvider>();
    return Scaffold(
      appBar: const AppTopBar(title: 'Gestation Spells', action: AppIcons.heart),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 6, 16, 14),
        children: [
          if (!g.hasLmp)
            _buildEmpty(context)
          else ...[
            _buildHero(g),
            const SizedBox(height: 12),
            _buildComparison(g),
            const SizedBox(height: 12),
            _buildTips(g),
            const SizedBox(height: 12),
            _buildLmpRow(context, g),
          ],
        ],
      ),
    );
  }
}
