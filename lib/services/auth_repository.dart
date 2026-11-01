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
import 'package:bulka_frontend/models/logout_result.dart';
import 'package:bulka_frontend/models/provider_register_request.dart';
import 'package:bulka_frontend/models/provider_register_result.dart';
import 'package:bulka_frontend/models/register_result.dart';
import 'package:bulka_frontend/models/resend_email_verification_result.dart';

/// Raw HTTP calls for authentication and registration. Returns typed models
/// and throws [ApiException] on failure; never lets a [DioException] or raw
/// response map escape. [SessionController] is the intended caller for
/// [login]; registration screens call [registerBuyer]/[registerProvider]
/// directly, since a successful registration doesn't establish a session.
///
/// `backend/swagger.json` documents no response schema at all for either
/// register endpoint — [registerBuyer]'s response has since been confirmed
/// live and decodes into [RegisterResult]; [registerProvider]'s hasn't, so
/// it still returns the untyped envelope (see its doc comment).
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

  /// `backend/swagger.json` declares no response schema for this endpoint,
  /// but the real response has now been confirmed live and decodes into
  /// [RegisterResult] — see its doc comment for the exact shape observed.
  Future<RegisterResult> registerBuyer({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String displayName,
    required bool acceptedTerms,
    required bool acceptedPrivacy,
  }) async {
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
    try {
      // No `X-Client-Type` header: `backend/swagger.json` doesn't declare
      // that parameter on this endpoint (same reasoning as `_register`).
      final response = await _dio.post<Map<String, dynamic>>(
        '/api/auth/register/buyer',
        data: request.toJson(),
      );

      final envelope = ApiResponse<RegisterResult>.fromJson(
        response.data ?? const {},
        (json) => RegisterResult.fromJson(json as Map<String, dynamic>),
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

  /// `backend/swagger.json` declares no response schema for this endpoint,
  /// but the real response has now been confirmed live and decodes into
  /// [ProviderRegisterResult] — see its doc comment for the exact shape
  /// observed (notably a different status field name than [registerBuyer],
  /// so that's its own type rather than [RegisterResult]).
  Future<ProviderRegisterResult> registerProvider({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String displayName,
    required String businessName,
    required bool acceptedTerms,
    required bool acceptedPrivacy,
  }) async {
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
    try {
      // No `X-Client-Type` header: `backend/swagger.json` doesn't declare
      // that parameter on this endpoint (same reasoning as `registerBuyer`).
      final response = await _dio.post<Map<String, dynamic>>(
        '/api/auth/register/provider',
        data: request.toJson(),
      );

      final envelope = ApiResponse<ProviderRegisterResult>.fromJson(
        response.data ?? const {},
        (json) =>
            ProviderRegisterResult.fromJson(json as Map<String, dynamic>),
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
  /// schema here, but the real response has been confirmed live and
  /// decodes into [LogoutResult] (`{ loggedOut: true }`). The request
  /// body's schema is shared with `/api/auth/refresh` in the OpenAPI
  /// contract (`RefreshRequest` — just `{ refreshToken }`), not a
  /// logout-specific schema.
  ///
  /// No `Authorization` header: [refreshToken] itself is what identifies
  /// the session to revoke, and `/api/auth/logout` is in [ApiClient]'s
  /// public-path exclusion list. Never log [refreshToken] — this method
  /// only ever passes it straight into the request body.
  Future<LogoutResult> logout({required String refreshToken}) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/api/auth/logout',
        options: Options(headers: const {'X-Client-Type': 'mobile'}),
        data: {'refreshToken': refreshToken},
      );

      final envelope = ApiResponse<LogoutResult>.fromJson(
        response.data ?? const {},
        (json) => LogoutResult.fromJson(json as Map<String, dynamic>),
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

  /// `POST /api/auth/resend-email-verification`. `backend/swagger.json`
  /// declares no response schema here either, but the real response has
  /// been confirmed live and decodes into [ResendEmailVerificationResult]
  /// (`{ sent: true }`).
  Future<ResendEmailVerificationResult> resendEmailVerification({
    required String email,
  }) async {
    try {
      // No `X-Client-Type` header: `backend/swagger.json` doesn't declare
      // that parameter on this endpoint (same reasoning as `registerBuyer`).
      final response = await _dio.post<Map<String, dynamic>>(
        '/api/auth/resend-email-verification',
        data: {'email': email},
      );

      final envelope = ApiResponse<ResendEmailVerificationResult>.fromJson(
        response.data ?? const {},
        (json) => ResendEmailVerificationResult.fromJson(
          json as Map<String, dynamic>,
        ),
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

  /// `POST /api/auth/verify-email`. The failure envelope is confirmed live
  /// (400, `{ code: "AUTH_EMAIL_VERIFICATION_INVALID", message: "Invalid
  /// verification code." }` for a wrong code) and decodes through the
  /// standard error path like every other endpoint here. A *successful*
  /// response's `data` hasn't actually been observed yet though (no real
  /// code has been tried), so — same as `registerProvider` before its
  /// response was confirmed — this deliberately does NOT decode `data` into
  /// a typed model; the caller only needs to know the call succeeded, not
  /// read anything out of `data`, so this isn't blocking. Type it for real
  /// once a successful response has actually been seen.
  Future<void> verifyEmail({required String email, required String code}) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/api/auth/verify-email',
        data: {'email': email, 'code': code},
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
    } on DioException catch (e) {
      throw ApiErrorMapper.map(e);
    }
  }

  /// `POST /api/auth/forgot-password`. `backend/swagger.json` declares no
  /// response schema here, and no response has been confirmed live yet —
  /// same pattern as [verifyEmail] before its response was confirmed: the
  /// caller only needs to know the call succeeded, not read anything out of
  /// `data`, so this isn't blocking. Type it for real once a response has
  /// actually been seen.
  Future<void> forgotPassword({required String email}) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/api/auth/forgot-password',
        data: {'email': email},
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
    } on DioException catch (e) {
      throw ApiErrorMapper.map(e);
    }
  }

  /// `POST /api/auth/reset-password`. Same caveat as [forgotPassword] — no
  /// response confirmed live yet, so this is deliberately untyped too.
  Future<void> resetPassword({
    required String email,
    required String code,
    required String password,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/api/auth/reset-password',
        data: {'email': email, 'code': code, 'password': password},
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
    } on DioException catch (e) {
      throw ApiErrorMapper.map(e);
    }
  }

  /// `POST /api/auth/refresh`. Confirmed live — the response decodes into
  /// exactly the same shape as `/api/auth/login`'s (`accessToken`,
  /// `accessTokenExpiresAtUtc`, `refreshToken`, `user`,
  /// `twoFactorChallenge`, `webSession`), so this reuses
  /// [LoginResponseData] rather than a separate model.
  ///
  /// **Confirmed live: the backend rotates the refresh token on every
  /// use** — the `refreshToken` in a real response was a different value
  /// from the one sent in the request. Callers MUST persist the new one
  /// and never reuse the old one again; this is exactly the risk that kept
  /// this method a no-op until this was confirmed.
  ///
  /// Returns `null` on any failure, including a technically-successful
  /// envelope missing required fields — [SessionController] treats `null`
  /// the same as a thrown [ApiException]: force a local logout, since the
  /// stored refresh token can no longer be trusted either way.
  Future<LoginResponseData?> refreshToken({
    required String refreshToken,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/api/auth/refresh',
        options: Options(headers: const {'X-Client-Type': 'mobile'}),
        data: {'refreshToken': refreshToken},
      );

      final envelope = ApiResponse<LoginResponseData>.fromJson(
        response.data ?? const {},
        (json) => LoginResponseData.fromJson(json as Map<String, dynamic>),
      );

      if (!envelope.success ||
          envelope.data == null ||
          !envelope.data!.isCompleteLogin) {
        return null;
      }

      return envelope.data;
    } on DioException {
      return null;
    }
  }
}
