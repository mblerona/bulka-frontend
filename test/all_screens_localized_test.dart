import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bulka_frontend/core/theme/app_theme.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bulka_frontend/core/constants/app_strings.dart';
import 'package:bulka_frontend/core/l10n/locale_controller.dart';
import 'package:bulka_frontend/dev/dev_launcher_screen.dart';
import 'package:bulka_frontend/l10n/app_localizations.dart';

/// Renders every screen from the dev launcher in every language on a
/// typical phone, so text that's longer in English or Albanian than in
/// Macedonian can't overflow unnoticed.
void main() {
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await initializeDateFormatting();
    // Tests draw text in a placeholder font where every letter is a full
    // square, which makes everything look far too wide. Load the app's real
    // font so text widths match the phone.
    final montserrat = FontLoader('Montserrat');
    for (final weight in [
      'Regular',
      'Medium',
      'SemiBold',
      'Bold',
      'ExtraBold',
    ]) {
      final bytes = File('fonts/Montserrat-$weight.ttf').readAsBytesSync();
      montserrat.addFont(Future.value(ByteData.sublistView(bytes)));
    }
    await montserrat.load();
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

      for (final (name, builder) in DevLauncherScreen.allScreens) {
        testWidgets('$name has no overflow', (tester) async {
          const size = Size(360, 740);
          await tester.binding.setSurfaceSize(size);
          tester.view.physicalSize = size;
          tester.view.devicePixelRatio = 1.0;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);

          await tester.pumpWidget(
            MaterialApp(
              theme: AppTheme.lightTheme,
              locale: locale,
              supportedLocales: AppLocalizations.supportedLocales,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              home: Builder(builder: builder),
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
