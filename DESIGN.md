# WITCHY: Mobile Design System & UI/UX Specification
**Document Version:** 1.0.0
**Product Name:** Witchy — Comprehensive Menstrual, Fertility & Reproductive Health Tracker  
**Target Platforms:** iOS, Android, web (Cross-Platform Mobile App)  
**Primary Aesthetic:** ?
**Reference Mockup:** `resources/Qwen_html_20260917_r3vw6tc9n.html` (authoritative for colors, radii, type)  

---

## 1. Executive Summary & Product Vision

**Witchy** is a comprehensive, beautifully designed women’s health application that re-frames reproductive health tracking as an empowering, intuitive, and holistic daily practice. By bridging clinical-grade biometric logging (menstrual flow, basal body temperature, ovulation hormones, gestational milestones) with an elegant, celestial-inspired aesthetic, Witchy allows users to understand the natural rhythms of their bodies without the sterile, patronizing feel of traditional medical apps.

### 1.1 Core UX Objectives

?

---

## 2. Design System Architecture & Foundational Tokens

### 2.0 COLOR TOKEN VISUAL HARMONY
`#??????` |  Color name       | Usage


### 2.1 Color Palette & Design Tokens
Witchy uses a dark purple-led palette per mockup: ?

| Token Name | Hex Value | RGB / Opacity | Usage & Application | Contrast vs. Surface |
| :--- | :--- | :--- | :--- | :--- |
| `color-primary` | `#??????` | `rgb(1, 2, 3)` | Primary buttons, hero dark cards, period days, active pills, chart bars, toggles ON | 12.9:1 (AAA) |


### 2.2 Typography System
?

| Style Token | Font Family | Weight | Size (pt/dp) | Line Height | Letter Spacing | Usage Examples |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| `type-display-l` | ?


### 2.3 Spacing, Grid & Layout System
?


### 2.4 Corner Radii & Elevation
?

---

## 3. Component Library & UI Patterns

### 3.1 Cycle & Fertility Status Badges
* **Period Day Badge:** ?
* **Fertile Window Badge:** ?
* **Ovulation Peak Badge:** ?
* **Status Cards:** ?
* **Info Banner:** ?

### 3.2 Biometric Logging Controls
* **Flow Severity Selector:** ?
* **Symptom Multi-Select Pills:** ?
* **Form Inputs:** ?
* **Cycle Slider:** ?
* **Primary Button:** ?
* **Secondary Button:** ?
* **BBT Quick-Entry Keypad:** ?
* **LH / Ovulation Test Reader Widget:** ?

### 3.3 Navigation Patterns
?

---

## 4. Screen-by-Screen UI/UX Specifications

This section details the layout, functional components, data schemas, and user flows for all **screens** in the comprehensive health tracking architecture.

### 4.1 App Navigation & Screen Architecture

| User Journey Phase | Core Screen | Connected / Sub-Screens | Dynamic Routing & Behavior |
| :--- | :--- | :--- | :--- |

---

### Screen 01: Splash, Welcome (`/welcome`)
* **Purpose:** Establish brand trust, holistic health authority, and privacy focus.

---

### Screen 02: Auth (`/auth`)
* **Purpose:** 

---

### Screen 03: Primary Health Goal & Setup (`/onboarding`)
* **Purpose:** ?

---

### Screen 04: Daily Dashboard & Cycle Clock (`/dashboard`)
* **Purpose:** The core home screen; provides instant visibility into current cycle day, fertile status, hormone phase, and daily health insights.

---

### Screen 05: Interactive Menstrual & Fertility Calendar (`/calendar`)
* **Purpose:** Comprehensive monthly/yearly view showing predicted periods, ovulation windows, and historical logs.

---

### Screen 06: Daily Biometric & Symptom Log (`/dailies`)
* **Purpose:** Efficient, friction-free daily data entry for all reproductive health biometrics.

---

### Screen 07: Cycle Trends & Length Analytics (`/insights/overview`)
* **Purpose:** Longitudinal analysis of cycle regularity, period duration variation, and luteal phase stability.

---

### Screen 08: Basal Body Temperature (BBT) & Ovulation Charting (`/insights/chart`)
* **Purpose:** Advanced clinical-grade BBT graphing to visually confirm ovulation via biphasic temperature shifts.

---

### Screen 09: Fertility & Ovulation Window Predictor (`/fertility/window`)
* **Purpose:** Dedicated view for users Trying to Conceive (TTC), highlighting peak conception probability days.

---

### Screen 10: Pregnancy & Gestational Tracker (`/pregnancy/dashboard`)
* **Purpose:** Replaces the standard cycle dashboard when Pregnancy Mode is enabled; tracks fetal development and maternal health.

---

### Screen 11: Holistic Wellness & Cycle-Syncing Library (`/wellness/library`)
* **Purpose:** Provide medically sound, holistic self-care, nutritional, and herbal guidance tailored to the current menstrual cycle phase.

---

### Screen 12: Educational Guide & Clinical Reference Detail (`/wellness/detail`)
* **Purpose:** Long-form reading interface for evidence-based reproductive health articles and clinical guides.

---

### Screen 13: Health Integration & Wearables (`/settings`)
* **Purpose:** Manage synchronization with external health ecosystems and smart temperature wearables.
