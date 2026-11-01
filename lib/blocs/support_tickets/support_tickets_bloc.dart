import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bulka_frontend/blocs/support_tickets/support_tickets_mock_data.dart';
import 'package:bulka_frontend/models/support_attachment.dart';
import 'package:bulka_frontend/models/support_ticket.dart';

part 'support_tickets_event.dart';
part 'support_tickets_state.dart';

/// The user's support tickets. Mock data until the tickets API is
/// connected.
class SupportTicketsBloc
    extends Bloc<SupportTicketsEvent, SupportTicketsState> {
  SupportTicketsBloc({List<SupportTicket>? initialTickets})
    : super(SupportTicketsState(initialTickets ?? mockTickets())) {
    on<SupportTicketCreated>((event, emit) {
      final now = DateTime.now();
      final ticket = SupportTicket(
        id: '${_nextTicketNumber++}',
        category: event.category,
        title: event.title,
        description: event.description,
        createdAt: now,
        updatedAt: now,
        status: TicketStatus.open,
        attachment: event.attachment,
      );
      emit(SupportTicketsState([ticket, ...state.tickets]));
    });
  }

  int _nextTicketNumber = 67;
}
