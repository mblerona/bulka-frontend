part of 'support_tickets_bloc.dart';

sealed class SupportTicketsEvent {
  const SupportTicketsEvent();
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
