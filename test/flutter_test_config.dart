import 'dart:async';

import 'package:bulka_frontend/core/network/api_client.dart';

import 'test_helpers.dart';

/// Runs before every test file: screens that load data from the backend
/// (e.g. Tourist Home's categories) get canned answers instead of making
/// real network calls, which never finish inside widget tests.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  ApiClient.instance.dio.httpClientAdapter = FakeBackendAdapter();
  await testMain();
}
