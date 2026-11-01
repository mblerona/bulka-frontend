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

**Entry point**: `lib/main.dart` — boots `BulkaApp` with `MaterialApp.router` (GoRouter), Material 3 and the custom theme. Debug builds start on the dev screen launcher (`/dev`), release builds on Splash (`/`).

**Core structure**:
- `lib/core/constants/` — `AppColors` and `AppStrings` (all user-facing text; `AppStrings` is generated and returns the current language)
- `lib/l10n/` — translations: `app_mk.arb` (template), `app_en.arb`, `app_sq.arb`, plus the generated `app_localizations*.dart`
- `lib/core/l10n/locale_controller.dart` — current language (MK/SQ/EN), saved choice, phone language on first launch
- `lib/core/theme/` — `AppTheme.lightTheme` with Montserrat font
- `lib/models/` — `UserRole` enum (`buyer`, `owner`)
- `lib/screens/` — one folder per screen (e.g. `splash_screen/`, `choose_role_screen/`)
- `lib/widgets/` — shared reusable widgets

**Routing**: `go_router`. All routes are in `lib/core/routing/app_router.dart`; all paths and path helpers in `lib/core/routing/app_routes.dart` (`AppRoutes`) — navigate with `context.go`/`context.push(AppRoutes.x)`, never hard-coded strings or `MaterialPageRoute`.
- Tourist and Provider tabs are `StatefulShellRoute`s (`TouristShell`/`ProviderShell` in `lib/widgets/app_bottom_nav.dart`) that draw the one shared bottom nav; each tab keeps its own history. Screens must not add their own `bottomNavigationBar`. Messages (and the Provider's Profile) open full screen.
- Screens that need an object get its id in the URL (e.g. `/home/listings/:listingId`); the route looks it up and shows `RouteNotFoundScreen` if it's missing. Only sign-up data (contains the password) travels as `extra`.
- To leave a tab cleared before jumping elsewhere (e.g. after booking), use `resetTabThenGo`.
- New screens also get a `DevScreenEntry` in `lib/dev/dev_launcher_screen.dart`; `test/all_screens_localized_test.dart` then checks it in every language.

**State management**: None yet — plain `StatefulWidget` where needed.

## Conventions

- All user-facing strings are read through `AppStrings`, never hardcoded inline. To add one: add the key to all three `.arb` files in `lib/l10n/`, then run `flutter gen-l10n` and `dart run tool/gen_app_strings.dart`. Text that's the same in every language (symbols, emoji) goes in the constants at the bottom of `AppStrings`.
- Translated `AppStrings` values aren't `const`; lists of labels must be getters (not `const`/`final` fields) so they follow a language switch. Store choices as values (enums, indexes), never as translated text.
- Screen folders live under `lib/screens/<screen_name>/` and contain a single `<screen_name>.dart` file.
- Assets are under `assets/images/` with subfolders per screen (e.g. `assets/images/SplashScreen/`).
- Package name / import prefix: `package:bulka_frontend/`.

## Key Dependencies

- Flutter SDK, Dart ^3.11.0
- `cupertino_icons` for icons
- `flutter_lints` for linting (rules in `analysis_options.yaml`)
- Custom font: Montserrat (400, 500, 700)
