import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bulka_frontend/core/network/api_client.dart';
import 'package:bulka_frontend/core/network/api_exception.dart';
import 'package:bulka_frontend/core/network/api_response.dart';
import 'package:bulka_frontend/models/support_attachment.dart';
import 'package:bulka_frontend/models/support_ticket.dart';

part 'support_tickets_event.dart';
part 'support_tickets_state.dart';

/// The signed-in user's support tickets, from `GET /api/me/tickets`, and
/// one ticket's details from `GET /api/me/tickets/{id}`.
///
/// Creating a ticket is still local only (`POST /api/me/tickets` isn't
/// connected), so a created ticket is gone after the next load.
class SupportTicketsBloc
    extends Bloc<SupportTicketsEvent, SupportTicketsState> {
  SupportTicketsBloc({Dio? dio})
    : _dio = dio ?? ApiClient.instance.dio,
      super(SupportTicketsState()) {
    on<SupportTicketsRequested>(_onRequested);
    on<SupportTicketDetailsRequested>(_onDetailsRequested);
    on<SupportTicketCreated>((event, emit) {
      final now = DateTime.now();
      final ticketNumber = _nextTicketNumber++;
      final ticket = SupportTicket(
        id: '$ticketNumber',
        number: '#$ticketNumber',
        category: event.category,
        title: event.title,
        description: event.description,
        createdAt: now,
        updatedAt: now,
        status: TicketStatus.open,
        attachments: [?event.attachment],
      );
      _localIds.add(ticket.id);
      emit(state.withTickets([ticket, ...state.tickets]));
    });
  }

  final Dio _dio;

  int _nextTicketNumber = 67;

  /// Tickets created on this device, which the backend doesn't know.
  final Set<String> _localIds = {};

  // Increases with every list request, so an older response that arrives
  // late (list or details) doesn't replace a newer one.
  int _latestRequest = 0;

  Future<void> _onRequested(
    SupportTicketsRequested event,
    Emitter<SupportTicketsState> emit,
  ) async {
    final request = ++_latestRequest;
    // The old list (and details) are dropped, as they may belong to a
    // previous account.
    _localIds.clear();
    emit(SupportTicketsState(status: SupportTicketsStatus.loading));
    try {
      final data = await _getData('/api/me/tickets');
      if (data is! List) throw const ApiException(kind: ApiErrorKind.unknown);
      final tickets = [
        for (final item in data)
          if (item is Map<String, dynamic>) SupportTicket.fromJson(item),
      ]..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      if (request != _latestRequest) return;
      emit(
        SupportTicketsState(
          tickets: tickets,
          status: SupportTicketsStatus.loaded,
        ),
      );
    } on ApiException {
      if (request != _latestRequest) return;
      emit(SupportTicketsState(status: SupportTicketsStatus.failed));
    }
  }

  Future<void> _onDetailsRequested(
    SupportTicketDetailsRequested event,
    Emitter<SupportTicketsState> emit,
  ) async {
    final id = event.id;
    if (_localIds.contains(id)) {
      emit(state.withDetails(id, status: SupportTicketsStatus.loaded));
      return;
    }
    final request = _latestRequest;
    emit(state.withDetails(id, status: SupportTicketsStatus.loading));
    try {
      final data = await _getData('/api/me/tickets/${Uri.encodeComponent(id)}');
      if (data is! Map<String, dynamic>) {
        throw const ApiException(kind: ApiErrorKind.unknown);
      }
      if (request != _latestRequest) return;
      emit(
        state.withDetails(
          id,
          status: SupportTicketsStatus.loaded,
          ticket: SupportTicket.fromJson(data),
        ),
      );
    } on ApiException catch (e) {
      if (request != _latestRequest) return;
      emit(
        state.withDetails(
          id,
          status: e.statusCode == 404
              ? SupportTicketsStatus.notFound
              : SupportTicketsStatus.failed,
        ),
      );
    }
  }

  /// The envelope's `data` for a GET to [path].
  Future<Object?> _getData(String path) async {
    final Response<Object?> response;
    try {
      response = await _dio.get<Object?>(path);
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
}
