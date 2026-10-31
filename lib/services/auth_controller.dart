import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:bulka_frontend/core/constants/app_strings.dart';
import 'package:bulka_frontend/core/network/api_client.dart';
import 'package:bulka_frontend/core/network/api_exception.dart';
import 'package:bulka_frontend/core/network/api_response.dart';
import 'package:bulka_frontend/core/network/auth_interceptor.dart';
import 'package:bulka_frontend/core/network/token_storage.dart';
import 'package:bulka_frontend/models/auth_user.dart';

/// Signs the user in and out, and holds who is signed in. Tokens live in
/// [TokenStorage]; attaching and refreshing them is [AuthInterceptor]'s job.
class AuthController extends ChangeNotifier {
  AuthController._(this._dio, this._tokenStorage);

  static final AuthController instance = AuthController._(
    ApiClient.instance.dio,
    TokenStorage.instance,
  );

  final Dio _dio;
  final TokenStorage _tokenStorage;

  AuthUser? _currentUser;
  AuthUser? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;

  /// Throws [ApiException] on failure. A wrong email/password comes back as
  /// [ApiErrorKind.unauthorized] or [ApiErrorKind.badRequest].
  Future<AuthUser> login({
    required String email,
    required String password,
  }) async {
    final Response<Map<String, dynamic>> response;
    try {
      response = await _dio.post<Map<String, dynamic>>(
        '/api/auth/login',
        data: {'email': email.trim(), 'password': password},
        options: Options(extra: {skipAuth: true}),
      );
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }

    final envelope = ApiResponse<Map<String, dynamic>>.fromJson(
      response.data ?? const {},
      (data) => data as Map<String, dynamic>,
    );
    final data = envelope.data;
    if (!envelope.success || data == null) {
      throw ApiException.fromEnvelope(envelope);
    }

    if (data['twoFactorChallenge'] != null) {
      // TODO: support 2FA via /api/auth/2fa/challenge/verify.
      throw const ApiException(
        kind: ApiErrorKind.badRequest,
        message: AppStrings.loginErrorTwoFactorUnsupported,
      );
    }

    final accessToken = data['accessToken'] as String?;
    final refreshToken = data['refreshToken'] as String?;
    final userJson = data['user'];
    if (accessToken == null ||
        refreshToken == null ||
        userJson is! Map<String, dynamic>) {
      debugPrint(
        '[Auth] Login response is missing fields — '
        'accessToken: ${accessToken != null}, '
        'refreshToken: ${refreshToken != null}, '
        'user: ${userJson is Map}',
      );
      throw const ApiException(
        kind: ApiErrorKind.unknown,
        message: AppStrings.apiErrorUnknown,
      );
    }

    await _tokenStorage.save(
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
    final user = AuthUser.fromJson(userJson);
    _currentUser = user;
    notifyListeners();
    return user;
  }

  /// Ends the session on the backend (best effort) and always clears it
  /// locally, even if the request fails or there's no connection.
  Future<void> logout() async {
    final refreshToken = await _tokenStorage.readRefreshToken();
    if (refreshToken != null) {
      try {
        await _dio.post<void>(
          '/api/auth/logout',
          data: {'refreshToken': refreshToken},
        );
      } on DioException {
        // Ignored: the local session is cleared below either way.
      }
    }
    await _tokenStorage.clear();
    clearSession();
  }

  /// Forgets the signed-in user without calling the backend — used when the
  /// session has already expired.
  void clearSession() {
    if (_currentUser == null) return;
    _currentUser = null;
    notifyListeners();
  }
}
