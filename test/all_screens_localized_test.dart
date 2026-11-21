import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bulka_frontend/core/constants/app_strings.dart';
import 'package:bulka_frontend/core/l10n/app_locale.dart';
import 'package:bulka_frontend/core/routing/app_router.dart';
import 'package:go_router/go_router.dart';
import 'screen_catalog.dart';
import 'package:bulka_frontend/l10n/app_localizations.dart';
import 'package:bulka_frontend/main.dart';

import 'test_helpers.dart';

/// Renders every screen from [ScreenCatalog] in every language on a
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
      test('AppStrings returns this language', () {
        AppLocale.apply(locale);
        expect(
          AppStrings.loginTitle,
          lookupAppLocalizations(locale).loginTitle,
        );
      });

      for (final entry in ScreenCatalog.allEntries) {
        testWidgets('${entry.label} has no overflow', (tester) async {
          await usePhoneScreen(tester);

          // The whole app (blocs, router, shared bottom nav), opened from
          // the catalog the same way a tap on the entry would.
          final router = createAppRouter(
            initialLocation: ScreenCatalog.path,
            extraRoutes: [
              GoRoute(
                path: ScreenCatalog.path,
                builder: (context, state) => const ScreenCatalog(),
              ),
            ],
          );
          await tester.pumpWidget(
            BulkaApp(router: router, initialLocale: locale),
          );
          await tester.pump();
          final launcher = tester.element(find.byType(ScreenCatalog));
          final location = entry.location;
          if (location != null) {
            router.push(await location(launcher), extra: entry.extra);
          } else {
            Navigator.of(
              launcher,
            ).push(MaterialPageRoute<void>(builder: entry.builder!));
          }
          // Not pumpAndSettle: some screens have looping animations.
          await tester.pump(const Duration(milliseconds: 500));
          // Lets requests the screen started on its first frames (Home's
          // categories, the filter sheet's amenities — that sheet opens one
          // frame later) finish and draw their result.
          await tester.pump(const Duration(milliseconds: 100));
          await tester.pump(const Duration(milliseconds: 100));
          expect(tester.takeException(), isNull);
        });
      }
    });
  }
}
