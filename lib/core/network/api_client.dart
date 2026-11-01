import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:bulka_frontend/core/l10n/locale_controller.dart';
import 'package:bulka_frontend/core/network/api_environment.dart';
import 'package:bulka_frontend/core/network/auth_interceptor.dart';
import 'package:bulka_frontend/core/network/token_storage.dart';

/// Single shared Dio instance for all backend calls. Services should take
/// this in via constructor rather than creating their own Dio instances.
class ApiClient {
  ApiClient._internal(this.dio);

  static final ApiClient instance = ApiClient._create();

  static ApiClient _create() {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiEnvironment.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: const {
          'Content-Type': 'application/json',
          // Required by the auth endpoints: without it the backend uses its
          // web (cookie) session and doesn't return the tokens.
          'X-Client-Type': 'mobile',
        },
      ),
    );
    final client = ApiClient._internal(dio);
    // The app's current language, so the backend can return translated
    // content (listings, categories) where it supports it.
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          options.headers['Accept-Language'] =
              LocaleController.instance.locale.languageCode;
          handler.next(options);
        },
      ),
    );
    dio.interceptors.add(
      AuthInterceptor(
        dio: dio,
        tokenStorage: TokenStorage.instance,
        onSessionExpired: () => client.onSessionExpired?.call(),
      ),
    );
    if (kDebugMode) dio.interceptors.add(_DebugLogInterceptor());
    return client;
  }

  final Dio dio;

  /// Called when the tokens can no longer be refreshed (the user has to log
  /// in again). Set once at startup in `main.dart`.
  VoidCallback? onSessionExpired;

  void addInterceptor(Interceptor interceptor) {
    dio.interceptors.add(interceptor);
  }
}

/// Debug builds only: prints one line per request, plus the error details
/// when one fails. Request bodies and successful response bodies are never
/// printed, since they can contain passwords and tokens.
class _DebugLogInterceptor extends Interceptor {
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final r = response.requestOptions;
    debugPrint('[API] ${r.method} ${r.path} -> ${response.statusCode}');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final r = err.requestOptions;
    debugPrint(
      '[API] ${r.method} ${r.path} FAILED '
      '(${err.type.name}, status ${err.response?.statusCode}): '
      '${err.response?.data ?? err.error ?? err.message}',
    );
    handler.next(err);
  }
}
