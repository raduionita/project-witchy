# CHANGES.md - Witchy Changelog

Chronological record of shipped updates, oldest first. Update numbers are permanent.
Every update left the app analyze-clean, tested and buildable.

---

## Update 0 - Foundation & Data Layer

- **0.1** Base dependencies in `pubspec.yaml`: kept `provider`, `shared_preferences`, `uuid`, `intl`, `font_awesome_flutter`, `google_fonts`, `flutter_svg`, `google_sign_in`, `sign_in_with_apple`; dev `flutter_lints`. Dropped as unneeded: `freezed`, `json_serializable`, `build_runner`, `device_info_plus`, `url_launcher`.
- **0.2** Run `flutter pub get`. No codegen anywhere in the project (no `build_runner`).
- **0.3** Folder skeleton ✓ + `assets/icons` + `assets/images`. `assets/content/` omitted - seeded articles live in `lib/models/mock_data.dart`.
- **0.4** Design system: `lib/theme/` (`AppColors`, `AppText`, `buildAppTheme`) and shared widget primitives in `lib/widgets/` (`AppButton`, `AppCard`, `AppTag`, `AppChip`, `AppTextField`, `AppSliderRow`, `AppTopBar`, `AppBottomNav`, `AppAvatar`, `AppIcons`).
- **0.5** Simple navigation: `MaterialApp.routes` - **note**: temporary stand-in; Navigator 2.0 migration in Update 2.
- **0.6** Root bootstrap: async `main()` → `PrefsService` + 5 providers loaded → `MultiProvider` + `MaterialApp` (`App` in `lib/main.dart`).
- **0.7** Models - done differently: plain-Dart, one per file, hand-written `toJson`/`fromJson` where needed - `DayLog`, `Article`, `ReminderItem`, `AlertItem`, `CovenPost`, `CycleSettings`, `AuthIdentity`. No freezed; no `UserProfile`/`PeriodLog`/`Cycle`/`SymptomLog` (replaced by `DayLog` + `CycleSettings` + `AuthIdentity`).
- **0.8** `PrefsService` (as `StorageService`): typed accessors over `shared_preferences`, `witchy_*` key namespacing, session + settings + day-log getters/setters - `lib/services/prefs_service.dart`.
- **0.9** Providers - done differently: `AuthProvider`, `OnboardingProvider`, `LoggingProvider`, `SettingsProvider`, `RemindersProvider` individually loaded in `main()` (no `AppStateProvider`, no repository layer). Persistence = static `load(PrefsService)` + save-on-mutation in each provider.
- **0.10** Tests: serialization round-trips (`DayLog`, `AuthIdentity`, `CycleSettings` - missing/extra JSON keys tolerated); provider persistence round-trips via `SharedPreferences.setMockInitialValues` (settings incl. lunar/dark/3 share flags, reminders, onboarding, logging, auth session save/restore/clear); auth session behavior (email sign-in covered then was later removed in Update 3).

**Gate:** `flutter analyze` ✅ · `flutter test` ✅ · `flutter build apk --debug` ✅ · `flutter build web` ✅

## Update 1 - Cycle Engine

- **1.1** `lib/services/cycle_calculator.dart` - pure functions, injectable `today`: cycle day, phase, next-period date + days remaining, fertile window, ovulation peak day, bleed-day progress, month day-sets (inputs: `lastPeriod`, cycle length, bleed length); backwards multi-cycle wrap - dates before `lastStart` resolve into earlier cycles instead of clamping.
- **1.2** `CyclePhase` enum (`lib/models/cycle_phase.dart`: menstrual / follicular / fertile / ovulatory / luteal - 5 values so `Fertile Window` keeps its own label) + `CycleCalculator.phaseAt(...) → CyclePhase`; themed labels live on the enum as the single source.
- **1.3** `CalendarFetcher` (`lib/services/calendar_fetcher.dart`): `MonthCells` for a month - fixed 42-cell Monday-first grid; per-day flags: predicted period, logged bleed (actual), fertile, ovulation, logged, selected. Consumed by `CycleMapScreen`; `CycleCalendar` stays purely presentational.
- **1.4** `CycleProvider` (`lib/providers/cycle_provider.dart`, ChangeNotifier): constructed from `OnboardingProvider` + `LoggingProvider`, subscribes to both; exposes **effective** `lastStart`/`cycleLength`, today's cycleDay / phase / next-period / days-until / fertile window / ovulation, recent bleed chronology; provided in `main.dart` `MultiProvider`; consumed by sanctuary, fertility, cycle_map, blood, settings + `main()` notification prediction.
- **1.5** `PeriodHistory` (`lib/services/period_history.dart`): infer bleed spans from `DayLog.flow != 'None'` days → period start dates, median cycle length, latest start; adaptation rule = ≥2 observed cycle lengths → median + latest logged start, else onboarding settings.
- **1.6** Log data integrity: `LoggingProvider.deleteDay()`; non-materializing reads (`peekDay`/`hasLog` - view code no longer calls `day()`); default flow `'Medium'` → `'None'` (incl. `fromJson` fallback + `day_log_test`); calendar/blood detail cards show placeholders when the day is unlogged.
- **1.7** Wire dynamic predictions: Sanctuary stat duo + peak card, `/fertility` window duo, `/cycle` "Day X of Y", `/calendar` fertile/period day coloring (from `lastPeriod` + `CycleSettings` + logged `DayLog`s).
- **1.8** Unit tests: calculator boundaries (today = period start, cycle wrap into next month, short 20d / long 40d cycles), fetcher grids (Feb 2026, leap-safe, 42 cells), `phaseAt` + enum labels, history (median odd/even/empty, spans, cycle lengths), `CycleProvider` reactivity + adaptation overrides, log integrity (peek/delete/`'None'` default).

**Gate:** `flutter analyze` ✅ · `flutter test` ✅ · `flutter build apk --debug` ✅ · `flutter build web` ✅

## Update 2 - App Shell & Tracking UI

### App framework

- **2.1** Add `fl_chart` to `pubspec.yaml`.
- **2.2** Navigator 2.0: `RouteInformationParser<String>` + `RouterDelegate` (stack of route names → `Navigator(pages:)`); replace all `pushNamed` / `pop` / `pushReplacementNamed` / `pushNamedAndRemoveUntil` call sites (~20, incl. `AppTopBar` back) with `context.go()` / `context.back()` / `context.reset()` helpers; preserve `/library/<slug>` dynamic segment + unknown-slug fallback; shell-tab routes stay `MainScreen(initialIndex:)`; web deep links work.
- **2.3** Rebuild `TrendBars` with `fl_chart` `BarChart` (same M1-M7 pur-gradient bars) - `/insights` + `/chart`. **Exception:** `CycleOrb` ring gauge stays custom-painted (fl_chart has no radial gauge).
- **2.4** Existing widget tests still pass (navigation behavior preserved).
- **2.5** Shell bottom nav wired to real screens (`Sanctuary` / `CycleMap` / `Records` / `Coven` + log FAB); `CycleProvider` provided in `main.dart` (1.4).
- **2.6** Boot navigation: splash post-frame redirect (`onboarded → /dashboard`) + onboarding `finish()` → `reset('/dashboard')` - no separate router bootstrap needed.

### Screens & calendar

- **2.7** `CycleCalendar` rebuilt - fixed 6-row / 42-cell Monday-first grid over `MonthCells`, ovulation day marker (pink dot), predicted (outline) vs logged-bleed (solid) styling, horizontal swipe month navigation alongside the arrows, per-cell click cursor.
- **2.8** Logging flow - done differently: `LogBottomSheet` (flow / mood / symptom / notes chips) instead of spec'd "LogPeriodSheet + LoggingScreen". **Completed**: `RecordsScreen` shows real data - bleed chronology (range, length, On Time / Short / Long / Current tags vs effective cycle length) + average cycle/bleed from `CycleProvider`, with an empty state for no data.
- **2.9** Home dashboard - delivered as `SanctuaryScreen` (phase orb, cycle day, next-period countdown, fertility window card).
- **2.10** Cell fidelity: `CalendarDayCell` + `CalendarFetcher` - `isToday` flag (injectable `today:` param, normalized day comparison), per-cell `cycleDay` (0 for adjacent), adjacent-month cells carry real prev/next-month day numbers via normalized `DateTime` arithmetic.
- **2.11** `CycleCalendar` render - today ring (pur outline on empty cells, white on filled), dimmed non-tappable adjacent cells (`placeholder` color), cycle-day micro-label under every in-month circle, per-cell `Semantics` label (full date + today/selected/period logged/predicted/ovulation/fertile/entries/cycle day; adjacent → "outside this month").
- **2.12** `CalendarLegend` (`lib/widgets/calendar_legend.dart`) - centered wrap: period (solid) / predicted (outline) / fertile / ovulation / logged dots.
- **2.13** `MonthPickerSheet` (`lib/widgets/month_picker_sheet.dart`) - `showMonthPicker(context, current)` modal bottom sheet: year chevron stepper (clamped 1900-2200) + 12-month grid; `CycleMapScreen` month label opens it (replaces the direct `/chart` jump).
- **2.14** `CycleMapScreen` - `CycleProvider.daysLate` gold "N Days Late" pill + tappable "Today" chip when late or off-month; month shift keeps sensible selection (today if in view, else 1st); flow/mood detail rows tappable → `showLogSheet`; "Clear this day's log" link → confirm dialog → `deleteDay`.
- **2.15** `CycleProvider.daysLate({today})` (floor 0, resets when a new bleed start logs) + `LogBottomSheet` gains the `AppSliderRow` pain slider (Uterine Contraction Pain 0-10) above Notes.
- **2.16** Tests - fetcher (+isToday, cycleDay, adjacent day numbers), provider (+daysLate group), `test/widgets/calendar_widgets_test.dart` (day tap, adjacent muted/non-tappable/semantics, legend labels, month-picker result + year stepping, calendar-tab screen wiring).
- **2.17** Docs - DESIGN.md: Screen 06 legend/picker/today/late/clear-day, Screen 07 pain slider + real `DayLog` defaults, §4.1 `/calendar` + `/chart` entry rows.

**Out of scope (flagged):** year view, week strip, pill/birth-control dots, wearables/BBT, pregnancy mode, locale week-start (Monday-first fixed), per-cell follicular/luteal phase tints.

**Gate:** `flutter analyze` ✅ · `flutter test` ✅ · `flutter build apk --debug` ✅ · `flutter build web` ✅

## Update 3 - Entry Flow & Onboarding

- **3.1** Onboarding (`lib/screens/rhythms_screen.dart` at `/onboarding`): date field → native `showDatePicker` (past dates only, default today); `finish()` saves the picked date **and writes the start-day `DayLog`** (`setFlow(..., 'Medium')`) then `reset('/dashboard')`. Year of Birth dropdown (current year … −100, `witchy_birth_year` persisted via `OnboardingProvider.yearOfBirth`/`setYear`/`finish()`); CTA "Begin the Journey", inert (Opacity 0.45) until a year is chosen.
- **3.2** Welcome (was Splash, `lib/screens/welcome_screen.dart`): renamed class/file, bottom "Sign In" link removed, post-frame redirect (`onboarded → /dashboard`) kept; "Awaken Your Power" routes through the consent gate - `PrefsService.isPrivacyAccepted()` ? `/auth` : `/privacy`.
- **3.3** Privacy gate (`lib/screens/privacy_screen.dart` at `/privacy`): "Your Privacy Promise" copy + 3 checkbox rows (Terms, Privacy Policy, Child Protection) each linking to an in-app webview (`lib/screens/webview_screen.dart` at `/webview?title&url`, `webview_flutter` ^4.10.0, web falls back to selectable URL card); URLs centralized in `lib/utils/legal_links.dart`; Refuse → back to `/`, Accept (enabled only when all 3 checked) → `setPrivacyAccepted()` then `reset('/auth')`; consent persists (`witchy_privacy_accepted`) so Awaken skips the gate next time.
- **3.4** Join (`lib/screens/join_screen.dart`): email/password form removed (`AuthProvider.signInWithEmail` deleted + tests), `MoonRow` deleted; center = `AppEmblem` + "Join Witchy" + subtitle; bottom actions (thumb reach): Continue with Google, Continue with Apple, "Skip for now" - all three `reset('/onboarding')`.
- **3.5** `AppEmblem` widget extracted (`lib/widgets/app_emblem.dart`); `moon_row.dart` + old `splash_screen.dart` deleted.
- **3.6** Tests: widget flow suite (welcome, gate accept/refuse/consent-skip, skip→onboarding→year→journey→Sanctuary, sign-out) + persistence (consent/birth-year round-trips) + auth tests (email removed); `main.dart` now injects `Provider<PrefsService>` so screens can read/write prefs directly.
- **3.7** Docs - CHANGES.md (this update), DESIGN.md → v1.4.0 (privacy screen + renumbered screens, join/rhythms/welcome rewrites, nav tree + route table), README.md (consent + anonymous skip + in-app privacy screen).

**Gate:** `flutter analyze` ✅ · `flutter test` ✅ · `flutter build apk --debug` ✅ · `flutter build web` ✅

## Update 4 - Profile, Settings & Reminders

### Notifications & identity

- **4.1** Add `flutter_local_notifications` + `timezone` / `flutter_timezone`; Android: core-library desugaring in `android/app/build.gradle.kts`, `POST_NOTIFICATIONS` manifest entry; iOS: `requestAuthorization` flow.
- **4.2** `lib/services/notification_service.dart` - init + schedule/cancel per bell (`zonedSchedule`, daily at configured time, `matchDateTimeComponents: time`); pure `buildNotificationRequests()` extracted for testability.
- **4.3** Wire: `RemindersProvider` bell toggles ↔ schedule/cancel; `SettingsProvider.lunarNotifications` ↔ period-prediction alert; existing `PrefsService` persistence unchanged.
- **4.4** Profile identity: header shows `AuthIdentity` display name/email (fallback to placeholder), **Sign Out** button → `auth.signOut()` → reset stack to `/`.
- **4.5** Tests: `buildNotificationRequests` unit test; sign-out widget test.

### Profile consolidation

- **4.6** `ProfileScreen` rework - top-bar action `AppIcons.gear → AppIcons.alerts` (`go('/alerts')`); dropped the `Notification Preferences → Manage` and `Appearance → Manage` links (Lunar Alignments = stats only, Apothecary keeps Gestation + Bond).
- **4.7** New **App Settings** `AppCard` - `Receive Lunar Notifications` switch (`setLunar` + `NotificationService.syncPeriodPrediction` with `CycleProvider.nextPeriodStart()`) and `Dark Magic Mode` switch (`setDark`), ported from the old SettingsScreen.
- **4.8** **Amulet Bells** card rebuilt - header + live count kept; `Open Amulet Reminders` button removed; 5 inline bell rows (hairline dividers: `IconBadge` + title/subtitle + pur `Switch` → `toggle` + `NotificationService.syncReminder`; ON rows show clock/freq `InfoPill`s).
- **4.9** Deletions - `lib/screens/settings_screen.dart`, `lib/screens/reminders_screen.dart` removed; `app_router_delegate.dart` drops both imports and the `/settings` + `/reminders` cases (unknown paths recover via the welcome redirect).
- **4.10** Tests - suite unchanged (sign-out widget test still reaches Sign Out after the taller Profile; no screen tests referenced the deleted routes).
- **4.11** Docs - DESIGN.md → v1.6.0 (nav/app-bar lines, §4.1 rows, nav tree, Screen 14 rewrite, Settings + Amulet Reminders sections deleted, screens renumbered), CHANGES.md (this update).

**Gate:** `flutter analyze` ✅ · `flutter test` ✅ · `flutter build apk --debug` ✅ · `flutter build web` ✅

## Update 5 - Splash & Branding

- **5.1** Native splash via `flutter_native_splash` - pubspec gains `assets/images/` in `flutter.assets`; splash config fixed (old `#0x…` color strings were invalid) → `color: "#3B0A5E"`, `fullscreen: true`, `android_12` plum color/icon-background + gold image; `dart run flutter_native_splash:create` generated Android (drawables + `windowSplashScreen*` styles incl. night/v31), iOS (LaunchImage + storyboard + Info.plist) and web splash assets (was default white).
- **5.2** `AppEmblem` uses the cat-moon image instead of `FaIcon(AppIcons.moon)` (size box `size * 0.36` kept); final state after 5.6: `Image.asset('assets/images/cat-moon-mask-512.png', color: AppColors.gold, colorBlendMode: BlendMode.srcIn)` (`cacheWidth: 256`). Other `AppIcons.moon` sites (nav Today tab, cycle orb, moods, mocks) unchanged.
- **5.3** Logo sizing iterations (superseded by 5.2/5.6): source resampled 128 → 256 → **512×512** and splash regenerated each time; un-suffixed `cat-moon-gold.png` replaced by `cat-moon-{black,plum,plum2,gold}-{128,256,512}` variants (fixed dangling refs).
- **5.4** In-app `SplashScreen` (`lib/screens/splash_screen.dart`, `/splash` - direct route only, no in-app links/buttons): full-bleed plum `Scaffold`, `LayoutBuilder` emblem at `min(w,h) * 0.25`, `Image.asset(...)` `BoxFit.contain`, centered; no text/SafeArea/redirect logic; router case after `/binding`; test `test/widgets/splash_screen_test.dart` (plum background + single `Image`, no text).
- **5.5** Native splash logo = **25% of the smaller viewport axis** - the package exposes no size option, so post-`create` hand-edits: **iOS** `LaunchScreen.storyboard` centered imageView with 4 constraint multipliers `0.25` vs superview width/height (`scaleAspectFit`); **web** `index.html` splash `<img>` → `style="min(25vw, 25vh)"`; **Android** all 15 generated bitmaps (`sips`-resized to `90dp × density` = 90/135/180/270/360px, upscaled from the 512 source, night included).
  - ⚠️ **Fragile:** `dart run flutter_native_splash:create` **overwrites** the storyboard, `index.html` and the Android bitmaps - after any pubspec splash-config change, re-run `create` **and re-apply these hand-edits**. Splash verified by pixel math + builds only (no emulator/device here).
- **5.6** Asset consolidation: pixel audit showed all 12 `cat-moon-{black,gold,plum,plum2}-{128,256,512}.png` are flat single-color + alpha stencils (extra colors = antialias edges) → created `assets/images/cat-moon-mask-512.png`; `AppEmblem` + in-app `SplashScreen` tint with `AppColors.gold` (`#D9A036`, identical pixels to the old gold PNGs); pruned 11 files - kept mask (all in-app use) + `cat-moon-gold-512.png` (only for `flutter_native_splash`, which bakes static PNGs and cannot tint).
- **5.7** Docs - CHANGES.md (this update), DESIGN.md → v1.7.0 (emblem PNG + native launch splash), v1.8.0 (Screen 19 app-splash preview, §4.1 route row, nav tree `/splash`), v1.8.2 (mask + tint).

**Gate:** `flutter analyze` ✅ · `flutter test` ✅ (81/81 final suite) · `flutter build apk --debug` ✅ · `flutter build web` ✅

## Update 6 - Article Feed & Feature Removal

> Coven becomes a web-sourced reading feed; Library and Binding are deleted.

- **6.1** Add `http` + `xml` to `pubspec.yaml`; run `flutter pub get`.
- **6.2** `lib/services/feed_service.dart` - fetch `https://qvonyx.com/witchy/articles.xml`, parse `<item>` entries (title, link, description, pubDate, category) into a rebuilt `Article` model (`link` + `pubDate` replace `thumb`/`readTime`); cache payload in `PrefsService` for offline; expose `load({bool refresh})`. RFC-822 `pubDate` parsed via `DateFormat('EEE, dd MMM yyyy HH:mm:ss Z', 'en_US')`; fetch failure falls back to cache, rethrows only when no cache.
- **6.3** Rewrite `lib/screens/coven_screen.dart` - no `AppTopBar` title, no segment tabs, no FAB, no `MockData.posts`; scrollable article cards (serif title, muted meta, excerpt, category tag) with pull-to-refresh + loading/error/empty states; tap -> `context.go('/webview?title=...&url=...')` (privacy-screen mechanism). Optional `feed` constructor param for tests.
- **6.4** Delete `lib/screens/library_screen.dart` + `lib/screens/article_detail_screen.dart`; remove `/library` and `/library/<slug>` from `app_router_delegate.dart` (slug fallback + `MockData` import); remove all library entry points.
- **6.5** Delete `lib/screens/binding_screen.dart`; remove `/binding` route, Profile "Cosmic Partner Bond" row, and the 3 share flags from `SettingsProvider` + their `PrefsService` keys (`clearLegacyBindingFlags()` runs on `SettingsProvider.load`).
- **6.6** Prune dead code: `MockData.posts()`, `MockData.articles()`, `MockData.articleById()`, `lib/models/coven_post.dart`; keep `MockData.reminders()` + `alerts()` (replaced in Update 9).
- **6.7** Docs - `DESIGN.md` v1.9.0 (nav tree, Screen 12/13/18 tombstoned, Screen 17 rewritten as article feed, welcome/privacy rows now hand off to `/onboarding`), `CHANGES.md` (this update).
- **6.8** Tests - `test/services/feed_service_test.dart` (parse fixture, HTML strip, defaults, dropped incomplete items, cache round-trip, cache-first load, unreachable-feed rethrow) + `test/screens/coven_screen_test.dart` (renders cached items, no tabs/FAB, tap -> `/webview` route with encoded params, empty state) + `test/providers/persistence_test.dart` (share-flag removal).

**Gate:** `flutter analyze` ✅ · `flutter test` ✅ (93/93) · `flutter build apk --debug` ✅ · `flutter build web` ✅

## Update 7 - Tracking Mode Selection

> Onboarding gains Cycle / Pregnancy / Perimenopause choice; the mode gates Updates 10-11.

- **7.1** `lib/models/tracking_mode.dart` - enum `TrackingMode { cycle, pregnancy, perimenopause }` with themed labels (`Cycle` / `Pregnancy` / `Perimenopause`) + `toJson`/`fromJson` (unknown/missing -> `cycle`).
- **7.2** Persist - `PrefsService` key `witchy_tracking_mode` (default `cycle`) + `OnboardingProvider.trackingMode`/`setTrackingMode` (setter persists immediately so Profile edits stick without `finish()`; `finish()` also saves).
- **7.3** `lib/widgets/tracking_mode_chip.dart` - `TrackingModeChips` single-select `Wrap` of `AppChip`s (icons: droplet / personPregnant / moon, selected = pur fill); wired into `rhythms_screen.dart` as a "What shall we track?" `AppCard` directly under the header; saved in `finish()`.
- **7.4** Gating hooks - `OnboardingProvider.trackingMode` exposed; this update only surfaces the label (Profile row); real screen differences land in Updates 10/11.
- **7.5** Profile Lunar Alignments gains a "Tracking Mode" row (pur underline = current label) opening a modal bottom sheet with the same 3 chips (persist + notify + pop).
- **7.6** Docs - `DESIGN.md` v1.9.1 (Screen 04 tracking card, Screen 14 row, §4.1 onboarding row); `/auth` stays hidden (sign-in kept as-is, deferred) - noted in v1.9.0 pass.
- **7.7** Tests - `test/models/tracking_mode_test.dart` (round-trip, default, labels) + `persistence_test` (default cycle, setTrackingMode reactive + persists, finish saves) + `widget_test` (select Pregnancy -> begin -> Profile shows it, prefs key = 'pregnancy').

**Gate:** `flutter analyze` ✅ · `flutter test` ✅ (99/99) · `flutter build apk --debug` ✅ · `flutter build web` ✅

## Update 8 - BBT Temperature Logging & Real Charts

> Real data replaces `TrendBars` fake heights and the fake `36.4°` / `+0.4°`.

- **8.1** `DayLog` gains `temperature` (`double?`, °C, null = unlogged) with `fromJson` missing-key tolerance; extend `day_log_test`.
- **8.2** Log sheet - new "Basal Body Temperature" section between pain slider and notes (35.0-38.0 °C, step 0.1, live serif value); `LoggingProvider.setTemperature(date, value)`; `peekDay` defaults unaffected.
- **8.3** `lib/widgets/trend_bars.dart` - accept `values` + `labels` params (drop the `_heights` constant); Records passes real observed cycle lengths from `PeriodHistory`, empty state under 2 cycles.
- **8.4** `lib/screens/chart_screen.dart` rebuild - fl_chart `LineChart` of the last ~30 logged temperatures (gaps for null), ovulation marker at `CycleCalculator` peak day, computed pre-shift average + post-shift rise; empty state with "Log your temperature" prompt -> log sheet.
- **8.5** Docs - `DESIGN.md` Screen 09 rewrite + Screen 07 temperature row.
- **8.6** Tests - `DayLog` temperature round-trip, `setTemperature` persistence, trend-bars real inputs, chart screen widget test (empty + data), averages math.

**Gate:** `flutter analyze` ✅ · `flutter test` ✅ (104/104) · `flutter build apk --debug` ✅ · `flutter build web` ✅

## Update 9 - Real Local Alerts Inbox

> `MockData.alerts()` dies; alerts are generated from real cycle events.

- **9.1** `AlertItem` gains `id`, `type` (periodPredicted / fertileWindow / logMissing / lunarMilestone), `createdAt`, `read` with `toJson`/`fromJson` (+ extra `eventDate` used for expiry pruning; icon/tint derive from `AlertType`).
- **9.2** `lib/services/alert_generator.dart` - pure functions from `CycleProvider` + `LoggingProvider`: period predicted in 2 days / 1 day, fertile peak today, log missing after 18:00, lunar milestone (computed new/full moon); deduped by stable id.
- **9.3** `AlertProvider` (ChangeNotifier) - persisted list (`witchy_alerts`, cap 30), `bind()` generates on startup + listens to `CycleProvider`, `markRead`/`markAllRead`, unread count, expired `eventDate`s pruned.
- **9.4** `lib/screens/alerts_screen.dart` - reads `AlertProvider`, real relative timestamps (`intl`), read/unread styling, tap marks read, empty state; shell/profile bells show unread dot (`AppTopBar.badge`).
- **9.5** Retire `MockData.alerts()`.
- **9.6** Docs - `DESIGN.md` Screen 16 (v1.9.3); `CHANGES.md` (this update).
- **9.7** Tests - generator cases (2-day, 1-day, peak, missing log, lunar, dedupe determinism), persistence, markRead, alerts screen widget test.

**Gate:** `flutter analyze` ✅ · `flutter test` ✅ (118/118) · `flutter build apk --debug` ✅ · `flutter build web` ✅

## Update 10 - Pregnancy Mode

> Gestation becomes computed; reachable only when `TrackingMode.pregnancy`.

- **10.1** `lib/providers/gestation_provider.dart` - `lmpDate` input persisted (`witchy_pregnancy_lmp`); computes gestational days, week/day, `progress = days/280`, days remaining, trimester, due date (past-due counter + future-LMP clamp included).
- **10.2** Date entry - gestation screen empty state `AppButton` opens a past-only date picker; the LMP row card reopens it; onboarding seeds `lmpDate = lastPeriodStart` when the Pregnancy chip is chosen (`rhythms_screen._complete`).
- **10.3** `lib/models/gestation_week.dart` + `lib/common/gestation_content.dart` - 10 week-range buckets covering weeks 0-40 (size tag, development, tip) + past-term fallback for >40; negative clamps to first.
- **10.4** Rebuild `lib/screens/gestation_screen.dart` - computed `Week N (Day D)`, real progress bar, countdown/past-due copy, due date + trimester line, content lookup per week; profile Apothecary row hidden unless mode = pregnancy.
- **10.5** Engine respect - `CycleProvider.showFertilityPredictions` (true only in Cycle mode; shared gate for Update 11) suppresses `isFertileDay`/`isOvulationDay` (→ sanctuary card, fertile alerts), calendar glyphs (`CalendarFetcher.showFertility`), BBT ovulation marker; logged bleeds + period predictions stay visible.
- **10.6** Docs - `DESIGN.md` Screen 11 (v1.9.4); `CHANGES.md` (this update).
- **10.7** Tests - gestation math (today/84/280/past-due/future/due date/trimester boundaries), persistence, content lookup + fallback + gap-free coverage, screen widget tests (empty + seeded + week-1), fertility gate (provider + fetcher + widget).

**Gate:** `flutter analyze` ✅ · `flutter test` ✅ (137/137) · `flutter build apk --debug` ✅ · `flutter build web` ✅

## Update 11 - Perimenopause Mode

> Cycle tracking continues with irregularity-aware predictions.

- **11.1** `CycleProvider` adaptation when `trackingMode == perimenopause` - expose `predictedRange` (earliest/latest next start from min/max observed cycle lengths), median fallback. -> `isPerimenopause`, `shortestCycleLength`/`longestCycleLength` (fallback = effective length), `cycleSpread` (null under 2 cycles), `predictedRange({today})` via `CycleCalculator.nextPeriodStart` on both extremes (results ordered earliest<=latest).
- **11.2** Sanctuary - stat duo shows a date window instead of a single day; fertility/peak card suppressed (ovulation unreliable); softened phase copy. -> `Bleeding In` renders `dMin-dMax Days` + `d MMM - d MMM · range` (collapses to `N Days` on a single-day window); day card note becomes `Period may start any day now` on d-1/d-2; fertility card already hidden by `showFertilityPredictions`.
- **11.3** Calendar - fertile/ovulation glyphs hidden; predicted period rendered as a range (whole window marked). -> `CalendarFetcher.forMonth` gains `predictedStart`/`predictedEnd`; marks the union of possible bleed days (earliest start through latest start + bleedLength) replacing arithmetic; `cycle_screen` passes `predictedRange()` only when `isPerimenopause`; fertile/ovulation glyphs already hidden via `showFertility: false`.
- **11.4** Records gains an "Irregularity" row (cycle-length spread, longest vs shortest) from `PeriodHistory`. -> `_buildIrregularityCard`: `shortest-longest Days` + `N Days variation` tag from `cycle.cycleSpread`; empty state under 2 cycles; always visible (most meaningful in Perimenopause).
- **11.5** Alerts generator - fertile alerts become "window opens as early as..." in this mode. -> `else if (cycle.isPerimenopause && cycle.ovulationDay(today: now) == today)` fires the hedged `Fertility Window` alert ("may open as early as today..."), same `fertile-<date>` id; peak alert unchanged for Cycle mode.
- **11.6** Docs - `DESIGN.md` Screen 05/06 mode variants + §4.1 (v1.9.5); `CHANGES.md` (this update).
- **11.7** Tests - range math + spread fallback (`cycle_provider_test`), window glyph marking (`calendar_fetcher_test`), hedged + quiet alert cases (`alert_generator_test`), Sanctuary widget tests per mode, Records irregularity widget tests (empty + spread).

**Gate:** `flutter analyze` ✅ · `flutter test` ✅ (146/146) · `flutter build apk --debug` ✅ · `flutter build web` ✅

## Update 12 - Dark Theme & Profile/Notification Polish

- **12.1** `AppColors` dark token set (bg `#1B0A2A`, card `#26063F`, lav text, line `#3E2A54`, brightened pur) + `buildAppTheme({Brightness})` dark variant in `app_theme.dart`. Mode-varying tokens became getters behind `AppColors.dark` (const call sites and const default params de-consted; `LogData` categories became getters so section colors resolve live).
- **12.2** `main.dart` theme follows `SettingsProvider.dark` override else platform brightness; `setDark` repaints live (`ListenableBuilder` on the settings instance above `MaterialApp.router`); Profile toggle kept.
- **12.3** Profile real data - `29 Days`/`5 Days` -> `CycleProvider.meanCycleLength`/`bleedLength` (empty-state dashes); bell denominator -> `reminders.length`; version string -> `package_info_plus` ^10.2.2 (single source, fallback `1.0.0` on hosts without a bundle).
- **12.4** Notification `freq` semantics honoured - `buildNotificationRequests` maps freq -> schedule rule (`Every day`/`Daytime` daily repeat, `Daily during peak` one-shot per predicted bleed day, `Window start` one-shot at `CycleProvider.fertileWindowStart`, `3 days prior` one-shot at predicted start minus 3; deterministic `idAtDate`, cancel window -7..+45 days); `main.dart` re-syncs on `CycleProvider`/`RemindersProvider` change with cycle anchors.
- **12.5** Stop swallowing scheduling errors - sync methods `debugPrint` + rethrow; `main` wraps startup sync in try/catch log; Profile lunar + bell toggles await and surface failures as SnackBar.
- **12.6** Docs - `DESIGN.md` §2.1 dark tokens + Screen 14 rewrite (v1.9.6); `CHANGES.md` (this update).
- **12.7** Tests - dark theme builder (`test/theme/app_theme_test.dart`), freq -> request mapping (expanded `notification_service_test.dart`: per-freq rules, past-date drop, missing-anchor skip, `idAtDate`), profile reads provider values (`test/screens/profile_screen_test.dart`: real averages, dash fallback, bell count, version footer via scroll). Re-sync trigger not unit-tested (listener wiring lives in `main()`).

**Gate:** `flutter analyze` ✅ · `flutter test` ✅ (157/157) · `flutter build apk --debug` ✅ · `flutter build web` ✅

## Update 13 - Release Hardening & Final Gate

- **13.1** Android - `android/key.properties` + release `signingConfigs` (loaded when the git-ignored file exists, debug-key fallback otherwise so local release builds keep working), applicationId TODO dropped (`com.qvonyx.witchy`), compile/target/min pinned to 36/36/24, `android:label="Witchy"`, keystore generation + `key.properties` steps added to `README.md`, `.gitignore` covers `key.properties`/`*.jks`/`*.keystore`.
- **13.2** Branded launcher icons via `flutter_launcher_icons` ^0.14.4 - `tool/generate_app_icon.dart` composites the gold cat-moon onto brand purple into `assets/images/app_icon_1024.png`; Android legacy + adaptive (fg gold, bg `#3B0A5E`, generated `colors.xml` + `mipmap-anydpi-v26`), full iOS AppIcon set, web icons + favicon. Reverted the tool's invalid `ASSETCATALOG_COMPILER_GENERATE_SWIFT_ASSET_SYMBOL_EXTENSIONS` rewrite in `project.pbxproj`.
- **13.3** iOS - empty `DEVELOPMENT_TEAM` placeholder in all three Runner configs (fill in Xcode), `Podfile` platform `13.0`, `ios/Runner/PrivacyInfo.xcprivacy` bundled via pbxproj (NSUserDefaults reason CA92.1, no tracking/collection), `ITSAppUsesNonExemptEncryption=false` in Info.plist, scope note in `auth_provider.dart` about the config sign-in would need.
- **13.4** Web - `<title>Witchy</title>`, real meta description, `apple-mobile-web-app-title` Witchy; `manifest.json` name/short_name Witchy, real description, `theme_color`/`background_color` `#3B0A5E` (valid JSON verified).
- **13.5** Version single-sourced - Profile footer reads `package_info_plus` (done in 12.3).
- **13.6** Live endpoints verified - `https://qvonyx.com/witchy/articles.xml` reachable and parses (18 items); item links are relative slugs so `FeedService._resolveLink` resolves them against the feed URL (new test). Legal URLs `https://qvonyx.com/witchy/{terms,privacy,child-protection}.html` all return 200.
- **13.7** Test-suite review - 158 cases, zero skipped; coverage includes feed parse/cache/link resolution, alerts generator/inbox, gestation math/content/screen, BBT chart, dark theme, profile provider reads.
- **13.8** Release gate - `flutter analyze` zero issues · `flutter test` 158/158 · `flutter build apk --release` ✓ (60.6MB, debug-key fallback) · `flutter build ios --release --no-codesign` ✓ (23.2MB, PrivacyInfo bundled) · `flutter build web` ✓.
- **13.9** Docs - `CHANGES.md` (this update), `DESIGN.md` bumped to 1.9.7, `README.md` build/signing/icon instructions.

**Gate:** `flutter analyze` ✅ · `flutter test` ✅ (158/158) · `flutter build apk --release` ✅ · `flutter build ios --release --no-codesign` ✅ · `flutter build web` ✅

> Out of scope (flagged): Google/Apple sign-in activation (hidden), real couples/backend sync, Coven posting, sovereign-blood screen from MOCK.html (not in DESIGN.md), localization, analytics/crash reporting.

## Update 14 - 2026.10.09 - Fixes

- theme -> dark vs light: should start as light (default) - use toggle in profile -> settings
- rhythyms -> button: should mark user as logged-in and continue to main screen 
- profile -> signup: should mark user as logged-out and return to first screen
- floating button: opacity agains purple widgets/cards is not good - try to add a gold border to make it more visible
- profile: after sign-out, we need a delete all data button (dark-ish red bg, white text)
- rhythyms - tracking mode: should be a multi-toggle - the app MUST allow tracking all modes (cycle, pregnancy, perimenopause) simultaneously on the same interface (calendar, records, sanctuary, fertility, alert)
- app: app icon needed - should be the same as the one in the splash screen - use images in @resources/
 
## Update 15 - 2026.10.12 - Fixes

- rythyms -> tracking: widget/card should be full width - icons neede to be visible when a chip is selected (now backgroundh has the same color as the selected chip = bad contrast) - `TrackingModeChips` now `Row` + `Expanded` (chips fill the card); `AppChip._icon` selected color fixed: uses `onColor(active)` fg instead of the chip background (icons visible on selected chips; benefits every chip incl. log sheet)
- profile -> session: the buttons need a confirm dialog/drawer - the dialog should explain the consequences of each action - added `_confirmSignOut` dialog (explains: back to welcome, logs/settings stay on device, can sign back in); `Delete All Data` already had `_confirmDeleteData` (explains erasure + not undoable); Sign Out button now wired through the dialog; test updated (confirm tap)
- magic (coven screen) -> needs minimum 1 entry, so that the screen doesn't look blank, always last, with info about the app, it should not open an article (since it's local) - `_buildAboutCard()` ("Witchy" + local/privacy blurb, not tappable) appended as last ListView entry always; when feed is empty the list shows "No articles yet" block + the about card (screen never blank). Test: `coven_screen_test.dart`
- log_bottom_sheet: add a divider between each `_LogCycleSection` - make title and buttons always visible, the rest should scroll - sheet restructured to `Column`: pinned head (drag handle + `_SheetHeader` date/cancel/approve + subtitle) above `Expanded(ListView)` body; `Divider` between consecutive sections; `_scrollToTarget` viewport now the list (`_listKey`) instead of the whole sheet so scrollTo-QA math stays correct
- app - app icon: use the can-moon logo - already cat-moon on every surface (verified: `assets/images/app_icon_1024.png`, android mipmaps + adaptive `ic_launcher_foreground`, iOS `Icon-App-*`, web `Icon-*`/`favicon.png`, splash); generated from `cat-moon-gold-512.png` via `flutter_launcher_icons` / `tool/generate_app_icon.dart` (redesign.13)

Gates: `flutter analyze` = No issues found, `flutter test` = 195/195 passing.

## Update 16 - 2026.10.12 - Fixes

Feedback batch from debug/ screenshots (Issues 1-7 + icon audit). Product name "Witchy", moon glyphs and plum/gold visuals kept; all user-facing copy neutralized to health terminology. Routes, pref keys, enum JSON values, class/file/method names unchanged for stability.

- Issue 1 - legal pages: added `assets/legal/{privacy,terms,child-protection}.html` (pubspec assets), added `url_launcher: ^6.3.1`, `common/legal_links.dart` maps assets -> fallback `https://qvonyx.com/witchy/<name>.html`, `webview_screen.dart` loads bundled assets (kIsWeb -> external browser instead of blank screen) + open-in-browser button, `app_route_parser.dart` keeps query params, AndroidManifest gets INTERNET perm + `<queries>` block. Test: `test/common/legal_links_test.dart`
- Issue 2 - cycle math: `CycleCalculator.nextOvulationDay`, `CycleProvider._resolveAnchor()` skips future anchors (phantom predicted start no longer seeds the cycle) and prefers logged bleeds, `hasLoggedBleedOn`/`bleedDayOf`/`phaseAt` menstrual override (logged bleeding shows Menstrual, not Luteal), `nextOvulationDate` getter, onboarding `_derive` clamps future last-period dates. Regression tests in `cycle_provider_test.dart`
- Issue 2b - onboarding period history: `OnboardingProvider.previousPeriodStarts` + `addPreviousPeriod`/`removePreviousPeriod`/`deriveCycleLengthFromHistory` (median of recent cycles, entry for last 2+ periods), cleared in `resetToDefaults`. Test: `test/providers/onboarding_provider_test.dart`
- Issue 3 - calendar recolor: `assets/svgs/moon-period.svg` + `moon-period-predicted.svg` -> period red `#C0392B`, `moon-fertile.svg` -> fertile purple `#7B2CBF`, `moon-ovulation.svg` + ovulation dot -> turquoise `#2A9D8F`. Palette tests in `calendar_widgets_test.dart`
- Issue 3b - flow single-select: `LoggingProvider.selectFlow` replaces `toggleFlow` (one flow value per day), wired into log sheet. Deviation: `bleedLength` left slider-only (auto-deriving from history would under-report partial/current spans)
- Issue 4 - occult copy sweep (~25 lib files): tabs Today/Calendar/Insights/Articles (was Sanctuary/Lunar Cycle Map/Lunar Records/Coven Sanctum), bottom-nav "Magic"->"Articles", CTAs "Awaken Your Power"->"Get Started" / "Set Your Rhythms"->"Set Your Cycle", profile "Witch Profile"->"Profile" / "High Priestess Selene"->"Guest", "Celestial Alerts"->"Alerts" / "Whispers Received"->"Recent Alerts", "Amulet Bells"->"Reminders", "Dark Magic Mode"->"Dark Mode", phase labels Shedding Tide/Waxing Glow/Full Moon Peak/Waning Glow -> Menstrual/Follicular/Ovulation/Luteal, alert/notification titles and bodies neutralized ("New Moon"->"Cycle Start", "Full Moon"->"Ovulation Window", channel "Amulet Reminders"->"Cycle Reminders"), mock reminders, coven/records/fertility/gestation/log-sheet copy, DESIGN.md vocabulary updated in lockstep (old terms now 0 hits). MOCK.html + documents/ untouched (not compiled into the app). Tests updated accordingly (194 pass)
- Issue 5 - tappable stats + bleeding screen: `StatCard` gained optional `onTap` (MouseRegion + GestureDetector, default null keeps old behavior), call sites wired (sanctuary Bleeding In -> `/bleeding`, Fertility -> `/fertility`; records Average Bleed -> `/bleeding`, Average Cycle -> `/chart`), new `lib/screens/bleeding_screen.dart` + route `/bleeding` (per-day flow history + averages). Tests: `stat_card_test.dart`, `bleeding_screen_test.dart`
- Issue 6+7 - Pregnancy Tracker rename/decoupling: "Gestation Spells"->"Pregnancy Tracker" (gestation appbar + profile row), LMP auto-seed removed from rhythms (no silent coupling), `/pregnancy` route gated in `app_router_delegate` (needs onboarded + pregnancy tracking mode, else Welcome; context threaded through `_pageFor`/`_childFor`), "separate journey" note in onboarding, DESIGN.md updated. Test: `test/navigation/pregnancy_route_gating_test.dart`
- Issue 8 - FontAwesome icon audit: all 77 `FontAwesomeIcons.*` usages in lib/ + test/ verified present in `font_awesome_flutter` 11.0.0 (0 missing). No changes needed.

Gates: `flutter analyze` = No issues found, `flutter test` = 194/194 passing.

## Update 17 - 2026.10.15 - Prediction engine MVP

Algorithm analysis vs Flo/Clue (local-only, no cloud ML - compete on honest rolling statistics + signal integration, not neural nets). MVP = engine correctness + surgical edits to existing screens. Flo-parity decision: pregnancy suppresses BOTH period and fertility predictions, triggered when pregnancy mode is in the set AND gestation has an LMP (mode-only would blank a fresh user who never entered LMP; gap state gets a setup-nudge card). Precedence: pregnancy-suppression > peri-range > normal. Moon-milestone alerts stay in pregnancy mode (lunar events, not cycle predictions). New pref keys use `witchy_` prefix so Delete All Data wipes them. Adapted to commit 2026.10.14 (fertile-start alert, onboarding 20..40 clamps + minGap 15, Records Irregular > 7, alert dismiss/undo, CycleOrb progress).

A - engine:
- **A4** BBT personal luteal (most isolated - do first) - `lib/services/bbt_analyzer.dart` (BbtAnalyzer: >= 10 temps °C, 3-day sustained mean rise >= 0.3 C over 6-day baseline with >= 4 baseline / >= 2 post readings, every post reading above baseline mean, 6-day dedup gap; outputs `confirmedOvulation` = day before rise, `personalLutealLength` = median ovulation-to-next-bleed clamped 10..18, recomputed from logs each time, no pref key). `CycleCalculator` ovulation/fertility functions take `{int lutealLength = 14}` (defaults preserve behavior); `CycleProvider` exposes `detectedLutealLength`/`confirmedOvulationDate`/`lutealLength` (personal ?? 14) and threads it through all 9 call sites + `CalendarFetcher.forMonth(lutealLength:)` + `cycle_screen`. Signal precedence BBT > OPK > arithmetic. Tests: `test/services/bbt_analyzer_test.dart` (8 cases: empty, <10, flat, sustained rise, spike rejection, luteal measure, clamp, null-skip). Gates: analyze clean, 214/214.
- **A1** fertile window science - `CycleCalculator.fertileStartCycleDay` ovu-2 -> ovu-5, `fertileEndCycleDay` ovu+2 -> ovu+1 (single-point change: calendar, stats, alerts flow through the provider getters). Uncertainty pad `u` each side: `u = observed<3 ? 2 : (spreadRecent>7 ? min(spreadRecent~/2, 4) : 0)`, total width capped at 14 days. Rewrite `AlertGenerator` fertile-start condition (id `fertile-start-{date}`) to fire at the new window start; peak alert unchanged on ovulation day. Invariant tests: window always contains ovulation, L in 21..40
- **A2** rolling statistics - new pure `lib/services/cycle_stats.dart` built from `PeriodHistory` spans: `medianRecent` (last 6), `medianWindow` (last 12), `spreadRecent` (last 6, null when < 2), `longestRecent`; respects onboarding clamps (20..40). `CycleProvider` delegates `effectiveCycleLength`/`observedCycleLengths`/`cycleSpread` to it (call sites unchanged where possible). Verify `rhythms_screen` history seeding covers the pre-log case before adding any new seeding. Bleed length stays slider-only (Fixes 3 deviation kept). Records keeps all-time shortest/longest display; Irregular/Regular status moves to `spreadRecent` (one ancient outlier no longer flags forever). Pin `PeriodHistory.median` even-count rounding in tests
- **A3** late / missed handling - late 1-5 -> `late-dN-{date}` alert inside the generator (id rolls daily, yesterday's pruned by eventDate cleanup), exclusive vs `period-dN`. Late > longestRecent+5 -> `predictionsConfident=false`: hides fertility/peak alerts AND calendar predicted dots, Today shows "cycle running long - log to re-anchor". Late > longestRecent+10 -> stop projection: `predictedRange`/`nextPeriodStart` become nullable; add null branches in calendar fetcher, sanctuary, records, notification resync (`syncPeriodPrediction` already nullable-safe)
- **A6** range promotion - `predictedRange()` for all modes; Today single-day only when `spreadRecent` < 2, else earliest-latest range (Peri forces range + wording). Keep `CycleOrb(progress:)` params intact
- **A5** pregnancy dating + suppression - GestationProvider: keep Naegele LMP+280, add Parikh alternative when cycleLength != 28, manual EDD override (`witchy_pregnancy_edd_override` + provenance label + clear-override). Suppression = pregnancy in set + LMP present: `showFertilityPredictions` false, period countdown/late/period-day alerts hidden (fertility alerts already flag-gated per 10.14). Gap state (mode on, no LMP): Today setup-nudge card linking `/pregnancy`. `/fertility` route kept with "predictions paused" placeholder. F6 widget test unchanged ({cycle,pregnancy} without LMP still shows fertility - correct); add provider-level suppression tests + nudge test. Audit reminder prediction-dependence; resync/cancel notifications on suppression

B - screens (surgical edits, no new screens):
- **B1** disclaimers - "Predictions are estimates - not a contraceptive and not medical advice." on Today, Fertility, Pregnancy, Chart (AppText/AppColors tokens, light + dark)
- **B2** Today states - late + uncertain copy, variable-cycle range line for non-peri (A6), pregnancy setup-nudge card (A5)
- **B3** Pregnancy screen - due-date override picker + "Due date: LMP / doctor" provenance + Parikh alternative when cycle != 28 (done inside A5)
- **B4** OPK - `DayLog.ovulationTest` (additive `positive`/`negative`/null JSON, legacy-safe), log-sheet row inside Fixes 2 pinned-head/divider structure; positive -> provisional ovulation tomorrow + `opk-positive-{date}` alert (provider-level one-shot) + feeds A4 luteal stats (BBT wins conflicts)
- **B5** Chart marker - BBT-confirmed ovulation dot (confirmed vs predicted) + legend update
- **B6** alerts - period-day-of one-shot at provider level (`items.any(id == 'period-today-{key}')` check before insert - generator is pure and cannot dedup); ids stable under `dismiss()`/`restore()`; read current alerts_screen dismiss/undo UI first
- **B7** tests - window invariants + fertile-start timing, rolling stats (aging-out, clamps, median rounding, seeds), late thresholds + undo interplay, suppression combos ({cycle}, {cycle,pregnancy}+LMP, {cycle,peri}, {pregnancy}+LMP, {peri}, mode-no-LMP gap, LMP-no-mode), peri range, OPK round-trip, disclaimer presence. Baseline reconciled at 274 (was 195/194). Fixtures need `witchy_session` + `witchy_onboarded`
- **B8** docs - DESIGN.md prediction-model section + bump from current 1.9.8; tick this section; backlog stays open

Gates: `flutter analyze` = No issues found, `flutter test` = 277/277 passing, `flutter build apk --debug` = ✓.

## Update 18 - 2026.10.19 - Fixes

A - Prediction engine truth + goal framing (done)
- **1.1** Fertile window is the fixed biological span: ovulation minus 5 through ovulation plus 1 = 7 days (cycle days 9-15 on a 28-day cycle, 8-14 on a 27-day cycle). The `pad` parameter was removed from `CycleCalculator` (`fertileStartCycleDay`, `fertileEndCycleDay`, `isFertileDay`, `phaseAt`, `phase`, `fertileDaysInMonth`) and from `CalendarFetcher` and the calendar call site. Uncertainty is copy only now, driven by `CycleProvider.uncertaintyPad` ("Timing is estimated and may shift by up to N days.").
- **1.2** One shared `CycleProvider.fertilityStatus` (beforeWindow, windowOpen, peakToday, windowClosing, passed) replaced the per-screen `ovulationToday` / `fertileToday` ternaries, so Today, Fertility and the calendar read the same state. `ovulationDateThisCycle` names the current cycle's peak even after it has passed while `nextOvulationDate` keeps rolling forward: the old "Peak in 24 Days" copy after the peak was behind us is gone.
- **1.3** Today fertility card copy: "Peak Today / High chance", "Window Open / Ovulation nears", "Window Closing / Ovulation passed", "Peak Passed / next peak <d MMM>", "In N Days / <d MMM> · window opens".
- **1.4** Fertility screen rewritten: the chance duo reads Peak / High / Medium / Low with the ovulation date as the sub, the Window card shows the fixed 7-day window and its cycle-day range, tips are phase-aware and goal-aware, a Next Peak card covers the passed case, and the orb caption says "Peak Day", "Peak in N Days" or "Peak passed".
- **1.5** Spotting rule: `PeriodHistory.minSpanDays = 2` with `periods` and `spotting` helpers. A lone flow day can no longer start a period or shift anything: it is excluded from cycle lengths, the anchor, BBT bleed baselines, the OPK luteal gap and `meanBleedLength`.
- **1.6** Goal framing: new `CycleGoal` (track / conceive / avoid) persisted as `witchy_goal` through `SettingsProvider` and `PrefsService`, selected during onboarding ("What brings you here?") and changeable from a Profile "Your goal" row with a bottom sheet. It only tunes fertility wording: conceive keeps the TTC tips, track stays neutral, avoid drops the TTC framing and always repeats "not a contraceptive method".
- **1.7** Tests and docs: new `test/providers/settings_provider_test.dart`; `cycle_provider_test` gained the fixed-window, day-by-day status pipeline and spotting groups; sanctuary, fertility, records, profile and alert_generator tests updated (2-day bleed fixtures, new copy); DESIGN.md prediction-engine bullets, calendar wording, Profile App Settings rows and the Fertility screen row updated.

B - Honest onboarding history (done)
- **2.1** `DayLog.assumed` (JSON-compatible, defaults false) marks days that came from onboarding history instead of the user's own logging. `LoggingProvider.setFlow` clears the flag, so editing a day by hand silently promotes the estimate into a real log.
- **2.2** `LoggingProvider.seedAssumedSpan(start, days, flow)` writes whole spans as assumed and `wipeAssumed()` removes every assumed day, so a second onboarding run can never leave a phantom period behind.
- **2.3** `OnboardingProvider.previousPeriodDurations` with `durationFor` and `setPreviousPeriodDuration` (clamped 2-10) keeps a bleed length per earlier period; durations follow the entry through edit, removal and `resetToDefaults`.
- **2.4** `rhythms_screen._finish` wipes assumed seeds and then seeds exactly `bleedLength` days for the picked last period and `durationFor(start)` days for each earlier period, so Average Bleed and cycle length come from the user's own numbers instead of a hardcoded 5-day span.
- **2.5** `bleeding_screen` marks assumed spans with an "Estimated" tag and labels spans shorter than the period threshold as "Spotting".

C - Log sheet, logging states and dark mode (done)
- **3.1** Log sheet options are complete. Every option in every category now has an icon (collection methods gained tampon / pad / cup / period-underwear glyphs; Abdominal pain, Migraine, Swelling, Bloating, Constipation, Gas, Stool changes, Acne, Dry skin, Dry hair, Guilty, Self-critical, Salty cravings, None or dry and Masturbation were previously iconless) and the shared `bone` glyph on Backache and Joint pain was split (Joint pain now uses `crutch`).
- **3.2** Section titles use the neutral `AppText.sec` / `sectionTitle` token; the category colour stays on the section's chips (selected fill and option icon tint), so vivid accents (gold, orange, brown) no longer fight the heading.
- **3.3** The "Collection method" section only renders once a flow level is logged, and `LoggingProvider.selectFlow` clears the collection set when the flow ends up empty - an orphaned method can never be saved.
- **3.4** The sheet header now labels its buttons ("Cancel" / "Save", with tooltips). Save fills solid green as soon as the day has unsaved edits, and Cancel opens a "Discard changes?" confirm (`Keep editing` / `Discard`) before `restoreDay`. The sheet body is an eager `SingleChildScrollView`, which fixed the pre-existing bug where opening at a far category could never scroll there (the target key was never built by the lazy `ListView`); the target category also flashes a tinted outline for ~1.4s so the jump is explained.
- **3.5** Logging states: the four Today tiles now report what was logged (`Medium`, `Happy +1`, `Cramps`, `Good sleep`) with `Not logged` as the fallback so they keep equal height, and both the Today summary card and the Calendar entry cards list all four categories (flow, mood, symptoms, sleep) instead of flow and mood only. The shared one-line summary is `lib/common/log_summary.dart` (`summarizeLogSet`).
- **3.6** Dark mode: `quick_action.dart`, `month_picker_sheet.dart`, `app_text_field.dart`, the log sheet header and notes field, `privacy_screen.dart` and `app_emblem.dart` (new `AppColors.emblemBg` token) stopped hardcoding `Colors.white` / literal hex surfaces. `buildAppTheme` gained shared input, switch, checkbox, dialog, snack bar, slider, divider, bottom-sheet and text-button themes so one-off sheets and dialogs stay on the token palette in both brightnesses.
- **3.7** Tests: new `test/widgets/log_bottom_sheet_test.dart` (collection gating, discard confirm, scroll-to-category), `test/widgets/quick_action_test.dart`, `test/common/log_summary_test.dart`; `logging_provider_test` gained the collection-clearing cases; `app_theme_test` now covers the new sub-themes and `emblemBg`; the sanctuary disclaimer test scrolls first because the taller summary card pushed it below the fold.

D - Insights, articles resilience and copy (done)
- **4.1** Articles resilience. `FeedService` gained `FeedResult` (articles plus a `stale` flag) and `loadResult({refresh})`, with `load()` kept as a thin delegate. `coven_screen.dart` now shows a skeleton of three placeholder cards while the first load is in flight (no more bare spinner), an explicit error state when a refresh fails with nothing to show ("Could not be loaded. Check your connection, then try again." plus a `Try again` action), and a gold "Offline - showing saved articles, so a few may be out of date." banner with a `Refresh` tap when a refresh fails but the cached copy is still on screen. A failed load never blanks out the articles the user is reading.
- **4.2** The web CORS cause is documented in `README.md` (`## Content Feed Deployment`): `https://qvonyx.com/witchy/articles.xml` sends no `Access-Control-Allow-Origin`, so the browser blocks the fetch from `https://witchy.qvonyx.com`; fix it by sending `Access-Control-Allow-Origin` for the web origin (or serving the feed same-origin). Native builds are unaffected and the app now degrades gracefully either way.
- **4.3** Insights empty state. `RecordsScreen` shows a hero `EmptyState` above the preview cards whenever no period spans exist: "No cycles yet" / "Insights build from your bleeding days. Two completed cycles unlock your trends, averages and cycle spread." with a `Log your period` button wired to the log sheet. The preview cards stay so the user can see what will fill in. The two `Average Cycle` / `Average Bleeding` placeholders use a hyphen instead of an em dash.
- **4.4** New shared `lib/widgets/empty_state.dart` (`EmptyState` - icon badge, title, message, optional action). `AppButton` now wraps its label in a `Flexible`, so a long label truncates rather than overflowing when the button is width-capped. Profile gained a `Data` card covering "Where it lives" (On this device), "Shared with" (No one) and a "Your privacy policy" link into the in-app policy, and the delete-data dialog now spells out that the wipe is complete and irreversible.

- **2.8** Tests: `onboarding_provider_test` gained the per-period length cases (fallback to `bleedLength`, 2-10 clamp, new entry default) and `restorePreviousPeriod` (undo restores date and length, skips a date already listed), and the two clamp cases were retargeted at the new 15-60 range plus a long-median case; `cycle_stats_test` asserts both clamps via `CycleStats.minLength` / `maxLength`. New `test/widgets/app_slider_row_test.dart` covers tap-to-type, out-of-range clamping, a no-op retype and cancel.

E - Onboarding period editor and slider typing (done)
- **2.6** Earlier-period rows are fully editable in place. Each row is a 44px touch target: the date opens the date picker and a new length control ("5 days") opens the shared `NumberEntryDialog` (2-10 days, clamped) wired to `setPreviousPeriodDuration`. Both cells carry a pencil glyph and a tooltip ("Edit date" / "Edit length"). Removing a row offers an undo SnackBar ("Removed <date>" / `Undo`) backed by the new `OnboardingProvider.restorePreviousPeriod`, which puts the date back with the length it had and skips revalidation because the date was accepted moments ago. Validation failures are no longer transient toasts: the reason renders inline above the list in a `Semantics(liveRegion: true)` banner and clears on the next successful edit. The counter reads "N of 6 earlier periods" and the empty-state copy is "Add at least one earlier period to calculate your cycle length. Keep at least 15 days between dates."
- **2.7** Cycle-length slider range decision: **15-60 days**, no separate "irregular" mode. The medically typical 21-35 sits inside it, and long cycles (PCOS, perimenopause - a mode the app already ships) can be stated honestly instead of being silently clamped to 40. `OnboardingProvider.min/maxCycleLength` and the mirrored `CycleStats.minLength/maxLength` both moved to 15/60, so onboarding, the Profile "Cycle Basics" sheet and the prediction clamps agree. Every `AppSliderRow` value is now tappable and opens the shared `NumberEntryDialog` (new `lib/widgets/number_entry_dialog.dart`: a number field plus -/+ steppers, both held inside min..max), so an exact number can be typed instead of hunting for a thumb position on a 45-step track; that covers cycle length, bleeding phase length, the Profile sheet and the log sheet's pain slider.

F - Polish (done)
- **5.1** `AppTopBar` reserves its trailing slot unconditionally (a 34px `SizedBox` stands in when there is no action) so an action-less bar keeps its title optically centred, and the default leading icon is now the standard `arrowLeft` instead of the hand-pointing glyph. Profile no longer overrides the leading icon or the back handler, so it behaves like every other pushed screen.
- **5.2** `lib/common/date_format.dart` (`AppDate`) is the single source of truth for dates the UI shows: `long`, `monthDay`, `short`, `shortYear`, `dayMonth`, `dayMonthYear`, `monthYear`, `monthShort`, `weekdayLong`, `weekdayShort` and `range`. Eleven screens/widgets dropped their ad-hoc `DateFormat(...)` literals (and the now-unused `intl` import), so the same value can no longer drift between screens. `FeedService` keeps its RFC-822 pattern, which parses the feed rather than formatting text.
- **5.3** `CycleOrb` now draws the cycle instead of a single progress arc: the ring is a hard-edged `SweepGradient` with the period days in pink and the fertile window (ovulation -5 through +1) in purple over a neutral track, a gold dot rides the ring at today's progress, the centre adds "N% through", and a legend (Period / Fertile / Today) sits below. Sanctuary and Fertility feed it the real lengths, so the arc matches the predictions, and a `Semantics` label spells out the day, phase, both day ranges and the progress.
- **5.4** Tracking modes are one row of equal-width chips: `AppChip` gained `singleLine`, which clips a long label at the chip edge instead of wrapping it, so "Perimenopause" can no longer make its chip taller than its siblings.
- **5.5** The bleeding screen's Today card no longer repeats the next-bleed countdown the stats row above already shows. When the user is not bleeding it says where they are instead: "Cycle day N, counted from your last period start on <Sep 10>.", or "Cycle day N. Predictions pause until you log your next period." once predictions stop.
- **5.6** FAB clearance was verified rather than re-implemented: `AppDims.fabClearance` (96) is already the bottom padding of every tab scrollable that sits behind the floating log button (Today, Calendar, Insights), and the button is only hidden on the Articles tab, so the last card is never covered.
- **5.7** Tests: new `test/common/date_format_test.dart` (every pattern, single-digit days, the range en dash), `test/widgets/cycle_orb_test.dart` (period/fertile/track colours, day, phase, progress, legend, `showLegend: false`, the semantics label) and `test/widgets/tracking_mode_chip_test.dart` (three equal-width chips on one line, all labels present, tap reporting, clipping). `widget_test.dart`'s dashboard-landing checks now expect three "Today" labels because the orb legend adds one.

Gates: `flutter analyze` = No issues found, `flutter test` = 323/323 passing, `flutter build apk --debug` = ✓.

## Update 19 - 2026.10.19 - Screen rename

Seven screens were named after implementation vocabulary or the wrong concept, so the file you open never told you the screen you get. Every name now matches the title on the bar and the route in `app_router_delegate.dart`, which is what the route table in DESIGN.md already used.

| Was (file / class) | Now (file / class) | Title / route |
| --- | --- | --- |
| `rhythms_screen.dart` / `RhythmsScreen` | `onboarding_screen.dart` / `OnboardingScreen` | Set Your Cycle, `/onboarding` |
| `sanctuary_screen.dart` / `SanctuaryScreen` | `today_screen.dart` / `TodayScreen` | Today, `/dashboard` -> `/today` |
| `cycle_screen.dart` / `CycleScreen` | `calendar_screen.dart` / `CalendarScreen` | Calendar, `/calendar` |
| `records_screen.dart` / `RecordsScreen` | `insights_screen.dart` / `InsightsScreen` | Insights, `/insights` |
| `coven_screen.dart` / `CovenScreen` | `articles_screen.dart` / `ArticlesScreen` | Articles, `/coven` -> `/articles` |
| `gestation_screen.dart` / `GestationScreen` | `pregnancy_screen.dart` / `PregnancyScreen` | Pregnancy Tracker, `/pregnancy` |
| `bleeding_screen.dart` / `BleedingScreen` | `bleed_history_screen.dart` / `BleedHistoryScreen` | Bleed History, `/bleeding` -> `/bleed-history` |

- `rhythms` and `coven` were product metaphors that appear nowhere in the UI; `sanctuary` was the old name of the Today tab; `records` held Insights; `cycle` held the Calendar (and collided with `CycleProvider`); `gestation` showed the Pregnancy Tracker; `bleeding` showed the bleed log.
- Three routes moved with their screens: `/dashboard` -> `/today`, `/coven` -> `/articles`, `/bleeding` -> `/bleed-history`. `shellRoutes` is now `{/today, /calendar, /insights, /articles}`, the router's `back()` fallback is `/today`, and `/onboarding`, `/calendar`, `/insights`, `/pregnancy`, `/chart`, `/fertility`, `/profile`, `/alerts`, `/privacy` were already accurate and are unchanged.
- The five mirroring tests were renamed with their screens (`test/screens/today_screen_test.dart`, `insights_`, `articles_`, `pregnancy_`, `bleed_history_`), private `State` classes follow the new names (`_OnboardingScreenState`, `_CalendarScreenState`, `_ArticlesScreenState`), and stale prose in comments and test helper names was updated (`pumpSanctuary` -> `pumpToday`, `pumpRecords` -> `pumpInsights`).
- Kept deliberately, because they name data rather than a screen: `OnboardingProvider.persistRhythms` / `PrefsService.saveRhythms` (they persist the cycle and bleed values), `GestationProvider` / `gestation_content.dart` / `GestationContent` (the pregnancy provider and its content model), and `CycleProvider` / `lib/widgets/cycle_calendar.dart`, which were never related to the old `cycle_screen.dart`.
- Docs: DESIGN.md was swept for the same terms (route table, route tree, screen headings, private-widget lists, app-bar fallbacks, the CycleStats note), so no old route or class name survives outside this log's historical entries.

Gates: `flutter analyze` = No issues found, `flutter test` = 323/323 passing, `flutter build apk --debug` = built.

## Update 20 - 2026.10.19 - Goal chips

The onboarding goal picker was the last chip block still built from a `Wrap`, so `Track / Conceive / Avoid pregnancy` sat at their natural widths and the long third label wrapped onto a second line, making that chip taller than its siblings. It now uses the same layout as the tracking-mode picker directly below it, so both single-choice blocks read the same way.

- `lib/screens/onboarding_screen.dart` `_GoalCard`: the `Wrap(spacing: 8, runSpacing: 8, ...)` became a `Row` of `Expanded` `AppChip`s with 8dp gaps and `singleLine: true`, so the three goals are equal thirds and "Avoid pregnancy" is clipped at the chip edge instead of wrapping. The icons, the `SettingsProvider.setGoal` wiring and the blurb under the row are unchanged.
- `DESIGN.md`: the `Equal-Width Chip Rows` bullet and the Screen 04 `Goal Card` bullet now both name the goal picker, not only the tracking modes.
- Tests: new `test/screens/onboarding_screen_test.dart` - the three goal chips share one width and one line, "Avoid pregnancy" is clipped to a single line (`maxLines: 1`, `softWrap: false`, `TextOverflow.clip`), and tapping `Conceive` records the goal.

Gates: `flutter analyze` = No issues found, `flutter test` = 325/325 passing, `flutter build apk --debug` = ✓.

## Update 21 - 2026.10.21 - Trust, period history and plan closeout

Closes `plans/2026.10.19.md`. Predictions now share one rolling median, onboarding stops inventing period lengths, past starts can be added and edited from Insights, Bleeding and Profile, and goal-based fertility wording is removed.

### Trust fixes
- `AppTopBar` now renders both Font Awesome and Material icons, so the back arrow and the Profile/Alerts glyphs no longer fail on web. Profile and Alerts use person and bell icons.
- Before-window fertility copy counts to the fertile-window start instead of ovulation: `In 14 Days` now means 14 days until the window opens.
- Profile and Insights show the same cycle length: the last-6 median once two completed cycles exist, otherwise the setup value marked `Estimated`. No screen uses a separate mean.
- Cycle tags use absolute clinical bands: `Short` below 21 days, `Long` above 35 days, otherwise `Typical`. A 23-day cycle is no longer called short only because its neighbours are longer.
- Cycle trend labels use full start dates such as `May 3`, so repeated months stay distinguishable.
- Calendar shows only the selected day in its detail card, or `No entry for this day` with a direct log action. The duplicate header chevron is gone, and FAB clearance is 128 dp.
- Tracking Modes and the other Profile selector rows are tappable across the full row and carry a chevron.

### Period records and history
- New `PeriodRecord` model and `witchy_period_records` preference list. A record can be start-only, carry an optional end date, and is marked estimated when it came from onboarding or migration.
- `PeriodHistory` merges real flow spans with records. Real flow wins on overlap, so editing a saved start cannot overwrite a logged bleed.
- Onboarding seeds start-only estimated records instead of five days of made-up `Medium` flow. The last period date is required before Get Started, and the last-period row plus earlier starts live in one `Past periods` card.
- Existing assumed flow is migrated once into estimated records, then cleared only from those days. Notes, symptoms and other non-flow details are kept.
- `CycleProvider.bleedLength` now comes from real logged spans, clamped 2-10, with the setup value as a fallback. Estimated and start-only records do not count toward the average.
- New shared `PeriodRangeSheet`: add a period, set an optional last day, save, or delete the saved dates. Deleting a record does not delete flow logged day by day.
- `Add past period` and tappable history rows are available in Insights, Bleeding and Profile. Start-only records show one date and `Start only` or `Estimated start` instead of a fabricated duration.

### Prediction and screen polish
- The predicted range trims one lowest and one highest cycle once four recent cycles exist, so a single outlier cannot widen the whole window. Late-cycle thresholds still use the full recent maximum.
- Today, Calendar and Fertility show whether predictions are `Based on N cycles` or `Based on default 28 days`.
- Late periods keep the cycle count running, stop new projections after the grace window, and show `Log to update` rather than pretending the next period is still on schedule.
- Insights Cycle Trends and Irregularity cards gained direct log actions.
- The Articles tab ships and stays in the bottom navigation even when the feed is empty. The shell, the nav bar and the router are back to four sections (Today, Calendar, Insights, Articles), and the log FAB is hidden on the reading tab.
- Goal framing is removed: onboarding keeps only the tracking-mode question, Profile has no `Your goal` row, `CycleGoal` and its preference key are gone, and Fertility uses neutral `Cycle notes` copy with a `Fertility` stat. Stored `avoid` values from older builds simply stop being read.
- Moon-phase differentiation was declined and the plan item is closed.

### Articles feed
- The web build could not load the feed because of CORS, not because of the URL or the parser. `https://qvonyx.com/witchy/articles.xml` answers `200` with `application/xml` and 18 items that `FeedService.parseFeed` reads without changes, but it sends no `Access-Control-Allow-Origin`, so the browser blocks the XHR from the web app origin `https://witchy.qvonyx.com` and the request dies with `net::ERR_FAILED`. A direct address-bar load still worked because top-level navigation is not CORS-protected, which is why the feed looked reachable in a browser and empty inside the app. Native builds were never affected.
- `documents/.htaccess` now carries the header rules (`Access-Control-Allow-Origin`, `-Methods`, `-Headers`, `-Max-Age`, plus an `OPTIONS` preflight branch) scoped to `articles.xml`. Upload it next to the feed as `public_html/witchy/.htaccess` and purge the CDN cache for that file, otherwise the edge keeps serving the headerless response. The feed is public and carries no user data, so `*` is used; the file documents how to pin it to the web origin instead.
- Verified after the header lands with `curl -sSI -H 'Origin: https://witchy.qvonyx.com' https://qvonyx.com/witchy/articles.xml`.
- Known gap, left as is: the feed links are relative slugs that resolve to `https://qvonyx.com/witchy/<slug>.html`, and none of those article pages are published yet, so every article tap opens a 404 until the bodies are written.

### Onboarding past periods
- The onboarding `Past periods` card no longer splits into a "last period" row and an "earlier periods" list. It is one list of the periods the user adds, newest first, and the most recent start is the anchor: `OnboardingProvider.lastPeriodStart` and `pickedDate` both come from the newest range, so the cycle day, the predictions and the saved rhythm start from the period the user remembers last. Removing the newest period promotes the next one.
- Ranges are picked with a booking-style calendar (`PeriodRangeCalendar`), like an airplane or hotel booker: tap the first day, then the last day. The month grid is Monday-first, the header steps between months and can jump to any month of the last two years, the picked range is highlighted, and the summary line reads `October 29, 2026 - November 3, 2026 · 6 days`.
- The rules are applied while picking, not only on save. `PeriodRangeRules` is the single source of truth and the calendar disables the days that cannot be used: at least 15 days between two period starts (exactly 15 is allowed), 2 to 10 days per period, no overlap with a period already added, no dates in the future, only the last two years, and at most 7 periods. The reason is shown inline in the sheet and the save button stays disabled until the range is valid.
- Every row shows the full range, `October 29, 2026 - November 3, 2026`, and the `Estimated` tag is gone. The counter reads `2 of 7 periods`, the copy explains that the most recent start sets the cycle day, and the only action is a calendar icon plus `Add past period`. A row can be edited with the pencil or removed with the x, with an undo snackbar.
- Get Started stays blocked until at least one period is added, and the hint now reads `Add at least one past period to continue.`
- The periods are stored as real records, `PeriodRecord(start, end, source: onboarding, estimated: false)`. Because they are no longer estimated they also count toward the bleeding length average, so the `Bleeding Phase Length` value in Today and Profile is the average of the periods the user confirmed instead of the onboarding slider. That is the intended trade-off: the user picked both ends, so the length is known.
- The same calendar and the same rules now back the shared add/edit sheet, so `Add past period` on Insights, Bleeding and Profile picks a range instead of two separate date pickers, and an overlapping or too-close period is refused there too. A stored start-only record counts as a one-day range for the gap and overlap checks.
- New files: `lib/models/period_range.dart`, `lib/services/period_range_rules.dart`, `lib/widgets/period_range_calendar.dart`, `lib/widgets/period_range_calendar_sheet.dart`.
- Date ranges use a plain hyphen. The old `AppDate.range` helper used an en dash, and `AppDate.longRange` was added for the full `October 29, 2026 - November 3, 2026` form used by the card rows.

Gates: `flutter analyze` = No issues found, `flutter test` = 383/383 passing, `flutter build apk --debug` = ✓, `flutter build web` = ✓.

## Update 22 - 2026.10.22 - Overdue cycles and honest period math

This update carries the full P0-P4 cycle-trust roadmap. All four phases are shipped below.

### Roadmap
- **P0 - Stop the app from lying**: shipped.
- **P1 - Make every screen tell the same story**: shipped.
- **P2 - Trust the data you already collect**: shipped.
- **P3 - Model the bodies the app cannot represent**: shipped.
- **P4 - Lock it down with tests**: shipped.

### Phase P0 - Stop the app from lying

P0 of the cycle-tracking review. The goal was to stop the app from presenting a late cycle as a fresh ovulatory cycle, and to stop low-quality period data from inventing short cycles.

#### Overdue state
- `CycleProvider` now has one due-date basis: earliest due is the trimmed shortest recent cycle, latest due is the trimmed longest. `daysLate` counts from the latest due date, so a 35-day cycle is not called late on day 33 just because the median is 32.
- Predictions stay confident for 5 days past the latest due date and stop entirely after 10. `isOverdue` is the explicit state between those.
- When overdue, every fertility surface pauses: `fertilityStatus` returns `FertilityStatus.overdue`, `showFertilityNow` is false, fertile/ovulation day checks are false, the fertile window getters return null, Today hides the fertility stat card and the orb's fertile segment and legend, the Fertility screen shows `Predictions paused` with a test prompt, and the chart hides the predicted ovulation marker.
- Today keeps the overdue message after the projection stops (`Log to update` plus `period overdue - consider a test`) and the astral card says `Cycle running long` instead of a phase.
- The period window no longer rolls one bound into the next cycle: `predictedRange` anchors both bounds to the last start, so a range that is already open reads `Due Now` instead of showing next-cycle dates.

#### Cycle day and period detection
- `CycleCalculator.elapsedCycleDay` returns the real day count since the last start, with no modulo. Today, Fertility, Bleed History and the orb use it, so a 39-day cycle reads `Cycle Day 39`, not `Cycle Day 11`.
- Today only shows the `Period Day N` tag when bleeding is actually logged; predicted period days are a separate glyph.
- Spotting is no longer a period: `PeriodHistory` marks all-`Spotting` spans and `periods()` excludes them from starts, cycle lengths, bleed averages and BBT/OPK baselines. Spotting remains visible in the logs and history.
- A one-day gap inside a bleed is bridged, so an unlogged day cannot split one period into two starts. Observed cycle gaps below 15 days are rejected, matching the manual range floor.
- An explicit period record is no longer replaced by a spotting or too-short real flow span that happens to share its start date.

#### P0 tests and gates
- Added regression coverage for the overdue state, elapsed vs modular cycle day, spotting-only spans, the one-day gap bridge, sub-15 cycle rejection, the due-window rollover, and the late-vs-median case.
- `flutter analyze` = No issues found, `flutter test` = 396/396 passing, `flutter build apk --debug` = ✓.

Files: `lib/models/fertility_status.dart`, `lib/models/period_span.dart`, `lib/services/cycle_calculator.dart`, `lib/services/period_history.dart`, `lib/providers/cycle_provider.dart`, `lib/screens/today_screen.dart`, `lib/screens/fertility_screen.dart`, `lib/screens/bleed_history_screen.dart`, `lib/screens/chart_screen.dart`, `lib/widgets/cycle_orb.dart`, plus the matching tests.

### Phase P1 - Make every screen tell the same story

P1 aligned the countdown, phase, fertility, calendar and chart surfaces with the same cycle state and confidence rules.

#### Countdown
- `CycleProvider.nextPeriodStart` no longer rolls into the next cycle. It returns the earliest plausible due date while the current cycle is still due or late, then null once that date has passed or the projection stops.
- `daysUntilPeriod` is nullable and counts to that same anchored date. Today, Bleed History, AlertGenerator and the reminder scheduler treat null as `Due now` or no next-cycle schedule instead of inventing a future date.

#### Effective ovulation
- The current cycle's peak now has one source priority: BBT confirmation on or after the current anchor, then a positive OPK indication on or after the anchor, then the arithmetic estimate.
- Confirmations and OPKs from earlier cycles are ignored for the current peak. Chart also ignores a prior-cycle BBT confirmation when choosing its marker.
- The effective peak drives `ovulationDay`, the fertile window, `fertilityStatus`, fertile and ovulation day checks, cycle-day window bounds, phase classification, Today copy, Fertility copy and the Chart marker. Today, Fertility and Chart now agree when BBT or OPK moves ovulation.

#### Spotting and consistency
- Added `hasLoggedPeriodBleedOn`, which only matches real period spans. The menstrual phase, `isPeriodDay`, `bleedDayOf`, Today's `Period Day N` tag and Calendar's period tags use it; spotting stays visible as bleeding in logs and Bleed History without becoming a period.
- Calendar uses the earliest-latest predicted window whenever `showPeriodRange` is true, not only in perimenopause. Its entry fallback now says `Logged` or `Flow Logged`, never `Period Logged`, for a non-period flow day.
- Audited fertility gating across Today, Fertility, Chart, Calendar and alerts. Every surface still reads the same `showFertilityNow` confidence rule; no bypass was found.

#### Calculator guard
- Added `CycleCalculator.projectionValid`, which stays true through the latest plausible due date plus the projection grace and then stops. `CycleProvider.projectionStopped` now delegates to it, so direct calculator callers cannot project past the threshold.

#### P1 tests and gates
- Added coverage for the non-rolling nullable countdown, current-cycle and prior-cycle OPK behavior, BBT confirmation outranking OPK, period-only spotting, the Today spotting tag, Calendar range wiring in cycle mode, and the calculator projection boundary.
- `flutter analyze` = No issues found, `flutter test` = 405/405 passing, `flutter build apk --debug` = ✓.

Files: `lib/services/cycle_calculator.dart`, `lib/providers/cycle_provider.dart`, `lib/screens/today_screen.dart`, `lib/screens/calendar_screen.dart`, `lib/screens/chart_screen.dart`, `lib/screens/bleed_history_screen.dart`, plus `test/providers/cycle_provider_test.dart`, `test/services/cycle_calculator_test.dart`, `test/screens/today_screen_test.dart`, `test/screens/calendar_screen_test.dart` and `test/screens/bleed_history_screen_test.dart`.

### Phase P2 - Trust the data you already collect

P2 improved the inputs the predictions already rely on instead of adding new tracking models.

#### Typical bleed
- Added `PeriodHistory.measuredPeriods`, which keeps only real logged periods and excludes estimated records, start-only records, spotting and spans shorter than two days.
- Added `PeriodHistory.medianRecentBleedLength`, using the last six measured periods. `CycleProvider.bleedLength` now uses that median, with the onboarding length as the fallback.
- Bleed History and Insights now show `Typical Bleed` / `Typical Bleeding` as a whole number of days. Today and Fertility orbs read the same `bleedLength`.

#### Merged records
- `PeriodHistory.spansFrom` now unions overlapping explicit period records before merging them with logged flow. The union keeps the earliest start, the latest end, a measured flag if any record is measured, and a known end if any record has one.
- Logged flow still wins over an explicit record that covers the same start, and explicit records that overlap real logged periods are still ignored.

#### Logged signals
- Added `loggedSignalOvulationDate`, which uses signals already in the logs when BBT and OPK are absent: the latest `Ovulation pain`, then `Egg white` discharge, then `Watery` discharge.
- A logged signal only counts in the current cycle, on or after cycle day 5, not in the future, and within seven days of the arithmetic peak. The effective peak priority is now BBT, OPK, logged signal, then arithmetic, so the signal moves the fertile window, phase and all prediction surfaces consistently.

#### BBT hardening
- `BbtAnalyzer.analyze` now accepts excluded nights. CycleProvider excludes nights logged as `Restless sleep`, `Insomnia`, `Woke up at night` or `Woke up early` before detecting a shift.
- Temperatures at or above 38.0 C are treated as likely fever and dropped, so a fever spike cannot create a false ovulation confirmation or distort the measured luteal length.

#### Estimated policy
- Estimated period records still anchor predictions and cycle-length history, but they stay out of measured bleed statistics. This is now explicit in Bleed History and Profile: `Estimated dates guide predictions but stay out of measured bleed averages.`
- The existing gold `Estimated` tags remain, and `CycleProvider.hasEstimatedPeriods` exposes whether the policy note applies.

#### P2 tests and gates
- Added coverage for median recent bleed, exclusion of estimated and spotting spans, overlapping-record merging, logged ovulation pain and egg-white signals, signal guards, prior-cycle signal rejection, fever filtering and poor-sleep exclusions.
- `flutter analyze` = No issues found, `flutter test` = 423/423 passing, `flutter build apk --debug` = ✓, `git diff --check` = clean.

Files: `lib/services/period_history.dart`, `lib/services/bbt_analyzer.dart`, `lib/providers/cycle_provider.dart`, `lib/screens/bleed_history_screen.dart`, `lib/screens/insights_screen.dart`, `lib/screens/today_screen.dart`, `lib/screens/fertility_screen.dart`, `lib/screens/profile_screen.dart`, plus `test/services/period_history_test.dart`, `test/services/bbt_analyzer_test.dart`, `test/providers/cycle_provider_test.dart` and `test/screens/bleed_history_screen_test.dart`.

### Phase P3 - Model the bodies the app cannot represent

P3 added models for bodies the single-length, single-window model could not describe, without changing the privacy model.

#### Variable fertile window
- `CycleProvider.fertileWindowPad` widens the window by one day for PCOS and one day for irregular history (three or more observed cycles with a spread above seven days), capped at two days.
- `fertileStartCycleDay` and `fertileEndCycleDay` use the pad around the effective ovulation day. The start still clamps to cycle day 1, so an early peak cannot produce a negative day.
- The padded window drives Today, Fertility, Calendar and the fertile-day checks.

#### Contraception and conditions
- Added `TrackingMode.contraception` to onboarding and Profile. `contraceptionModeOn` suppresses fertility predictions, the fertile window and fertility status while leaving period predictions intact.
- Added `CycleCondition` with `postpartum`, `breastfeeding`, `pregnancyLoss` and `pcos`. Profile exposes a conditions sheet.
- Postpartum, breastfeeding and pregnancy loss pause fertility predictions until the user clears them. PCOS widens the fertile window instead of pausing it.
- Conditions persist through `PrefsService` and reload with `OnboardingProvider.load`.

#### Missed-period testing
- `LoggingProvider.setPregnancyTest` stores a negative or positive result on a day log.
- `hasNegativeTestThisCycle` only counts a negative test on or after the current anchor, and `hasRecentNegativeTest` counts one within three days.
- Today shows `I tested negative` when the cycle is late and no current-cycle negative exists. After logging, the CTA clears and the late copy reads `negative test logged - retest in 3 days`.

#### Cycle clamp
- `OnboardingProvider.minCycleLength` and `maxCycleLength` are 15 and 60.
- `CycleStats.rawMedianRecent` exposes the unclamped recent median. `CycleProvider.rawCycleLength` reports it, `effectiveCycleLength` clamps to 15-60, and `isCycleLengthClamped` drives the Profile warning tag.
- A very long observed median no longer silently disappears into the slider bounds.

#### Prediction snapshots
- Added `PredictionSnapshot` and `PredictionSnapshotStore`. The first prediction seen for a cycle start is stored and later logs do not rewrite it.
- Snapshots dedupe by normalized cycle start and keep the newest 24.
- `CycleProvider.predictionHistory` is newest-first, and Insights shows a `Prediction History` card with up to three saved predictions.

#### Trends
- Added `TrendAnalyzer`, which compares the last three values with the prior three for cycle length and measured bleed length.
- Symptom trends compare the last 30 days with the previous 30 days and report the top symptom.
- Insights shows a `What Changed` card with `Increasing`, `Decreasing`, `Stable` or `Not enough data` tags.

#### P3 tests and gates
- Added provider coverage for contraception and condition suppression, the 15-60 clamp, negative-test state and snapshot recording.
- Added unit coverage for `PredictionSnapshotStore` persistence, dedupe and the 24-item cap; `TrendAnalyzer` cycle, bleed and symptom trends; and Calendar effective fertile and ovulation dates.
- Added widget coverage for the Today negative-test action, onboarding condition persistence and the Insights trends and history cards.
- `flutter analyze` = No issues found, `flutter test` = 445/445 passing, `flutter build apk --debug` = success, `git diff --check` = clean.

Files: `lib/models/cycle_condition.dart`, `lib/models/prediction_snapshot.dart`, `lib/models/trend_direction.dart`, `lib/models/trend_summary.dart`, `lib/providers/cycle_provider.dart`, `lib/providers/onboarding_provider.dart`, `lib/services/cycle_stats.dart`, `lib/services/prediction_snapshot_store.dart`, `lib/services/trend_analyzer.dart`, `lib/services/calendar_fetcher.dart`, `lib/screens/today_screen.dart`, `lib/screens/profile_screen.dart`, `lib/screens/insights_screen.dart`, `lib/screens/fertility_screen.dart`, `lib/screens/calendar_screen.dart`, plus `test/providers/cycle_provider_test.dart`, `test/providers/onboarding_provider_test.dart`, `test/services/prediction_snapshot_store_test.dart`, `test/services/trend_analyzer_test.dart`, `test/services/calendar_fetcher_test.dart`, `test/screens/today_screen_test.dart` and `test/screens/insights_screen_test.dart`.

### Phase P4 - Lock it down with tests

- Added `test/roadmap_regression_test.dart` with cross-phase regression checks: overdue cycles pause projections while the elapsed day keeps counting, the due window never rolls forward while late, spotting never anchors the cycle or enters bleed statistics, typical bleed uses the median of measured periods, and contraception plus a fertility-pausing condition suppress every prediction.
- Added `test/services/cycle_math_properties_test.dart` with leap-day and US daylight-saving boundary checks, cycle position properties across 15-60 day lengths, start/next-period bracketing, exactly one ovulation day and a fixed fertile width per cycle, exact bleed-day counts, projection-validity boundaries, 500 seeded random dates and leap February month sets.
- Added `test/providers/cycle_mode_matrix_test.dart` covering all 15 non-empty tracking-mode subsets with and without a pregnancy LMP, fertility-pausing conditions across every cycle-mode subset, and PCOS widening without suppression.
- `flutter analyze` = No issues found, `flutter test` = 462/462 passing, `flutter build apk --debug` = success, `git diff --check` = clean.

Files: `test/roadmap_regression_test.dart`, `test/services/cycle_math_properties_test.dart`, `test/providers/cycle_mode_matrix_test.dart`.

## Update 23 - 2026.10.23 - Calendar polish and Birth Control removal

### Birth Control removal

- Removed the `Birth Control` tracking mode, its chip icon, its fertility gate, and its paused-state copy. Cycle, Pregnancy and Perimenopause remain.
- `PrefsService.trackingModes` now filters stored mode names to the modes that still exist. A stored `Birth Control` value is dropped; if nothing valid remains, the app falls back to Cycle instead of inventing a mode.

### Calendar selected-day empty state

- The selected day now shows its full date and a proper card when nothing is logged: calendar badge, `Nothing logged yet`, a short prompt, and a full-width primary button.
- Estimated period starts keep their `Estimated start` tag and onboarding explanation inside the card.
- The dark entry card is unchanged when the day has a log.

### Primary CTAs

- Calendar `Log this day` and Insights `Log your period` now use the app's primary `AppButton` instead of link-style `TextButton`s.
- The Insights button keeps the `cycle-trends-cta` key, so it remains directly testable.

### Profile metadata

- Added `AppMetadata.lastUpdated` in `lib/common/app_metadata.dart`. The profile footer now reads `Witchy`, `Version x.y.z`, and `Updated Oct 23, 2026`.
- Bump `AppMetadata.lastUpdated` together with each shipped `CHANGES.md` entry so the date stays truthful.

### Calendar today marker and legend

- The current day now uses a rounded full-cell background instead of a small circle: plum in light mode and a muted lavender in dark mode. The inner circle keeps the normal cell surface and day label colors, so only the space outside the circle turns purple.
- Today gets a gold ring when unselected and a white ring when selected.
- Moon glyph cells keep their dark labels.
- The legend now lists only Period, Predicted, Fertile and Ovulation. Logged and Estimated were removed because the dots are not explained by the legend and the extra items made it feel cluttered.

### Tests and gates

- Updated tracking-mode, chip, mode-matrix, roadmap regression, calendar, profile and Insights tests.
- Added `test/services/prefs_service_test.dart` for the stored-mode migration and `test/widgets/calendar_widgets_test.dart` coverage for the today background in both themes.
- `flutter analyze` = No issues found, `flutter test` = 469/469 passing, `flutter build apk --debug` = success, `git diff --check` = clean.

Files: `lib/models/tracking_mode.dart`, `lib/providers/cycle_provider.dart`, `lib/screens/calendar_screen.dart`, `lib/screens/fertility_screen.dart`, `lib/screens/insights_screen.dart`, `lib/screens/profile_screen.dart`, `lib/screens/today_screen.dart`, `lib/services/prefs_service.dart`, `lib/widgets/calendar_legend.dart`, `lib/widgets/cycle_calendar.dart`, `lib/widgets/tracking_mode_chip.dart`, `lib/common/app_metadata.dart`, plus `test/models/tracking_mode_test.dart`, `test/providers/cycle_mode_matrix_test.dart`, `test/providers/cycle_provider_test.dart`, `test/roadmap_regression_test.dart`, `test/screens/calendar_screen_test.dart`, `test/screens/insights_screen_test.dart`, `test/screens/profile_screen_test.dart`, `test/services/prefs_service_test.dart`, `test/widgets/calendar_widgets_test.dart`, `test/widgets/tracking_mode_chip_test.dart`.

## Update 24 - 2026.10.24 - Alert freshness, future calendar, and onboarding polish

### Alert freshness

- `AlertProvider.generate` now removes stale live alerts when the current cycle and logging state no longer produce them. Live ids cover late, period countdown, fertile window and log-missing alerts.
- Still-valid alerts keep their read state. One-shots (`opk-positive-*`, `period-today-*`) and lunar alerts stay untouched.
- This fixes the Today screen showing Luteal while an old fertile-window alert remained, and `Log Missing` staying after the day was logged.

### Onboarding

- `What to track` chips now sit in one row that fills the card. Widths follow label content, so Perimenopause is the widest chip.
- Tracking chips use 10px horizontal and 6px vertical padding. `AppChip` takes an optional padding override, so log-sheet chips keep their original 8/4 padding.
- `Add past period` is now a compact primary button with a calendar icon, matching the Calendar `Log this day` treatment at a smaller size.
- `AppSliderRow` min and max labels are centered under the 40px minus and plus buttons.

### Calendar

- Future dates are marked in `CalendarFetcher` and render muted day numbers. Prediction glyphs and dots remain visible.
- Future dates cannot be tapped or logged. Selecting one shows `Future dates cannot be logged. Predictions stay visible on the calendar.` with no log button.

### Articles

- Relative feed links resolve against `https://qvonyx.com/witchy/articles/`, so article slugs open under the correct path.
- Legacy cached links under `https://qvonyx.com/witchy/<slug>.html` are normalized to the articles path and the cache is rewritten.

### Tests and gates

- Added alert provider coverage for removing stale log-missing and fertility alerts.
- Added onboarding coverage for proportional tracking chips, compact Add past period, and slider label alignment.
- Added calendar coverage for future flags, muted future cells, disabled taps, and the future selected-day card.
- Added feed coverage for relative article links and legacy cache normalization.
- `flutter analyze` = No issues found, `flutter test` = 476/476 passing, `flutter build apk --debug` = success, `git diff --check` = clean.

Files: `lib/models/article.dart`, `lib/models/calendar_day_cell.dart`, `lib/providers/alert_provider.dart`, `lib/screens/calendar_screen.dart`, `lib/screens/onboarding_screen.dart`, `lib/services/calendar_fetcher.dart`, `lib/services/feed_service.dart`, `lib/widgets/app_button.dart`, `lib/widgets/app_chip.dart`, `lib/widgets/app_slider_row.dart`, `lib/widgets/cycle_calendar.dart`, `lib/widgets/tracking_mode_chip.dart`, `lib/common/app_metadata.dart`, plus `test/providers/alert_provider_test.dart`, `test/screens/calendar_screen_test.dart`, `test/screens/onboarding_screen_test.dart`, `test/services/calendar_fetcher_test.dart`, `test/services/feed_service_test.dart`, `test/widgets/app_slider_row_test.dart`, `test/widgets/calendar_widgets_test.dart`, `test/widgets/tracking_mode_chip_test.dart`.

## Update 25 - 2026.10.26 - UI and behavior fixes

### Onboarding

- Removed the icons from the tracking mode chips while keeping the three choices in one proportional row.
- Replaced the onboarding `Add past period` text button with the shared 34x34 purple icon-only calendar button, right aligned with a 10px top gap.
- The period range calendar now turns the first clicked start day purple immediately, then paints every day through the end with the same purple fill and white bold text. The existing-period marker stays hidden anywhere inside the selected range.
- The cycle length slider now exposes 45 divisions from 15 to 60, draws visible tick marks, and aligns the min and max labels under the minus and plus buttons.

### Insights

- The Period History add action now uses the same icon-only purple button as onboarding, stays on the right, and has a small bottom margin under the header.

### Alerts

- Dismissed alert ids now persist in shared preferences and are filtered out of loaded, generated, and one-shot alerts.
- The dismissed id list is capped at 200 entries, removing the oldest first, and restore or reset clears the matching id.
- Lunar alerts such as Full Moon stay dismissed after refresh instead of being regenerated on the next pass.

### Profile and starting tab

- The profile identity uses a moon emoji avatar, hides an empty display name, removes the `LOCAL` marker, and keeps the device-only storage line.
- The tracking label is now derived from the selected modes, for example `CYCLE TRACKING` or `CYCLE + PREGNANCY TRACKING`.
- The Past periods card uses the shared icon-only purple add button on the right.
- App Settings gained a Starting tab dropdown, defaulting to Today.
- The starting tab is persisted by SettingsProvider and used by the normal `/today` startup path, while explicit `/calendar`, `/insights`, and `/articles` routes keep their own indices.

### WebView

- Removed the URL line shown below `Open in browser` in the fallback view.

### Navigation and calendar

- The bottom navigation is now split into four equal full-height tap targets spanning the row, with each icon and label centered in its quarter.
- The current-day purple calendar background is now a fixed square capped at 54px and clamped to the available width, staying square-ish behind the 44px inner circle.

### Tests and gates

- Added coverage for nav quarter taps, slider divisions and tick marks, chips without icons, first-click and full-range purple selection, the square today surface, starting tab settings and persistence, dismissed Full Moon persistence, profile identity and starting-tab defaults, and the icon-only add buttons.
- `flutter analyze` = No issues found, `flutter test` = 483/483 passing, `flutter build apk --debug` = success, `git diff --check` = clean.

Files: `lib/common/app_metadata.dart`, `lib/navigation/app_router_delegate.dart`, `lib/providers/alert_provider.dart`, `lib/providers/settings_provider.dart`, `lib/screens/insights_screen.dart`, `lib/screens/main_screen.dart`, `lib/screens/onboarding_screen.dart`, `lib/screens/profile_screen.dart`, `lib/screens/webview_screen.dart`, `lib/services/prefs_service.dart`, `lib/widgets/add_past_period_button.dart`, `lib/widgets/app_avatar.dart`, `lib/widgets/app_bottom_nav.dart`, `lib/widgets/app_slider_row.dart`, `lib/widgets/cycle_calendar.dart`, `lib/widgets/period_range_calendar.dart`, `lib/widgets/tracking_mode_chip.dart`, plus `test/providers/alert_provider_test.dart`, `test/providers/persistence_test.dart`, `test/providers/settings_provider_test.dart`, `test/screens/insights_screen_test.dart`, `test/screens/onboarding_screen_test.dart`, `test/screens/profile_screen_test.dart`, `test/widgets/app_bottom_nav_test.dart`, `test/widgets/app_slider_row_test.dart`, `test/widgets/calendar_widgets_test.dart`, `test/widgets/period_range_calendar_test.dart`, `test/widgets/tracking_mode_chip_test.dart`.

## Update 26 - 2026.10.30 - Articles stay in the app on the web build

### Article viewer

- Web builds now render article pages in an in-app iframe instead of showing `This page opens in your browser` with an external-browser button. `webview_flutter` has no web implementation, which is why the fallback appeared there; native builds already used the platform webview and are unchanged.
- `InAppWebFrame` is exported through a conditional import, so the web implementation registers a sandboxed iframe view while a stub keeps the widget tree valid on mobile.
- The frame is sandboxed (`allow-scripts allow-same-origin allow-forms`) and cannot navigate the Flutter app away.
- Bundled legal pages load in the same frame from the Flutter asset URL (`assets/assets/legal/...`), so the first-run privacy gate also stays in the app and still works offline.
- `documents/articles/.htaccess` now also clears `X-Frame-Options` and pins `frame-ancestors` to the web app origin, so framing keeps working if the host tightens headers later. Upload it next to the article HTML files.
- `README.md` documents the framing requirement next to the existing feed deployment notes.

### Tests and gates

- Repaired the prediction-snapshot test, whose hard-coded cycle start aged past the projection window and failed from 2026.10.30 onward; it now anchors the fixture to today.
- `flutter analyze` = No issues found, `flutter test` = 483/483 passing, `flutter build apk --debug` = success, `flutter build web` = success, `git diff --check` = clean.
- Verified in Chrome against a local web build: an article and the bundled terms page both render inside the app frame, and Back returns to the Articles list.

Files: `lib/screens/webview_screen.dart`, `lib/widgets/in_app_web_frame.dart`, `lib/widgets/in_app_web_frame_stub.dart`, `lib/widgets/in_app_web_frame_web.dart`, `pubspec.yaml`, `pubspec.lock`, `documents/articles/.htaccess`, `README.md`, plus `test/providers/cycle_provider_test.dart`.
