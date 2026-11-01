part of 'support_tickets_bloc.dart';

final class SupportTicketsState {
  SupportTicketsState(List<SupportTicket> tickets)
    : tickets = List.unmodifiable(tickets);

  /// Newest first.
  final List<SupportTicket> tickets;
}
