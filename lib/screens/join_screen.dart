import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/onboarding_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../utils/app_icons.dart';
import '../widgets/moon_row.dart';
import '../widgets/app_button.dart';
import '../widgets/app_text_field.dart';

class JoinScreen extends StatefulWidget {
  const JoinScreen({super.key});
  @override
  State<JoinScreen> createState() => _JoinScreenState();
}

class _JoinScreenState extends State<JoinScreen> {
  bool obscure = true;
  final email = TextEditingController();
  final pass = TextEditingController(text: 'moonwater13');

  Future<void> _signIn(Future<void> Function() action) async {
    await action();
    if (!mounted) return;
    final auth = context.read<AuthProvider>();
    final error = auth.lastError;
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
      return;
    }
    if (!auth.signedIn) return;
    final onboarding = context.read<OnboardingProvider>();
    Navigator.pushNamedAndRemoveUntil(context, onboarding.onboarded ? '/dashboard' : '/onboarding', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
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
            AppTextField(label: 'Astral Email', hint: 'your.essence@cosmic.com', controller: email),
            const SizedBox(height: 12),
            AppTextField(label: 'Mystic Secret Key', hint: '••••••••', obscure: obscure, controller: pass, onToggleObscure: () => setState(() => obscure = !obscure)),
            const SizedBox(height: 16),
            AppButton(
              label: 'Cast Invitation Scroll',
              busy: auth.busy,
              onTap: () => _signIn(() => context.read<AuthProvider>().signInWithEmail(email.text)),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                const Expanded(child: Divider(color: AppColors.line)),
                Padding(padding: const EdgeInsets.symmetric(horizontal: 10), child: Text('Or align via', style: AppText.sans(10, c: AppColors.navInactive))),
                const Expanded(child: Divider(color: AppColors.line)),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: _Soc(label: 'Apple', icon: AppIcons.apple, onTap: () => _signIn(() => context.read<AuthProvider>().signInWithApple()))),
                const SizedBox(width: 10),
                Expanded(child: _Soc(label: 'Google', icon: AppIcons.google, onTap: () => _signIn(() => context.read<AuthProvider>().signInWithGoogle()))),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Soc extends StatelessWidget {
  final String label;
  final FaIconData icon;
  final VoidCallback onTap;
  const _Soc({required this.label, required this.icon, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(11),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.line)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [FaIcon(icon, size: AppIconSize.head), const SizedBox(width: 8), Text(label, style: AppText.sans(12, w: FontWeight.w600, c: AppColors.ink))],
        ),
      ),
    );
  }
}
