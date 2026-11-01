import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bulka_frontend/core/network/api_client.dart';
import 'package:bulka_frontend/core/network/api_exception.dart';
import 'package:bulka_frontend/core/network/api_response.dart';
import 'package:bulka_frontend/core/network/auth_interceptor.dart';
import 'package:bulka_frontend/models/home_category.dart';

part 'categories_event.dart';
part 'categories_state.dart';

/// Loads the offer categories from `GET /api/categories`. The names come
/// back in the app's current language, so screens ask again after a
/// language switch ([CategoriesState.needsLoadFor]).
class CategoriesBloc extends Bloc<CategoriesEvent, CategoriesState> {
  CategoriesBloc({Dio? dio})
    : _dio = dio ?? ApiClient.instance.dio,
      super(const CategoriesState()) {
    on<CategoriesRequested>(_onRequested);
  }

  final Dio _dio;

  /// Increases with every request, so an older response that arrives late
  /// (e.g. after a quick language switch) doesn't replace a newer one.
  int _latestRequest = 0;

  Future<void> _onRequested(
    CategoriesRequested event,
    Emitter<CategoriesState> emit,
  ) async {
    final request = ++_latestRequest;
    emit(state.loading(event.languageCode));
    try {
      final categories = await _fetch();
      if (request != _latestRequest) return;
      emit(state.loaded(categories, event.languageCode));
    } on ApiException catch (e) {
      if (request != _latestRequest) return;
      emit(state.failed(e));
    }
  }

  Future<List<HomeCategory>> _fetch() async {
    final Response<Object?> response;
    try {
      // Public endpoint: no token needed, and a 401 shouldn't trigger a
      // refresh.
      response = await _dio.get<Object?>(
        '/api/categories',
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
    final data = envelope.data;
    if (data is! List) throw const ApiException(kind: ApiErrorKind.unknown);
    return [
      for (final item in data)
        if (item is Map<String, dynamic>) HomeCategory.fromJson(item),
    ];
  }
}
