import 'package:dio/dio.dart';
import 'package:bulka_frontend/core/constants/app_strings.dart';
import 'package:bulka_frontend/core/network/api_client.dart';
import 'package:bulka_frontend/core/network/api_error_mapper.dart';
import 'package:bulka_frontend/core/network/api_exception.dart';
import 'package:bulka_frontend/core/network/api_response.dart';
import 'package:bulka_frontend/models/auth_user.dart';
import 'package:bulka_frontend/models/buyer_register_request.dart';
import 'package:bulka_frontend/models/login_request.dart';
import 'package:bulka_frontend/models/login_response_data.dart';
import 'package:bulka_frontend/models/provider_register_request.dart';

/// Raw HTTP calls for authentication and registration. Returns typed models
/// (or, for registration — whose response schema `backend/swagger.json`
/// doesn't document at all — the untyped envelope) and throws
/// [ApiException] on failure; never lets a [DioException] or raw response
/// map escape. [SessionController] is the intended caller for [login];
/// registration screens call [registerBuyer]/[registerProvider] directly,
/// since a successful registration doesn't establish a session.
class AuthRepository {
  AuthRepository({Dio? dio}) : _dio = dio ?? ApiClient.instance.dio;

  final Dio _dio;

  /// `turnstileToken` has no documented format anywhere in
  /// `backend/swagger.json` (no example, no enum, no min length). An empty
  /// string is confirmed to reach real credential validation (a
  /// AUTH_INVALID_CREDENTIALS 401, not a Turnstile-specific error), so this
  /// is safe for now — not a guess at what a real token looks like.
  /// TODO: replace with a real Cloudflare Turnstile token once/if the
  /// backend is confirmed to require one.
  static const String _placeholderTurnstileToken = '';

  Future<LoginResponseData> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/api/auth/login',
        options: Options(headers: const {'X-Client-Type': 'mobile'}),
        data: LoginRequest(
          email: email,
          password: password,
          turnstileToken: _placeholderTurnstileToken,
        ).toJson(),
      );

      final envelope = ApiResponse<LoginResponseData>.fromJson(
        response.data ?? const {},
        (json) => LoginResponseData.fromJson(json as Map<String, dynamic>),
      );

      if (!envelope.success || envelope.data == null) {
        // Not observed on a 2xx in practice, but don't assume it can't
        // happen — surface it the same way a real backend error would be.
        throw ApiException(
          kind: ApiExceptionKind.unknown,
          message: envelope.errors.isNotEmpty
              ? envelope.errors.first.message
              : AppStrings.apiErrorUnknown,
          errors: envelope.errors,
          traceId: envelope.traceId,
        );
      }

      return envelope.data!;
    } on DioException catch (e) {
      throw ApiErrorMapper.map(e);
    }
  }

  /// `backend/swagger.json` declares no response schema at all for
  /// `/api/auth/register/*` (same as every other endpoint in that
  /// document) — so unlike [login], this deliberately does NOT decode
  /// `data` into a typed model. Returns the raw envelope
  /// (`success`/`data`/`errors`/`traceId`) so callers can inspect exactly
  /// what the backend actually sends back, without this repository
  /// inventing a shape for it.
  Future<ApiResponse<Object?>> registerBuyer({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String displayName,
    required bool acceptedTerms,
    required bool acceptedPrivacy,
  }) {
    final request = BuyerRegisterRequest(
      email: email,
      password: password,
      firstName: firstName,
      lastName: lastName,
      displayName: displayName,
      acceptedTerms: acceptedTerms,
      acceptedPrivacy: acceptedPrivacy,
      turnstileToken: _placeholderTurnstileToken,
    );
    return _register('/api/auth/register/buyer', request.toJson());
  }

  /// See [registerBuyer] — same caveat about the undocumented response.
  Future<ApiResponse<Object?>> registerProvider({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String displayName,
    required String businessName,
    required bool acceptedTerms,
    required bool acceptedPrivacy,
  }) {
    final request = ProviderRegisterRequest(
      email: email,
      password: password,
      firstName: firstName,
      lastName: lastName,
      displayName: displayName,
      businessName: businessName,
      acceptedTerms: acceptedTerms,
      acceptedPrivacy: acceptedPrivacy,
      turnstileToken: _placeholderTurnstileToken,
    );
    return _register('/api/auth/register/provider', request.toJson());
  }

  /// `GET /api/users/me`. Confirmed live (via a temporary debug print during
  /// integration) to return exactly the same shape as `/api/auth/login`'s
  /// `data.user` — reuses [AuthUser] rather than a separate model.
  ///
  /// Requires an authenticated session — `/api/users/me` is not in
  /// [ApiClient]'s public-path exclusion list, so the Bearer interceptor
  /// attaches `Authorization` automatically as long as [SessionController]
  /// currently holds a token; this method does nothing special for auth.
  Future<AuthUser> getCurrentUser() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('/api/users/me');

      final envelope = ApiResponse<AuthUser>.fromJson(
        response.data ?? const {},
        (json) => AuthUser.fromJson(json as Map<String, dynamic>),
      );

      if (!envelope.success || envelope.data == null) {
        throw ApiException(
          kind: ApiExceptionKind.unknown,
          message: envelope.errors.isNotEmpty
              ? envelope.errors.first.message
              : AppStrings.apiErrorUnknown,
          errors: envelope.errors,
          traceId: envelope.traceId,
        );
      }

      return envelope.data!;
    } on DioException catch (e) {
      throw ApiErrorMapper.map(e);
    }
  }

  /// `POST /api/auth/logout`. `backend/swagger.json` declares no response
  /// schema here either — parses only the generic envelope, `data` left
  /// untyped, same as registration.
  ///
  /// No `Authorization` header: [refreshToken] itself is what identifies
  /// the session to revoke, and `/api/auth/logout` is in [ApiClient]'s
  /// public-path exclusion list. Never log [refreshToken] — this method
  /// only ever passes it straight into the request body.
  Future<ApiResponse<Object?>> logout({required String refreshToken}) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/api/auth/logout',
        options: Options(headers: const {'X-Client-Type': 'mobile'}),
        data: {'refreshToken': refreshToken},
      );

      final envelope = ApiResponse<Object?>.fromJson(
        response.data ?? const {},
        (json) => json,
      );

      if (!envelope.success) {
        throw ApiException(
          kind: ApiExceptionKind.unknown,
          message: envelope.errors.isNotEmpty
              ? envelope.errors.first.message
              : AppStrings.apiErrorUnknown,
          errors: envelope.errors,
          traceId: envelope.traceId,
        );
      }

      return envelope;
    } on DioException catch (e) {
      throw ApiErrorMapper.map(e);
    }
  }

  Future<ApiResponse<Object?>> _register(
    String path,
    Map<String, dynamic> body,
  ) async {
    try {
      // No `X-Client-Type` header here: unlike `/api/auth/login`,
      // `/api/auth/refresh`, `/api/auth/logout`, and the 2FA challenge
      // endpoint, `backend/swagger.json` does not declare that parameter on
      // either register endpoint — only adding headers the contract
      // actually documents.
      final response = await _dio.post<Map<String, dynamic>>(
        path,
        data: body,
      );

      final envelope = ApiResponse<Object?>.fromJson(
        response.data ?? const {},
        (json) => json,
      );

      if (!envelope.success) {
        // Covers a backend that reports failure via a 2xx + success:false
        // rather than a non-2xx status — same defensive shape as `login`.
        throw ApiException(
          kind: ApiExceptionKind.unknown,
          message: envelope.errors.isNotEmpty
              ? envelope.errors.first.message
              : AppStrings.apiErrorUnknown,
          errors: envelope.errors,
          traceId: envelope.traceId,
        );
      }

      return envelope;
    } on DioException catch (e) {
      throw ApiErrorMapper.map(e);
    }
  }
}
