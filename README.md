# Witchy - Witchy Period Tracker & Cycle Calendar app for iOS and Android using Flutter and Dart

Witchy is a comprehensive health tracking application designed to help you understand and monitor your menstrual cycle, fertility window, pregnancy, and overall reproductive health. Witchy combines personalized insights with evidence-based medical guidance.

---

## Key Features

| Feature | Description |
|---------|-------------|
| **Menstrual Cycle Tracking** | Track period symptoms, discharge patterns, mood changes, and other indicators. Medical guidance from 100+ healthcare professionals. |
| **Ovulation & Fertility Insights** | Get personalized predictions of your fertile window and ovulation dates with expert-backed information. |
| **Pregnancy Tracker** | Access important health insights, birth preparation guidance, and postpartum care information throughout your pregnancy journey. |
| **Perimenopause Tracker** | Specialized tracking for perimenopause symptoms with expert-reviewed content for better understanding of body changes. |
| **Witchy for Couples** | Share cycle, pregnancy, and health updates with your partner to deepen connection and support. |
| **Anonymous Mode** | Slip in incognito with "Skip for now" — no account required; health data stays on your device, unlinked to your name, email, or device identifiers. |
| **Smart Reminders** | Customize notifications for period start/end dates, medication, water intake, sleep, and more. |
| **Content Library** | Access thousands of articles and videos about women's health, menstruation, and reproductive wellness. |
| **Symptom Pattern Recognition** | Identify patterns in your symptoms to better understand your body signals. |
| **Wear OS Integration** | Add tiles and complications to your smartwatch with Wear OS 3 compatibility. |

---

## Data Safety & Privacy

- NO Third-Party Sharing: Your health data is never shared with third parties
- NO Location data collected
- NO Personal information collected
- NO Health and fitness data collected
- NO Reproductive health information collected
- NO AI system is being trained data in this app
- One-time privacy consent: a first-run privacy screen presents our Terms of Service, Privacy Policy, and Child Protection pages (opened in-app) and stores your acceptance locally — nothing is uploaded

---

## Important Disclaimers

- Witchy is **not a diagnostic tool** and should not replace professional medical advice
- Should **not** be used as a contraception or fertility method
- Predictions and information are for **educational** purposes only
- Always **consult a qualified healthcare professional** for medical concerns or decisions

---

## About Witchy & QVONYX.com

**Developer**: qvonyx.com  
**Email**: witchy@qvonyx.com
**Website**: [witchy.qvonyx.com](https://witchy.qvonyx.com)  

Witchy is dedicated to providing evidence-based reproductive health insights with a mission to support over 460 million users worldwide in understanding their bodies better.

---

## Building for Release

### Android release signing

1. Generate a keystore once (keep it safe, it cannot be recreated):

```bash
keytool -genkey -v -keystore ~/witchy-release.jks -keyalg RSA -keysize 2048 -validity 10000 -alias witchy
```

2. Create `android/key.properties` (git-ignored):

```properties
storePassword=<keystore password>
keyPassword=<key password>
keyAlias=witchy
storeFile=/absolute/path/to/witchy-release.jks
```

3. Build:

```bash
flutter build apk --release
```

Without `key.properties` the release build falls back to the debug key (local testing only - never ship that APK).

### Launcher icons

Branded icons are generated with `flutter_launcher_icons` (config in `pubspec.yaml`).
To regenerate after changing the art:

```bash
dart run tool/generate_app_icon.dart   # composites gold cat-moon onto brand purple -> assets/images/app_icon_1024.png
dart run flutter_launcher_icons
```

---

## License & Terms

By using Witchy, you agree to the app's Terms of Service and Privacy Policy. For detailed terms, visit the Witchy Health website, the Google Play Store listing, or the in-app privacy screen (Terms of Service, Privacy Policy, and Child Protection pages).
