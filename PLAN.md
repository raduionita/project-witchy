# PLAN.md — Witchy Period Tracker & Cycle Calendar App

A full, **ready-for-production implementation plan** for a comprehensive health tracking application that helps users understand and monitor their menstrual cycle, fertility window, pregnancy, and overall reproductive health.

This plan is split into **Phases**. Each phase is a list of tasks that MUST be completed **one-by-one**. At the **end of every phase** the project MUST be **error-free and buildable**.

**Status legend:** `[x]` done · `[~]` done differently (details noted) · `[-]` obsolete (superseded) · `[ ]` open

> Phases were compacted (old 0–13 → new 0–5); obsolete `[-]` tasks were pruned and deviations kept as `[~]` or footnotes. Final test suite: **81/81**. Production-readiness work is planned as open **Phases 6–13** (bottom of Milestone 1) — scope decisions locked: Coven = remote article feed (Library removed), Binding removed, auth hidden as-is, tracking chips (Cycle/Pregnancy/Perimenopause), real BBT, real alerts, dark theme, release hardening.

---

## Rules & Conventions (apply in every phase)

- **NO Firebase.** Storage uses `shared_preferences`; state uses `provider`.
- **Files**: `snake_case.dart`. **Classes**: `PascalCase`. **Functions/Variables**: `camelCase`. **Constants**: `kPascalCase`. **Private members**: leading underscore `_`.
- **Import order**: Dart → Flutter → Packages → Relative.
- **Navigation**: Navigator 2.0 (`Router` + custom `RouterDelegate` + `RouteInformationParser`). *Mandated rule — implemented in Phase 2; until then the app uses named routes.*
- **Charts**: `fl_chart`. *Mandated rule — implemented in Phase 2; `CycleOrb` ring gauge stays custom-painted (fl_chart has no radial gauge).*
- **Couples Mode / Binding**: removed in Phase 6 (no backend allowed; feature was a no-op placeholder).
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

### Phases 6-13 - Production Readiness (open)

> Audit-driven finishing work: replace every mocked surface with real data (or remove it), add the tracking modes, then harden for store release. Scope decisions locked with the product owner: Coven becomes a remote article feed (Library removed), Binding removed, auth stays hidden as-is, onboarding gains Cycle / Pregnancy / Perimenopause tracking chips, BBT gets real temperature capture, alerts become locally generated, dark mode gets a real theme.

### Phase 6 - Article Feed & Feature Removal (done)

> Coven becomes a web-sourced reading feed; Library and Binding are deleted.

- [x] **6.1** Add `http` + `xml` to `pubspec.yaml`; run `flutter pub get`.
- [x] **6.2** `lib/services/feed_service.dart` - fetch `https://qvonyx.com/witchy/articles.xml`, parse `<item>` entries (title, link, description, pubDate, category) into a rebuilt `Article` model (`link` + `pubDate` replace `thumb`/`readTime`); cache payload in `PrefsService` for offline; expose `load({bool refresh})`. RFC-822 `pubDate` parsed via `DateFormat('EEE, dd MMM yyyy HH:mm:ss Z', 'en_US')`; fetch failure falls back to cache, rethrows only when no cache.
- [x] **6.3** Rewrite `lib/screens/coven_screen.dart` - no `AppTopBar` title, no segment tabs, no FAB, no `MockData.posts`; scrollable article cards (serif title, muted meta, excerpt, category tag) with pull-to-refresh + loading/error/empty states; tap -> `context.go('/webview?title=...&url=...')` (privacy-screen mechanism). Optional `feed` constructor param for tests.
- [x] **6.4** Delete `lib/screens/library_screen.dart` + `lib/screens/article_detail_screen.dart`; remove `/library` and `/library/<slug>` from `app_router_delegate.dart` (slug fallback + `MockData` import); remove all library entry points.
- [x] **6.5** Delete `lib/screens/binding_screen.dart`; remove `/binding` route, Profile "Cosmic Partner Bond" row, and the 3 share flags from `SettingsProvider` + their `PrefsService` keys (`clearLegacyBindingFlags()` runs on `SettingsProvider.load`).
- [x] **6.6** Prune dead code: `MockData.posts()`, `MockData.articles()`, `MockData.articleById()`, `lib/models/coven_post.dart`; keep `MockData.reminders()` + `alerts()` (replaced in Phase 9).
- [x] **6.7** Docs - `DESIGN.md` v1.9.0 (nav tree, Screen 12/13/18 tombstoned, Screen 17 rewritten as article feed, welcome/privacy rows now hand off to `/onboarding`), `PLAN.md` (this section).
- [x] **6.8** Tests - `test/services/feed_service_test.dart` (parse fixture, HTML strip, defaults, dropped incomplete items, cache round-trip, cache-first load, unreachable-feed rethrow) + `test/screens/coven_screen_test.dart` (renders cached items, no tabs/FAB, tap -> `/webview` route with encoded params, empty state) + `test/providers/persistence_test.dart` (share-flag removal).

**Gate:** `flutter analyze` ✅ · `flutter test` ✅ (93/93) · `flutter build apk --debug` ✅ · `flutter build web` ✅

### Phase 7 - Tracking Mode Selection (done)

> Onboarding gains Cycle / Pregnancy / Perimenopause choice; the mode gates Phases 10-11.

- [x] **7.1** `lib/models/tracking_mode.dart` - enum `TrackingMode { cycle, pregnancy, perimenopause }` with themed labels (`Cycle` / `Pregnancy` / `Perimenopause`) + `toJson`/`fromJson` (unknown/missing -> `cycle`).
- [x] **7.2** Persist - `PrefsService` key `witchy_tracking_mode` (default `cycle`) + `OnboardingProvider.trackingMode`/`setTrackingMode` (setter persists immediately so Profile edits stick without `finish()`; `finish()` also saves).
- [x] **7.3** `lib/widgets/tracking_mode_chip.dart` - `TrackingModeChips` single-select `Wrap` of `AppChip`s (icons: droplet / personPregnant / moon, selected = pur fill); wired into `rhythms_screen.dart` as a "What shall we track?" `AppCard` directly under the header; saved in `finish()`.
- [x] **7.4** Gating hooks - `OnboardingProvider.trackingMode` exposed; this phase only surfaces the label (Profile row); real screen differences land in Phases 10/11.
- [x] **7.5** Profile Lunar Alignments gains a "Tracking Mode" row (pur underline = current label) opening a modal bottom sheet with the same 3 chips (persist + notify + pop).
- [x] **7.6** Docs - `DESIGN.md` v1.9.1 (Screen 04 tracking card, Screen 14 row, §4.1 onboarding row); `/auth` stays hidden (sign-in kept as-is, deferred) - noted in v1.9.0 pass.
- [x] **7.7** Tests - `test/models/tracking_mode_test.dart` (round-trip, default, labels) + `persistence_test` (default cycle, setTrackingMode reactive + persists, finish saves) + `widget_test` (select Pregnancy -> begin -> Profile shows it, prefs key = 'pregnancy').

**Gate:** `flutter analyze` ✅ · `flutter test` ✅ (99/99) · `flutter build apk --debug` ✅ · `flutter build web` ✅

### Phase 8 - BBT Temperature Logging & Real Charts (done)

> Real data replaces `TrendBars` fake heights and the fake `36.4°` / `+0.4°`.

- [x] **8.1** `DayLog` gains `temperature` (`double?`, °C, null = unlogged) with `fromJson` missing-key tolerance; extend `day_log_test`.
- [x] **8.2** Log sheet - new "Basal Body Temperature" section between pain slider and notes (35.0-38.0 °C, step 0.1, live serif value); `LoggingProvider.setTemperature(date, value)`; `peekDay` defaults unaffected.
- [x] **8.3** `lib/widgets/trend_bars.dart` - accept `values` + `labels` params (drop the `_heights` constant); Records passes real observed cycle lengths from `PeriodHistory`, empty state under 2 cycles.
- [x] **8.4** `lib/screens/chart_screen.dart` rebuild - fl_chart `LineChart` of the last ~30 logged temperatures (gaps for null), ovulation marker at `CycleCalculator` peak day, computed pre-shift average + post-shift rise; empty state with "Log your temperature" prompt -> log sheet.
- [x] **8.5** Docs - `DESIGN.md` Screen 09 rewrite + Screen 07 temperature row.
- [x] **8.6** Tests - `DayLog` temperature round-trip, `setTemperature` persistence, trend-bars real inputs, chart screen widget test (empty + data), averages math.

**Gate:** `flutter analyze` ✅ · `flutter test` ✅ (104/104) · `flutter build apk --debug` ✅ · `flutter build web` ✅

### Phase 9 - Real Local Alerts Inbox (done)

> `MockData.alerts()` dies; alerts are generated from real cycle events.

- [x] **9.1** `AlertItem` gains `id`, `type` (periodPredicted / fertileWindow / logMissing / lunarMilestone), `createdAt`, `read` with `toJson`/`fromJson` (+ extra `eventDate` used for expiry pruning; icon/tint derive from `AlertType`).
- [x] **9.2** `lib/services/alert_generator.dart` - pure functions from `CycleProvider` + `LoggingProvider`: period predicted in 2 days / 1 day, fertile peak today, log missing after 18:00, lunar milestone (computed new/full moon); deduped by stable id.
- [x] **9.3** `AlertProvider` (ChangeNotifier) - persisted list (`witchy_alerts`, cap 30), `bind()` generates on startup + listens to `CycleProvider`, `markRead`/`markAllRead`, unread count, expired `eventDate`s pruned.
- [x] **9.4** `lib/screens/alerts_screen.dart` - reads `AlertProvider`, real relative timestamps (`intl`), read/unread styling, tap marks read, empty state; shell/profile bells show unread dot (`AppTopBar.badge`).
- [x] **9.5** Retire `MockData.alerts()`.
- [x] **9.6** Docs - `DESIGN.md` Screen 16 (v1.9.3); `PLAN.md`.
- [x] **9.7** Tests - generator cases (2-day, 1-day, peak, missing log, lunar, dedupe determinism), persistence, markRead, alerts screen widget test.

**Gate:** `flutter analyze` ✅ · `flutter test` ✅ (118/118) · `flutter build apk --debug` ✅ · `flutter build web` ✅

### Phase 10 - Pregnancy Mode (done)

> Gestation becomes computed; reachable only when `TrackingMode.pregnancy`.

- [x] **10.1** `lib/providers/gestation_provider.dart` - `lmpDate` input persisted (`witchy_pregnancy_lmp`); computes gestational days, week/day, `progress = days/280`, days remaining, trimester, due date (past-due counter + future-LMP clamp included).
- [x] **10.2** Date entry - gestation screen empty state `AppButton` opens a past-only date picker; the LMP row card reopens it; onboarding seeds `lmpDate = lastPeriodStart` when the Pregnancy chip is chosen (`rhythms_screen._complete`).
- [x] **10.3** `lib/models/gestation_week.dart` + `lib/common/gestation_content.dart` - 10 week-range buckets covering weeks 0-40 (size tag, development, tip) + past-term fallback for >40; negative clamps to first.
- [x] **10.4** Rebuild `lib/screens/gestation_screen.dart` - computed `Week N (Day D)`, real progress bar, countdown/past-due copy, due date + trimester line, content lookup per week; profile Apothecary row hidden unless mode = pregnancy.
- [x] **10.5** Engine respect - `CycleProvider.showFertilityPredictions` (true only in Cycle mode; shared gate for Phase 11) suppresses `isFertileDay`/`isOvulationDay` (→ sanctuary card, fertile alerts), calendar glyphs (`CalendarFetcher.showFertility`), BBT ovulation marker; logged bleeds + period predictions stay visible.
- [x] **10.6** Docs - `DESIGN.md` Screen 11 (v1.9.4); `PLAN.md`.
- [x] **10.7** Tests - gestation math (today/84/280/past-due/future/due date/trimester boundaries), persistence, content lookup + fallback + gap-free coverage, screen widget tests (empty + seeded + week-1), fertility gate (provider + fetcher + widget).

**Gate:** `flutter analyze` ✅ · `flutter test` ✅ (137/137) · `flutter build apk --debug` ✅ · `flutter build web` ✅

### Phase 11 - Perimenopause Mode (done)

> Cycle tracking continues with irregularity-aware predictions.

- [x] **11.1** `CycleProvider` adaptation when `trackingMode == perimenopause` - expose `predictedRange` (earliest/latest next start from min/max observed cycle lengths), median fallback. -> `isPerimenopause`, `shortestCycleLength`/`longestCycleLength` (fallback = effective length), `cycleSpread` (null under 2 cycles), `predictedRange({today})` via `CycleCalculator.nextPeriodStart` on both extremes (results ordered earliest<=latest).
- [x] **11.2** Sanctuary - stat duo shows a date window instead of a single day; fertility/peak card suppressed (ovulation unreliable); softened phase copy. -> `Bleeding In` renders `dMin–dMax Days` + `d MMM – d MMM · range` (collapses to `N Days` on a single-day window); day card note becomes `Period may start any day now` on d-1/d-2; fertility card already hidden by `showFertilityPredictions`.
- [x] **11.3** Calendar - fertile/ovulation glyphs hidden; predicted period rendered as a range (whole window marked). -> `CalendarFetcher.forMonth` gains `predictedStart`/`predictedEnd`; marks the union of possible bleed days (earliest start through latest start + bleedLength) replacing arithmetic; `cycle_screen` passes `predictedRange()` only when `isPerimenopause`; fertile/ovulation glyphs already hidden via `showFertility: false`.
- [x] **11.4** Records gains an "Irregularity" row (cycle-length spread, longest vs shortest) from `PeriodHistory`. -> `_buildIrregularityCard`: `shortest–longest Days` + `N Days variation` tag from `cycle.cycleSpread`; empty state under 2 cycles; always visible (most meaningful in Perimenopause).
- [x] **11.5** Alerts generator - fertile alerts become "window opens as early as..." in this mode. -> `else if (cycle.isPerimenopause && cycle.ovulationDay(today: now) == today)` fires the hedged `Fertility Window` alert ("may open as early as today..."), same `fertile-<date>` id; peak alert unchanged for Cycle mode.
- [x] **11.6** Docs - `DESIGN.md` Screen 05/06 mode variants + §4.1 (v1.9.5); `PLAN.md`.
- [x] **11.7** Tests - range math + spread fallback (`cycle_provider_test`), window glyph marking (`calendar_fetcher_test`), hedged + quiet alert cases (`alert_generator_test`), Sanctuary widget tests per mode, Records irregularity widget tests (empty + spread).

**Gate:** `flutter analyze` ✅ · `flutter test` ✅ (146/146) · `flutter build apk --debug` ✅ · `flutter build web` ✅

### Phase 12 - Dark Theme & Profile/Notification Polish (open)

- [ ] **12.1** `AppColors` dark token set (bg `#1B0A2A`, card `#26063F`, lav text, line `#3E2A54`, brightened pur) + `buildAppTheme({Brightness})` dark variant in `app_theme.dart`.
- [ ] **12.2** `main.dart` theme follows `SettingsProvider.dark` override else platform brightness; `setDark` repaints live; Profile toggle kept.
- [ ] **12.3** Profile real data - `29 Days`/`5 Days` -> `CycleProvider.meanCycleLength`/`bleedLength` (empty-state dashes); bell denominator -> `reminders.length`; version string -> `package_info_plus` (single source, replaces hardcoded `1.2.4`).
- [ ] **12.4** Notification `freq` semantics honoured - `buildNotificationRequests` maps freq -> schedule rule (daily, daily-during-peak, window-start one-shot, period-minus-3-days one-shot, hourly daytime); re-sync whenever `CycleProvider` or reminders change.
- [ ] **12.5** Stop swallowing scheduling errors - surface via `debugPrint` + SnackBar on Profile toggle failure.
- [ ] **12.6** Docs - `DESIGN.md` §2 dark tokens + Screen 14; `PLAN.md`.
- [ ] **12.7** Tests - dark theme builder, freq -> request mapping per rule, profile reads provider values (widget test), re-sync trigger.

**Gate:** `flutter analyze` · `flutter test` · `flutter build apk --debug` · `flutter build web`

### Phase 13 - Release Hardening & Final Gate (open)

- [ ] **13.1** Android - `key.properties` + release `signingConfigs` (git-ignored keystore, README steps), drop applicationId TODO, pin compile/target/min SDK, `android:label="Witchy"`.
- [ ] **13.2** Branded launcher icons via `flutter_launcher_icons` - cat-moon icon for Android (all densities), iOS (incl. adaptive), web; replaces default Flutter logo everywhere.
- [ ] **13.3** iOS - `DEVELOPMENT_TEAM` placeholder, uncomment Podfile platform (13.0), `PrivacyInfo.xcprivacy`, `ITSAppUsesNonExemptEncryption=false`; comment in `auth_provider.dart` documenting the future Google/Apple sign-in config (kept hidden per scope decision).
- [ ] **13.4** Web - `<title>Witchy</title>`, meta description, `apple-mobile-web-app-title`, `manifest.json` name/description + `theme_color`/`background_color` `#3B0A5E`, icons from 13.2.
- [ ] **13.5** Version single-sourced from pubspec into the profile footer (12.3).
- [ ] **13.6** Verify live endpoints - `legal_links.dart` URLs deployed; `articles.xml` reachable and parseable.
- [ ] **13.7** Test-suite review - add coverage for feed, alerts, gestation, chart, dark mode; zero skipped tests.
- [ ] **13.8** Release gate - `flutter analyze` zero issues · `flutter test` all green · `flutter build apk --release` · `flutter build ios --release --no-codesign` · `flutter build web`.
- [ ] **13.9** Docs - `PLAN.md` Milestone 1 closed, `DESIGN.md` final bump, `README` build/signing instructions.

**Gate:** `flutter analyze` · `flutter test` · `flutter build apk --release` · `flutter build ios --release --no-codesign` · `flutter build web`

> Out of scope (flagged): Google/Apple sign-in activation (hidden), real couples/backend sync, Coven posting, sovereign-blood screen from MOCK.html (not in DESIGN.md), localization, analytics/crash reporting.


### Fixes - Post Milestone 1 phases

- [ ] rhythyms -> button: should mark user as logged-in and continue to main screen 
- [ ] profile -> signup: should mark user as logged-out and return to first screen
- [ ] floating button: opacity agains purple widgets/cards is not good - try to add a gold border to make it more visible
- [ ] profile: after sign-out, we need a delete all data button (dark-ish red bg, white text)
- [ ] rhythyms - tracking mode: should be a multi-toggle - the app MUST allow tracking all modes (cycle, pregnancy, perimenopause) simultaneously on the same interface (calendar, records, sanctuary, fertility, alert)
 
--- 

## Milestone 2 - TBD
