import 'package:dio/dio.dart';
import 'package:bulka_frontend/core/network/api_environment.dart';

/// Single shared Dio instance for all backend calls. Services should take
/// this in via constructor rather than creating their own Dio instances.
class ApiClient {
  ApiClient._internal(this.dio) {
    dio.interceptors.add(
      _AuthHeaderInterceptor(tokenProvider: () => _tokenProvider?.call()),
    );
    dio.interceptors.add(
      _RefreshOnUnauthorizedInterceptor(
        dio: dio,
        refreshHandler: () => _unauthorizedRefreshHandler?.call() ?? Future.value(false),
      ),
    );
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
  Future<bool> Function()? _unauthorizedRefreshHandler;

  /// Called once by `SessionController` so this interceptor can read the
  /// current access token without `ApiClient` importing `SessionController`
  /// directly (that would create an import cycle: `SessionController` needs
  /// `ApiClient`/`AuthRepository`, so the dependency has to run one way).
  void setAccessTokenProvider(String? Function() provider) {
    _tokenProvider = provider;
  }

  /// Called once by `SessionController` (same import-cycle reasoning as
  /// [setAccessTokenProvider]) so a 401 can trigger a token-refresh attempt
  /// without `ApiClient` depending on `SessionController`/`AuthRepository`
  /// directly. The handler should return `true` only once a new access
  /// token has actually been obtained and applied (so [_tokenProvider]
  /// returns the new value on retry) — any other outcome is treated as
  /// "this session can't be recovered."
  void setUnauthorizedRefreshHandler(Future<bool> Function() handler) {
    _unauthorizedRefreshHandler = handler;
  }

  void addInterceptor(Interceptor interceptor) {
    dio.interceptors.add(interceptor);
  }
}

/// Attaches `Authorization: Bearer <token>` to every request except the
/// public auth endpoints — either because no session/token exists yet
/// (login, register, verify-email, etc.) or because the endpoint identifies
/// the session via a body field instead (logout/refresh, via their own
/// `refreshToken`).
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
    '/api/auth/refresh',
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

/// On a 401 from any non-public-auth endpoint, calls [refreshHandler] once
/// and either retries the original request (if it reports success) or lets
/// the original 401 through (if not) — so a request that failed only
/// because the access token expired doesn't surface as a user-facing error
/// when it could have just been retried transparently.
///
/// A `QueuedInterceptor`, not a plain `Interceptor`, specifically so a burst
/// of concurrent requests that all 401 around the same moment (e.g. a
/// screen that fires several calls at once) triggers exactly one refresh
/// attempt — [_refreshInFlight] is the shared in-progress attempt every
/// concurrent 401 awaits instead of calling [refreshHandler] again.
///
/// [refreshHandler] is `SessionController.attemptTokenRefresh` — see its
/// doc comment for what a `true`/`false` result actually means (a real
/// refresh now happens, confirmed live against `POST /api/auth/refresh`).
class _RefreshOnUnauthorizedInterceptor extends QueuedInterceptor {
  _RefreshOnUnauthorizedInterceptor({
    required this.dio,
    required this.refreshHandler,
  });

  final Dio dio;
  final Future<bool> Function() refreshHandler;

  Future<bool>? _refreshInFlight;

  static const _excludedPaths = [
    '/api/auth/login',
    '/api/auth/register/buyer',
    '/api/auth/register/provider',
    '/api/auth/verify-email',
    '/api/auth/resend-email-verification',
    '/api/auth/forgot-password',
    '/api/auth/reset-password',
    '/api/auth/refresh',
    '/api/auth/logout',
  ];

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final options = err.requestOptions;
    final isExcludedPath = _excludedPaths.any(
      (path) => options.path.startsWith(path),
    );
    final alreadyRetried = options.extra['retriedAfterRefresh'] == true;

    if (err.response?.statusCode != 401 || isExcludedPath || alreadyRetried) {
      handler.next(err);
      return;
    }

    _refreshInFlight ??= refreshHandler().whenComplete(() {
      _refreshInFlight = null;
    });
    final refreshed = await _refreshInFlight!;

    if (!refreshed) {
      handler.next(err);
      return;
    }

    try {
      final retryOptions = options.copyWith(
        extra: {...options.extra, 'retriedAfterRefresh': true},
      );
      final response = await dio.fetch<dynamic>(retryOptions);
      handler.resolve(response);
    } catch (_) {
      handler.next(err);
    }
  }
}
