import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class WitchyCard extends StatelessWidget {
  final Widget child;
  final bool dark;
  final EdgeInsetsGeometry padding;
  const WitchyCard({super.key, required this.child, this.dark = false, this.padding = const EdgeInsets.all(16)});

  @override
  Widget build(BuildContext context) {
    if (dark) {
      return Container(
        padding: padding,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(18), gradient: AppColors.plumGradient),
        child: DefaultTextStyle.merge(style: const TextStyle(color: Colors.white), child: child),
      );
    }
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.line),
        boxShadow: const [BoxShadow(color: Color(0x0A2B0A3D), blurRadius: 2, offset: Offset(0, 1))],
      ),
      child: child,
    );
  }
}

class WitchyButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onTap;
  final bool busy;
  const WitchyButton({super.key, required this.label, this.icon, this.onTap, this.busy = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: busy ? null : onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), gradient: AppColors.plumGradient, boxShadow: const [AppColors.primaryShadow]),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (busy)
              const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.gold))
            else if (icon != null) ...[
              Icon(icon, size: 16, color: AppColors.gold),
              const SizedBox(width: 8),
            ],
            Text(label, style: AppText.btn),
          ],
        ),
      ),
    );
  }
}

class WitchyAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final IconData? action;
  final VoidCallback? onAction;
  final IconData leading;
  final VoidCallback? onLeading;
  const WitchyAppBar({super.key, required this.title, this.action, this.onAction, this.leading = Icons.arrow_back, this.onLeading});

  @override
  Size get preferredSize => const Size.fromHeight(50);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: SizedBox(
        height: 50,
        child: Row(
          children: [
            IconButton(
              onPressed:
                  onLeading ??
                  () {
                    if (Navigator.canPop(context)) {
                      Navigator.pop(context);
                    } else {
                      Navigator.pushNamed(context, '/dashboard');
                    }
                  },
              icon: Icon(leading, color: AppColors.chipText),
            ),
            Expanded(child: Text(title, textAlign: TextAlign.center, style: AppText.appBar)),
            IconButton(onPressed: onAction, icon: Icon(action ?? Icons.auto_awesome, color: AppColors.pur)),
          ],
        ),
      ),
    );
  }
}

class WitchyTag extends StatelessWidget {
  final String label;
  final Color bg;
  final Color fg;
  const WitchyTag(this.label, {super.key, this.bg = AppColors.lav, this.fg = AppColors.purDark});
  factory WitchyTag.pink(String l) => WitchyTag(l, bg: AppColors.pinkBg, fg: AppColors.pinkDark);
  factory WitchyTag.gold(String l) => WitchyTag(l, bg: const Color(0x29D9A036), fg: AppColors.gold);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
      child: Text(label, style: AppText.sans(9.5, w: FontWeight.w600, c: fg)),
    );
  }
}

class WitchyChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color? iconColor;
  final bool selected;
  final VoidCallback onTap;
  const WitchyChip({super.key, required this.label, this.icon, this.iconColor, this.selected = false, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(color: selected ? AppColors.pur : Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: selected ? AppColors.pur : AppColors.line)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[Icon(icon, size: 12, color: selected ? Colors.white : (iconColor ?? AppColors.pur)), const SizedBox(width: 6)],
            Flexible(child: Text(label, style: AppText.sans(11.5, w: FontWeight.w500, c: selected ? Colors.white : AppColors.chipText))),
          ],
        ),
      ),
    );
  }
}

class IconBadge extends StatelessWidget {
  final IconData icon;
  final Color bg;
  final Color fg;
  final double size;
  const IconBadge({super.key, required this.icon, this.bg = AppColors.lav, this.fg = AppColors.pur, this.size = 34});

  @override
  Widget build(BuildContext context) {
    return Container(width: size, height: size, decoration: BoxDecoration(shape: BoxShape.circle, color: bg), child: Icon(icon, size: 16, color: fg));
  }
}

class WitchyAvatar extends StatelessWidget {
  final String initials;
  final double size;
  final bool big;
  const WitchyAvatar({super.key, required this.initials, this.size = 40, this.big = false});

  @override
  Widget build(BuildContext context) {
    final s = big ? 84.0 : size;
    return Container(
      width: s,
      height: s,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: AppColors.avatarGradient,
        border: big ? Border.all(color: Colors.white, width: 2) : null,
        boxShadow: big ? [BoxShadow(color: AppColors.gold.withValues(alpha: .6), blurRadius: 0, spreadRadius: 1.5)] : null,
      ),
      alignment: Alignment.center,
      child: Text(initials, style: AppText.serif(big ? 26 : 13, c: AppColors.avatarText)),
    );
  }
}

class InfoPill extends StatelessWidget {
  final IconData icon;
  final String label;
  const InfoPill({super.key, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(color: const Color(0xFFF6EEFB), borderRadius: BorderRadius.circular(9), border: Border.all(color: AppColors.line)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [Icon(icon, size: 12, color: AppColors.pur), const SizedBox(width: 6), Text(label, style: AppText.sans(10, w: FontWeight.w500, c: AppColors.chipText))],
      ),
    );
  }
}

class SettingsRow extends StatelessWidget {
  final String label;
  final Widget trailing;
  final bool first;
  const SettingsRow({super.key, required this.label, required this.trailing, this.first = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(border: first ? null : const Border(top: BorderSide(color: AppColors.line))),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(label, style: AppText.sans(12, w: FontWeight.w500, c: AppColors.ink)), trailing]),
    );
  }
}

class WitchyTextField extends StatelessWidget {
  final String? label;
  final String hint;
  final IconData? lead;
  final bool obscure;
  final TextEditingController? controller;
  final VoidCallback? onToggleObscure;
  const WitchyTextField({super.key, this.label, required this.hint, this.lead, this.obscure = false, this.controller, this.onToggleObscure});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[Padding(padding: const EdgeInsets.only(left: 2, bottom: 6), child: Text(label!, style: AppText.sans(10.5, w: FontWeight.w600, c: const Color(0xFF4D3B52))))],
        TextField(
          controller: controller,
          obscureText: obscure,
          style: AppText.sans(12.5, c: AppColors.ink),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppText.sans(12.5, c: AppColors.placeholder),
            filled: true,
            fillColor: Colors.white,
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12).copyWith(left: lead != null ? 36 : 12),
            prefixIcon: lead != null ? Icon(lead, size: 16, color: AppColors.muted) : null,
            prefixIconConstraints: const BoxConstraints(minWidth: 36, minHeight: 20),
            suffixIcon:
                onToggleObscure != null
                    ? IconButton(onPressed: onToggleObscure, icon: Icon(obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 16, color: AppColors.muted))
                    : null,
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.line)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.pur)),
          ),
        ),
      ],
    );
  }
}

class WitchySliderRow extends StatelessWidget {
  final String label;
  final String value;
  final double min;
  final double max;
  final double current;
  final ValueChanged<double> onChanged;
  const WitchySliderRow({super.key, required this.label, required this.value, required this.min, required this.max, required this.current, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(label, style: AppText.sec), Text(value, style: AppText.serif(13.5, c: AppColors.pur))]),
        SliderTheme(
          data: SliderTheme.of(
            context,
          ).copyWith(activeTrackColor: AppColors.pur, inactiveTrackColor: AppColors.sliderTrack, thumbColor: Colors.white, overlayShape: SliderComponentShape.noOverlay, trackHeight: 4),
          child: Slider(min: min, max: max, value: current, onChanged: onChanged),
        ),
      ],
    );
  }
}

class MoonRow extends StatelessWidget {
  const MoonRow({super.key});
  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.dark_mode_outlined, color: AppColors.pur, size: 20),
        SizedBox(width: 16),
        Icon(Icons.dark_mode_outlined, color: AppColors.pur, size: 20),
        SizedBox(width: 16),
        Icon(Icons.dark_mode_outlined, color: AppColors.gold, size: 20),
        SizedBox(width: 16),
        Icon(Icons.dark_mode_outlined, color: AppColors.pur, size: 20),
        SizedBox(width: 16),
        Icon(Icons.dark_mode_outlined, color: AppColors.pur, size: 20),
      ],
    );
  }
}

class WitchyBottomNav extends StatelessWidget {
  final int index;
  final ValueChanged<int> onTap;
  const WitchyBottomNav({super.key, required this.index, required this.onTap});

  @override
  Widget build(BuildContext context) {
    const items = [(Icons.dark_mode_outlined, 'Today'), (Icons.calendar_month_outlined, 'Calendar'), (Icons.bar_chart_outlined, 'Insights'), (Icons.auto_awesome, 'Magic')];
    return Container(
      height: 78,
      decoration: const BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: AppColors.line))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          for (var i = 0; i < items.length; i++)
            GestureDetector(
              onTap: () => onTap(i),
              child: Container(
                width: 60,
                padding: const EdgeInsets.only(top: 10),
                child: Column(
                  children: [
                    Icon(items[i].$1, size: 20, color: i == index ? AppColors.pur : AppColors.navInactive),
                    const SizedBox(height: 4),
                    Text(items[i].$2, style: AppText.sans(9.5, w: FontWeight.w500, c: i == index ? AppColors.pur : AppColors.navInactive)),
                    if (i == index) Container(margin: const EdgeInsets.only(top: 4), width: 18, height: 2.5, decoration: BoxDecoration(color: AppColors.pur, borderRadius: BorderRadius.circular(2))),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
