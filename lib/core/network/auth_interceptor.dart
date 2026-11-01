import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:bulka_frontend/core/network/token_storage.dart';

/// Put `extra: {skipAuth: true}` on requests that must not send or refresh
/// the token (login, register, refresh itself).
const String skipAuth = 'skipAuth';
const String _retried = 'authRetried';

/// Attaches `Authorization: Bearer <accessToken>` to every request, and on
/// a 401 refreshes the tokens once and retries the request. If the refresh
/// fails, the tokens are cleared and [onSessionExpired] is called.
///
/// It's a [QueuedInterceptor], so when several requests get a 401 at the
/// same time only the first one refreshes; the rest see the new token and
/// just retry.
class AuthInterceptor extends QueuedInterceptor {
  AuthInterceptor({
    required Dio dio,
    required TokenStorage tokenStorage,
    required this.onSessionExpired,
  }) : _dio = dio,
       _tokenStorage = tokenStorage,
       // Separate client without this interceptor, so the refresh call
       // can't loop back into itself.
       _refreshDio = Dio(dio.options.copyWith());

  final Dio _dio;
  final Dio _refreshDio;
  final TokenStorage _tokenStorage;
  final VoidCallback onSessionExpired;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (options.extra[skipAuth] != true) {
      final token = await _tokenStorage.readAccessToken();
      if (token != null) options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final options = err.requestOptions;
    final isAuthFailure = err.response?.statusCode == 401;
    if (!isAuthFailure ||
        options.extra[skipAuth] == true ||
        options.extra[_retried] == true) {
      return handler.next(err);
    }

    // Another request may have refreshed the token while this one waited
    // in the queue — if so, just retry with the new one.
    final sentHeader = options.headers['Authorization'];
    final currentToken = await _tokenStorage.readAccessToken();
    if (currentToken != null && sentHeader != 'Bearer $currentToken') {
      return _retry(options, currentToken, handler);
    }

    final newToken = await _refreshTokens();
    if (newToken == null) {
      await _tokenStorage.clear();
      onSessionExpired();
      return handler.next(err);
    }
    return _retry(options, newToken, handler);
  }

  /// Returns the new access token, or null if the session can't be renewed.
  Future<String?> _refreshTokens() async {
    final refreshToken = await _tokenStorage.readRefreshToken();
    if (refreshToken == null) return null;
    try {
      final response = await _refreshDio.post<Map<String, dynamic>>(
        '/api/auth/refresh',
        data: {'refreshToken': refreshToken},
      );
      final data = response.data?['data'];
      if (data is! Map<String, dynamic>) return null;
      final accessToken = data['accessToken'] as String?;
      final newRefreshToken = data['refreshToken'] as String?;
      if (accessToken == null) return null;
      await _tokenStorage.save(
        accessToken: accessToken,
        // Keep the old refresh token if the backend doesn't rotate it.
        refreshToken: newRefreshToken ?? refreshToken,
      );
      return accessToken;
    } on DioException {
      return null;
    }
  }

  Future<void> _retry(
    RequestOptions options,
    String token,
    ErrorInterceptorHandler handler,
  ) async {
    options.headers['Authorization'] = 'Bearer $token';
    options.extra[_retried] = true;
    try {
      handler.resolve(await _dio.fetch<dynamic>(options));
    } on DioException catch (e) {
      handler.next(e);
    }
  }
}
