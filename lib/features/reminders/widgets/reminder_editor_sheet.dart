import 'package:flutter/material.dart';

import '../../../models/reminder.dart';
import '../../../models/reminder_type.dart';
import '../../../models/time_of_day_model.dart';
import '../../../utils/app_theme.dart';
import '../../trackers/shared_tracker_text.dart';
import '../reminder_defaults.dart';

/// Bottom sheet for creating or editing a [Reminder].
///
/// Editing keeps the original type; creation can pick any type and starts from
/// that type's sensible defaults. Period-based reminders skip the weekday pick
/// because they anchor to the predicted cycle instead.
class ReminderEditorSheet extends StatefulWidget {
  const ReminderEditorSheet({super.key, this.reminder});

  /// The reminder being edited, or null to create a new one.
  final Reminder? reminder;

  static Future<Reminder?> show(
    BuildContext context, {
    Reminder? reminder,
  }) {
    return showModalBottomSheet<Reminder>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => ReminderEditorSheet(reminder: reminder),
    );
  }

  @override
  State<ReminderEditorSheet> createState() => _ReminderEditorSheetState();
}

class _ReminderEditorSheetState extends State<ReminderEditorSheet> {
  static const List<(int, String)> _weekdayLabels = <(int, String)>[
    (1, 'Mon'),
    (2, 'Tue'),
    (3, 'Wed'),
    (4, 'Thu'),
    (5, 'Fri'),
    (6, 'Sat'),
    (7, 'Sun'),
  ];

  late ReminderType _type;
  late final TextEditingController _title;
  late final TextEditingController _body;
  late TimeOfDayModel _time;
  late List<int> _weekdays;

  bool get _isNew => widget.reminder == null;

  bool get _isPeriodBased => ReminderDefaults.isPeriodBased(_type);

  @override
  void initState() {
    super.initState();
    final Reminder? seed = widget.reminder;
    _type = seed?.type ?? ReminderType.custom;
    _title = TextEditingController(text: seed?.title ?? '');
    _body = TextEditingController(text: seed?.body ?? '');
    _time = seed?.time ?? const TimeOfDayModel(hour: 12, minute: 0);
    _weekdays = List<int>.from(seed?.weekday ?? const <int>[]);
    if (seed == null) _applyDefaults(_type);
  }

  @override
  void dispose() {
    _title.dispose();
    _body.dispose();
    super.dispose();
  }

  void _applyDefaults(ReminderType type) {
    final Reminder preset = ReminderDefaults.forType(type, id: '');
    _title.text = preset.title;
    _body.text = preset.body ?? '';
    _time = preset.time;
    _weekdays = List<int>.from(preset.weekday);
  }

  void _pickTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: _time.hour, minute: _time.minute),
    );
    if (picked == null || !mounted) return;
    setState(() => _time = TimeOfDayModel(hour: picked.hour, minute: picked.minute));
  }

  Future<void> _save() async {
    if (!_isPeriodBased && _weekdays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pick at least one day for this reminder.')),
      );
      return;
    }
    final Reminder result = Reminder(
      id: widget.reminder?.id ?? '',
      type: _type,
      title: _title.text.trim().isEmpty ? 'Reminder' : _title.text.trim(),
      body: _body.text.trim(),
      time: _time,
      weekday: _isPeriodBased ? const <int>[] : _weekdays,
      enabled: widget.reminder?.enabled ?? true,
    );
    Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.kMd,
        right: AppSpacing.kMd,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.kLg,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              _isNew ? 'New reminder' : 'Edit reminder',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: AppSpacing.kMd),
            if (_isNew) ...[
              DropdownButtonFormField<ReminderType>(
                value: _type,
                decoration: const InputDecoration(
                  labelText: 'Type',
                  border: OutlineInputBorder(),
                ),
                items: <DropdownMenuItem<ReminderType>>[
                  for (final ReminderType type in ReminderType.values)
                    DropdownMenuItem<ReminderType>(
                      value: type,
                      child: Text(ReminderDefaults.typeLabel(type)),
                    ),
                ],
                onChanged: (ReminderType? type) {
                  if (type == null) return;
                  setState(() {
                    _type = type;
                    _applyDefaults(type);
                  });
                },
              ),
              const SizedBox(height: AppSpacing.kMd),
            ],
            TextField(
              controller: _title,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: AppSpacing.kMd),
            TextField(
              controller: _body,
              decoration: const InputDecoration(
                labelText: 'Message',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: AppSpacing.kMd),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.schedule),
              title: const Text('Time'),
              trailing: Text(
                _timeLabel(),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              onTap: _pickTime,
            ),
            if (!_isPeriodBased) ...[
              const SizedBox(height: AppSpacing.kSm),
              Wrap(
                spacing: AppSpacing.kSm,
                runSpacing: AppSpacing.kSm,
                children: [
                  for (final (int weekday, String label) in _weekdayLabels)
                    FilterChip(
                      label: Text(label),
                      selected: _weekdays.contains(weekday),
                      onSelected: (bool selected) => setState(() {
                        if (selected) {
                          _weekdays.add(weekday);
                        } else {
                          _weekdays.remove(weekday);
                        }
                      }),
                    ),
                ],
              ),
            ] else
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.kSm),
                child: Text(
                  'This reminder follows your predicted period dates.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                ),
              ),
            const SizedBox(height: AppSpacing.kLg),
            FilledButton(
              onPressed: _save,
              child: const Text('Save reminder'),
            ),
            const SizedBox(height: AppSpacing.kMd),
            Text(
              TrackerInsightText.disclaimer(),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontStyle: FontStyle.italic,
                    color: Theme.of(context).colorScheme.outline,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  String _timeLabel() {
    final TimeOfDay tod = TimeOfDay(hour: _time.hour, minute: _time.minute);
    final String hour = (tod.hourOfPeriod == 0 ? 12 : tod.hourOfPeriod).toString();
    final String minute = tod.minute.toString().padLeft(2, '0');
    return '$hour:$minute ${tod.period.name}';
  }
}
