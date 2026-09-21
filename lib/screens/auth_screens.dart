import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_providers.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/witchy_widgets.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final auth = context.watch<MockAuthProvider>();
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _Emblem(),
                  SizedBox(height: 14),
                  Text('Witchy', style: AppText.brand),
                  SizedBox(height: 4),
                  Text('Track your cycle with magic', style: AppText.sans(12, c: AppColors.muted)),
                  SizedBox(height: 8),
                  Icon(Icons.star, size: 14, color: AppColors.gold),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
              child: Column(
                children: [
                  WitchyButton(label: 'Awaken Your Power', icon: Icons.auto_awesome, busy: auth.busy, onTap: () => Navigator.pushNamed(context, '/rhythms')),
                  const SizedBox(height: 12),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Text('Already a witch? ', style: AppText.sans(11, c: AppColors.muted)),
                    GestureDetector(onTap: () => Navigator.pushNamed(context, '/join'), child: Text('Sign In', style: AppText.sans(11, w: FontWeight.w600, c: AppColors.pur))),
                  ]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Emblem extends StatelessWidget {
  const _Emblem();
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 132,
      height: 132,
      decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFFEFE2F8)),
      alignment: Alignment.center,
      child: Container(
        width: 96,
        height: 96,
        decoration: const BoxDecoration(shape: BoxShape.circle, gradient: RadialGradient(center: Alignment(-0.3, -0.4), colors: [AppColors.orbLight, AppColors.orbDark])),
        child: const Icon(Icons.nightlight_round, size: 42, color: AppColors.gold),
      ),
    );
  }
}

class JoinScreen extends StatefulWidget {
  const JoinScreen({super.key});
  @override
  State<JoinScreen> createState() => _JoinScreenState();
}

class _JoinScreenState extends State<JoinScreen> {
  bool obscure = true;
  final email = TextEditingController();
  final pass = TextEditingController(text: 'moonwater13');
  @override
  Widget build(BuildContext context) {
    final auth = context.watch<MockAuthProvider>();
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 6, 16, 14),
          children: [
            const MoonRow(),
            const SizedBox(height: 12),
            Text('Join the Coven', style: AppText.h2),
            const SizedBox(height: 5),
            Text('Create an account to align your inner rhythms with the cosmic tide.', style: AppText.sub),
            const SizedBox(height: 16),
            WitchyTextField(label: 'Astral Email', hint: 'your.essence@cosmic.com', controller: email),
            const SizedBox(height: 12),
            WitchyTextField(label: 'Mystic Secret Key', hint: '••••••••', obscure: obscure, controller: pass, onToggleObscure: () => setState(() => obscure = !obscure)),
            const SizedBox(height: 16),
            WitchyButton(
                label: 'Cast Invitation Scroll',
                busy: auth.busy,
                onTap: () async {
                  await context.read<MockAuthProvider>().signIn();
                  if (context.mounted) Navigator.pushNamed(context, '/rhythms');
                }),
            const SizedBox(height: 14),
            Row(children: [const Expanded(child: Divider(color: AppColors.line)), Padding(padding: const EdgeInsets.symmetric(horizontal: 10), child: Text('Or align via', style: AppText.sans(10, c: AppColors.navInactive))), const Expanded(child: Divider(color: AppColors.line))]),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(child: _Soc(label: 'Apple', icon: Icons.apple, onTap: () async {})),
              const SizedBox(width: 10),
              Expanded(child: _Soc(label: 'Google', icon: Icons.g_mobiledata, onTap: () async {})),
            ]),
          ],
        ),
      ),
    );
  }
}

class _Soc extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  const _Soc({required this.label, required this.icon, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(11),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.line)),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(icon, size: 16), const SizedBox(width: 8), Text(label, style: AppText.sans(12, w: FontWeight.w600, c: AppColors.ink))]),
      ),
    );
  }
}

class RhythmsScreen extends StatelessWidget {
  const RhythmsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final ob = context.watch<OnboardingProvider>();
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 6, 16, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Set Your Rhythms', style: AppText.h2),
              const SizedBox(height: 5),
              Text('Calibrate your lunar engine. When did your last bleeding phase commence?', style: AppText.sub),
              const SizedBox(height: 12),
              WitchyCard(
                child: Column(
                  children: [
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      const Icon(Icons.chevron_left, color: AppColors.muted),
                      Text('Harvest Moon (Oct)', style: AppText.serif(13)),
                      const Icon(Icons.chevron_right, color: AppColors.muted),
                    ]),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        for (var d = 14; d <= 20; d++)
                          GestureDetector(
                            onTap: () => context.read<OnboardingProvider>().setDay(d),
                            child: Column(
                              children: [
                                Container(
                                  width: 30,
                                  height: 30,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(shape: BoxShape.circle, color: ob.selectedDay == d ? AppColors.pur : null),
                                  child: Text('$d', style: AppText.sans(11.5, c: ob.selectedDay == d ? Colors.white : AppColors.body, w: ob.selectedDay == d ? FontWeight.w600 : FontWeight.w400)),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              WitchyCard(child: WitchySliderRow(label: 'Cycle duration (stardust tides)', value: '${ob.cycleLength} Days', min: 20, max: 40, current: ob.cycleLength.toDouble(), onChanged: (v) => context.read<OnboardingProvider>().setCycle(v.round()))),
              const SizedBox(height: 12),
              WitchyCard(child: WitchySliderRow(label: 'Bleeding phase length', value: '${ob.bleedLength} Days', min: 2, max: 10, current: ob.bleedLength.toDouble(), onChanged: (v) => context.read<OnboardingProvider>().setBleed(v.round()))),
              const Spacer(),
              WitchyButton(
                  label: 'Bind Magic Link',
                  icon: Icons.auto_awesome,
                  onTap: () async {
                    await context.read<OnboardingProvider>().finish();
                    if (context.mounted) Navigator.pushNamedAndRemoveUntil(context, '/shell', (_) => false);
                  }),
            ],
          ),
        ),
      ),
    );
  }
}
