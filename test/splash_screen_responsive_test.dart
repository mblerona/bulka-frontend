import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bulka_frontend/blocs/app_bloc_providers.dart';
import 'package:bulka_frontend/screens/splash_screen/splash_screen.dart';

Future<void> _pumpAt(WidgetTester tester, Size size) async {
  await tester.binding.setSurfaceSize(size);
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  // Screens read the app's blocs, so they need the same providers.
  await tester.pumpWidget(
    const AppBlocProviders(
      initialLocale: Locale('mk'),
      child: MaterialApp(home: SplashScreen()),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('no overflow at 360x740 (Galaxy S8+)', (tester) async {
    await _pumpAt(tester, const Size(360, 740));
    expect(tester.takeException(), isNull);
  });

  testWidgets('no overflow at 320x568 (very short reference)', (tester) async {
    await _pumpAt(tester, const Size(320, 568));
    expect(tester.takeException(), isNull);
  });

  testWidgets('no overflow at 390x844 (tall reference / Figma frame)', (
    tester,
  ) async {
    await _pumpAt(tester, const Size(390, 844));
    expect(tester.takeException(), isNull);

    final logoFinder = find.byWidgetPredicate(
      (w) => w is SizedBox && w.width == 148 && w.height == 148,
    );
    expect(
      logoFinder,
      findsWidgets,
      reason: 'logo should render at full 148px size on a tall screen',
    );
  });
}
