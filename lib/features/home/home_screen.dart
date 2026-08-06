import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../app/router/app_route_path.dart';
import '../../app/router/app_router_delegate.dart';
import '../../models/cycle_phase.dart';
import '../../models/cycle_prediction.dart';
import '../../models/tracking_mode.dart';
import '../../providers/cycle_provider.dart';
import '../../utils/app_theme.dart';
import '../../utils/date_utils.dart';
import '../../widgets/app_card.dart';
import '../perimenopause/perimenopause_screen.dart';
import '../pregnancy/pregnancy_screen.dart';

/// The Home tab: today's status and cycle predictions.
///
/// Content adapts to the user's [TrackingMode]: cycle mode shows the classic
/// prediction cards, while pregnancy/perimenopause modes hand off to their
/// stage-specific screens.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Ensure predictions are fresh after onboarding/navigation.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<CycleProvider>().recompute();
    });
  }

  @override
  Widget build(BuildContext context) {
    final CycleProvider provider = context.watch<CycleProvider>();
    final CyclePrediction? prediction = provider.prediction;
    final bool onboarded = provider.profile?.onboarded ?? false;

    final TrackingMode mode = provider.profile?.mode ?? TrackingMode.cycle;
    if (mode == TrackingMode.pregnancy) return const PregnancyScreen();
    if (mode == TrackingMode.perimenopause) return const PerimenopauseScreen();

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.kMd),
        children: [
          _greeting(context),
          const SizedBox(height: AppSpacing.kMd),
          if (!onboarded || prediction == null)
            _onboardingCard(context)
          else ...[
            _todayCard(context, provider, prediction),
            const SizedBox(height: AppSpacing.kMd),
            _nextPeriodCard(context, prediction),
            const SizedBox(height: AppSpacing.kMd),
            _fertileCard(context, prediction),
          ],
        ],
      ),
    );
  }

  Widget _greeting(BuildContext context) {
    final String now = DateFormat('EEEE, MMM d').format(DateTime.now());
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          now,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
        ),
        const SizedBox(height: AppSpacing.kXs),
        Text(
          'Welcome to Witchy',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }

  Widget _onboardingCard(BuildContext context) {
    return AppCard(
      onTap: () {
        final AppRouterDelegate delegate =
            Router.of(context).routerDelegate as AppRouterDelegate;
        delegate.go(const AppOnboardingRoute());
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome,
                  color: Theme.of(context).colorScheme.primary),
              const Spacer(),
              const Icon(Icons.chevron_right),
            ],
          ),
          const SizedBox(height: AppSpacing.kSm),
          Text(
            'Set up your cycle',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: AppSpacing.kXs),
          Text(
            'Complete the short onboarding to unlock personalized predictions.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _todayCard(BuildContext context, CycleProvider provider, CyclePrediction prediction) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final CyclePhase phase = prediction.currentCyclePhase;
    final int cycleDay = daysBetween(prediction.currentCycleStart, DateTime.now()) + 1;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Today', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: AppSpacing.kMd),
          Row(
            children: [
              _phaseIcon(scheme, phase),
              const SizedBox(width: AppSpacing.kMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_phaseLabel(phase), style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: AppSpacing.kXs),
                    Text('Day $cycleDay of your cycle', style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _nextPeriodCard(BuildContext context, CyclePrediction prediction) {
    final int days = daysBetween(DateTime.now(), prediction.nextPeriodStart);
    return AppCard(
      child: Row(
        children: [
          Icon(Icons.calendar_month, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: AppSpacing.kMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Next period', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                Text('In $days day${days == 1 ? '' : 's'}', style: Theme.of(context).textTheme.bodyLarge),
              ],
            ),
          ),
          Text(
            DateFormat('MMM d').format(prediction.nextPeriodStart),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _fertileCard(BuildContext context, CyclePrediction prediction) {
    final bool fertileNow = prediction.fertileWindow.contains(DateTime.now());
    return AppCard(
      child: Row(
        children: [
          Icon(
            fertileNow ? Icons.favorite : Icons.favorite_border,
            color: const Color(0xFF2E7D32),
          ),
          const SizedBox(width: AppSpacing.kMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Fertile window', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                Text(
                  '${DateFormat('MMM d').format(prediction.fertileWindow.start)} – ${DateFormat('MMM d').format(prediction.fertileWindow.end)}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _phaseIcon(ColorScheme scheme, CyclePhase phase) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(color: scheme.primaryContainer, shape: BoxShape.circle),
      child: Icon(_phaseIconData(phase), color: scheme.onPrimaryContainer),
    );
  }

  IconData _phaseIconData(CyclePhase phase) {
    return switch (phase) {
      CyclePhase.menstruation => Icons.water_drop,
      CyclePhase.follicular => Icons.spa,
      CyclePhase.ovulatory => Icons.brightness_5,
      CyclePhase.luteal => Icons.nightlight,
    };
  }

  String _phaseLabel(CyclePhase phase) {
    return switch (phase) {
      CyclePhase.menstruation => 'Menstruation',
      CyclePhase.follicular => 'Follicular phase',
      CyclePhase.ovulatory => 'Ovulation',
      CyclePhase.luteal => 'Luteal phase',
    };
  }
}