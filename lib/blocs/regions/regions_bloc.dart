import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bulka_frontend/core/network/api_client.dart';
import 'package:bulka_frontend/core/network/api_exception.dart';
import 'package:bulka_frontend/core/network/public_api.dart';
import 'package:bulka_frontend/models/region.dart';

part 'regions_event.dart';
part 'regions_state.dart';

/// Loads the regions from `GET /api/regions` for the search filter's
/// location picker. The names come back in the app's current language, so
/// screens ask again after a language switch ([RegionsState.needsLoadFor]).
class RegionsBloc extends Bloc<RegionsEvent, RegionsState> {
  RegionsBloc({Dio? dio})
    : _dio = dio ?? ApiClient.instance.dio,
      super(const RegionsState()) {
    on<RegionsRequested>(_onRequested);
  }

  final Dio _dio;

  /// Increases with every request, so an older response that arrives late
  /// doesn't replace a newer one.
  int _latestRequest = 0;

  Future<void> _onRequested(
    RegionsRequested event,
    Emitter<RegionsState> emit,
  ) async {
    final request = ++_latestRequest;
    emit(state.loading(event.languageCode));
    try {
      final json = await getPublicList(_dio, '/api/regions');
      if (request != _latestRequest) return;
      emit(state.loaded([for (final r in json) Region.fromJson(r)]));
    } on ApiException catch (e) {
      if (request != _latestRequest) return;
      emit(state.failed(e));
    }
  }
}
