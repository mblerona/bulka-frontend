import 'package:dio/dio.dart';
import 'package:bulka_frontend/core/network/api_environment.dart';

/// Single shared Dio instance for all backend calls. Services should take
/// this in via constructor rather than creating their own Dio instances.
class ApiClient {
  ApiClient._internal(this.dio) {
    dio.interceptors.add(_AuthHeaderInterceptor(tokenProvider: () => _tokenProvider?.call()));
  }

  static final ApiClient instance = ApiClient._internal(
    Dio(
      BaseOptions(
        baseUrl: ApiEnvironment.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: const {'Content-Type': 'application/json'},
      ),
    ),
  );

  final Dio dio;

  String? Function()? _tokenProvider;

  /// Called once by `SessionController` so this interceptor can read the
  /// current access token without `ApiClient` importing `SessionController`
  /// directly (that would create an import cycle: `SessionController` needs
  /// `ApiClient`/`AuthRepository`, so the dependency has to run one way).
  void setAccessTokenProvider(String? Function() provider) {
    _tokenProvider = provider;
  }

  void addInterceptor(Interceptor interceptor) {
    dio.interceptors.add(interceptor);
  }
}

/// Attaches `Authorization: Bearer <token>` to every request except the
/// public auth endpoints — either because no session/token exists yet
/// (login, register, verify-email, etc.) or because the endpoint identifies
/// the session via a body field instead (logout, via its `refreshToken`).
///
/// Does NOT implement refresh-on-401 — `POST /api/auth/refresh` exists, but
/// its response shape hasn't been confirmed yet, so automatic refresh is a
/// later step, not guessed at here.
class _AuthHeaderInterceptor extends Interceptor {
  _AuthHeaderInterceptor({required this.tokenProvider});

  final String? Function() tokenProvider;

  static const _publicAuthPaths = [
    '/api/auth/login',
    '/api/auth/register/buyer',
    '/api/auth/register/provider',
    '/api/auth/verify-email',
    '/api/auth/resend-email-verification',
    '/api/auth/forgot-password',
    '/api/auth/reset-password',
    '/api/auth/logout',
  ];

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final isPublicAuthPath = _publicAuthPaths.any(
      (path) => options.path.startsWith(path),
    );
    final token = tokenProvider();
    if (!isPublicAuthPath && token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
}
