import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_providers.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/witchy_widgets.dart';
import '../widgets/cycle_widgets.dart';
import '../widgets/log_bottom_sheet.dart';

class SanctuaryScreen extends StatelessWidget {
  const SanctuaryScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 14),
      children: [
        const SizedBox(height: 8),
        const CycleOrb(),
        const SizedBox(height: 12),
        Row(children: [const Expanded(child: StatCard(label: 'Bleeding In', value: '14 Days', sub: 'Nov 10 · predicted')), const SizedBox(width: 12), Expanded(child: _FertilityPeakCard())]),
        const SizedBox(height: 12),
        Text("Log Today's Magic", style: AppText.sec),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: QuickAction(icon: Icons.water_drop_outlined, label: 'Flow', onTap: () => Navigator.pushNamed(context, '/cycle'))),
            const SizedBox(width: 10),
            Expanded(child: QuickAction(icon: Icons.favorite_border, label: 'Mood', onTap: () => showLogSheet(context, DateTime.now()))),
            const SizedBox(width: 10),
            Expanded(child: QuickAction(icon: Icons.show_chart, label: 'Pain', onTap: () => showLogSheet(context, DateTime.now()))),
            const SizedBox(width: 10),
            Expanded(child: QuickAction(icon: Icons.description_outlined, label: 'Notes', onTap: () => showLogSheet(context, DateTime.now()))),
          ],
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () => Navigator.pushNamed(context, '/library'),
          child: WitchyCard(
            dark: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.auto_awesome, size: 14, color: AppColors.gold),
                    const SizedBox(width: 7),
                    Text('Daily Astral Insight', style: AppText.serif(13.5, c: Colors.white)),
                    const Spacer(),
                    WitchyTag.gold('Scorpio Moon'),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'As your body summits this cycle peak, intuitive energies run deep. Ground your power with Mugwort tea, and honor your physical fatigue.',
                  style: AppText.sans(11.5, c: AppColors.insightText, h: 1.55),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _FertilityPeakCard extends StatelessWidget {
  const _FertilityPeakCard();
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/fertility'),
      child: const StatCard(label: 'Fertility Window', value: 'Peak Today', sub: 'High chance', valueColor: AppColors.pink),
    );
  }
}

class CycleMapScreen extends StatelessWidget {
  const CycleMapScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 14),
      children: [
        GestureDetector(
          onTap: () => Navigator.pushNamed(context, '/chart'),
          child: WitchyCard(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Icon(Icons.chevron_left, size: 16, color: AppColors.muted),
                    Text('October 2026', style: AppText.serif(13.5)),
                    const Icon(Icons.chevron_right, size: 16, color: AppColors.muted),
                  ],
                ),
                const SizedBox(height: 12),
                CycleCalendar(onDayTap: (day) => showLogSheet(context, DateTime(2026, 10, day))),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        WitchyCard(
          child: Column(
            children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('October 15, 2026', style: AppText.serif(13.5)), WitchyTag.pink('Period Day 2')]),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.water_drop_outlined, size: 15, color: AppColors.pink),
                  const SizedBox(width: 8),
                  Text('Medium bleed flow intensity', style: AppText.sans(11.5, c: AppColors.chipText)),
                ],
              ),
              const SizedBox(height: 5),
              Row(
                children: [
                  const Icon(Icons.favorite_border, size: 15, color: AppColors.pur),
                  const SizedBox(width: 8),
                  Text('Intuitive, reflective mood', style: AppText.sans(11.5, c: AppColors.chipText)),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class RecordsScreen extends StatelessWidget {
  const RecordsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 14),
      children: [
        GestureDetector(
          onTap: () => Navigator.pushNamed(context, '/chart'),
          child: WitchyCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Stardust Cycle Trends', style: AppText.secIn), const SizedBox(height: 10), const TrendBars()])),
        ),
        const SizedBox(height: 12),
        const Row(
          children: [Expanded(child: StatCard(label: '', value: '28.4 d', sub: 'Average Cycle')), SizedBox(width: 12), Expanded(child: StatCard(label: '', value: '5.2 d', sub: 'Average Bleed'))],
        ),
        const SizedBox(height: 12),
        WitchyCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Chronology of Bleeds', style: AppText.secIn),
              _Crow(date: 'Sept 14 – Sept 19', len: '5 Days', tag: 'On Time', pink: false),
              _Crow(date: 'Aug 16 – Aug 21', len: '5 Days', tag: 'On Time', pink: false),
              _Crow(date: 'July 19 – July 23', len: '4 Days', tag: 'Short', pink: true),
            ],
          ),
        ),
      ],
    );
  }
}

class _Crow extends StatelessWidget {
  final String date;
  final String len;
  final String tag;
  final bool pink;
  const _Crow({required this.date, required this.len, required this.tag, required this.pink});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 9),
      decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppColors.line))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [Text(date, style: AppText.sans(12, w: FontWeight.w600, c: AppColors.ink)), Text(len, style: AppText.sans(9.5, c: AppColors.muted))],
          ),
          pink ? WitchyTag.pink(tag) : WitchyTag(tag),
        ],
      ),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final bells = context.watch<RemindersProvider>().items.where((r) => r.enabled).length;
    return Scaffold(
      appBar: WitchyAppBar(
        title: 'Witch Profile',
        leading: Icons.arrow_back,
        onLeading: () {
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          } else {
            Navigator.pushNamed(context, '/dashboard');
          }
        },
        action: Icons.settings_outlined,
        onAction: () => Navigator.pushNamed(context, '/settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 6, 16, 14),
        children: [
          Column(
            children: [
              const WitchyAvatar(initials: 'HS', big: true),
              const SizedBox(height: 6),
              Text('High Priestess Selene', style: AppText.serif(18)),
              const SizedBox(height: 2),
              Text('SCORPIO MOON · THIRD CYCLE', style: AppText.sans(9, w: FontWeight.w700, c: AppColors.gold).copyWith(letterSpacing: 1.2)),
              const Icon(Icons.star, size: 12, color: AppColors.gold),
            ],
          ),
          const SizedBox(height: 12),
          WitchyCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Lunar Alignments', style: AppText.secIn),
                SettingsRow(label: 'Average Cycle Length', trailing: Text('29 Days', style: AppText.sans(12, w: FontWeight.w600, c: AppColors.pur)), first: true),
                SettingsRow(label: 'Bleeding Phase Length', trailing: Text('5 Days', style: AppText.sans(12, w: FontWeight.w600, c: AppColors.pur))),
                SettingsRow(
                  label: 'Notification Preferences',
                  trailing: GestureDetector(onTap: () => Navigator.pushNamed(context, '/settings'), child: Text('Manage', style: AppText.sans(11, w: FontWeight.w600, c: AppColors.pur))),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          WitchyCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Apothecary Settings', style: AppText.secIn),
                SettingsRow(label: 'Appearance', trailing: GestureDetector(onTap: () => Navigator.pushNamed(context, '/settings'), child: Text('Manage', style: AppText.sans(11, w: FontWeight.w600, c: AppColors.pur))), first: true),
                SettingsRow(
                  label: 'Gestation Spells',
                  trailing: GestureDetector(onTap: () => Navigator.pushNamed(context, '/pregnancy'), child: Text('View', style: AppText.sans(11, w: FontWeight.w600, c: AppColors.pur))),
                ),
                SettingsRow(
                  label: 'Cosmic Partner Bond',
                  trailing: GestureDetector(onTap: () => Navigator.pushNamed(context, '/binding'), child: Text('1 Active', style: AppText.sans(11, w: FontWeight.w600, c: AppColors.pur))),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          WitchyCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Amulet Bells', style: AppText.secIn),
                const SizedBox(height: 4),
                Text('$bells of 5 bells active', style: AppText.sans(11.5, c: AppColors.muted)),
                const SizedBox(height: 10),
                WitchyButton(label: 'Open Amulet Reminders', icon: Icons.notifications_outlined, onTap: () => Navigator.pushNamed(context, '/reminders')),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Center(child: Text('Witchy App\nVersion 1.2.4 · Made with celestial energy', textAlign: TextAlign.center, style: AppText.sans(9.5, c: AppColors.placeholder, h: 1.6))),
        ],
      ),
    );
  }
}
