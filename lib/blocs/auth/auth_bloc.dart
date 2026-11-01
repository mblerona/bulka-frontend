import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bulka_frontend/core/constants/app_strings.dart';
import 'package:bulka_frontend/core/network/api_client.dart';
import 'package:bulka_frontend/core/network/api_exception.dart';
import 'package:bulka_frontend/core/network/api_response.dart';
import 'package:bulka_frontend/core/network/auth_interceptor.dart';
import 'package:bulka_frontend/core/network/token_storage.dart';
import 'package:bulka_frontend/models/auth_user.dart';
import 'package:bulka_frontend/models/user_role.dart';

part 'auth_event.dart';
part 'auth_state.dart';

/// Signs the user in and out, registers and verifies accounts, and holds
/// who is signed in. Tokens live in [TokenStorage]; attaching and
/// refreshing them is [AuthInterceptor]'s job.
///
/// Each request ends in an [AuthState] with its [AuthOperation] and
/// [AuthOperationStatus]; screens react to those with a `BlocListener`
/// (navigate on success, show the error on failure).
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({Dio? dio, TokenStorage? tokenStorage})
    : _dio = dio ?? ApiClient.instance.dio,
      _tokenStorage = tokenStorage ?? TokenStorage.instance,
      super(const AuthState()) {
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthRegistrationRequested>(_onRegistrationRequested);
    on<AuthEmailVerificationRequested>(_onEmailVerificationRequested);
    on<AuthVerificationEmailResendRequested>(_onResendRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthSessionExpired>(_onSessionExpired);
  }

  final Dio _dio;
  final TokenStorage _tokenStorage;

  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.started(AuthOperation.login));
    try {
      final data = await _postWithoutAuth('/api/auth/login', {
        'email': event.email.trim(),
        'password': event.password,
      });
      if (data is! Map<String, dynamic>) {
        throw const ApiException(kind: ApiErrorKind.unknown);
      }
      final user = await _startSession(data);
      emit(state.succeeded(user: user));
    } on ApiException catch (e) {
      emit(state.failed(e));
    }
  }

  /// Creates a Tourist ([UserRole.buyer]) or Provider ([UserRole.owner])
  /// account. It doesn't sign the user in: the backend answers with
  /// `{ userId, status: "PendingVerification", emailVerificationRequired }`
  /// and the user logs in after confirming their email.
  Future<void> _onRegistrationRequested(
    AuthRegistrationRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.started(AuthOperation.register));
    try {
      final path = event.role == UserRole.owner
          ? '/api/auth/register/provider'
          : '/api/auth/register/buyer';
      final firstName = event.firstName.trim();
      final lastName = event.lastName.trim();
      final data = await _postWithoutAuth(path, {
        'email': event.email.trim(),
        'password': event.password,
        'firstName': firstName,
        'lastName': lastName,
        'displayName': '$firstName $lastName',
        'phone': event.phone.trim(),
        'acceptedTerms': true,
        'acceptedPrivacy': true,
      });
      // Assume verification is needed unless the backend explicitly says not.
      emit(
        state.succeeded(
          emailVerificationRequired:
              data is! Map<String, dynamic> ||
              data['emailVerificationRequired'] != false,
        ),
      );
    } on ApiException catch (e) {
      emit(state.failed(e));
    }
  }

  /// Confirms the account with the code from the verification email. Does
  /// not sign the user in.
  Future<void> _onEmailVerificationRequested(
    AuthEmailVerificationRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.started(AuthOperation.verifyEmail));
    try {
      await _postWithoutAuth('/api/auth/verify-email', {
        'email': event.email.trim(),
        'code': event.code.trim(),
      });
      emit(state.succeeded());
    } on ApiException catch (e) {
      emit(state.failed(e));
    }
  }

  Future<void> _onResendRequested(
    AuthVerificationEmailResendRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.started(AuthOperation.resendVerification));
    try {
      await _postWithoutAuth('/api/auth/resend-email-verification', {
        'email': event.email.trim(),
      });
      emit(state.succeeded());
    } on ApiException catch (e) {
      emit(state.failed(e));
    }
  }

  /// Ends the session on the backend (best effort) and always clears it
  /// locally, even if the request fails or there's no connection.
  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.started(AuthOperation.logout));
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
    emit(state.succeeded(signedOut: true));
  }

  /// The tokens could no longer be refreshed ([AuthInterceptor] already
  /// cleared them); forget the user. `BulkaApp` sends them to Login.
  void _onSessionExpired(AuthSessionExpired event, Emitter<AuthState> emit) {
    emit(
      const AuthState(
        operation: AuthOperation.sessionExpired,
        status: AuthOperationStatus.succeeded,
      ),
    );
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

  /// Stores the tokens from a login-style response and returns the user.
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
    return AuthUser.fromJson(userJson);
  }
}
