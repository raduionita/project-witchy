import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../providers/symptom_provider.dart';
import '../../utils/app_theme.dart';
import '../../widgets/app_button.dart';
import 'log_period_sheet.dart' show kCommonMoods, kCommonSymptoms;

/// Bottom sheet for logging symptoms + mood without a period.
class LogSymptomSheet extends StatefulWidget {
  const LogSymptomSheet({super.key, required this.date});

  final DateTime date;

  /// Shows the sheet and returns whether a log was saved.
  static Future<bool> show({
    required BuildContext context,
    required DateTime date,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (BuildContext context) => LogSymptomSheet(date: date),
    ).then((bool? saved) => saved ?? false);
  }

  @override
  State<LogSymptomSheet> createState() => _LogSymptomSheetState();
}

class _LogSymptomSheetState extends State<LogSymptomSheet> {
  final Set<String> _symptoms = <String>{};
  String? _mood;
  final TextEditingController _notes = TextEditingController();

  @override
  void dispose() {
    _notes.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    await context.read<SymptomProvider>().logSymptoms(
          widget.date,
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
              'Symptoms · ${DateFormat('EEE, MMM d').format(widget.date)}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: AppSpacing.kMd),
            _label('Symptoms'),
            const SizedBox(height: AppSpacing.kSm),
            Wrap(
              spacing: AppSpacing.kSm,
              runSpacing: AppSpacing.kSm,
              children: kCommonSymptoms
                  .map((String item) => FilterChip(
                        label: Text(item),
                        selected: _symptoms.contains(item),
                        onSelected: (_) => setState(() {
                          if (!_symptoms.add(item)) _symptoms.remove(item);
                        }),
                      ))
                  .toList(),
            ),
            const SizedBox(height: AppSpacing.kMd),
            _label('Mood'),
            const SizedBox(height: AppSpacing.kSm),
            Wrap(
              spacing: AppSpacing.kSm,
              runSpacing: AppSpacing.kSm,
              children: kCommonMoods
                  .map((String item) => FilterChip(
                        label: Text(item),
                        selected: _mood == item,
                        onSelected: (_) => setState(() => _mood = item),
                      ))
                  .toList(),
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

  Widget _label(String text) {
    return Text(
      text,
      style: Theme.of(context).textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
    );
  }
}