# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Bulka is a Flutter mobile app for rural tourism in Macedonia. It supports two user roles: Tourist (buyer) and Property Owner. The UI language is Macedonian.

## Common Commands

```bash
flutter pub get          # Install dependencies
flutter run              # Run on connected device/emulator
flutter build apk        # Build Android APK
flutter analyze          # Static analysis
dart format lib/         # Format code
flutter test             # Run tests
flutter test test/widget_test.dart  # Run single test file
```

## Architecture

**Entry point**: `lib/main.dart` — boots `BulkaApp` with `MaterialApp`, Material 3, custom theme, and `SplashScreen` as home.

**Core structure**:
- `lib/core/constants/` — `AppColors` and `AppStrings` (all user-facing text is in Macedonian, defined here)
- `lib/core/theme/` — `AppTheme.lightTheme` with Montserrat font
- `lib/models/` — `UserRole` enum (`buyer`, `owner`)
- `lib/screens/` — one folder per screen (e.g. `splash_screen/`, `choose_role_screen/`)
- `lib/widgets/` — shared reusable widgets

**Routing**: No routing library yet; navigation is done via `MaterialApp.home` and `Navigator.push`.

**State management**: None yet — plain `StatefulWidget` where needed.

## Conventions

- All user-facing strings go in `AppColors` / `AppStrings` in `lib/core/constants/`, never hardcoded inline.
- Screen folders live under `lib/screens/<screen_name>/` and contain a single `<screen_name>.dart` file.
- Assets are under `assets/images/` with subfolders per screen (e.g. `assets/images/SplashScreen/`).
- Package name / import prefix: `package:bulka_frontend/`.

## Key Dependencies

- Flutter SDK, Dart ^3.11.0
- `cupertino_icons` for icons
- `flutter_lints` for linting (rules in `analysis_options.yaml`)
- Custom font: Montserrat (400, 500, 700)
