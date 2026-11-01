import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:bulka_frontend/core/constants/app_strings.dart';
import 'package:bulka_frontend/core/network/api_client.dart';
import 'package:bulka_frontend/core/network/api_exception.dart';
import 'package:bulka_frontend/core/network/api_response.dart';
import 'package:bulka_frontend/core/network/auth_interceptor.dart';
import 'package:bulka_frontend/core/network/token_storage.dart';
import 'package:bulka_frontend/models/auth_user.dart';
import 'package:bulka_frontend/models/user_role.dart';

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
    final data = await _postWithoutAuth('/api/auth/login', {
      'email': email.trim(),
      'password': password,
    });
    if (data is! Map<String, dynamic>) {
      throw const ApiException(kind: ApiErrorKind.unknown);
    }
    return _startSession(data);
  }

  /// Creates a Tourist ([UserRole.buyer]) or Provider ([UserRole.owner])
  /// account. It does not sign the user in: the backend answers with
  /// `{ userId, status: "PendingVerification", emailVerificationRequired }`
  /// and the user logs in after confirming their email.
  ///
  /// Returns whether email verification is required. Validation errors
  /// (e.g. email already in use) come back as [ApiException] with the
  /// backend's message.
  Future<bool> register({
    required UserRole role,
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String password,
  }) async {
    final path = role == UserRole.owner
        ? '/api/auth/register/provider'
        : '/api/auth/register/buyer';
    final data = await _postWithoutAuth(path, {
      'email': email.trim(),
      'password': password,
      'firstName': firstName.trim(),
      'lastName': lastName.trim(),
      'displayName': '${firstName.trim()} ${lastName.trim()}',
      'phone': phone.trim(),
      'acceptedTerms': true,
      'acceptedPrivacy': true,
    });
    // Assume verification is needed unless the backend explicitly says not.
    return data is! Map<String, dynamic> ||
        data['emailVerificationRequired'] != false;
  }

  /// Confirms the account with the code from the verification email. Does
  /// not sign the user in.
  Future<void> verifyEmail({
    required String email,
    required String code,
  }) async {
    await _postWithoutAuth('/api/auth/verify-email', {
      'email': email.trim(),
      'code': code.trim(),
    });
  }

  Future<void> resendEmailVerification(String email) async {
    await _postWithoutAuth('/api/auth/resend-email-verification', {
      'email': email.trim(),
    });
  }

  /// POSTs to an endpoint that doesn't need a signed-in user and returns
  /// the envelope's `data`. Throws [ApiException] on any failure.
  Future<Object?> _postWithoutAuth(
    String path,
    Map<String, Object?> body,
  ) async {
    final Response<Object?> response;
    try {
      response = await _dio.post<Object?>(
        path,
        data: body,
        options: Options(extra: {skipAuth: true}),
      );
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
    final json = response.data;
    if (json is! Map<String, dynamic>) return null; // e.g. an empty 200
    final envelope = ApiResponse<Object?>.fromJson(json, (data) => data);
    if (!envelope.success) throw ApiException.fromEnvelope(envelope);
    return envelope.data;
  }

  /// Stores the tokens from a login-style response and remembers the user.
  Future<AuthUser> _startSession(Map<String, dynamic> data) async {
    if (data['twoFactorChallenge'] != null) {
      // TODO: support 2FA via /api/auth/2fa/challenge/verify.
      throw ApiException(
        kind: ApiErrorKind.badRequest,
        customMessage: () => AppStrings.loginErrorTwoFactorUnsupported,
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
      throw const ApiException(kind: ApiErrorKind.unknown);
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
