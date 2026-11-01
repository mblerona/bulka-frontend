import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bulka_frontend/core/l10n/locale_controller.dart';
import 'package:bulka_frontend/core/routing/app_router.dart';
import 'package:bulka_frontend/core/routing/app_routes.dart';
import 'package:bulka_frontend/main.dart';

void main() {
  tearDown(() {
    TestWidgetsFlutterBinding.instance.platformDispatcher.clearAllTestValues();
  });

  testWidgets('first launch uses the phone language when supported', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    tester.platformDispatcher.localesTestValue = const [
      Locale('de'),
      Locale('sq'),
    ];
    await LocaleController.instance.load();
    expect(LocaleController.instance.locale, const Locale('sq'));
  });

  testWidgets('first launch falls back to Macedonian', (tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.platformDispatcher.localesTestValue = const [Locale('de')];
    await LocaleController.instance.load();
    expect(LocaleController.instance.locale, const Locale('mk'));
  });

  testWidgets('a saved choice wins over the phone language', (tester) async {
    SharedPreferences.setMockInitialValues({'app.languageCode': 'en'});
    tester.platformDispatcher.localesTestValue = const [Locale('sq')];
    await LocaleController.instance.load();
    expect(LocaleController.instance.locale, const Locale('en'));
  });

  testWidgets('switching updates open screens, keeps history, is saved', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({'app.languageCode': 'mk'});
    await LocaleController.instance.load();
    final router = createAppRouter(initialLocation: AppRoutes.splash);
    await tester.pumpWidget(BulkaApp(router: router));
    router.push(AppRoutes.login);
    await tester.pumpAndSettle();
    expect(find.text('НАЈАВИ СЕ'), findsOneWidget);

    await LocaleController.instance.setLanguage('EN');
    await tester.pumpAndSettle();

    expect(find.text('LOG IN'), findsOneWidget);
    expect(find.text('НАЈАВИ СЕ'), findsNothing);
    expect(router.canPop(), isTrue);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('app.languageCode'), 'en');
  });
}
