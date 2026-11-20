part of 'support_tickets_bloc.dart';

enum SupportTicketsStatus { initial, loading, loaded, failed, notFound }

final class SupportTicketsState {
  SupportTicketsState({
    List<SupportTicket> tickets = const [],
    this.status = SupportTicketsStatus.initial,
    Map<String, SupportTicket> details = const {},
    Map<String, SupportTicketsStatus> detailsStatus = const {},
  }) : tickets = List.unmodifiable(tickets),
       details = Map.unmodifiable(details),
       detailsStatus = Map.unmodifiable(detailsStatus);

  /// Newest first.
  final List<SupportTicket> tickets;
  final SupportTicketsStatus status;

  // ── Ticket Details, by id (`GET /api/me/tickets/{id}`) ──
  final Map<String, SupportTicket> details;
  final Map<String, SupportTicketsStatus> detailsStatus;

  /// A ticket from the list by id.
  SupportTicket? byId(String id) {
    for (final ticket in tickets) {
      if (ticket.id == id) return ticket;
    }
    return null;
  }

  /// The loaded details, or else the ticket from the list (shown while the
  /// details load, and for a ticket created only on this device).
  SupportTicket? detailsFor(String id) => details[id] ?? byId(id);

  SupportTicketsStatus detailsStatusFor(String id) =>
      detailsStatus[id] ?? SupportTicketsStatus.initial;

  SupportTicketsState withTickets(List<SupportTicket> tickets) =>
      SupportTicketsState(
        tickets: tickets,
        status: status,
        details: details,
        detailsStatus: detailsStatus,
      );

  /// Updates one ticket's details entry. A failed reload keeps the details
  /// already shown.
  SupportTicketsState withDetails(
    String id, {
    required SupportTicketsStatus status,
    SupportTicket? ticket,
  }) {
    return SupportTicketsState(
      tickets: tickets,
      status: this.status,
      details: ticket == null ? details : {...details, id: ticket},
      detailsStatus: {...detailsStatus, id: status},
    );
  }
}
