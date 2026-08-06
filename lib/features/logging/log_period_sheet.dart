import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/flow_intensity.dart';
import '../../providers/cycle_provider.dart';
import '../../utils/app_theme.dart';
import '../../widgets/app_button.dart';
import 'widgets/symptom_chip_group.dart';

const List<String> kCommonMoods = ['Happy', 'Calm', 'Anxious', 'Irritable', 'Sad', 'Energetic'];

/// Bottom sheet for logging a period day with intensity, symptoms and mood.
class LogPeriodSheet extends StatefulWidget {
  const LogPeriodSheet({super.key, required this.date});

  final DateTime date;

  /// Shows the sheet and awaits a boolean indicating whether a log was saved.
  static Future<bool> show({required BuildContext context, required DateTime date}) {
    return showModalBottomSheet<bool>(
      context: context,
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

  @override
  void dispose() {
    _notes.dispose();
    super.dispose();
  }

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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.kLg,
        right: AppSpacing.kLg,
        bottom: AppSpacing.kLg + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Log ${DateFormat('EEE, MMM d').format(widget.date)}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: AppSpacing.kMd),
            _sectionTitle('Flow intensity'),
            const SizedBox(height: AppSpacing.kSm),
            _intensitySelector(),
            const SizedBox(height: AppSpacing.kMd),
            _sectionTitle('Symptoms'),
            const SizedBox(height: AppSpacing.kSm),
            SymptomChipGroup(
              selected: _symptoms,
              onToggle: (String value) => setState(() {
                if (!_symptoms.add(value)) _symptoms.remove(value);
              }),
            ),
            const SizedBox(height: AppSpacing.kMd),
            _sectionTitle('Mood'),
            const SizedBox(height: AppSpacing.kSm),
            _chipSelector(
              items: kCommonMoods,
              selected: _mood == null ? <String>{} : <String>{_mood!},
              onToggle: (String value) => setState(() => _mood = value),
            ),
            const SizedBox(height: AppSpacing.kMd),
            TextField(
              controller: _notes,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Notes (optional)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: AppSpacing.kLg),
            AppButton(label: 'Save log', onPressed: _save),
          ],
        ),
      ),
    );
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
    return Row(
      children: FlowIntensity.values.map((FlowIntensity intensity) {
        final bool selected = _intensity == intensity;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.kXs),
            child: ChoiceChip(
              label: Text(intensity.name),
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
      children: items
          .map(
            (String item) => FilterChip(
              label: Text(item),
              selected: selected.contains(item),
              onSelected: (_) => onToggle(item),
            ),
          )
          .toList(),
    );
  }
}