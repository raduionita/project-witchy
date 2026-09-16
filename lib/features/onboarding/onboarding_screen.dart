import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../app/router/app_route_path.dart';
import '../../app/router/app_router_delegate.dart';
import '../../l10n/app_localizations.dart';
import '../../models/user_profile.dart';
import '../../providers/app_state_provider.dart';
import '../../providers/cycle_provider.dart';
import '../../utils/app_theme.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_content_column.dart';
import '../../widgets/witchy_slider_card.dart';
import '../auth/auth_provider.dart';

/// First-run onboarding that collects baseline cycle data.
///
/// Walks through several steps, then persists a [UserProfile], logs the first
/// period date and navigates to the main shell.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  static const int _lastStep = 4;

  int _step = 0;
  DateTime _lastPeriod = _today();
  double _cycleLength = 28;
  double _periodLength = 5;
  bool _saving = false;

  static DateTime _today() {
    final DateTime now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  Future<void> _next() async {
    if (_step < _lastStep) {
      setState(() => _step += 1);
      return;
    }
    await _finish();
  }

  Future<void> _finish() async {
    setState(() => _saving = true);

    final AppStateProvider state = context.read<AppStateProvider>();
    final CycleProvider cycle = context.read<CycleProvider>();

    final UserProfile profile = UserProfile(
      id: const Uuid().v4(),
      averageCycleLength: _cycleLength.round(),
      averagePeriodLength: _periodLength.round(),
      firstPeriodDate: _lastPeriod,
      onboarded: true,
      firstDayOfWeek:
          MaterialLocalizations.of(context).firstDayOfWeekIndex == 0
          ? DateTime.sunday
          : MaterialLocalizations.of(context).firstDayOfWeekIndex,
    );

    await state.profile.save(profile);
    await cycle.logPeriodDay(_lastPeriod);
    cycle.recompute();

    if (!mounted) return;
    final AppRouterDelegate delegate =
        Router.of(context).routerDelegate as AppRouterDelegate;
    delegate.go(const AppShellRoute());
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return Scaffold(
      body: AppContentColumn(
        child: SafeArea(
          child: Padding(
          padding: const EdgeInsets.all(AppSpacing.kLg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSpacing.kSm),
              LinearProgressIndicator(value: (_step + 1) / (_lastStep + 1)),
              const SizedBox(height: AppSpacing.kLg),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: KeyedSubtree(
                    key: ValueKey<int>(_step),
                    child: _body(_step),
                  ),
                ),
              ),
              Row(
                children: [
                  if (_step > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _saving
                            ? null
                            : () => setState(() => _step -= 1),
                        child: Text(l10n.onboardingBack),
                      ),
                    ),
                  if (_step > 0) const SizedBox(width: AppSpacing.kMd),
                  Expanded(
                    flex: 2,
                    child: AppButton(
                      label: _step == _lastStep ? l10n.onboardingFinish : l10n.onboardingNext,
                      icon: Icons.auto_awesome,
                      isLoading: _saving,
                      onPressed: _next,
                    ),
                  ),
                ],
              ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _body(int step) {
    return switch (step) {
      0 => _welcome(),
      1 => _lastPeriodStep(),
      2 => _cycleLengthStep(),
      3 => _periodLengthStep(),
      _ => _accountStep(),
    };
  }

  Widget _welcome() {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return AppCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.homeWelcomeTitle,
            style: Theme.of(context).textTheme.displaySmall,
          ),
          const SizedBox(height: AppSpacing.kSm),
          Text(l10n.onboardingWelcomeBody),
          const SizedBox(height: AppSpacing.kMd),
          Text(
            l10n.onboardingDisclaimer,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }

  Widget _lastPeriodStep() {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final DateTime base = _lastPeriod.subtract(Duration(days: _lastPeriod.weekday % 7));
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(icon: const Icon(Icons.chevron_left, size: 16), onPressed: () => setState(() => _lastPeriod = _lastPeriod.subtract(const Duration(days: 7)))),
              Text(DateFormat('MMMM yyyy').format(_lastPeriod), style: Theme.of(context).textTheme.displaySmall?.copyWith(fontSize: 13)),
              IconButton(icon: const Icon(Icons.chevron_right, size: 16), onPressed: () => setState(() => _lastPeriod = _lastPeriod.add(const Duration(days: 7)))),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              for (int i = 0; i < 7; i++)
                Builder(
                  builder: (BuildContext context) {
                    final DateTime day = base.add(Duration(days: i));
                    final bool selected = day.year == _lastPeriod.year && day.month == _lastPeriod.month && day.day == _lastPeriod.day;
                    return GestureDetector(
                      onTap: () => setState(() => _lastPeriod = day),
                      child: Column(
                        children: [
                          Container(
                            width: 30,
                            height: 30,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(shape: BoxShape.circle, color: selected ? AppColors.kPurple : Colors.transparent),
                            child: Text('${day.day}', style: TextStyle(fontSize: 11.5, color: selected ? Colors.white : AppColors.kBody, fontWeight: selected ? FontWeight.w600 : FontWeight.w400)),
                          ),
                        ],
                      ),
                    );
                  },
                ),
            ],
          ),
          const SizedBox(height: 8),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.event, color: AppColors.kPurple),
            title: Text(l10n.onboardingLastPeriod),
            subtitle: Text(DateFormat.yMMMd().format(_lastPeriod)),
            onTap: () async {
              final DateTime? picked = await showDatePicker(context: context, initialDate: _lastPeriod, firstDate: _today().subtract(const Duration(days: 120)), lastDate: _today());
              if (picked != null) setState(() => _lastPeriod = picked);
            },
          ),
        ],
      ),
    );
  }

  Widget _cycleLengthStep() {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return _sliderCard(
      icon: Icons.autorenew,
      title: l10n.onboardingCycleLength,
      value: _cycleLength,
      min: 20,
      max: 45,
      suffix: l10n.onboardingDaysSuffix,
      onChanged: (double v) => setState(() => _cycleLength = v.roundToDouble()),
    );
  }

  Widget _periodLengthStep() {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return _sliderCard(
      icon: Icons.water_drop,
      title: l10n.onboardingPeriodLength,
      value: _periodLength,
      min: 2,
      max: 10,
      suffix: l10n.onboardingDaysSuffix,
      onChanged: (double v) => setState(() => _periodLength = v.roundToDouble()),
    );
  }

  Future<void> _signInAccount(
    Future<bool> Function() action,
  ) async {
    final bool ok = await action();
    if (!mounted) return;
    final AuthProvider auth = context.read<AuthProvider>();
    if (ok || auth.errorMessage == null) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(auth.errorMessage!)),
    );
  }

  Widget _accountStep() {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final AuthProvider auth = context.watch<AuthProvider>();
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.onboardingAccountTitle,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: AppSpacing.kSm),
          Text(
            l10n.onboardingAccountBody,
          ),
          const SizedBox(height: AppSpacing.kMd),
          FilledButton(
            onPressed: auth.busy
                ? null
                : () => _signInAccount(auth.signInWithGoogle),
            child: Text(l10n.authGoogleSignIn),
          ),
          const SizedBox(height: AppSpacing.kSm),
          OutlinedButton(
            onPressed: auth.busy
                ? null
                : () => _signInAccount(auth.signInWithApple),
            child: Text(l10n.authAppleSignIn),
          ),
          TextButton(
              onPressed: auth.busy
                  ? null
                  : () => _signInAccount(auth.signInAnonymously),
              child: Text(l10n.authAnonymous),
            ),
          const SizedBox(height: AppSpacing.kSm),
          TextButton(
            onPressed: _saving ? null : _finish,
            child: Text(l10n.onboardingSkip),
          ),
        ],
      ),
    );
  }

  Widget _sliderCard({
    required IconData icon,
    required String title,
    required double value,
    required double min,
    required double max,
    required String suffix,
    required ValueChanged<double> onChanged,
  }) {
    return WitchySliderCard(label: title, valueLabel: '${value.round()}$suffix', value: value, min: min, max: max, onChanged: onChanged);
  }
}
