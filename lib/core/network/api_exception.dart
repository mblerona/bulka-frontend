/// One item from the backend's response envelope's `errors` array:
/// `{ "code": "...", "message": "...", "field": null }` — confirmed against
/// a real 401 from `POST /api/auth/login`.
class ApiErrorItem {
  const ApiErrorItem({required this.code, required this.message, this.field});

  factory ApiErrorItem.fromJson(Map<String, dynamic> json) {
    return ApiErrorItem(
      code: json['code'] as String? ?? '',
      message: json['message'] as String? ?? '',
      field: json['field'] as String?,
    );
  }

  final String code;
  final String message;
  final String? field;
}

/// Coarse category of an [ApiException], derived from the HTTP status code —
/// lets a screen react generically (e.g. `unauthorized` -> force logout)
/// without switching on raw status codes itself.
enum ApiExceptionKind {
  validation,
  unauthorized,
  forbidden,
  notFound,
  conflict,
  server,
  network,
  unknown,
}

/// The one exception type the rest of the app ever deals with for a failed
/// API call. [ApiErrorMapper] is the only place a `DioException` gets turned
/// into this — repositories/controllers should let `DioException` propagate
/// out of their own try/catch only long enough to hand it to the mapper,
/// never surface it (or its raw message text) directly to a screen.
class ApiException implements Exception {
  const ApiException({
    required this.kind,
    required this.message,
    this.statusCode,
    this.errors = const [],
    this.traceId,
  });

  final ApiExceptionKind kind;

  /// Backend-provided message when available, otherwise a generic
  /// [AppStrings]-sourced fallback for [kind]. Safe to show to the user.
  final String message;

  final int? statusCode;

  /// The backend's full `errors` array, when the response body matched the
  /// confirmed envelope shape — empty for network failures or responses
  /// that didn't match it.
  final List<ApiErrorItem> errors;

  /// Present only for debugging/logging — deliberately not surfaced in any
  /// user-facing string.
  final String? traceId;

  /// The backend-provided error attached to [field], if any — lets a form
  /// show a message under the specific input it belongs to.
  ApiErrorItem? errorForField(String field) {
    for (final error in errors) {
      if (error.field == field) return error;
    }
    return null;
  }

  /// True if the backend attached an error with this exact [code] anywhere
  /// in [errors] — lets a caller react to a specific confirmed backend
  /// error condition (e.g. `AUTH_EMAIL_NOT_VERIFIED`) without matching on
  /// [message] text, which is free-form and not meant to be parsed.
  bool hasErrorCode(String code) => errors.any((e) => e.code == code);

  @override
  String toString() =>
      'ApiException(kind: $kind, statusCode: $statusCode, message: $message, traceId: $traceId)';
}
