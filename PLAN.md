# PLAN.md — Witchy Period Tracker & Cycle Calendar App

A full, **ready-for-production implementation plan** for a comprehensive health tracking application that helps users understand and monitor their menstrual cycle, fertility window, pregnancy, and overall reproductive health.

This plan is split into **Phases**. Each phase is a list of tasks that MUST be completed **one-by-one**. At the **end of every phase** the project MUST be **error-free and buildable**.

**Status legend:** `[x]` done · `[~]` done differently (details noted) · `[-]` obsolete (superseded) · `[ ]` open

> Phases were compacted (old 0–13 → new 0–5); obsolete `[-]` tasks were pruned and deviations kept as `[~]` or footnotes. Final test suite: **81/81**.

---

## Rules & Conventions (apply in every phase)

- **NO Firebase.** Storage uses `shared_preferences`; state uses `provider`.
- **Files**: `snake_case.dart`. **Classes**: `PascalCase`. **Functions/Variables**: `camelCase`. **Constants**: `kPascalCase`. **Private members**: leading underscore `_`.
- **Import order**: Dart → Flutter → Packages → Relative.
- **Navigation**: Navigator 2.0 (`Router` + custom `RouterDelegate` + `RouteInformationParser`). *Mandated rule — implemented in Phase 2; until then the app uses named routes.*
- **Charts**: `fl_chart`. *Mandated rule — implemented in Phase 2; `CycleOrb` ring gauge stays custom-painted (fl_chart has no radial gauge).*
- **Couples Mode**: placeholder only (local token, real backend deferred).
- Health data is **privacy-first**: no location, no personal info beyond local storage, no third-party sharing, not a diagnostic tool.

## Completion Gates (MUST pass)

| Gate | Command | When |
|------|---------|------|
| Analyze | `flutter analyze` | After **every task** — zero errors/warnings |
| Build | `flutter build apk --debug` | End of **every phase** |
| Test | `flutter test` | End of **every phase** |
| Release | `flutter build apk --release` + `flutter build ios --release --no-codesign` + `flutter build web` | End of the **final** phase (deferred — more phases expected before release) |

> If a gate fails, fix the error and run the gate again before moving to the next task.

## Project Structure

```
lib/
├── main.dart                          # entry point: runApp(App)
├── models/                            # core shared models
├── services/                          # storage, cycle calculation, reminders
├── providers/                         # shared/exposed providers
├── screens/                           # framework-level screens (splash, shell)
├── widgets/                           # shared primitives
├── utils/                             # constants, date helpers
├── theme/
assets/
├── images/
├── icons/
└── content/                           # seeded articles (privacy-first) — DEFERRED: articles live in lib/models/mock_data.dart
test/
```

---

## Milestone 1 — MVP - In Progress

### Phase 0 — Foundation & Data Layer ✅

> Old Phases 0 + 1 + 2 (config, design system, storage, providers, tests). Everything later builds on this baseline.

- [x] **0.1** Base dependencies in `pubspec.yaml`: kept `provider`, `shared_preferences`, `uuid`, `intl`, `font_awesome_flutter`, `google_fonts`, `flutter_svg`, `google_sign_in`, `sign_in_with_apple`; dev `flutter_lints`. Dropped as unneeded: `freezed`, `json_serializable`, `build_runner`, `device_info_plus`, `url_launcher`.
- [x] **0.2** Run `flutter pub get`. No codegen anywhere in the project (no `build_runner`).
- [x] **0.3** Folder skeleton ✓ + `assets/icons` + `assets/images`. `assets/content/` omitted — seeded articles live in `lib/models/mock_data.dart`.
- [x] **0.4** Design system: `lib/theme/` (`AppColors`, `AppText`, `buildAppTheme`) and shared widget primitives in `lib/widgets/` (`AppButton`, `AppCard`, `AppTag`, `AppChip`, `AppTextField`, `AppSliderRow`, `AppTopBar`, `AppBottomNav`, `AppAvatar`, `AppIcons`).
- [x] **0.5** Simple navigation: `MaterialApp.routes` — **note**: temporary stand-in; Navigator 2.0 migration in Phase 2.
- [x] **0.6** Root bootstrap: async `main()` → `PrefsService` + 5 providers loaded → `MultiProvider` + `MaterialApp` (`App` in `lib/main.dart`).
- [~] **0.7** Models — done differently: plain-Dart, one per file, hand-written `toJson`/`fromJson` where needed — `DayLog`, `Article`, `ReminderItem`, `AlertItem`, `CovenPost`, `CycleSettings`, `AuthIdentity`. No freezed; no `UserProfile`/`PeriodLog`/`Cycle`/`SymptomLog` (replaced by `DayLog` + `CycleSettings` + `AuthIdentity`).
- [x] **0.8** `PrefsService` (as `StorageService`): typed accessors over `shared_preferences`, `witchy_*` key namespacing, session + settings + day-log getters/setters — `lib/services/prefs_service.dart`.
- [~] **0.9** Providers — done differently: `AuthProvider`, `OnboardingProvider`, `LoggingProvider`, `SettingsProvider`, `RemindersProvider` individually loaded in `main()` (no `AppStateProvider`, no repository layer). Persistence = static `load(PrefsService)` + save-on-mutation in each provider.
- [x] **0.10** Tests: serialization round-trips (`DayLog`, `AuthIdentity`, `CycleSettings` — missing/extra JSON keys tolerated); provider persistence round-trips via `SharedPreferences.setMockInitialValues` (settings incl. lunar/dark/3 share flags, reminders, onboarding, logging, auth session save/restore/clear); auth session behavior (email sign-in covered then was later removed in Phase 3).

**Gate:** `flutter analyze` ✅ · `flutter test` ✅ · `flutter build apk --debug` ✅ · `flutter build web` ✅

### Phase 1 — Cycle Engine ✅

> Old Phases 3 + 6 (cycle prediction + domain logic): pure calculator, fetcher, enum, reactive provider, history adaptation, log integrity.

- [x] **1.1** `lib/services/cycle_calculator.dart` — pure functions, injectable `today`: cycle day, phase, next-period date + days remaining, fertile window, ovulation peak day, bleed-day progress, month day-sets (inputs: `lastPeriod`, cycle length, bleed length); backwards multi-cycle wrap — dates before `lastStart` resolve into earlier cycles instead of clamping.
- [x] **1.2** `CyclePhase` enum (`lib/models/cycle_phase.dart`: menstrual / follicular / fertile / ovulatory / luteal — 5 values so `Fertile Window` keeps its own label) + `CycleCalculator.phaseAt(...) → CyclePhase`; themed labels live on the enum as the single source.
- [x] **1.3** `CalendarFetcher` (`lib/services/calendar_fetcher.dart`): `MonthCells` for a month — fixed 42-cell Monday-first grid; per-day flags: predicted period, logged bleed (actual), fertile, ovulation, logged, selected. Consumed by `CycleMapScreen`; `CycleCalendar` stays purely presentational.
- [x] **1.4** `CycleProvider` (`lib/providers/cycle_provider.dart`, ChangeNotifier): constructed from `OnboardingProvider` + `LoggingProvider`, subscribes to both; exposes **effective** `lastStart`/`cycleLength`, today's cycleDay / phase / next-period / days-until / fertile window / ovulation, recent bleed chronology; provided in `main.dart` `MultiProvider`; consumed by sanctuary, fertility, cycle_map, blood, settings + `main()` notification prediction.
- [x] **1.5** `PeriodHistory` (`lib/services/period_history.dart`): infer bleed spans from `DayLog.flow != 'None'` days → period start dates, median cycle length, latest start; adaptation rule = ≥2 observed cycle lengths → median + latest logged start, else onboarding settings.
- [x] **1.6** Log data integrity: `LoggingProvider.deleteDay()`; non-materializing reads (`peekDay`/`hasLog` — view code no longer calls `day()`); default flow `'Medium'` → `'None'` (incl. `fromJson` fallback + `day_log_test`); calendar/blood detail cards show placeholders when the day is unlogged.
- [x] **1.7** Wire dynamic predictions: Sanctuary stat duo + peak card, `/fertility` window duo, `/cycle` "Day X of Y", `/calendar` fertile/period day coloring (from `lastPeriod` + `CycleSettings` + logged `DayLog`s).
- [x] **1.8** Unit tests: calculator boundaries (today = period start, cycle wrap into next month, short 20d / long 40d cycles), fetcher grids (Feb 2026, leap-safe, 42 cells), `phaseAt` + enum labels, history (median odd/even/empty, spans, cycle lengths), `CycleProvider` reactivity + adaptation overrides, log integrity (peek/delete/`'None'` default).

**Gate:** `flutter analyze` ✅ · `flutter test` ✅ · `flutter build apk --debug` ✅ · `flutter build web` ✅

### Phase 2 — App Shell & Tracking UI ✅

> Old Phases 4 + 7 (minus onboarding) + 9: Navigator 2.0 + fl_chart (mandated rules), shell wiring, calendar/dashboard/records with Flo-style parity.

### App framework

- [x] **2.1** Add `fl_chart` to `pubspec.yaml`.
- [x] **2.2** Navigator 2.0: `RouteInformationParser<String>` + `RouterDelegate` (stack of route names → `Navigator(pages:)`); replace all `pushNamed` / `pop` / `pushReplacementNamed` / `pushNamedAndRemoveUntil` call sites (~20, incl. `AppTopBar` back) with `context.go()` / `context.back()` / `context.reset()` helpers; preserve `/library/<slug>` dynamic segment + unknown-slug fallback; shell-tab routes stay `MainScreen(initialIndex:)`; web deep links work.
- [x] **2.3** Rebuild `TrendBars` with `fl_chart` `BarChart` (same M1–M7 pur-gradient bars) — `/insights` + `/chart`. **Exception:** `CycleOrb` ring gauge stays custom-painted (fl_chart has no radial gauge).
- [x] **2.4** Existing widget tests still pass (navigation behavior preserved).
- [x] **2.5** Shell bottom nav wired to real screens (`Sanctuary` / `CycleMap` / `Records` / `Coven` + log FAB); `CycleProvider` provided in `main.dart` (1.4).
- [x] **2.6** Boot navigation: splash post-frame redirect (`onboarded → /dashboard`) + onboarding `finish()` → `reset('/dashboard')` — no separate router bootstrap needed.

### Screens & calendar

- [x] **2.7** `CycleCalendar` rebuilt — fixed 6-row / 42-cell Monday-first grid over `MonthCells`, ovulation day marker (pink dot), predicted (outline) vs logged-bleed (solid) styling, horizontal swipe month navigation alongside the arrows, per-cell click cursor.
- [~] **2.8** Logging flow — done differently: `LogBottomSheet` (flow / mood / symptom / notes chips) instead of spec'd "LogPeriodSheet + LoggingScreen". **Completed**: `RecordsScreen` shows real data — bleed chronology (range, length, On Time / Short / Long / Current tags vs effective cycle length) + average cycle/bleed from `CycleProvider`, with an empty state for no data.
- [x] **2.9** Home dashboard — delivered as `SanctuaryScreen` (phase orb, cycle day, next-period countdown, fertility window card).
- [x] **2.10** Cell fidelity: `CalendarDayCell` + `CalendarFetcher` — `isToday` flag (injectable `today:` param, normalized day comparison), per-cell `cycleDay` (0 for adjacent), adjacent-month cells carry real prev/next-month day numbers via normalized `DateTime` arithmetic.
- [x] **2.11** `CycleCalendar` render — today ring (pur outline on empty cells, white on filled), dimmed non-tappable adjacent cells (`placeholder` color), cycle-day micro-label under every in-month circle, per-cell `Semantics` label (full date + today/selected/period logged/predicted/ovulation/fertile/entries/cycle day; adjacent → "outside this month").
- [x] **2.12** `CalendarLegend` (`lib/widgets/calendar_legend.dart`) — centered wrap: period (solid) / predicted (outline) / fertile / ovulation / logged dots.
- [x] **2.13** `MonthPickerSheet` (`lib/widgets/month_picker_sheet.dart`) — `showMonthPicker(context, current)` modal bottom sheet: year chevron stepper (clamped 1900–2200) + 12-month grid; `CycleMapScreen` month label opens it (replaces the direct `/chart` jump).
- [x] **2.14** `CycleMapScreen` — `CycleProvider.daysLate` gold "N Days Late" pill + tappable "Today" chip when late or off-month; month shift keeps sensible selection (today if in view, else 1st); flow/mood detail rows tappable → `showLogSheet`; "Clear this day's log" link → confirm dialog → `deleteDay`.
- [x] **2.15** `CycleProvider.daysLate({today})` (floor 0, resets when a new bleed start logs) + `LogBottomSheet` gains the `AppSliderRow` pain slider (Uterine Contraction Pain 0–10) above Notes.
- [x] **2.16** Tests — fetcher (+isToday, cycleDay, adjacent day numbers), provider (+daysLate group), `test/widgets/calendar_widgets_test.dart` (day tap, adjacent muted/non-tappable/semantics, legend labels, month-picker result + year stepping, calendar-tab screen wiring).
- [x] **2.17** Docs — DESIGN.md: Screen 06 legend/picker/today/late/clear-day, Screen 07 pain slider + real `DayLog` defaults, §4.1 `/calendar` + `/chart` entry rows.

**Out of scope (flagged):** year view, week strip, pill/birth-control dots, wearables/BBT, pregnancy mode, locale week-start (Monday-first fixed), per-cell follicular/luteal phase tints.

**Gate:** `flutter analyze` ✅ · `flutter test` ✅ · `flutter build apk --debug` ✅ · `flutter build web` ✅

### Phase 3 — Entry Flow & Onboarding ✅

> Old Phase 8 + old 7.4: privacy consent gate between welcome and auth, welcome cleanup, social-only join, onboarding year of birth.

- [x] **3.1** Onboarding (`lib/screens/rhythms_screen.dart` at `/onboarding`): date field → native `showDatePicker` (past dates only, default today); `finish()` saves the picked date **and writes the start-day `DayLog`** (`setFlow(..., 'Medium')`) then `reset('/dashboard')`. Year of Birth dropdown (current year … −100, `witchy_birth_year` persisted via `OnboardingProvider.yearOfBirth`/`setYear`/`finish()`); CTA "Begin the Journey", inert (Opacity 0.45) until a year is chosen.
- [x] **3.2** Welcome (was Splash, `lib/screens/welcome_screen.dart`): renamed class/file, bottom "Sign In" link removed, post-frame redirect (`onboarded → /dashboard`) kept; "Awaken Your Power" routes through the consent gate — `PrefsService.isPrivacyAccepted()` ? `/auth` : `/privacy`.
- [x] **3.3** Privacy gate (`lib/screens/privacy_screen.dart` at `/privacy`): "Your Privacy Promise" copy + 3 checkbox rows (Terms, Privacy Policy, Child Protection) each linking to an in-app webview (`lib/screens/webview_screen.dart` at `/webview?title&url`, `webview_flutter` ^4.10.0, web falls back to selectable URL card); URLs centralized in `lib/utils/legal_links.dart`; Refuse → back to `/`, Accept (enabled only when all 3 checked) → `setPrivacyAccepted()` then `reset('/auth')`; consent persists (`witchy_privacy_accepted`) so Awaken skips the gate next time.
- [x] **3.4** Join (`lib/screens/join_screen.dart`): email/password form removed (`AuthProvider.signInWithEmail` deleted + tests), `MoonRow` deleted; center = `AppEmblem` + "Join Witchy" + subtitle; bottom actions (thumb reach): Continue with Google, Continue with Apple, "Skip for now" — all three `reset('/onboarding')`.
- [x] **3.5** `AppEmblem` widget extracted (`lib/widgets/app_emblem.dart`); `moon_row.dart` + old `splash_screen.dart` deleted.
- [x] **3.6** Tests: widget flow suite (welcome, gate accept/refuse/consent-skip, skip→onboarding→year→journey→Sanctuary, sign-out) + persistence (consent/birth-year round-trips) + auth tests (email removed); `main.dart` now injects `Provider<PrefsService>` so screens can read/write prefs directly.
- [x] **3.7** Docs — PLAN.md (this section), DESIGN.md → v1.4.0 (privacy screen + renumbered screens, join/rhythms/welcome rewrites, nav tree + route table), README.md (consent + anonymous skip + in-app privacy screen).

**Gate:** `flutter analyze` ✅ · `flutter test` ✅ · `flutter build apk --debug` ✅ · `flutter build web` ✅

### Phase 4 — Profile, Settings & Reminders ✅

> Old Phases 5 + 10: scheduled notifications + profile identity, then Settings/Reminders folded into the Profile screen.

### Notifications & identity

- [x] **4.1** Add `flutter_local_notifications` + `timezone` / `flutter_timezone`; Android: core-library desugaring in `android/app/build.gradle.kts`, `POST_NOTIFICATIONS` manifest entry; iOS: `requestAuthorization` flow.
- [x] **4.2** `lib/services/notification_service.dart` — init + schedule/cancel per bell (`zonedSchedule`, daily at configured time, `matchDateTimeComponents: time`); pure `buildNotificationRequests()` extracted for testability.
- [x] **4.3** Wire: `RemindersProvider` bell toggles ↔ schedule/cancel; `SettingsProvider.lunarNotifications` ↔ period-prediction alert; existing `PrefsService` persistence unchanged.
- [x] **4.4** Profile identity: header shows `AuthIdentity` display name/email (fallback to placeholder), **Sign Out** button → `auth.signOut()` → reset stack to `/`.
- [x] **4.5** Tests: `buildNotificationRequests` unit test; sign-out widget test.

### Profile consolidation

- [x] **4.6** `ProfileScreen` rework — top-bar action `AppIcons.gear → AppIcons.alerts` (`go('/alerts')`); dropped the `Notification Preferences → Manage` and `Appearance → Manage` links (Lunar Alignments = stats only, Apothecary keeps Gestation + Bond).
- [x] **4.7** New **App Settings** `AppCard` — `Receive Lunar Notifications` switch (`setLunar` + `NotificationService.syncPeriodPrediction` with `CycleProvider.nextPeriodStart()`) and `Dark Magic Mode` switch (`setDark`), ported from the old SettingsScreen.
- [x] **4.8** **Amulet Bells** card rebuilt — header + live count kept; `Open Amulet Reminders` button removed; 5 inline bell rows (hairline dividers: `IconBadge` + title/subtitle + pur `Switch` → `toggle` + `NotificationService.syncReminder`; ON rows show clock/freq `InfoPill`s).
- [x] **4.9** Deletions — `lib/screens/settings_screen.dart`, `lib/screens/reminders_screen.dart` removed; `app_router_delegate.dart` drops both imports and the `/settings` + `/reminders` cases (unknown paths recover via the welcome redirect).
- [x] **4.10** Tests — suite unchanged (sign-out widget test still reaches Sign Out after the taller Profile; no screen tests referenced the deleted routes).
- [x] **4.11** Docs — DESIGN.md → v1.6.0 (nav/app-bar lines, §4.1 rows, nav tree, Screen 14 rewrite, Settings + Amulet Reminders sections deleted, screens renumbered), PLAN.md (this section).

**Gate:** `flutter analyze` ✅ · `flutter test` ✅ · `flutter build apk --debug` ✅ · `flutter build web` ✅

### Phase 5 — Splash & Branding ✅

> Old Phases 11 + 12 + 13: native splash, in-app splash preview, one mask + tint asset consolidation.

- [x] **5.1** Native splash via `flutter_native_splash` — pubspec gains `assets/images/` in `flutter.assets`; splash config fixed (old `#0x…` color strings were invalid) → `color: "#3B0A5E"`, `fullscreen: true`, `android_12` plum color/icon-background + gold image; `dart run flutter_native_splash:create` generated Android (drawables + `windowSplashScreen*` styles incl. night/v31), iOS (LaunchImage + storyboard + Info.plist) and web splash assets (was default white).
- [x] **5.2** `AppEmblem` uses the cat-moon image instead of `FaIcon(AppIcons.moon)` (size box `size * 0.36` kept); final state after 5.6: `Image.asset('assets/images/cat-moon-mask-512.png', color: AppColors.gold, colorBlendMode: BlendMode.srcIn)` (`cacheWidth: 256`). Other `AppIcons.moon` sites (nav Today tab, cycle orb, moods, mocks) unchanged.
- [x] **5.3** Logo sizing iterations (superseded by 5.2/5.6): source resampled 128 → 256 → **512×512** and splash regenerated each time; un-suffixed `cat-moon-gold.png` replaced by `cat-moon-{black,plum,plum2,gold}-{128,256,512}` variants (fixed dangling refs).
- [x] **5.4** In-app `SplashScreen` (`lib/screens/splash_screen.dart`, `/splash` — direct route only, no in-app links/buttons): full-bleed plum `Scaffold`, `LayoutBuilder` emblem at `min(w,h) * 0.25`, `Image.asset(...)` `BoxFit.contain`, centered; no text/SafeArea/redirect logic; router case after `/binding`; test `test/widgets/splash_screen_test.dart` (plum background + single `Image`, no text).
- [x] **5.5** Native splash logo = **25% of the smaller viewport axis** — the package exposes no size option, so post-`create` hand-edits: **iOS** `LaunchScreen.storyboard` centered imageView with 4 constraint multipliers `0.25` vs superview width/height (`scaleAspectFit`); **web** `index.html` splash `<img>` → `style="min(25vw, 25vh)"`; **Android** all 15 generated bitmaps (`sips`-resized to `90dp × density` = 90/135/180/270/360px, upscaled from the 512 source, night included).
  - ⚠️ **Fragile:** `dart run flutter_native_splash:create` **overwrites** the storyboard, `index.html` and the Android bitmaps — after any pubspec splash-config change, re-run `create` **and re-apply these hand-edits**. Splash verified by pixel math + builds only (no emulator/device here).
- [x] **5.6** Asset consolidation: pixel audit showed all 12 `cat-moon-{black,gold,plum,plum2}-{128,256,512}.png` are flat single-color + alpha stencils (extra colors = antialias edges) → created `assets/images/cat-moon-mask-512.png`; `AppEmblem` + in-app `SplashScreen` tint with `AppColors.gold` (`#D9A036`, identical pixels to the old gold PNGs); pruned 11 files — kept mask (all in-app use) + `cat-moon-gold-512.png` (only for `flutter_native_splash`, which bakes static PNGs and cannot tint).
- [x] **5.7** Docs — PLAN.md (this section), DESIGN.md → v1.7.0 (emblem PNG + native launch splash), v1.8.0 (Screen 19 app-splash preview, §4.1 route row, nav tree `/splash`), v1.8.2 (mask + tint).

**Gate:** `flutter analyze` ✅ · `flutter test` ✅ (81/81 final suite) · `flutter build apk --debug` ✅ · `flutter build web` ✅

--- 

## Milestone 2 - TBD
