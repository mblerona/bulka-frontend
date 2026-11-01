import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bulka_frontend/core/network/api_client.dart';
import 'package:bulka_frontend/core/network/api_exception.dart';
import 'package:bulka_frontend/core/network/public_api.dart';
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
    final json = await getPublicList(_dio, '/api/categories');
    return [for (final item in json) HomeCategory.fromJson(item)];
  }
}
