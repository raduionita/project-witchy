# WITCHY: Mobile Design System & UI/UX Specification
**Document Version:** 1.1.0
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
- **BBT Quick-Entry Keypad:** deferred — `/insights/chart` v1 uses slider + trend bars reusing `WitchySliderRow`/`TrendBars`; no custom keypad.
- **LH / Ovulation Test Reader Widget:** deferred — `/fertility/window` v1 uses orb + duo stat cards; no camera reader.

### 3.3 Navigation Patterns

- Bottom nav: 5 tabs `Today/Calendar/Log/Insights/Magic` (`WitchyBottomNav`), pur active + 18×2.5 underline; Log icon `add_circle_outline`, Magic icon `auto_awesome` → `CovenScreen` tab; labels frozen.
- App bar: `WitchyAppBar` 50px, serif 16.5 centered; shell tabs: **leading `person_outline` → `/profile`**, **action bell `notifications_outlined` → `/alerts`**; all pushed screens default **leading back `arrow_back`** (pop, `/dashboard` fallback); `/profile` leading back → home, action gear → `/profile/settings`; `/profile/settings` leading back → `/profile`.
- Pushes: Sanctuary QA → `/cycle/blood`, `/dailies`; Peak card → `/fertility/window`; Records filter → `/insights/chart`; Library card → `/wellness/detail`; Profile bond → `/community/binding`, gear → `/profile/settings`.
- Legacy aliases kept one release: `/`, `/join`, `/rhythms`, `/log`, `/blood`, `/library`, `/gestation`, `/reminders`, `/binding`, `/shell` → canonical.

---

## 4. Screen-by-Screen UI/UX Specifications

### 4.1 Screen Architecture

| User Journey Phase | Core Screen (title frozen) | Route | Connected / Sub-Screens | Dynamic Routing & Behavior |
| :--- | :--- | :--- | :--- | :--- |
| Entry | Splash, Welcome | `/welcome` (alias `/`) | → `/onboarding`, `/auth` | CTA `Awaken Your Power` → onboarding; `Sign In` → auth |
| Entry | Join the Coven | `/auth` (alias `/join`) | → `/onboarding` | Mock sign-in (600ms busy) → onboarding |
| Onboarding | Set Your Rhythms | `/onboarding` (alias `/rhythms`) | → `/dashboard` | Day 17 default, 28d/5d sliders, persist, `pushNamedAndRemoveUntil` shell |
| Home | Sanctuary | `/dashboard` (shell 0) | → `/cycle/blood`, `/dailies`, `/fertility/window`, `/alerts` | Orb day 14 Full Moon Peak; Bleeding In 14d/Nov 10; Peak Today → fertility |
| Home | Lunar Cycle Map | `/calendar` (shell 1) | → `/insights/chart` | Oct 2026 grid (10–13 fertile lav, 14–18 period pur); detail card Oct 15 Period Day 2; filter → chart |
| Home | Apothecary Log | `/dailies` (shell 2, alias `/log`) | — | Flow single + moods/symptoms multi; state in `LogProvider` |
| Home | Lunar Records | `/insights/overview` (shell 3) | → `/insights/chart` | Bars M1–M7 (58–94%), 28.4d/5.2d, chronology Sept/Aug/July tags |
| Home | Witch Profile | `/profile` (pushed, not a tab) | → `/profile/settings`, `/profile/reminders`, `/community/binding` | Avatar HS, Scorpio Moon; back top-left → home, gear top-right → settings |
| Community | Coven Sanctum | `/community/coven` (shell 4, Magic tab) | — | Tabs Recent/Ancients; 3 posts (MC/CS/LG); FAB plum/gold plus |
| Cycle | Sovereign Blood | `/cycle/blood` (alias `/blood`) | — | Dark `Day 3 of 5` + 3 drops; volume single; pain slider L6; scribbles note |
| Pregnancy | Gestation Spells | `/pregnancy/dashboard` (alias `/gestation`) | — | Dark Week 12 (Day 4), gold 30% bar, 196 days; Lime Size; tips |
| Alerts | Celestial Alerts | `/alerts` | — | 4 cards (Period, Fertility, Log Missing, Milestone); entry = bell top-right on all shell tabs |
| Library | Apothecary Library | `/wellness/library` (alias `/library`) | → `/wellness/detail` | Search + 4 articles (Luteal, Herbs, Meditation, Fertility); tap → detail |
| Library | Article Detail | `/wellness/detail` (new) | — | Thumb gradient hero, cat/readTime, title, excerpt + body; back to library |
| Insights | BBT & Ovulation Chart | `/insights/chart` (new) | — | Reuses `TrendBars` + avg duo + note card; entry = Records filter icon |
| Fertility | Fertility Window | `/fertility/window` (new) | — | Orb variant (Peak Day) + window duo + TTC tips; entry = Sanctuary Peak card |
| Profile | Wearables Settings | `/profile/settings` (new) | — | Gear top-right of Profile; HealthKit/Google Fit + temp wearable toggles, lunar switch, dark mode; reuses `SettingsRow` |
| Profile | Amulet Reminders | `/profile/reminders` (alias `/reminders`) | — | 5 bells (09:00 Daily peak, 08:30 Every day, 07:00 Window, 18:00 3d prior, Hourly Daytime); OFF collapses pills |
| Community | Coven Binding | `/community/binding` (alias `/binding`) | — | HS✦KP header, invite input + send, 3 visibility switches |

### Screen 01: Splash, Welcome (`/welcome`)

- **Purpose:** Establish brand trust, holistic health authority, and privacy focus.
- Layout: centered emblem (132 outer `#EFE2F8` / 96 radial `#4A1170→#2A0740` / gold moon), `Witchy` 34/800, `Track your cycle with magic` 12 muted, gold star; foot CTA `Awaken Your Power` → `/onboarding`, `Sign In` → `/auth`.

### Screen 02: Join the Coven (`/auth`)

- **Purpose:** Mock email + Apple/Google entry; no backend.
- Layout: `MoonRow`, h2 `Join the Coven`, sub, Astral Email + Mystic Secret Key (peek), `Cast Invitation Scroll` → `/onboarding`, `Or align via` + Apple/Google soc buttons.

### Screen 03: Set Your Rhythms (`/onboarding`)

- **Purpose:** Calibrate last bleed day, cycle + bleed lengths; persist to `PrefsService`.
- Layout: h2 + sub; Harvest Moon (Oct) day strip 14–20 (17 ON); sliders 20–40→28d, 2–10→5d; `Bind Magic Link` → `/dashboard` (clear stack).

### Screen 04: Sanctuary (`/dashboard`)

- **Purpose:** The core home screen; provides instant visibility into current cycle day, fertile status, hormone phase, and daily health insights.
- Layout: orb 14 Full Moon Peak; duo Bleeding In 14d + Peak Today (tap → `/fertility/window`); `Log Today's Magic` QA (Flow → `/cycle/blood`, rest → `/dailies`); dark insight Scorpio Moon.

### Screen 05: Lunar Cycle Map (`/calendar`)

- **Purpose:** Comprehensive monthly view showing predicted periods, ovulation windows, and historical logs.
- Layout: Oct 2026 calendar (`CycleCalendar`), fertile 10–13 / period 14–18; detail card Oct 15 + mood rows; filter action → `/insights/chart`.

### Screen 06: Apothecary Log (`/dailies`)

- **Purpose:** Efficient, friction-free daily data entry for all reproductive health biometrics.
- Layout: `Log Today's Energy` + sub; Bleed Intensity single; Emotional Currents + Somatic Echoes multi grids; state in `LogProvider` (Medium, Uterine Cramps default).

### Screen 07: Lunar Records (`/insights/overview`)

- **Purpose:** Longitudinal analysis of cycle regularity, period duration variation, and luteal phase stability.
- Layout: `Stardust Cycle Trends` bars; 28.4d/5.2d duo; `Chronology of Bleeds` 3 rows with On Time/Short tags.

### Screen 08: BBT & Ovulation Chart (`/insights/chart`)

- **Purpose:** Advanced clinical-grade BBT graphing to visually confirm ovulation via biphasic temperature shifts.
- v1: reuses trend bars + avg duo + explainer card; full keypad/chart deferred. Entry: Records filter icon.

### Screen 09: Fertility Window (`/fertility/window`)

- **Purpose:** Dedicated view for users Trying to Conceive (TTC), highlighting peak conception probability days.
- v1: orb variant `Peak Day`, window duo (Peak/High chance), TTC tips card reusing kit. Entry: Sanctuary Peak Today card.

### Screen 10: Gestation Spells (`/pregnancy/dashboard`)

- **Purpose:** Replaces the standard cycle dashboard when Pregnancy Mode is enabled; tracks fetal development and maternal health.
- Layout: dark Week 12 (Day 4) + 30% gold bar + 196 days; `Spiritual Comparison` Lime Size; `Astral Gestation Tips`.

### Screen 11: Apothecary Library (`/wellness/library`)

- **Purpose:** Provide medically sound, holistic self-care, nutritional, and herbal guidance tailored to the current menstrual cycle phase.
- Layout: search `Search spells, herbs, anatomy...`; 4 article cards (thumb gradient, CAT, readTime, title, excerpt); tap → `/wellness/detail`.

### Screen 12: Article Detail (`/wellness/detail`)

- **Purpose:** Long-form reading interface for evidence-based reproductive health articles and clinical guides.
- Layout: 62dp thumb hero large, category + readTime, serif title, excerpt + 2 body paragraphs (mock from `MockData.articles`), back chevron; same card/button kit.

### Screen 13: Witch Profile (`/profile`)

- **Purpose:** Identity + alignments hub; gateway to settings/reminders/binding.
- Layout: HS big avatar gold ring, `High Priestess Selene`, `SCORPIO MOON · THIRD CYCLE`; `Lunar Alignments` (29d/5d/notifications); `Apothecary Settings` (dark mode, `1 Active` → `/community/binding`); footer v1.2.4; **back top-left → home, gear top-right → `/profile/settings`** (pushed route, shell avatar entry).

### Screen 14: Wearables Settings (`/profile/settings`)

- **Purpose:** Manage synchronization with external health ecosystems and smart temperature wearables.
- Layout: `Health Integration` card (HealthKit, Google Fit, Temp wearable switches), `Lunar Alignments` + `Apothecary Settings` rows reused; all `SettingsRow` + pur switches.

### Screen 15: Sovereign Blood (`/cycle/blood`)

- **Purpose:** Bleed-day detail: volume, pain, notes.
- Layout: dark `Day 3 of 5` + drops; `Bleeding Volume` single (Heavy ON); pain slider L6; `Grimoire Scribbles` note field-bg card.

### Screen 16: Celestial Alerts (`/alerts`)

- **Purpose:** The cosmos whispers its reminders. Align your biological temple.
- Layout: sub + 4 alert cards with `IconBadge` tints; global entry = bell top-left.

### Screen 17: Coven Sanctum (`/community/coven`)

- **Purpose:** Anonymous community whispers + wisdom tabs.
- Layout: `Recent Whispers`/`Ancients' Wisdom` tabs; 3 posts with avatar/meta/tag/likes/comments; FAB plum/gold `+`.

### Screen 18: Amulet Reminders (`/profile/reminders`)

- **Purpose:** Calibrate mystical bells for upcoming tides.
- Layout: sub + 5 reminder cards with switch; OFF collapses time/freq pills (`InfoPill` clock + freq).

### Screen 19: Coven Binding (`/community/binding`)

- **Purpose:** Invite partners/coven to shared celestial map + visibility scopes.
- Layout: HS✦KP header + copy; invite input + `Send Binding Scroll`; `Scroll Visibility` 3 switches.
