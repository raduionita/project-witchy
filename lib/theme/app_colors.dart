import 'package:flutter/material.dart';

/// Design tokens extracted from resources/Qwen_html_20260917_r3vw6tc9n.html
abstract final class AppColors {
  /// Flip before buildAppTheme so every token getter resolves dark values.
  static bool dark = false;

  static Color _t(Color light, Color night) => dark ? night : light;

  static Color get bg => _t(const Color(0xFFFAF7FC), const Color(0xFF1B0A2A));
  static Color get card => _t(const Color(0xFFFFFFFF), const Color(0xFF26063F));
  static Color get ink => _t(const Color(0xFF2A0A3C), const Color(0xFFF3EAF9));
  static Color get body => _t(const Color(0xFF4D3B5E), const Color(0xFFCDBEDD));
  static Color get muted => _t(const Color(0xFF8B7F95), const Color(0xFF9E90AC));
  static Color get line => _t(const Color(0xFFECE3F2), const Color(0xFF3E2A54));
  static Color get pur => _t(const Color(0xFF7B2CBF), const Color(0xFF9D5CFF));
  static Color get purDark => _t(const Color(0xFF6A1B9A), const Color(0xFFB07AFF));
  static Color get lav => _t(const Color(0xFFF3EAF9), const Color(0xFF2E1145));
  static Color get lav2 => _t(const Color(0xFFE7D6F4), const Color(0xFF3E2A54));
  static Color get switchOff => _t(const Color(0xFFE4D7EE), const Color(0xFF3E2A54));
  static Color get sliderTrack => _t(const Color(0xFFE7DBF0), const Color(0xFF4A3560));
  static Color get fieldBg => _t(const Color(0xFFFAF6FD), const Color(0xFF2A0F45));
  static Color get sectionTitle => _t(const Color(0xFF3F2B52), const Color(0xFFD9C2EC));
  static Color get chipText => _t(const Color(0xFF5D4A70), const Color(0xFFC7B7D6));
  static Color get navInactive => _t(const Color(0xFFA795B8), const Color(0xFF9B8DAA));
  static Color get placeholder => _t(const Color(0xFFB4A6C2), const Color(0xFF6E5F7E));
  static Color get fertileBg => _t(const Color(0xFFEBDCF7), const Color(0xFF3A1A55));
  static Color get fertileText => _t(const Color(0xFF6B21A8), const Color(0xFFD8B4FE));
  static Color get pinkBg => _t(const Color(0xFFFCE7EF), const Color(0xFF3E1226));
  static Color get pinkDark => _t(const Color(0xFFC2336B), const Color(0xFF7BA3FF));
  static Color get goldBg => _t(const Color(0xFFF8EED9), const Color(0xFF3D2E12));
  static Color get blueBg => _t(const Color(0xFFE3EEF9), const Color(0xFF16283F));
  static Color get tabBg => _t(const Color(0xFFEFE6F6), const Color(0xFF2E1145));
  static Color get tabText => _t(const Color(0xFF6B5B7D), const Color(0xFFC7B7D6));

  static const plum = Color(0xFF3B0A5E);
  static const plum2 = Color(0xFF26063F);
  static const gold = Color(0xFFD9A036);
  static const pink = Color(0xFFE0517F);
  static const blue = Color(0xFF3E7BC0);
  static const danger = Color(0xFF8B1E2F);
  static const green = Color(0xFF4C8C4A);
  static const red = Color(0xFFC0392B);
  static const orange = Color(0xFFE07B36);
  static const teal = Color(0xFF2A9D8F);
  static const brown = Color(0xFF9C6B3F);
  static const indigo = Color(0xFF5B4A8C);
  static const orbLight = Color(0xFF4A1170);
  static const orbDark = Color(0xFF2A0740);
  static const insightText = Color(0xFFE9D9F5);
  static const orbSub = Color(0xFFD9C2EC);
  static const avatarFrom = Color(0xFFE6D4F2);
  static const avatarTo = Color(0xFFC9A6E4);
  static const avatarText = Color(0xFF5B2186);

  static const plumGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [plum, plum2],
  );
  static LinearGradient get barGradient => LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: dark
            ? const [Color(0xFF9D5CFF), Color(0xFFB07AFF)]
            : const [Color(0xFF8B3FC6), Color(0xFF6A1B9A)],
      );
  static const avatarGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [avatarFrom, avatarTo],
  );

  static const primaryShadow = BoxShadow(
    color: Color(0x8C3B0A5E),
    blurRadius: 18,
    offset: Offset(0, 8),
  );

  /// WCAG contrast ratio between two colors (1..21).
  static double contrast(Color a, Color b) {
    final la = a.computeLuminance();
    final lb = b.computeLuminance();
    final hi = la > lb ? la : lb;
    final lo = la > lb ? lb : la;
    return (hi + 0.05) / (lo + 0.05);
  }

  /// Darkens [c] just enough to stay readable (>= 4.5:1) on [bg].
  /// Used for section titles so vivid accents (gold, orange) keep AA contrast.
  static Color readableOn(Color c, Color bg) {
    var out = c;
    var guard = 0;
    while (contrast(out, bg) < 4.5 && guard++ < 24) {
      out = Color.lerp(out, Colors.black, 0.1)!;
    }
    return out;
  }

  /// White or ink, whichever contrasts more against [bg] (selected chip text).
  static Color onColor(Color bg) => contrast(bg, Colors.white) >= contrast(bg, ink) ? Colors.white : ink;
}
