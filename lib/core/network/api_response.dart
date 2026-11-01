/// One entry of the backend's `errors` array.
class ApiError {
  const ApiError({this.code, this.message, this.field});

  factory ApiError.fromJson(Map<String, dynamic> json) {
    return ApiError(
      code: json['code'] as String?,
      message: json['message'] as String?,
      field: json['field'] as String?,
    );
  }

  final String? code;
  final String? message;

  /// The request field the error is about (e.g. "email"), if any.
  final String? field;
}

/// The envelope most endpoints wrap their result in:
/// `{ success, data, errors, traceId }`.
class ApiResponse<T> {
  const ApiResponse({
    required this.success,
    required this.data,
    required this.errors,
    this.traceId,
  });

  /// [parseData] turns the raw `data` value into [T]. It's only called when
  /// `data` is present.
  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? data) parseData,
  ) {
    final rawData = json['data'];
    return ApiResponse(
      success: json['success'] as bool? ?? false,
      data: rawData == null ? null : parseData(rawData),
      errors: parseApiErrors(json['errors']),
      traceId: json['traceId'] as String?,
    );
  }

  final bool success;
  final T? data;
  final List<ApiError> errors;
  final String? traceId;
}

/// A page of results: `{ items, page, pageSize, totalCount, totalPages }`.
class PaginatedResponse<T> {
  const PaginatedResponse({
    required this.items,
    required this.page,
    required this.pageSize,
    required this.totalCount,
    required this.totalPages,
  });

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic> item) parseItem,
  ) {
    final rawItems = json['items'] as List<dynamic>? ?? const [];
    return PaginatedResponse(
      items: [
        for (final item in rawItems) parseItem(item as Map<String, dynamic>),
      ],
      page: json['page'] as int? ?? 1,
      pageSize: json['pageSize'] as int? ?? rawItems.length,
      totalCount: json['totalCount'] as int? ?? rawItems.length,
      totalPages: json['totalPages'] as int? ?? 1,
    );
  }

  final List<T> items;
  final int page;
  final int pageSize;
  final int totalCount;
  final int totalPages;

  bool get hasMore => page < totalPages;
}

List<ApiError> parseApiErrors(Object? raw) {
  if (raw is! List) return const [];
  return [
    for (final e in raw)
      if (e is Map<String, dynamic>) ApiError.fromJson(e),
  ];
}
