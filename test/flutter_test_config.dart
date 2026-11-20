import 'dart:async';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:bulka_frontend/core/network/api_client.dart';

import 'test_helpers.dart';

/// Runs before every test file: screens that load data from the backend
/// (e.g. Tourist Home's categories) get canned answers instead of making
/// real network calls, which never finish inside widget tests.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  ApiClient.instance.dio.httpClientAdapter = FakeBackendAdapter();
  // In-memory token storage: the real one needs the phone's keychain,
  // which never answers in tests, and the auth interceptor reads it before
  // every signed-in request (holding up every request queued behind it).
  FlutterSecureStorage.setMockInitialValues({});
  await testMain();
}
