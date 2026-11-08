part of 'support_tickets_bloc.dart';

sealed class SupportTicketsEvent {
  const SupportTicketsEvent();
}

/// Loads the signed-in user's tickets, each time My Tickets opens.
final class SupportTicketsRequested extends SupportTicketsEvent {
  const SupportTicketsRequested();
}

/// Loads (or reloads) one ticket's details, each time Ticket Details opens.
final class SupportTicketDetailsRequested extends SupportTicketsEvent {
  const SupportTicketDetailsRequested(this.id);

  final String id;
}

/// From the New Support Ticket screen; the ticket starts "open".
final class SupportTicketCreated extends SupportTicketsEvent {
  const SupportTicketCreated({
    required this.category,
    required this.title,
    required this.description,
    this.attachment,
  });

  final String category;
  final String title;
  final String description;
  final SupportAttachment? attachment;
}
