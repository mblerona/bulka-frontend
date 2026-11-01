import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:bulka_frontend/core/constants/app_strings.dart';
import 'package:bulka_frontend/core/network/api_error_translator.dart';
import 'package:bulka_frontend/core/network/api_response.dart';

enum ApiErrorKind {
  network,
  timeout,
  unauthorized,
  badRequest,
  server,
  unknown,
}

/// The one error type services throw, so screens never deal with Dio
/// directly. [message] is always safe to show to the user.
class ApiException implements Exception {
  /// [customMessage] replaces the usual text (e.g. "2FA isn't supported");
  /// it's a function so it's read in the current language.
  const ApiException({
    required this.kind,
    this.statusCode,
    this.errors = const [],
    String Function()? customMessage,
  }) : _customMessage = customMessage;

  factory ApiException.fromDio(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const ApiException(kind: ApiErrorKind.timeout);
      case DioExceptionType.connectionError:
        return const ApiException(kind: ApiErrorKind.network);
      default:
        break;
    }

    final status = e.response?.statusCode;
    final body = e.response?.data;
    final errors = body is Map<String, dynamic>
        ? parseApiErrors(body['errors'])
        : const <ApiError>[];

    final ApiErrorKind kind;
    if (status == 401) {
      kind = ApiErrorKind.unauthorized;
    } else if (status != null && status >= 400 && status < 500) {
      kind = ApiErrorKind.badRequest;
    } else if (status != null && status >= 500) {
      kind = ApiErrorKind.server;
    } else {
      kind = ApiErrorKind.unknown;
    }
    _logUntranslated(errors);
    return ApiException(kind: kind, statusCode: status, errors: errors);
  }

  /// For a 2xx response whose envelope still says `success: false`.
  factory ApiException.fromEnvelope(ApiResponse<Object?> response) {
    _logUntranslated(response.errors);
    return ApiException(kind: ApiErrorKind.badRequest, errors: response.errors);
  }

  final ApiErrorKind kind;
  final int? statusCode;
  final List<ApiError> errors;
  final String Function()? _customMessage;

  /// Whether the backend sent an error with this `code`, e.g.
  /// `AUTH_EMAIL_NOT_VERIFIED`.
  bool hasErrorCode(String code) => errors.any((e) => e.code == code);

  /// In the app's current language, never the backend's English text.
  /// Worked out on every read, so it follows a language switch.
  String get message {
    final custom = _customMessage;
    if (custom != null) return custom();
    for (final error in errors) {
      final translated = translateApiError(error);
      if (translated != null) return translated;
    }
    return switch (kind) {
      ApiErrorKind.network => AppStrings.apiErrorNetwork,
      ApiErrorKind.timeout => AppStrings.apiErrorTimeout,
      ApiErrorKind.unauthorized => AppStrings.apiErrorUnauthorized,
      ApiErrorKind.badRequest => AppStrings.apiErrorInvalidInput,
      ApiErrorKind.server => AppStrings.apiErrorServer,
      ApiErrorKind.unknown => AppStrings.apiErrorUnknown,
    };
  }

  /// Debug builds: print errors the app has no text for yet, so they can be
  /// added to api_error_translator.dart.
  static void _logUntranslated(List<ApiError> errors) {
    for (final error in errors) {
      if (translateApiError(error) == null) {
        debugPrint(
          '[API] No translation for error ${error.code} '
          '(field: ${error.field}): ${error.message}',
        );
      }
    }
  }

  @override
  String toString() => 'ApiException($kind, $statusCode): $message';
}
