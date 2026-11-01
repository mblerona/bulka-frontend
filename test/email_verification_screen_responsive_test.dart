import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bulka_frontend/screens/email_verification_screen/email_verification_screen.dart';

/// [keyboardHeight] simulates the on-screen keyboard being open, which is
/// when the code field and buttons are most likely to run out of room.
Future<void> _pumpAt(
  WidgetTester tester,
  Size size, {
  double keyboardHeight = 0,
}) async {
  await tester.binding.setSurfaceSize(size);
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  tester.view.viewInsets = FakeViewPadding(bottom: keyboardHeight);
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetViewInsets);
  await tester.pumpWidget(const MaterialApp(home: EmailVerificationScreen()));
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

  testWidgets('no overflow with the keyboard open', (tester) async {
    await _pumpAt(tester, const Size(360, 740), keyboardHeight: 300);
    expect(tester.takeException(), isNull);
  });
}
