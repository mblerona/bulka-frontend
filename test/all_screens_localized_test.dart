import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bulka_frontend/core/theme/app_theme.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bulka_frontend/core/constants/app_strings.dart';
import 'package:bulka_frontend/core/l10n/locale_controller.dart';
import 'package:bulka_frontend/core/routing/app_router.dart';
import 'package:bulka_frontend/dev/dev_launcher_screen.dart';
import 'package:bulka_frontend/l10n/app_localizations.dart';

import 'test_helpers.dart';

/// Renders every screen from the dev launcher in every language on a
/// typical phone, so text that's longer in English or Albanian than in
/// Macedonian can't overflow unnoticed.
void main() {
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await initializeDateFormatting();
    await loadAppFonts();
  });

  for (final locale in AppLocalizations.supportedLocales) {
    group('[${locale.languageCode}]', () {
      setUp(() => LocaleController.instance.setLanguage(locale.languageCode));

      test('AppStrings returns this language', () {
        expect(
          AppStrings.loginTitle,
          lookupAppLocalizations(locale).loginTitle,
        );
      });

      for (final entry in DevLauncherScreen.allEntries) {
        testWidgets('${entry.label} has no overflow', (tester) async {
          await usePhoneScreen(tester);

          // Route entries open through the real router, so tab screens are
          // checked together with the shared bottom nav bar.
          final location = entry.location;
          await tester.pumpWidget(
            location != null
                ? MaterialApp.router(
                    theme: AppTheme.lightTheme,
                    locale: locale,
                    supportedLocales: AppLocalizations.supportedLocales,
                    localizationsDelegates:
                        AppLocalizations.localizationsDelegates,
                    routerConfig: createAppRouter(
                      initialLocation: location(),
                      initialExtra: entry.extra,
                    ),
                  )
                : MaterialApp(
                    theme: AppTheme.lightTheme,
                    locale: locale,
                    supportedLocales: AppLocalizations.supportedLocales,
                    localizationsDelegates:
                        AppLocalizations.localizationsDelegates,
                    home: Builder(builder: entry.builder!),
                  ),
          );
          // Not pumpAndSettle: some screens have looping animations.
          await tester.pump(const Duration(milliseconds: 500));
          expect(tester.takeException(), isNull);
        });
      }
    });
  }
}
