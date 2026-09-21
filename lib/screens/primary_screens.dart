import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_providers.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/witchy_widgets.dart';
import '../widgets/cycle_widgets.dart';

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
        const Row(children: [
          Expanded(child: StatCard(label: 'Bleeding In', value: '14 Days', sub: 'Nov 10 · predicted')),
          SizedBox(width: 12),
          Expanded(child: StatCard(label: 'Fertility Window', value: 'Peak Today', sub: 'High chance', valueColor: AppColors.pink)),
        ]),
        const SizedBox(height: 12),
        Text("Log Today's Magic", style: AppText.sec),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(child: QuickAction(icon: Icons.water_drop_outlined, label: 'Flow', onTap: () => Navigator.pushNamed(context, '/blood'))),
          const SizedBox(width: 10),
          Expanded(child: QuickAction(icon: Icons.favorite_border, label: 'Mood', onTap: () => Navigator.pushNamed(context, '/log'))),
          const SizedBox(width: 10),
          Expanded(child: QuickAction(icon: Icons.show_chart, label: 'Pain', onTap: () => Navigator.pushNamed(context, '/log'))),
          const SizedBox(width: 10),
          Expanded(child: QuickAction(icon: Icons.description_outlined, label: 'Notes', onTap: () => Navigator.pushNamed(context, '/log'))),
        ]),
        const SizedBox(height: 12),
        WitchyCard(
          dark: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                const Icon(Icons.auto_awesome, size: 14, color: AppColors.gold),
                const SizedBox(width: 7),
                Text('Daily Astral Insight', style: AppText.serif(13.5, c: Colors.white)),
                const Spacer(),
                WitchyTag.gold('Scorpio Moon'),
              ]),
              const SizedBox(height: 8),
              Text('As your body summits this cycle peak, intuitive energies run deep. Ground your power with Mugwort tea, and honor your physical fatigue.',
                  style: AppText.sans(11.5, c: AppColors.insightText, h: 1.55)),
            ],
          ),
        ),
      ],
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
        WitchyCard(
          child: Column(
            children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const Icon(Icons.chevron_left, size: 16, color: AppColors.muted),
                Text('October 2026', style: AppText.serif(13.5)),
                const Icon(Icons.chevron_right, size: 16, color: AppColors.muted),
              ]),
              const SizedBox(height: 12),
              const CycleCalendar(),
            ],
          ),
        ),
        WitchyCard(
          child: Column(
            children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('October 15, 2026', style: AppText.serif(13.5)), WitchyTag.pink('Period Day 2')]),
              const SizedBox(height: 8),
              Row(children: [const Icon(Icons.water_drop_outlined, size: 15, color: AppColors.pink), const SizedBox(width: 8), Text('Medium bleed flow intensity', style: AppText.sans(11.5, c: AppColors.chipText))]),
              const SizedBox(height: 5),
              Row(children: [const Icon(Icons.favorite_border, size: 15, color: AppColors.pur), const SizedBox(width: 8), Text('Intuitive, reflective mood', style: AppText.sans(11.5, c: AppColors.chipText))]),
            ],
          ),
        ),
      ],
    );
  }
}

class LogScreen extends StatelessWidget {
  const LogScreen({super.key});
  static const flows = ['None', 'Light', 'Medium', 'Heavy'];
  static const moods = [('Enchanted', Icons.auto_awesome, AppColors.pur), ('Grounded', Icons.eco_outlined, Color(0xFF4C8C4A)), ('Shadowy', Icons.dark_mode_outlined, Color(0xFF5B4A8C)), ('Restless', Icons.bolt_outlined, Color(0xFFC2703B))];
  static const symptoms = [('Uterine Cramps', Icons.warning_amber_outlined, AppColors.pur), ('Headache', Icons.bolt_outlined, Color(0xFFC2703B)), ('Bloating', Icons.water_drop_outlined, Color(0xFF3E7BC0)), ('Fatigue', Icons.dark_mode_outlined, Color(0xFF5B4A8C))];

  @override
  Widget build(BuildContext context) {
    final log = context.watch<LogProvider>();
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 14),
      children: [
        Text("Log Today's Energy", style: AppText.serif(17)),
        const SizedBox(height: 4),
        Text('Select physical and mental essences flowing within you.', style: AppText.sub),
        const SizedBox(height: 12),
        Text('Bleed Intensity', style: AppText.sec),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [for (final f in flows) WitchyChip(label: f, selected: log.flow == f, onTap: () => context.read<LogProvider>().setFlow(f))],
        ),
        const SizedBox(height: 12),
        Text('Emotional Currents', style: AppText.sec),
        const SizedBox(height: 8),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 3.4,
          children: [for (final m in moods) WitchyChip(label: m.$1, icon: m.$2, iconColor: m.$3, selected: log.moods.contains(m.$1), onTap: () => context.read<LogProvider>().toggleMood(m.$1))],
        ),
        const SizedBox(height: 12),
        Text('Somatic Echoes', style: AppText.sec),
        const SizedBox(height: 8),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 3.4,
          children: [for (final s in symptoms) WitchyChip(label: s.$1, icon: s.$2, iconColor: s.$3, selected: log.symptoms.contains(s.$1), onTap: () => context.read<LogProvider>().toggleSymptom(s.$1))],
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
        WitchyCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [Text('Stardust Cycle Trends', style: AppText.secIn), const SizedBox(height: 10), const TrendBars()],
          ),
        ),
        const Row(children: [
          Expanded(child: StatCard(label: '', value: '28.4 d', sub: 'Average Cycle')),
          SizedBox(width: 12),
          Expanded(child: StatCard(label: '', value: '5.2 d', sub: 'Average Bleed')),
        ]),
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
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(date, style: AppText.sans(12, w: FontWeight.w600, c: AppColors.ink)), Text(len, style: AppText.sans(9.5, c: AppColors.muted))]),
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
    final s = context.watch<SettingsProvider>();
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 14),
      children: [
        Column(children: [
          const WitchyAvatar(initials: 'HS', big: true),
          const SizedBox(height: 6),
          Text('High Priestess Selene', style: AppText.serif(18)),
          const SizedBox(height: 2),
          Text('SCORPIO MOON · THIRD CYCLE', style: AppText.sans(9, w: FontWeight.w700, c: AppColors.gold).copyWith(letterSpacing: 1.2)),
          const Icon(Icons.star, size: 12, color: AppColors.gold),
        ]),
        const SizedBox(height: 12),
        WitchyCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Lunar Alignments', style: AppText.secIn),
              SettingsRow(label: 'Average Cycle Length', trailing: Text('29 Days', style: AppText.sans(12, w: FontWeight.w600, c: AppColors.pur)), first: true),
              SettingsRow(label: 'Bleeding Phase Length', trailing: Text('5 Days', style: AppText.sans(12, w: FontWeight.w600, c: AppColors.pur))),
              SettingsRow(label: 'Receive Lunar Notifications', trailing: Switch(value: s.lunarNotifications, activeColor: AppColors.pur, onChanged: (v) => context.read<SettingsProvider>().setLunar(v))),
            ],
          ),
        ),
        WitchyCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Apothecary Settings', style: AppText.secIn),
              SettingsRow(label: 'Dark Magic Mode', trailing: Switch(value: s.darkMode, activeColor: AppColors.pur, onChanged: (v) => context.read<SettingsProvider>().setDark(v)), first: true),
              SettingsRow(label: 'Cosmic Partner Bond', trailing: GestureDetector(onTap: () => Navigator.pushNamed(context, '/binding'), child: Text('1 Active', style: AppText.sans(11, w: FontWeight.w600, c: AppColors.pur)))),
            ],
          ),
        ),
        Center(child: Text('Witchy App\nVersion 1.2.4 · Made with celestial energy', textAlign: TextAlign.center, style: AppText.sans(9.5, c: AppColors.placeholder, h: 1.6))),
      ],
    );
  }
}
