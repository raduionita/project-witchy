import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/flow_intensity.dart';
import '../../providers/cycle_provider.dart';
import '../../utils/app_theme.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_card.dart';
import '../../widgets/witchy_chip.dart';
import '../../widgets/witchy_slider_card.dart';
import '../../l10n/app_localizations.dart';

/// Sovereign Blood: Qwen period-detail screen (volume, pain, notes).
class SovereignBloodScreen extends StatefulWidget {
  const SovereignBloodScreen({super.key, required this.date});

  final DateTime date;

  @override
  State<SovereignBloodScreen> createState() => _SovereignBloodScreenState();
}

class _SovereignBloodScreenState extends State<SovereignBloodScreen> {
  FlowIntensity _volume = FlowIntensity.heavy;
  double _pain = 6;
  final TextEditingController _notes = TextEditingController(text: 'Drank chamomile raspberry leaf infusion. Felt waves of emotional clearing in the afternoon.');
  bool _saving = false;

  Future<void> _save() async {
    setState(() => _saving = true);
    await context.read<CycleProvider>().logPeriodDay(widget.date, intensity: _volume, symptoms: const <String>['Cramps'], notes: _notes.text.isEmpty ? null : _notes.text);
    if (!mounted) return;
    setState(() => _saving = false);
    Navigator.of(context).pop(true);
  }

  @override
  void dispose() {
    _notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final CycleProvider cycle = context.watch<CycleProvider>();
    final int dayOfBleed = cycle.periodDays.where((DateTime d) => d.isBefore(widget.date.add(const Duration(days: 1)))).length;
    return Scaffold(
      backgroundColor: AppColors.kCanvas,
      appBar: AppBar(title: const Text('Sovereign Blood'), backgroundColor: AppColors.kCanvas),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 6, 16, 24),
        children: [
          AppCard(
            dark: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('SHEDDING PHASE', style: TextStyle(fontSize: 9, letterSpacing: 1.26, fontWeight: FontWeight.w700, color: AppColors.kGold)),
                const SizedBox(height: 6),
                Text('Day $dayOfBleed of ${cycle.profile?.averagePeriodLength ?? 5}', style: Theme.of(context).textTheme.displaySmall?.copyWith(fontSize: 23, color: Colors.white)),
                const SizedBox(height: 8),
                const Row(children: [Icon(Icons.water_drop, size: 20, color: AppColors.kGold), SizedBox(width: 5), Icon(Icons.water_drop, size: 20, color: AppColors.kGold), SizedBox(width: 5), Icon(Icons.water_drop, size: 20, color: AppColors.kGold)]),
              ],
            ),
          ),
          const SizedBox(height: 12),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Bleeding Volume', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.kTextSecondary)),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final FlowIntensity v in FlowIntensity.values)
                      WitchyChip(label: flowIntensityLabel(l10n, v), selected: _volume == v, onTap: () => setState(() => _volume = v)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          WitchySliderCard(label: 'Uterine Contraction Pain', valueLabel: 'Level ${_pain.round()}', value: _pain, min: 0, max: 10, onChanged: (double v) => setState(() => _pain = v)),
          const SizedBox(height: 12),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Grimoire Scribbles', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.kTextSecondary)),
                const SizedBox(height: 10),
                TextField(controller: _notes, maxLines: 4, minLines: 3, decoration: const InputDecoration(hintText: 'How does your temple feel today?')),
              ],
            ),
          ),
          const SizedBox(height: 16),
          AppButton(label: 'Save Bleed Log', icon: Icons.auto_awesome, isLoading: _saving, onPressed: _save),
        ],
      ),
    );
  }
}
