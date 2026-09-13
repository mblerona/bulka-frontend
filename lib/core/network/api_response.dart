import 'package:bulka_frontend/core/network/api_exception.dart';

/// Generic wrapper for the backend's response envelope, confirmed on both a
/// successful and a failed `POST /api/auth/login` call:
/// ```json
/// { "success": true, "data": { ... }, "errors": [], "traceId": null }
/// { "success": false, "data": null, "errors": [ {...} ], "traceId": "..." }
/// ```
/// Callers decode the typed `data` payload via [fromJsonT] — this class
/// itself doesn't assume what shape `data` is.
class ApiResponse<T> {
  const ApiResponse({
    required this.success,
    required this.data,
    required this.errors,
    required this.traceId,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) {
    final rawData = json['data'];
    return ApiResponse<T>(
      success: json['success'] as bool? ?? false,
      data: rawData == null ? null : fromJsonT(rawData),
      errors: (json['errors'] as List<dynamic>? ?? const [])
          .whereType<Map>()
          .map((e) => ApiErrorItem.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      traceId: json['traceId'] as String?,
    );
  }

  final bool success;
  final T? data;
  final List<ApiErrorItem> errors;
  final String? traceId;
}
