import 'package:dio/dio.dart';
import 'package:bulka_frontend/core/network/api_exception.dart';
import 'package:bulka_frontend/core/network/api_response.dart';
import 'package:bulka_frontend/core/network/auth_interceptor.dart';

/// GETs a public endpoint (no token sent, a 401 doesn't trigger a refresh)
/// and returns the envelope's `data`. Throws [ApiException] on any failure.
Future<Object?> getPublicData(
  Dio dio,
  String path, {
  Map<String, Object?>? query,
}) async {
  final Response<Object?> response;
  try {
    response = await dio.get<Object?>(
      path,
      queryParameters: query,
      options: Options(extra: {skipAuth: true}),
    );
  } on DioException catch (e) {
    throw ApiException.fromDio(e);
  }
  final json = response.data;
  if (json is! Map<String, dynamic>) {
    throw const ApiException(kind: ApiErrorKind.unknown);
  }
  final envelope = ApiResponse<Object?>.fromJson(json, (data) => data);
  if (!envelope.success) throw ApiException.fromEnvelope(envelope);
  return envelope.data;
}

/// [getPublicData] for endpoints whose `data` is a JSON array.
Future<List<Map<String, dynamic>>> getPublicList(
  Dio dio,
  String path, {
  Map<String, Object?>? query,
}) async {
  final data = await getPublicData(dio, path, query: query);
  if (data is! List) throw const ApiException(kind: ApiErrorKind.unknown);
  return [
    for (final item in data)
      if (item is Map<String, dynamic>) item,
  ];
}
