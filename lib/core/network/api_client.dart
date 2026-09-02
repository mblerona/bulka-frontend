import 'package:dio/dio.dart';
import 'package:bulka_frontend/core/network/api_environment.dart';

/// Single shared Dio instance for all backend calls. Services should take
/// this in via constructor rather than creating their own Dio instances.
class ApiClient {
  ApiClient._internal(this.dio);

  static final ApiClient instance = ApiClient._internal(
    Dio(
      BaseOptions(
        baseUrl: ApiEnvironment.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: const {'Content-Type': 'application/json'},
      ),
    ),
  );

  final Dio dio;

  // TODO: once auth is implemented, add an Interceptor here that attaches
  // the stored auth token to every request (and handles 401 refresh/logout).
  void addInterceptor(Interceptor interceptor) {
    dio.interceptors.add(interceptor);
  }
}
