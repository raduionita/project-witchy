# WITCHY: Mobile Design System & UI/UX Specification
**Document Version:** 1.2.0
**Product Name:** Witchy — Comprehensive Menstrual, Fertility & Reproductive Health Tracker
**Target Platforms:** iOS, Android, web (Cross-Platform Mobile App)
**Primary Aesthetic:** Celestial witch / soft mystic — deep plum gradients on lavender-white, gold accents, Playfair Display + Inter
**Reference Mockup:** `resources/Qwen_html_20260917_r3vw6tc9n.html` (authoritative for colors, radii, type)

---

## 1. Executive Summary & Product Vision

**Witchy** is a comprehensive, beautifully designed women's health application that re-frames reproductive health tracking as an empowering, intuitive, and holistic daily practice. By bridging clinical-grade biometric logging (menstrual flow, basal body temperature, ovulation hormones, gestational milestones) with an elegant, celestial-inspired aesthetic, Witchy allows users to understand the natural rhythms of their bodies without the sterile, patronizing feel of traditional medical apps.

### 1.1 Core UX Objectives

- Instant cycle orientation: day count, bleed countdown, fertility status in one glance (Sanctuary).
- Friction-free daily logging: single-tap flow, multi-tap moods/symptoms, pain slider.
- Trust via consistency: one card style, one button style, one bottom nav across all 19 routes.
- Privacy-first mock auth: no backend; `MockAuthProvider` + `shared_preferences` rhythms persistence.
- Titles are mystical and frozen (`Sanctuary`, `Sovereign Blood`, `Coven Sanctum`); only routes are clinical.

---

## 2. Design System Architecture & Foundational Tokens

### 2.0 COLOR TOKEN VISUAL HARMONY

| Hex | Color name | Usage |
| :--- | :--- | :--- |
| `#FAF7FC` | bg | App scaffold background |
| `#FFFFFF` | card | Card surface |
| `#2A0A3C` | ink | Headings, body strong |
| `#4D3B5E` | body | Secondary body text |
| `#8B7F95` | muted | Hints, timestamps, subs |
| `#ECE3F2` | line | Card borders, dividers |
| `#7B2CBF` | pur | Primary: active chips, period days, toggles ON, chart bars, links |
| `#6A1B9A` | pur-d | Tag text on lavender |
| `#3B0A5E` / `#26063F` | plum / plum2 | Gradient buttons, dark cards, FAB (`135deg plum → plum2`) |
| `#D9A036` | gold | Stars, moon emblem, tags, progress, FAB icon, avatar ring |
| `#E0517F` | pink | Fertility peak, bleed badges, alert icons |
| `#F3EAF9` / `#E7D6F4` | lav / lav2 | Icon badges, tags, pills |

### 2.1 Color Palette & Design Tokens

Witchy uses a dark purple-led palette per mockup (see 2.0).

| Token Name | Hex Value | RGB / Opacity | Usage & Application | Contrast vs. Surface |
| :--- | :--- | :--- | :--- | :--- |
| `color-primary` | `#7B2CBF` | `rgb(123,44,191)` | Primary buttons (via plum gradient), period days, active pills, chart bars, toggles ON | 7.2:1 on white (AA) |
| `color-plum` | `#3B0A5E` | `rgb(59,10,94)` | Button/dark-card gradient start, tab ON, FAB | 12.9:1 (AAA) on white |
| `color-ink` | `#2A0A3C` | `rgb(42,10,60)` | Headings | 15.1:1 on `#FAF7FC` |
| `color-gold` | `#D9A036` | `rgb(217,160,54)` | Accents, tags on dark, progress fill | 2.4:1 decorative only |
| `color-pink` | `#E0517F` | `rgb(224,81,127)` | Fertility peak value, period tags, bleed icons | 4.1:1 on white |
| `color-line` | `#ECE3F2` | `rgb(236,227,242)` | Borders, dividers | — |
| `color-surface` | `#FAF7FC` | `rgb(250,247,252)` | Scaffold | — |

Code: `lib/theme/app_colors.dart` (`AppColors`).

### 2.2 Typography System

Playfair Display (display/serif) + Inter (sans). Code: `lib/theme/app_text_styles.dart` (`AppText`).

| Style Token | Font Family | Weight | Size (pt/dp) | Line Height | Letter Spacing | Usage Examples |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| `type-display-l` | Playfair Display | 800 | 34 | 1.1 | 0 | Splash `Witchy` brand (`AppText.brand`) |
| `type-h2` | Playfair Display | 700 | 21 | 1.2 | 0 | `Join the Coven`, `Set Your Rhythms` (`AppText.h2`) |
| `type-serif-18` | Playfair Display | 700 | 18 | 1.25 | 0 | Profile name, `Log Today's Energy` |
| `type-appbar` | Playfair Display | 700 | 16.5 | 1.2 | 0.2 | `WitchyAppBar` titles |
| `type-body` | Inter | 400/500 | 11–12.5 | 1.5–1.55 | 0 | Subs, alert/post/article bodies (`AppText.sub`) |
| `type-sec` | Inter | 600 | 11.5–12 | 1.4 | 0 | Section labels (`AppText.sec`, `secIn`) |
| `type-caps` | Inter | 700 | 9 | 1.4 | 0.14em | `SHEDDING PHASE`, `CYCLE DAY` eyebrow |
| `type-btn` | Inter | 600 | 13.5 | 1.3 | 0 | `WitchyButton` label (white) |

### 2.3 Spacing, Grid & Layout System

- Page: `16px` horizontal padding, `6px` top / `14px` bottom, `12px` card gap (`ListView padding: 16,6,16,14`).
- Card inner: `16px`; rows: `8–12px` gaps; chip grids: `8px` spacing; bottom nav `78px` tall.
- Max width: single 390dp column (phone frame `390×844`); web centers same column.
- Status bar `46px` mock only; Flutter uses `SafeArea`.

### 2.4 Corner Radii & Elevation

- Card `18`, button `14`, input/soc `12`, chip `10`, pills/switches/avatar `999` (circle).
- Card shadow `0 1px 2px rgba(43,10,61,.04)`; button/FAB shadow `0 8–10px 18–22px rgba(59,10,94,.55–.6)`.
- Dark card: `linear-gradient(135deg, #3B0A5E, #26063F)`, no border, white text, `lav`-tinted body (`#E9D9F5`).

---

## 3. Component Library & UI Patterns

### 3.1 Cycle & Fertility Status Badges

- **Period Day Badge:** pink `WitchyTag.pink` (`#FCE7EF` on `#C2336B`), e.g. `Period Day 2`.
- **Fertile Window Badge:** lavender `WitchyTag` (`#F3EAF9` on `#6A1B9A`), e.g. `On Time`, `Lime Size`.
- **Ovulation Peak Badge:** pink stat value (`Peak Today` in `AppColors.pink`).
- **Status Cards:** `StatCard` duo (label caps 8.5 / serif value 19 / sub 10); `CycleOrb` 172dp radial (`#4A1170→#2A0740`) in conic ring (46% pur).
- **Info Banner:** dark `WitchyCard(dark:true)` with gold spark + tag + 11.5/1.55 body (`Daily Astral Insight`).

### 3.2 Biometric Logging Controls

- **Flow Severity Selector:** single-select `Wrap` of `WitchyChip` (`None/Light/Medium/Heavy`, `data-single`); selected = pur fill white text.
- **Symptom Multi-Select Pills:** 2-col grid `WitchyChip` with icon tint; toggle ON/OFF (moods, somatic echoes).
- **Form Inputs:** `WitchyTextField` white, 12dp radius, line border, pur focus; lead icon + `pad`; eye toggle for secret key.
- **Cycle Slider:** `WitchySliderRow` label + serif pur value (`28 Days`, `Level 6`), 4dp track, white thumb pur border.
- **Primary Button:** `WitchyButton` full-width plum gradient, 14dp radius, gold icon, white 13.5/600 label.
- **Secondary Button:** `.soc` white bordered 12dp radius (Apple/Google).
- **BBT Quick-Entry Keypad:** deferred — `/chart` v1 uses slider + trend bars reusing `WitchySliderRow`/`TrendBars`; no custom keypad.
- **LH / Ovulation Test Reader Widget:** deferred — `/fertility` v1 uses orb + duo stat cards; no camera reader.

### 3.3 Navigation Patterns

- Bottom nav: 4 tabs `Today/Calendar/Insights/Magic` (`WitchyBottomNav`), pur active + 18×2.5 underline; Magic icon `auto_awesome` → `CovenScreen` tab; labels frozen. Log is a bottom drawer (`showLogSheet`), not a tab.
- App bar: `WitchyAppBar` 50px, serif 16.5 centered; shell tabs: **leading `person_outline` → `/profile`**, **action bell `notifications_outlined` → `/alerts`**; all pushed screens default **leading back `arrow_back`** (pop, `/dashboard` fallback); `/profile` leading back → home, action gear → `/settings`; `/settings` leading back → `/profile`.
- Pushes: Sanctuary Flow QA → `/cycle`, Mood/Pain/Notes QA → log bottom sheet (today); Peak card → `/fertility`; insight card → `/library`; CycleMap day tap → log bottom sheet (that date); trends + CycleMap cards → `/chart`; Library card → `/library/<slug>` (via `onGenerateRoute`, unknown slug → `/library`); Profile bond → `/binding`, gear/Manage → `/settings`, bells card button → `/reminders`, gestation → `/pregnancy`.
- No legacy aliases: every route in `main.dart` is canonical and reachable (see §4.2).

---

## 4. Screen-by-Screen UI/UX Specifications

### 4.1 Screen Architecture

| User Journey Phase | Core Screen (title frozen) | Route | Connected / Sub-Screens | Dynamic Routing & Behavior |
| :--- | :--- | :--- | :--- | :--- |
| Entry | Splash, Welcome | `/` | → `/onboarding`, `/auth` | CTA `Awaken Your Power` → onboarding; `Sign In` → auth |
| Entry | Join the Coven | `/auth` | → `/onboarding` | Mock sign-in (600ms busy) → onboarding |
| Onboarding | Set Your Rhythms | `/onboarding` | → `/dashboard` | Day 17 default, 28d/5d sliders, persist, `pushNamedAndRemoveUntil` shell |
| Home | Sanctuary | `/dashboard` (shell 0) | → `/cycle`, `/fertility`, `/library`, log sheet | Orb day 14 Full Moon Peak; Bleeding In 14d/Nov 10; Peak Today → fertility; insight card → library; Mood/Pain/Notes QA → log sheet (today) |
| Home | Lunar Cycle Map | `/calendar` (shell 1) | → `/chart`, log sheet | Oct 2026 grid (10–13 fertile lav, 14–18 period pur); day tap → log bottom sheet; detail card Oct 15 Period Day 2; month card tap → chart |
| Log | Apothecary Log sheet | bottom drawer (no route) | — | `showLogSheet(date)`; flow single + moods/symptoms multi; per-date state in `LoggingProvider` (`DayLog` map); entries = calendar day tap, Sanctuary QA |
| Home | Lunar Records | `/insights` (shell 2) | → `/chart` | Bars M1–M7 (58–94%), 28.4d/5.2d, chronology Sept/Aug/July tags; trends card tap → chart |
| Home | Witch Profile | `/profile` (pushed, not a tab) | → `/settings`, `/reminders`, `/pregnancy`, `/binding` | Avatar HS, Scorpio Moon; toggles owned by Settings (Manage links); `Amulet Bells` 3rd card (live active count + button → reminders); gestation → pregnancy |
| Community | Coven Sanctum | `/coven` (shell 3, Magic tab) | — | Tabs Recent/Ancients; 3 posts (MC/CS/LG); FAB plum/gold plus |
| Cycle | Sovereign Blood | `/cycle` | — | Dark `Day 3 of 5` + 3 drops; volume single; pain slider L6; scribbles note |
| Pregnancy | Gestation Spells | `/pregnancy` | — | Dark Week 12 (Day 4), gold 30% bar, 196 days; Lime Size; tips |
| Alerts | Celestial Alerts | `/alerts` | — | `Whispers Received` inbox (sub + 4 alert cards with `IconBadge` tints); entry = bell top-right on all shell tabs |
| Profile | Amulet Reminders | `/reminders` | — | 5 configurable bells (`RemindersProvider`); header live `X of 5 bells active`; OFF collapses time/freq pills; entry = Profile `Amulet Bells` card button |
| Library | Apothecary Library | `/library` | → `/library/<slug>` | Search + 4 articles (Luteal, Herbs, Meditation, Fertility); tap → detail via `onGenerateRoute` |
| Library | Article Detail | `/library/<slug>` (dynamic) | — | Slug lookup (`articleById`, unknown → library); thumb gradient hero, cat/readTime, title, excerpt + body; back to library |
| Insights | BBT & Ovulation Chart | `/chart` | — | Reuses `TrendBars` + avg duo + note card; entries = Records trends card, CycleMap month card |
| Fertility | Fertility Window | `/fertility` | — | Orb variant (Peak Day) + window duo + TTC tips; entry = Sanctuary Peak card |
| Profile | Settings | `/settings` | — | App settings owned here: lunar switch, dark mode; gear/Manage top-right of Profile; reuses `SettingsRow` |
| Community | Coven Binding | `/binding` | — | HS✦KP header, invite input + send, 3 visibility switches |

### 4.2 App Navigation

Every route is canonical (no aliases) and reachable. Tree of how screens connect:

```
/ (Splash, Welcome)
├── "Awaken Your Power" → /onboarding ──→ /dashboard (stack cleared)
└── "Sign In" → /auth ──→ /onboarding ──→ /dashboard
/dashboard (MainScreen shell: Today/Calendar/Insights/Magic tabs)
├── tab 1 → /calendar ──→ day tap → log bottom sheet (that date); month card tap → /chart
├── tab 2 → /insights ──→ trends card tap → /chart
├── tab 3 → /coven
├── avatar (all tabs) → /profile ──┬── gear/Manage → /settings
│                                  ├── Amulet Bells card button → /reminders
│                                  ├── Gestation Spells row → /pregnancy
│                                  └── "1 Active" → /binding
├── bell (all tabs) → /alerts
├── Flow QA → /cycle; Mood/Pain/Notes QA → log bottom sheet (today)
├── Peak Today card → /fertility
└── insight card → /library ──→ article tap → /library/<slug>
Back rule: pushed screens pop (fallback `/dashboard`); shell tabs switch in place; sheet dismisses down.
```

### Screen 01: Splash, Welcome (`/`)

- **Purpose:** Establish brand trust, holistic health authority, and privacy focus.
- **Layout Structure:**
  - **Hero Emblem:** Circular emblem (`132x132pt`, `_Emblem`) — `#EFE2F8` outer disc, `96x96pt` radial core (`#4A1170 → #2A0740`) with gold `nightlight_round` glyph (`42pt`, `#D9A036`), centered in expanded upper half.
  - **Title Section:** Brand name `"Witchy"` (`type-display-l`, 34/800), tagline `"Track your cycle with magic"` (12, muted), gold star (`14pt`) below.
  - **Bottom Actions:** Primary CTA `"Awaken Your Power"` (`WitchyButton`, gold spark icon) → `/onboarding`; secondary row `"Already a witch? Sign In"` (pur link) → `/auth`. Foot padding `20/30`.

### Screen 02: Join the Coven (`/auth`)

- **Purpose:** Mock email + Apple/Google entry; no backend (`MockAuthProvider`, 600ms busy).
- **Layout Structure:**
  - **Header:** `MoonRow` (5 moon icons, center gold), `h2` `"Join the Coven"` (`type-h2`, 21/700), sub `"Create an account to align your inner rhythms with the cosmic tide."`.
  - **Form Fields:** `WitchyTextField` `"Astral Email"` (`your.essence@cosmic.com`) + `"Mystic Secret Key"` (prefilled `moonwater13`, eye peek toggle).
  - **Actions:** Primary `"Cast Invitation Scroll"` (busy spinner while mock sign-in) → `/onboarding`; divider row `"Or align via"`; secondary pair Apple / Google (`_Soc`, white bordered `12dp`).

### Screen 03: Set Your Rhythms (`/onboarding`)

- **Purpose:** Calibrate last bleed day, cycle + bleed lengths; persist via `PrefsService` (`OnboardingProvider.finish`).
- **Layout Structure:**
  - **Header:** `h2` `"Set Your Rhythms"` + sub `"Calibrate your lunar engine. When did your last bleeding phase commence?"`.
  - **Day Picker Card:** `WitchyCard` with `"Harvest Moon (Oct)"` serif header (chevron pair) + day strip `14–20` (`30pt` circles, selected day pur fill, default `17`).
  - **Slider Cards:** Two `WitchyCard`s hosting `WitchySliderRow` — `"Cycle duration (stardust tides)"` (`20–40`, default `28 Days`), `"Bleeding phase length"` (`2–10`, default `5 Days`).
  - **Bottom Action:** Spacer-pinned `"Bind Magic Link"` → `/dashboard` with stack cleared (`pushNamedAndRemoveUntil`).

### Screen 04: Sanctuary (`/dashboard`)

- **Purpose:** The core home screen; provides instant visibility into current cycle day, fertile status, hormone phase, and daily health insights.
- **Layout Structure:**
  - **Cycle Orb:** `CycleOrb` — `172pt` radial (`#4A1170 → #2A0740`) in conic ring (46% pur), `"CYCLE DAY"` gold caps + serif `14` + `"Full Moon Peak"`.
  - **Stat Duo:** `Bleeding In / 14 Days / Nov 10 · predicted` + pink `Fertility Window / Peak Today / High chance` (tap → `/fertility`).
  - **Quick Actions:** `"Log Today's Magic"` label + 4 `QuickAction` tiles — Flow → `/cycle`, Mood/Pain/Notes → log bottom sheet for today.
  - **Insight Card:** Dark card — gold spark + `"Daily Astral Insight"` + `WitchyTag.gold("Scorpio Moon")` + 11.5/1.55 body (tap → `/library`).

### Screen 05: Lunar Cycle Map (`/calendar`)

- **Purpose:** Comprehensive monthly view showing predicted periods, ovulation windows, and historical logs.
- **Layout Structure:**
  - **Calendar Card:** `WitchyCard` with `"October 2026"` serif header (chevron pair) + `CycleCalendar` 7-col grid (fertile `10–13` lav `#EBDCF7`, period `14–18` pur fill white text); day tap → log bottom sheet for that date; month header tap → `/chart`.
  - **Detail Card:** `"October 15, 2026"` + `WitchyTag.pink("Period Day 2")`; rows — pink drop `"Medium bleed flow intensity"`, pur heart `"Intuitive, reflective mood"`.

### Screen 06: Apothecary Log (bottom drawer, no route)

- **Purpose:** Per-day symptom logging without leaving context; opened by tapping a calendar day or Sanctuary QA.
- **Layout Structure:**
  - **Sheet Chrome:** `showLogSheet(context, date)` (`log_bottom_sheet.dart`) — `showModalBottomSheet`, `DraggableScrollableSheet` (`0.5–0.95`, initial `0.85`), top-rounded `24dp`, drag handle (`40x4` line fill).
  - **Header:** Serif `{Month} {day}, {year}` (17pt) + sub `"Select physical and mental essences flowing within you."`.
  - **Bleed Intensity:** Single-select `Wrap` of `WitchyChip` (`None/Light/Medium/Heavy`, pur fill when ON).
  - **Emotional Currents:** 2-col grid — Enchanted / Grounded / Shadowy / Restless (icon-tinted, multi-toggle).
  - **Somatic Echoes:** 2-col grid — Uterine Cramps / Headache / Bloating / Fatigue (multi-toggle).
  - **State:** Per-date `DayLog` map in `LoggingProvider` (key `yyyy-MM-dd`); new days seed `Medium` + Uterine Cramps + pain 6 + default scribble.

### Screen 07: Lunar Records (`/insights`)

- **Purpose:** Longitudinal analysis of cycle regularity, period duration variation, and luteal phase stability.
- **Layout Structure:**
  - **Trends Card:** `"Stardust Cycle Trends"` + `TrendBars` (`112pt`, 7 bars `58–94%` pur gradient, `M1–M7`); tap → `/chart`.
  - **Average Duo:** Centered `StatCard`s — `28.4 d / Average Cycle`, `5.2 d / Average Bleed`.
  - **Chronology Card:** `"Chronology of Bleeds"` + 3 `_Crow` rows (`Sept 14–19 / 5 Days / On Time`, `Aug 16–21 / On Time`, `July 19–23 / 4 Days / Short` pink tag).

### Screen 08: BBT & Ovulation Chart (`/chart`)

- **Purpose:** Advanced clinical-grade BBT graphing to visually confirm ovulation via biphasic temperature shifts.
- **Layout Structure:**
  - **App Bar:** `WitchyAppBar("BBT Chart")`, back pops (fallback `/dashboard`).
  - **Shift Card:** `"Biphasic Temperature Shift"` + reused `TrendBars`.
  - **Average Duo:** `36.4° / Pre-shift average` + `+0.4° / Post-shift rise`.
  - **Explainer Card:** Dark card — serif `"How to read this"` + 11.5/1.55 lav body on three-morning sustained rise.
  - **Entries:** Records trends card, CycleMap month card. Full keypad/chart deferred.

### Screen 09: Fertility Window (`/fertility`)

- **Purpose:** Dedicated view for users Trying to Conceive (TTC), highlighting peak conception probability days.
- **Layout Structure:**
  - **App Bar:** `WitchyAppBar("Fertility Window")`, back pops.
  - **Peak Orb:** `CycleOrb` variant — serif `14` + `"Peak Day"` phase.
  - **Window Duo:** Pink `Conception chance / Peak Today / Ovulation likely` + `Window / 5 Days / Day 12 – Day 16`.
  - **Tips Card:** Dark card — serif `"TTC Tips"` + cervical-fluid/LH-surge guidance body.
  - **Entry:** Sanctuary Peak Today card. LH/camera reader deferred.

### Screen 10: Gestation Spells (`/pregnancy`)

- **Purpose:** Replaces the standard cycle dashboard when Pregnancy Mode is enabled; tracks fetal development and maternal health.
- **Layout Structure:**
  - **App Bar:** `WitchyAppBar("Gestation Spells", action: favorite_border)`.
  - **Progress Card:** Dark card — gold caps `"GESTATION SANCTUARY"`, serif `"Week 12 (Day 4)"` (21pt), gold `30%` progress bar (`6pt`, white 22% track), `"196 days until arrival portal opens"` (10.5, orb-sub).
  - **Comparison Card:** `"Spiritual Comparison"` + `WitchyTag("Lime Size")`; search `IconBadge` + `"Your little spirit matches a ripe Lime..."` body.
  - **Tips Card:** `"Astral Gestation Tips"` + first-trimester iron/mantra body (11.5/1.55).

### Screen 11: Apothecary Library (`/library`)

- **Purpose:** Provide medically sound, holistic self-care, nutritional, and herbal guidance tailored to the current menstrual cycle phase.
- **Layout Structure:**
  - **App Bar:** `WitchyAppBar("Apothecary Library")`, back pops.
  - **Search:** `WitchyTextField` (`"Search spells, herbs, anatomy..."`, search lead).
  - **Article Cards:** 4 `WitchyCard` rows — `62x62pt` gradient thumb + gold `CAT` caps + `readTime` + serif title (ellipsis) + excerpt (ellipsis): Luteal Phase (ANATOMY, 5 min), Cramp Herbs (BOTANICAL, 8 min), Moon Meditation (MINDFULNESS, 12 min), Fertility Window (LUNAR CYCLE, 6 min); tap → `/library/<slug>`.

### Screen 12: Article Detail (`/library/<slug>`)

- **Purpose:** Long-form reading interface for evidence-based reproductive health articles and clinical guides.
- **Layout Structure:**
  - **App Bar:** `WitchyAppBar("Wellness Detail")`, back → `/library`.
  - **Hero Card:** `140pt` gradient hero (`12dp` radius) + category `WitchyTag` / readTime row + serif title (18pt) + excerpt sub.
  - **Body Card:** Single practice paragraph (tea/rest/breath + log prompt, 11.5/1.55). Slug lookup via `articleById`; unknown slug falls back to `/library`.

### Screen 13: Witch Profile (`/profile`)

- **Purpose:** Identity + alignments hub; gateway to settings/reminders/pregnancy/binding.
- **Layout Structure:**
  - **App Bar:** `"Witch Profile"` — back top-left → home (fallback `/dashboard`), gear top-right → `/settings`.
  - **Identity Header:** `WitchyAvatar` HS `84pt` (white ring + gold halo), serif `"High Priestess Selene"` (18pt), gold caps `"SCORPIO MOON · THIRD CYCLE"`, gold star.
  - **Lunar Alignments Card:** Statics `29 Days / 5 Days` + `Notification Preferences → Manage` (→ `/settings`).
  - **Apothecary Settings Card:** `Appearance → Manage` (→ `/settings`), `Gestation Spells → View` (→ `/pregnancy`), `Cosmic Partner Bond → 1 Active` (→ `/binding`).
  - **Amulet Bells Card:** `"Amulet Bells"` header + live `"X of 5 bells active"` (watches `RemindersProvider`) + full-width `WitchyButton("Open Amulet Reminders")` → `/reminders`.
  - **Footer:** Centered `"Witchy App / Version 1.2.4 · Made with celestial energy"` (9.5, placeholder). Settings owns all toggles — Profile only links out.

### Screen 14: Settings (`/settings`)

- **Purpose:** App-level preferences (notifications, appearance).
- **Layout Structure:**
  - **App Bar:** `"Settings"`, back → `/profile` (pop, fallback `/profile`).
  - **Alignments Card:** `"Lunar Alignments"` + two `SettingsRow`s with pur switches (`SettingsProvider`) — `Receive Lunar Notifications` (ON), `Dark Magic Mode` (OFF).

### Screen 15: Sovereign Blood (`/cycle`)

- **Purpose:** Bleed-day detail: volume, pain, notes. Binds today's `DayLog`.
- **Layout Structure:**
  - **App Bar:** `WitchyAppBar("Sovereign Blood")`, back pops.
  - **Phase Card:** Dark card — gold caps `"SHEDDING PHASE"`, serif `"Day 3 of 5"` (23pt), 3 gold drops.
  - **Volume Card:** `"Bleeding Volume"` + single-select chips (`Spotting/Light/Medium/Heavy`).
  - **Pain Card:** `WitchySliderRow` `"Uterine Contraction Pain"` (`0–10`, `"Level 6"`).
  - **Scribbles Card:** `"Grimoire Scribbles"` + field-bg note container (chamomile/raspberry text).

### Screen 16: Celestial Alerts (`/alerts`)

- **Purpose:** The cosmos' received whispers, one inbox.
- **Layout Structure:**
  - **App Bar:** `WitchyAppBar("Celestial Alerts")`, back pops.
  - **Inbox Header:** Serif `"Whispers Received"` + sub `"The cosmos whispers its reminders. Align your biological temple."`.
  - **Alert Cards:** 4 `WitchyCard` rows — tinted `IconBadge` + serif title + muted timestamp + 11/1.55 body: Period Commencing (pink drop, 2h), Fertility Window Peak (gold moon, 1d), Magical Log Missing (quill, 2d), Astrological Milestone (star, 3d).
  - **Entry:** Bell top-right on all shell tabs.

### Screen 17: Amulet Reminders (`/reminders`)

- **Purpose:** Calibrate mystical bells for upcoming tides.
- **Layout Structure:**
  - **App Bar:** `WitchyAppBar("Amulet Reminders")`, back pops.
  - **Header:** Sub `"Calibrate mystical bells to warn you of upcoming tides."` + pur `"X of 5 bells active"` live count.
  - **Bell Cards:** 5 `WitchyCard`s — tinted `IconBadge` + serif title + muted subtitle + pur switch; when ON, `InfoPill` pair (clock time + freq): Log Period Commencing (09:00 AM / Daily during peak), Take Cosmic Pill (08:30 AM / Every day), Fertility Window Alert (07:00 AM / Window start), PMS Warning (06:00 PM / 3 days prior), Somatic Hydration (Hourly / Daytime).
  - **Entry:** Profile `Amulet Bells` card button.

### Screen 18: Coven Sanctum (`/coven`)

- **Purpose:** Anonymous community whispers + wisdom tabs.
- **Layout Structure:**
  - **Segment Tabs:** `Recent Whispers` / `Ancients' Wisdom` (`tabBg` pill, ON = plum fill).
  - **Post Cards:** 3 `WitchyCard`s — avatar initials + serif author + muted meta + tag + 11/1.55 body + likes/comments footer (MC 24/8 Herbal Remedies, CS 42/15 Dream Work, LG 18/3 Cosmic Cycle).
  - **FAB:** `50pt` plum-gradient circle, gold `+`.

### Screen 19: Coven Binding (`/binding`)

- **Purpose:** Invite partners/coven to shared celestial map + visibility scopes.
- **Layout Structure:**
  - **App Bar:** `WitchyAppBar("Coven Binding")`, back pops.
  - **Invite Header Card:** Centered HS ✦(gold spark) KP avatars + serif `"Bind Cosmic Partners"` (15pt) + share-map sub copy.
  - **Invite Card:** `"Invite Cosmic Bond"` + `WitchyTextField` (`partner@cosmic.com`, mail lead) + `WitchyButton("Send Binding Scroll")`.
  - **Visibility Card:** `"Scroll Visibility"` + 3 pur-switch `SettingsRow`s (`SettingsProvider`) — Share Bleeding Predictions (ON), Share Fertile Windows (ON), Share Anonymized Symptom Log (OFF).
