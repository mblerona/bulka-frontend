import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bulka_frontend/core/network/api_client.dart';
import 'package:bulka_frontend/core/network/api_exception.dart';
import 'package:bulka_frontend/core/network/public_api.dart';
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
    final json = await getPublicList(_dio, '/api/amenities');
    return [for (final item in json) Amenity.fromJson(item)];
  }
}
