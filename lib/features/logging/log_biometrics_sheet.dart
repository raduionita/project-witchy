import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../l10n/app_localizations.dart';
import '../../models/bbt_reading.dart';
import '../../models/biometric_log.dart';
import '../../models/cervical_mucus_type.dart';
import '../../models/intercourse_log.dart';
import '../../models/ovulation_test_result.dart';
import '../../models/pregnancy_test_result.dart';
import '../../models/time_of_day_model.dart';
import '../../providers/biometric_provider.dart';
import '../../utils/app_theme.dart';
import '../../utils/date_utils.dart';
import '../../widgets/app_button.dart';

/// Bottom sheet for logging a day's fertility & biometric data: BBT, cervical
/// mucus, LH (ovulation) test, pregnancy test and intimacy.
class LogBiometricsSheet extends StatefulWidget {
  const LogBiometricsSheet({super.key, required this.date});

  final DateTime date;

  /// Shows the sheet and returns whether a log was saved or cleared.
  static Future<bool> show({
    required BuildContext context,
    required DateTime date,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (BuildContext context) => LogBiometricsSheet(date: date),
    ).then((bool? saved) => saved ?? false);
  }

  @override
  State<LogBiometricsSheet> createState() => _LogBiometricsSheetState();
}

class _LogBiometricsSheetState extends State<LogBiometricsSheet> {
  static const double _kStep = 0.05;
  final Uuid _uuid = const Uuid();

  late double? _bbt;
  late TextEditingController _bbtField;
  TimeOfDayModel? _bbtTime;
  CervicalMucusType? _mucus;
  OvulationTestResult? _ovulationTest;
  PregnancyTestResult? _pregnancyTest;
  bool _intercourse = false;

  @override
  void initState() {
    super.initState();
    final BiometricLog? existing =
        context.read<BiometricProvider>().logFor(widget.date);
    _bbt = existing?.bbt?.tempC;
    _bbtTime = existing?.bbt?.takenAt ?? _currentTime();
    _bbtField = TextEditingController(text: _bbt?.toStringAsFixed(2) ?? '');
    _mucus = existing?.mucus;
    _ovulationTest = existing?.ovulationTest;
    _pregnancyTest = existing?.pregnancyTest;
    _intercourse = existing?.intercourse != null;
  }

  TimeOfDayModel _currentTime() {
    final TimeOfDay now = TimeOfDay.now();
    return TimeOfDayModel(hour: now.hour, minute: now.minute);
  }

  String _formatTemp(double value) => value.toStringAsFixed(2);

  void _setBbt(double value) {
    setState(() {
      _bbt = double.parse(value.toStringAsFixed(2));
      _bbtField.text = _formatTemp(_bbt!);
    });
  }

  void _readBbtField(String raw) {
    final double? parsed = double.tryParse(raw.trim());
    setState(() => _bbt = parsed);
  }

  Future<void> _pickTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: _bbtTime?.hour ?? 7,
        minute: _bbtTime?.minute ?? 0,
      ),
    );
    if (picked == null || !mounted) return;
    setState(() => _bbtTime = TimeOfDayModel(hour: picked.hour, minute: picked.minute));
  }

  Future<void> _save() async {
    final BiometricProvider provider = context.read<BiometricProvider>();
    final DateTime day = dateOnly(widget.date);
    final BiometricLog? existing = provider.logFor(day);

    final BbtReading? bbt = _bbt == null
        ? null
        : BbtReading(
            id: existing?.bbt?.id ?? _uuid.v4(),
            date: day,
            tempC: _bbt!,
            takenAt: _bbtTime,
          );
    final IntercourseLog? intercourse = _intercourse
        ? IntercourseLog(id: existing?.intercourse?.id ?? _uuid.v4(), date: day)
        : null;

    await provider.saveLog(
      BiometricLog(
        id: existing?.id ?? _uuid.v4(),
        date: day,
        bbt: bbt,
        mucus: _mucus,
        ovulationTest: _ovulationTest,
        pregnancyTest: _pregnancyTest,
        intercourse: intercourse,
      ),
    );
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  Future<void> _clear() async {
    await context.read<BiometricProvider>().removeBiometrics(widget.date);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context).biometricsCleared)),
    );
    Navigator.of(context).pop(true);
  }

  @override
  void dispose() {
    _bbtField.dispose();
    super.dispose();
  }

  Widget _label(String text) {
    return Text(
      text,
      style: Theme.of(
        context,
      ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
    );
  }

  Widget _bbtSection(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(l10n.bbtTitle),
        const SizedBox(height: AppSpacing.kXs),
        Text(l10n.bbtSubtitle, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: AppSpacing.kSm),
        Row(
          children: [
            IconButton(
              onPressed: () => _setBbt((_bbt ?? 36.5) - _kStep),
              icon: const Icon(Icons.remove_circle_outline),
              tooltip: l10n.bbtAdjust,
            ),
            Expanded(
              child: TextField(
                controller: _bbtField,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                ],
                onChanged: _readBbtField,
                decoration: InputDecoration(
                  hintText: '36.5',
                  suffixText: '°C',
                  border: const OutlineInputBorder(),
                  isDense: true,
                ),
              ),
            ),
            IconButton(
              onPressed: () => _setBbt((_bbt ?? 36.5) + _kStep),
              icon: const Icon(Icons.add_circle_outline),
              tooltip: l10n.bbtAdjust,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.kSm),
        Align(
          alignment: Alignment.centerRight,
          child: ActionChip(
            avatar: const Icon(Icons.schedule, size: 18),
            label: Text(
              l10n.biometricsLoggedAt(_formatTime(_bbtTime ?? _currentTime())),
            ),
            onPressed: _pickTime,
          ),
        ),
      ],
    );
  }

  String _formatTime(TimeOfDayModel time) {
    final String hh = time.hour.toString().padLeft(2, '0');
    final String mm = time.minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }

  Widget _choiceChips<T>({
    required List<T> values,
    required T? selected,
    required String Function(T value) labelOf,
    required ValueChanged<T> onSelect,
  }) {
    return Wrap(
      spacing: AppSpacing.kSm,
      runSpacing: AppSpacing.kSm,
      children: values
          .map(
            (T value) => ChoiceChip(
              label: Text(labelOf(value)),
              selected: selected == value,
              onSelected: (_) => onSelect(value),
            ),
          )
          .toList(),
    );
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
                    l10n.logBiometricsTitle(
                      DateFormat('EEE, MMM d').format(widget.date),
                    ),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.kMd),
                  _bbtSection(l10n),
                  const SizedBox(height: AppSpacing.kMd),
                  _label(l10n.mucusTitle),
                  const SizedBox(height: AppSpacing.kSm),
                  _choiceChips<CervicalMucusType>(
                    values: CervicalMucusType.values,
                    selected: _mucus,
                    labelOf: (CervicalMucusType v) =>
                        cervicalMucusLabel(l10n, v),
                    onSelect: (CervicalMucusType v) => setState(
                      () => _mucus = _mucus == v ? null : v,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.kMd),
                  _label(l10n.lhTestTitle),
                  const SizedBox(height: AppSpacing.kSm),
                  _choiceChips<OvulationTestResult>(
                    values: OvulationTestResult.values,
                    selected: _ovulationTest,
                    labelOf: (OvulationTestResult v) =>
                        ovulationTestLabel(l10n, v),
                    onSelect: (OvulationTestResult v) => setState(
                      () => _ovulationTest = _ovulationTest == v ? null : v,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.kMd),
                  _label(l10n.pregnancyTestTitle),
                  const SizedBox(height: AppSpacing.kSm),
                  _choiceChips<PregnancyTestResult>(
                    values: PregnancyTestResult.values,
                    selected: _pregnancyTest,
                    labelOf: (PregnancyTestResult v) =>
                        pregnancyTestLabel(l10n, v),
                    onSelect: (PregnancyTestResult v) => setState(
                      () => _pregnancyTest = _pregnancyTest == v ? null : v,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.kMd),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(l10n.intimacyTitle),
                    subtitle: Text(l10n.intimacyToggle),
                    value: _intercourse,
                    onChanged: (bool value) =>
                        setState(() => _intercourse = value),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.kSm),
          Row(
            children: [
              TextButton(
                onPressed: _clear,
                child: Text(l10n.biometricsClear),
              ),
              const Spacer(),
              SizedBox(
                width: 180,
                child: AppButton(label: l10n.logSave, onPressed: _save),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
