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
  const ApiException({
    required this.kind,
    required this.message,
    this.statusCode,
    this.errors = const [],
  });

  factory ApiException.fromDio(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const ApiException(
          kind: ApiErrorKind.timeout,
          message: AppStrings.apiErrorTimeout,
        );
      case DioExceptionType.connectionError:
        return const ApiException(
          kind: ApiErrorKind.network,
          message: AppStrings.apiErrorNetwork,
        );
      default:
        break;
    }

    final status = e.response?.statusCode;
    final body = e.response?.data;
    final errors = body is Map<String, dynamic>
        ? parseApiErrors(body['errors'])
        : const <ApiError>[];

    final ApiErrorKind kind;
    final String fallback;
    if (status == 401) {
      kind = ApiErrorKind.unauthorized;
      fallback = AppStrings.apiErrorUnauthorized;
    } else if (status != null && status >= 400 && status < 500) {
      kind = ApiErrorKind.badRequest;
      fallback = AppStrings.apiErrorInvalidInput;
    } else if (status != null && status >= 500) {
      kind = ApiErrorKind.server;
      fallback = AppStrings.apiErrorServer;
    } else {
      kind = ApiErrorKind.unknown;
      fallback = AppStrings.apiErrorUnknown;
    }

    return ApiException(
      kind: kind,
      message: _translatedMessage(errors) ?? fallback,
      statusCode: status,
      errors: errors,
    );
  }

  /// For a 2xx response whose envelope still says `success: false`.
  factory ApiException.fromEnvelope(ApiResponse<Object?> response) {
    return ApiException(
      kind: ApiErrorKind.badRequest,
      message:
          _translatedMessage(response.errors) ??
          AppStrings.apiErrorInvalidInput,
      errors: response.errors,
    );
  }

  final ApiErrorKind kind;

  /// Always in the app's language, never the backend's English text.
  final String message;
  final int? statusCode;
  final List<ApiError> errors;

  /// The first error the app has its own text for. Errors without a
  /// translation are logged (debug builds) so they can be added to
  /// api_error_translator.dart.
  static String? _translatedMessage(List<ApiError> errors) {
    for (final error in errors) {
      final translated = translateApiError(error);
      if (translated != null) return translated;
      debugPrint(
        '[API] No translation for error ${error.code} '
        '(field: ${error.field}): ${error.message}',
      );
    }
    return null;
  }

  @override
  String toString() => 'ApiException($kind, $statusCode): $message';
}
