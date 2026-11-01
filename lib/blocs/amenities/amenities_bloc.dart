import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bulka_frontend/core/network/api_client.dart';
import 'package:bulka_frontend/core/network/api_exception.dart';
import 'package:bulka_frontend/core/network/api_response.dart';
import 'package:bulka_frontend/core/network/auth_interceptor.dart';
import 'package:bulka_frontend/models/amenity.dart';

part 'amenities_event.dart';
part 'amenities_state.dart';

/// Loads the amenities from `GET /api/amenities`. The names come back in
/// the app's current language, so screens ask again after a language
/// switch ([AmenitiesState.needsLoadFor]).
class AmenitiesBloc extends Bloc<AmenitiesEvent, AmenitiesState> {
  AmenitiesBloc({Dio? dio})
    : _dio = dio ?? ApiClient.instance.dio,
      super(const AmenitiesState()) {
    on<AmenitiesRequested>(_onRequested);
  }

  final Dio _dio;

  /// Increases with every request, so an older response that arrives late
  /// (e.g. after a quick language switch) doesn't replace a newer one.
  int _latestRequest = 0;

  Future<void> _onRequested(
    AmenitiesRequested event,
    Emitter<AmenitiesState> emit,
  ) async {
    final request = ++_latestRequest;
    emit(state.loading(event.languageCode));
    try {
      final amenities = await _fetch();
      if (request != _latestRequest) return;
      emit(state.loaded(amenities, event.languageCode));
    } on ApiException catch (e) {
      if (request != _latestRequest) return;
      emit(state.failed(e));
    }
  }

  Future<List<Amenity>> _fetch() async {
    final Response<Object?> response;
    try {
      // Public endpoint: no token needed, and a 401 shouldn't trigger a
      // refresh.
      response = await _dio.get<Object?>(
        '/api/amenities',
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
        if (item is Map<String, dynamic>) Amenity.fromJson(item),
    ];
  }
}
