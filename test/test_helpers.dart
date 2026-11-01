import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Tests draw text in a placeholder font where every letter is a full
/// square, which makes everything look far too wide. Call once (in
/// `setUpAll`) to use the app's real font so text widths match the phone.
Future<void> loadAppFonts() async {
  final montserrat = FontLoader('Montserrat');
  for (final weight in ['Regular', 'Medium', 'SemiBold', 'Bold', 'ExtraBold']) {
    final bytes = File('fonts/Montserrat-$weight.ttf').readAsBytesSync();
    montserrat.addFont(Future.value(ByteData.sublistView(bytes)));
  }
  await montserrat.load();
}

/// A typical phone screen (360×740) instead of the 800×600 test default.
Future<void> usePhoneScreen(WidgetTester tester) async {
  const size = Size(360, 740);
  await tester.binding.setSurfaceSize(size);
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}
