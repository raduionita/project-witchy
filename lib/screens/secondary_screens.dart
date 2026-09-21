import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/witchy_models.dart';
import '../providers/app_providers.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/witchy_widgets.dart';

class BloodScreen extends StatelessWidget {
  const BloodScreen({super.key});
  static const volumes = ['Spotting', 'Light', 'Medium', 'Heavy'];
  @override
  Widget build(BuildContext context) {
    final log = context.watch<LoggingProvider>();
    return Scaffold(
      appBar: const WitchyAppBar(title: 'Sovereign Blood'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 6, 16, 14),
        children: [
          WitchyCard(
            dark: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('SHEDDING PHASE', style: AppText.sans(9, w: FontWeight.w700, c: AppColors.gold).copyWith(letterSpacing: 1.2)),
                const SizedBox(height: 6),
                Text('Day 3 of 5', style: AppText.serif(23, c: Colors.white)),
                const SizedBox(height: 8),
                const Row(
                  children: [
                    Icon(Icons.water_drop, size: 18, color: AppColors.gold),
                    SizedBox(width: 5),
                    Icon(Icons.water_drop, size: 18, color: AppColors.gold),
                    SizedBox(width: 5),
                    Icon(Icons.water_drop, size: 18, color: AppColors.gold),
                  ],
                ),
              ],
            ),
          ),
          WitchyCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Bleeding Volume', style: AppText.secIn),
                const SizedBox(height: 10),
                Wrap(spacing: 8, runSpacing: 8, children: [for (final v in volumes) WitchyChip(label: v, selected: log.flow == v, onTap: () => context.read<LoggingProvider>().setFlow(v))]),
              ],
            ),
          ),
          WitchyCard(
            child: WitchySliderRow(
              label: 'Uterine Contraction Pain',
              value: 'Level ${log.pain.round()}',
              min: 0,
              max: 10,
              current: log.pain,
              onChanged: (v) => context.read<LoggingProvider>().setPain(v),
            ),
          ),
          WitchyCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Grimoire Scribbles', style: AppText.secIn),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(11),
                  decoration: BoxDecoration(color: AppColors.fieldBg, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.line)),
                  child: Text(log.notes, style: AppText.sans(11.5, c: AppColors.chipText, h: 1.55)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class GestationScreen extends StatelessWidget {
  const GestationScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const WitchyAppBar(title: 'Gestation Spells', action: Icons.favorite_border),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 6, 16, 14),
        children: [
          WitchyCard(
            dark: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('GESTATION SANCTUARY', style: AppText.sans(9, w: FontWeight.w700, c: AppColors.gold).copyWith(letterSpacing: 1.2)),
                const SizedBox(height: 6),
                Text('Week 12 (Day 4)', style: AppText.serif(21, c: Colors.white)),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(value: 0.30, minHeight: 6, backgroundColor: Colors.white.withValues(alpha: .22), valueColor: const AlwaysStoppedAnimation(AppColors.gold)),
                ),
                const SizedBox(height: 8),
                Text('196 days until arrival portal opens', style: AppText.sans(10.5, c: AppColors.orbSub)),
              ],
            ),
          ),
          WitchyCard(
            child: Column(
              children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Spiritual Comparison', style: AppText.serif(12.5)), WitchyTag('Lime Size')]),
                const SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const IconBadge(icon: Icons.search),
                    const SizedBox(width: 10),
                    Expanded(child: Text('Your little spirit matches a ripe Lime. Organs are fully formed and commencing magical function.', style: AppText.sans(11.5, h: 1.55))),
                  ],
                ),
              ],
            ),
          ),
          WitchyCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Astral Gestation Tips', style: AppText.secIn),
                const SizedBox(height: 6),
                Text(
                  'First-trimester tiredness is shifting. Elevate your iron levels with organic spinach potions and continue speaking soft, loving mantras to your belly.',
                  style: AppText.sans(11.5, h: 1.55),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AlertsScreen extends StatelessWidget {
  const AlertsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final alerts = MockData.alerts();
    return Scaffold(
      appBar: const WitchyAppBar(title: 'Celestial Alerts'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 6, 16, 14),
        children: [
          Text('The cosmos whispers its reminders. Align your biological temple.', style: AppText.sub),
          const SizedBox(height: 12),
          for (final a in alerts) ...[
            WitchyCard(
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

class CovenScreen extends StatefulWidget {
  const CovenScreen({super.key});
  @override
  State<CovenScreen> createState() => _CovenScreenState();
}

class _CovenScreenState extends State<CovenScreen> {
  int tab = 0;
  @override
  Widget build(BuildContext context) {
    final posts = MockData.posts();
    return Scaffold(
      floatingActionButton: Container(
        width: 50,
        height: 50,
        decoration: const BoxDecoration(shape: BoxShape.circle, gradient: AppColors.plumGradient, boxShadow: [AppColors.primaryShadow]),
        child: const Icon(Icons.add, color: AppColors.gold),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 6, 16, 14),
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(color: AppColors.tabBg, borderRadius: BorderRadius.circular(12)),
            child: Row(
              children: [
                for (var i = 0; i < 2; i++)
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => tab = i),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(color: tab == i ? AppColors.plum : null, borderRadius: BorderRadius.circular(9)),
                        child: Text(
                          i == 0 ? 'Recent Whispers' : "Ancients' Wisdom",
                          style: AppText.sans(11, w: tab == i ? FontWeight.w600 : FontWeight.w500, c: tab == i ? Colors.white : AppColors.tabText),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          for (final p in posts) ...[
            WitchyCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      WitchyAvatar(initials: p.initials, size: 34),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(p.author, style: AppText.serif(12.5)), Text(p.meta, style: AppText.sans(9, c: AppColors.muted))]),
                      ),
                      WitchyTag(p.tag),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(p.body, style: AppText.sans(11, h: 1.55)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(Icons.favorite_border, size: 12, color: AppColors.muted),
                      const SizedBox(width: 5),
                      Text('${p.likes}', style: AppText.sans(10.5, c: AppColors.muted)),
                      const SizedBox(width: 16),
                      Icon(Icons.chat_bubble_outline, size: 12, color: AppColors.muted),
                      const SizedBox(width: 5),
                      Text('${p.comments}', style: AppText.sans(10.5, c: AppColors.muted)),
                    ],
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

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final articles = MockData.articles();
    return Scaffold(
      appBar: const WitchyAppBar(title: 'Apothecary Library'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 6, 16, 14),
        children: [
          const WitchyTextField(hint: 'Search spells, herbs, anatomy...', lead: Icons.search),
          const SizedBox(height: 12),
          for (final a in articles) ...[
            GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/wellness/detail', arguments: a),
              child: WitchyCard(
                child: Row(
                  children: [
                    Container(width: 62, height: 62, decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), gradient: LinearGradient(colors: a.thumb))),
                    const SizedBox(width: 11),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(a.category, style: AppText.sans(8.5, w: FontWeight.w700, c: AppColors.gold).copyWith(letterSpacing: 1.0)),
                              Text(a.readTime, style: AppText.sans(9, c: AppColors.muted)),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(a.title, style: AppText.serif(12.5), maxLines: 1, overflow: TextOverflow.ellipsis),
                          Text(a.excerpt, style: AppText.sans(10, c: AppColors.muted), maxLines: 1, overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

class RemindersScreen extends StatelessWidget {
  const RemindersScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final rp = context.watch<RemindersProvider>();
    return Scaffold(
      appBar: const WitchyAppBar(title: 'Amulet Reminders'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 6, 16, 14),
        children: [
          Text('Calibrate mystical bells to warn you of upcoming tides.', style: AppText.sub),
          const SizedBox(height: 12),
          for (var i = 0; i < rp.items.length; i++) ...[
            WitchyCard(
              child: Column(
                children: [
                  Row(
                    children: [
                      IconBadge(icon: rp.items[i].icon, bg: rp.items[i].badgeBg, fg: rp.items[i].badgeFg),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [Text(rp.items[i].title, style: AppText.serif(12.5)), Text(rp.items[i].subtitle, style: AppText.sans(9.5, c: AppColors.muted))],
                        ),
                      ),
                      Switch(value: rp.items[i].enabled, activeColor: AppColors.pur, onChanged: (v) => context.read<RemindersProvider>().toggle(i, v)),
                    ],
                  ),
                  if (rp.items[i].enabled) ...[
                    const SizedBox(height: 11),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [InfoPill(icon: Icons.schedule_outlined, label: rp.items[i].time), InfoPill(icon: Icons.auto_awesome, label: rp.items[i].freq)],
                    ),
                  ],
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

class BindingScreen extends StatelessWidget {
  const BindingScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final s = context.watch<SettingsProvider>();
    return Scaffold(
      appBar: const WitchyAppBar(title: 'Coven Binding'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 6, 16, 14),
        children: [
          WitchyCard(
            child: Column(
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [WitchyAvatar(initials: 'HS'), SizedBox(width: 12), Icon(Icons.auto_awesome, color: AppColors.gold, size: 26), SizedBox(width: 12), WitchyAvatar(initials: 'KP')],
                ),
                const SizedBox(height: 10),
                Text('Bind Cosmic Partners', style: AppText.serif(15)),
                const SizedBox(height: 6),
                Text('Invite partners or coven members to sync and visualize predictions on a shared celestial map.', textAlign: TextAlign.center, style: AppText.sub),
              ],
            ),
          ),
          WitchyCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Invite Cosmic Bond', style: AppText.secIn),
                const SizedBox(height: 8),
                const WitchyTextField(hint: 'partner@cosmic.com', lead: Icons.mail_outline),
                const SizedBox(height: 12),
                WitchyButton(label: 'Send Binding Scroll', icon: Icons.auto_awesome, onTap: () {}),
              ],
            ),
          ),
          WitchyCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Scroll Visibility', style: AppText.secIn),
                SettingsRow(
                  label: 'Share Bleeding Predictions',
                  trailing: Switch(value: s.shareBleed, activeColor: AppColors.pur, onChanged: (v) => context.read<SettingsProvider>().setShareBleed(v)),
                  first: true,
                ),
                SettingsRow(label: 'Share Fertile Windows', trailing: Switch(value: s.shareFertile, activeColor: AppColors.pur, onChanged: (v) => context.read<SettingsProvider>().setShareFertile(v))),
                SettingsRow(
                  label: 'Share Anonymized Symptom Log',
                  trailing: Switch(value: s.shareSymptoms, activeColor: AppColors.pur, onChanged: (v) => context.read<SettingsProvider>().setShareSymptoms(v)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
