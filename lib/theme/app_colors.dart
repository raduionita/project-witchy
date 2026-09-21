import 'package:flutter/material.dart';

/// Design tokens extracted from resources/Qwen_html_20260917_r3vw6tc9n.html
abstract final class AppColors {
  static const bg = Color(0xFFFAF7FC);
  static const card = Color(0xFFFFFFFF);
  static const ink = Color(0xFF2A0A3C);
  static const body = Color(0xFF4D3B5E);
  static const muted = Color(0xFF8B7F95);
  static const line = Color(0xFFECE3F2);
  static const pur = Color(0xFF7B2CBF);
  static const purDark = Color(0xFF6A1B9A);
  static const plum = Color(0xFF3B0A5E);
  static const plum2 = Color(0xFF26063F);
  static const gold = Color(0xFFD9A036);
  static const pink = Color(0xFFE0517F);
  static const lav = Color(0xFFF3EAF9);
  static const lav2 = Color(0xFFE7D6F4);
  static const switchOff = Color(0xFFE4D7EE);
  static const sliderTrack = Color(0xFFE7DBF0);
  static const fieldBg = Color(0xFFFAF6FD);
  static const sectionTitle = Color(0xFF3F2B52);
  static const chipText = Color(0xFF5D4A70);
  static const navInactive = Color(0xFFA795B8);
  static const placeholder = Color(0xFFB4A6C2);
  static const fertileBg = Color(0xFFEBDCF7);
  static const fertileText = Color(0xFF6B21A8);
  static const pinkBg = Color(0xFFFCE7EF);
  static const pinkDark = Color(0xFFC2336B);
  static const goldBg = Color(0xFFF8EED9);
  static const blueBg = Color(0xFFE3EEF9);
  static const blue = Color(0xFF3E7BC0);
  static const tabBg = Color(0xFFEFE6F6);
  static const tabText = Color(0xFF6B5B7D);
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
  static const barGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF8B3FC6), purDark],
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
}
