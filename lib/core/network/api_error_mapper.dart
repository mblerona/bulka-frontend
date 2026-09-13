import 'package:dio/dio.dart';
import 'package:bulka_frontend/core/constants/app_strings.dart';
import 'package:bulka_frontend/core/network/api_exception.dart';

/// The one place a `DioException` is ever interpreted. Repositories call
/// `ApiErrorMapper.map(e)` inside their `on DioException catch (e)` block and
/// throw the resulting [ApiException] — screens/controllers only ever see
/// [ApiException], never Dio's own exception type or its raw message text.
///
/// Backend error envelope this is built against (confirmed against a real
/// 401 from `POST /api/auth/login`):
/// ```json
/// {
///   "success": false,
///   "data": null,
///   "errors": [ { "code": "...", "message": "...", "field": null } ],
///   "traceId": "..."
/// }
/// ```
/// This is NOT ASP.NET's default `ProblemDetails` shape — do not reintroduce
/// that. Only the `errors`/`traceId` shape above has actually been observed;
/// every status-code-to-[ApiExceptionKind] mapping below is inferred from
/// the HTTP status code alone, since no other status code's body has been
/// confirmed yet. If a response's body doesn't match this envelope (e.g. a
/// plain-text 500 from a proxy, or no response at all), this falls back to
/// a generic [AppStrings] message for that status/kind instead of guessing.
class ApiErrorMapper {
  ApiErrorMapper._();

  static ApiException map(DioException error) {
    final statusCode = error.response?.statusCode;
    final envelope = _tryParseEnvelope(error.response?.data);
    final kind = _kindForStatus(statusCode);

    if (envelope != null) {
      return ApiException(
        kind: kind,
        message: envelope.errors.isNotEmpty
            ? envelope.errors.first.message
            : _fallbackMessage(kind),
        statusCode: statusCode,
        errors: envelope.errors,
        traceId: envelope.traceId,
      );
    }

    if (statusCode != null) {
      return ApiException(
        kind: kind,
        message: _fallbackMessage(kind),
        statusCode: statusCode,
      );
    }

    // No response reached the app at all: timeout, no connectivity, DNS
    // failure, TLS failure, or the request was cancelled.
    return ApiException(
      kind: ApiExceptionKind.network,
      message: _networkFallbackMessage(error.type),
    );
  }

  static _ParsedEnvelope? _tryParseEnvelope(dynamic data) {
    if (data is! Map) return null;
    final errorsRaw = data['errors'];
    if (errorsRaw is! List) return null;
    return _ParsedEnvelope(
      errors: errorsRaw
          .whereType<Map>()
          .map((e) => ApiErrorItem.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      traceId: data['traceId'] as String?,
    );
  }

  static ApiExceptionKind _kindForStatus(int? statusCode) {
    switch (statusCode) {
      case 400:
      case 422:
        return ApiExceptionKind.validation;
      case 401:
        return ApiExceptionKind.unauthorized;
      case 403:
        return ApiExceptionKind.forbidden;
      case 404:
        return ApiExceptionKind.notFound;
      case 409:
        return ApiExceptionKind.conflict;
    }
    if (statusCode != null && statusCode >= 500) return ApiExceptionKind.server;
    return ApiExceptionKind.unknown;
  }

  static String _fallbackMessage(ApiExceptionKind kind) {
    switch (kind) {
      case ApiExceptionKind.validation:
        return AppStrings.apiErrorValidation;
      case ApiExceptionKind.unauthorized:
        return AppStrings.apiErrorUnauthorized;
      case ApiExceptionKind.forbidden:
        return AppStrings.apiErrorForbidden;
      case ApiExceptionKind.notFound:
        return AppStrings.apiErrorNotFound;
      case ApiExceptionKind.conflict:
        return AppStrings.apiErrorConflict;
      case ApiExceptionKind.server:
        return AppStrings.apiErrorServer;
      case ApiExceptionKind.network:
      case ApiExceptionKind.unknown:
        return AppStrings.apiErrorUnknown;
    }
  }

  static String _networkFallbackMessage(DioExceptionType type) {
    switch (type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return AppStrings.apiErrorTimeout;
      case DioExceptionType.connectionError:
        return AppStrings.apiErrorNoConnection;
      default:
        return AppStrings.apiErrorConnectionFailed;
    }
  }
}

class _ParsedEnvelope {
  const _ParsedEnvelope({required this.errors, this.traceId});

  final List<ApiErrorItem> errors;
  final String? traceId;
}
