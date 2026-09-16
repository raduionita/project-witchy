import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../models/flow_intensity.dart';
import '../../providers/cycle_provider.dart';
import '../../utils/app_theme.dart';
import '../../widgets/app_button.dart';
import 'widgets/chip_icons.dart';
import 'widgets/symptom_chip_group.dart';

/// Common quick moods offered when logging a day, localized via [l10n].
List<String> kCommonMoods(AppLocalizations l10n) => <String>[
  l10n.moodHappy,
  l10n.moodCalm,
  l10n.moodAnxious,
  l10n.moodIrritable,
  l10n.moodSad,
  l10n.moodEnergetic,
];

/// Bottom sheet for logging a period day with intensity, symptoms and mood.
class LogPeriodSheet extends StatefulWidget {
  const LogPeriodSheet({super.key, required this.date});

  final DateTime date;

  /// Shows the sheet and awaits a boolean indicating whether a log was saved.
  static Future<bool> show({
    required BuildContext context,
    required DateTime date,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (BuildContext context) => LogPeriodSheet(date: date),
    ).then((bool? saved) => saved ?? false);
  }

  @override
  State<LogPeriodSheet> createState() => _LogPeriodSheetState();
}

class _LogPeriodSheetState extends State<LogPeriodSheet> {
  FlowIntensity? _intensity;
  final Set<String> _symptoms = <String>{};
  String? _mood;
  final TextEditingController _notes = TextEditingController();

  Future<void> _save() async {
    await context.read<CycleProvider>().logPeriodDay(
      widget.date,
      intensity: _intensity,
      symptoms: _symptoms.toList(),
      mood: _mood,
      notes: _notes.text.isEmpty ? null : _notes.text,
    );
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.labelLarge?.copyWith(
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _intensitySelector() {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return Row(
      children:
          FlowIntensity.values.map((FlowIntensity intensity) {
            final bool selected = _intensity == intensity;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.kXs),
                child: ChoiceChip(
                  avatar: Icon(logFlowIcon(intensity), size: 18),
                  showCheckmark: false,
                  label: Text(flowIntensityLabel(l10n, intensity)),
                  selected: selected,
                  onSelected: (_) => setState(() => _intensity = intensity),
                ),
              ),
            );
          }).toList(),
    );
  }

  Widget _chipSelector({
    required List<String> items,
    required Set<String> selected,
    required ValueChanged<String> onToggle,
  }) {
    return Wrap(
      spacing: AppSpacing.kSm,
      runSpacing: AppSpacing.kSm,
      children:
          items
              .map(
                (String item) => FilterChip(
                  avatar: Icon(logMoodIcon(item), size: 18),
                  showCheckmark: false,
                  label: Text(item),
                  selected: selected.contains(item),
                  onSelected: (_) => onToggle(item),
                ),
              )
              .toList(),
    );
  }

  @override
  void dispose() {
    _notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.kLg,
        right: AppSpacing.kLg,
        bottom: AppSpacing.kLg + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: AppSpacing.kMd),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    l10n.logPeriodTitle(
                      DateFormat('EEE, MMM d').format(widget.date),
                    ),
                    textAlign: TextAlign.right,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.kMd),
                  _sectionTitle(l10n.logFlowIntensity),
                  const SizedBox(height: AppSpacing.kSm),
                  _intensitySelector(),
                  const SizedBox(height: AppSpacing.kMd),
                  SymptomChipGroup(
                    selected: _symptoms,
                    onToggle:
                        (String value) => setState(() {
                          if (!_symptoms.add(value)) _symptoms.remove(value);
                        }),
                  ),
                  const SizedBox(height: AppSpacing.kMd),
                  _sectionTitle(l10n.logMood),
                  const SizedBox(height: AppSpacing.kSm),
                  _chipSelector(
                    items: kCommonMoods(l10n),
                    selected: _mood == null ? <String>{} : <String>{_mood!},
                    onToggle: (String value) => setState(() => _mood = value),
                  ),
                ],
              ),
            ),
          ),
          TextField(
            controller: _notes,
            maxLines: 2,
            decoration: InputDecoration(
              labelText: l10n.logNotes,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: AppSpacing.kLg),
          AppButton(
            label: l10n.logSave,
            onPressed: _save,
          ),
        ],
      ),
    );
  }
}
