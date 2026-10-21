# AGENTS.md - Period Tracker Flutter App Project

This document provides context, guidelines, and project structure information to help AI assistants understand and contribute effectively to this Dart + Flutter period tracking application.

---

## Project Overview

**Project Name**: Witchy 
**Description**: A comprehensive period tracker and reproductive health app built with Flutter/Dart, similar to Flo.  
**Target Users**: Individuals tracking menstrual cycles, fertility, pregnancy, and reproductive health.
**Platform**: Mobile-first (iOS, Android, Web via Flutter)

### Core Mission
Provide users with **private, accurate, and empowering reproductive health tracking** with a focus on user privacy and evidence-based health information.

---

## Rules

- Do NOT use em dash (—), ONLY hyphens (-)
- NEVER `git commit`, `git add` or `git push`
- Do NOT bundle multiple models, provides, widgets, screens, components into a single file, each in its own file.
- `shared_preferences` and `provider` for storage and state management
- D0 NOT Firebase, keep data local
- methods that return a widget should be prefixed with `_build` and placed above the `build()` method
- `build()` methods stay at the bottom of the class
- Before calling work complete: `flutter analyze` zero issues, `flutter test` green, `flutter build apk --debug` succeeds.

---

## Technology Stack
**Flutter** - Cross-platform mobile UI framework
**Dart** - Programming language for Flutter
**Provider** - State management
**Authentication** - Google and Apple Sign-In, (NO Firebase)

---

## File Structure Conventions

### Naming Conventions
- **Files**: `snake_case.dart` (e.g., `period_tracker_screen.dart`)
- **Classes**: `PascalCase` (e.g., `PeriodTrackerScreen`)
- **Functions/Variables**: `camelCase` (e.g., `calculateCycleLength()`)
- **Constants**: `kPascalCase` (e.g., `kDefaultCycleLength`)
- **Private members**: Leading underscore (e.g., `_internalValue`)

### Import Organization
```dart
// Dart imports
import 'dart:async';
import 'dart:convert';

// Flutter imports
import 'package:flutter/material.dart';

// Package imports
import 'package:provider/provider.dart';

// Relative imports
import '../models/period_cycle.dart';
import '../services/period_tracking_service.dart';
```

---

## Running the App

```bash
flutter pub get
flutter run
```

---

## Plans & Changelog

- `CHANGES.md` is the changelog: one entry per shipped update, `## Update N - YYYY.MM.DD - Title`, appended at the bottom, oldest first.
- Shipped entries are append-only; fix typos only, never rewrite history.
- Open work never lives in `CHANGES.md`; it lives in `plans/`.
- `plans/` holds one file per plan, named `YYYY.MM.DD.<slug>.md`.
- A plan is only done when the matching update entry is added to `CHANGES.md` with its gate results.
- NEVER execute plans from this (`plans/`) folder directly - only the user can ask for them.

---

## Project Structure

```
lib/
├── main.dart
├── common/
├── models/
├── navigation/
├── providers/
├── screens/
├── services/
├── theme/
└── widgets/
assets/
├── icons/
├── images/
├── legal/
└── svgs/
test/
```
