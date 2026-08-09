import 'package:flutter/foundation.dart';
import 'package:bulka_frontend/models/support_attachment.dart';
import 'package:bulka_frontend/models/support_ticket.dart';

/// Single shared source of truth for the signed-in user's support tickets —
/// same singleton + `ChangeNotifier` pattern as `NotificationsController`
/// and `ChatController`, so My Tickets re-renders automatically whenever a
/// ticket is created elsewhere (the New Ticket screen).
///
/// There's no support API yet, so [_tickets] starts out as local mock data
/// reproducing the Figma example, and [createTicket] only appends locally.
/// Swapping in a real backend later only means replacing [_mockTickets]
/// and [createTicket]'s body with an API call — nothing that reads
/// [tickets] needs to change.
class SupportTicketController extends ChangeNotifier {
  SupportTicketController._()
    : _tickets = _mockTickets(),
      _nextTicketNumber = 67;

  static final SupportTicketController instance = SupportTicketController._();

  List<SupportTicket> _tickets;
  int _nextTicketNumber;

  List<SupportTicket> get tickets => List.unmodifiable(_tickets);

  SupportTicket createTicket({
    required String category,
    required String title,
    required String description,
    SupportAttachment? attachment,
  }) {
    final now = DateTime.now();
    final ticket = SupportTicket(
      id: '${_nextTicketNumber++}',
      category: category,
      title: title,
      description: description,
      createdAt: now,
      updatedAt: now,
      status: TicketStatus.open,
      attachment: attachment,
    );
    _tickets = [ticket, ..._tickets];
    notifyListeners();
    return ticket;
  }

  static List<SupportTicket> _mockTickets() {
    final now = DateTime.now();
    return [
      SupportTicket(
        id: '58',
        category: 'Резервации',
        title: 'Проблем со плаќање на резервација',
        description: '',
        createdAt: now.subtract(const Duration(days: 3)),
        updatedAt: now.subtract(const Duration(days: 2)),
        status: TicketStatus.resolved,
      ),
      SupportTicket(
        id: '61',
        category: 'Огласи',
        title: 'Не можам да ја уредам понудата',
        description: '',
        createdAt: now.subtract(const Duration(hours: 8)),
        updatedAt: now.subtract(const Duration(hours: 5)),
        status: TicketStatus.inProgress,
      ),
      SupportTicket(
        id: '64',
        category: 'Плаќање',
        title: 'Прашање за провизија на платформата',
        description: '',
        createdAt: now.subtract(const Duration(days: 1)),
        updatedAt: now.subtract(const Duration(days: 1)),
        status: TicketStatus.open,
      ),
      SupportTicket(
        id: '66',
        category: 'Профил',
        title: 'Барање за бришење слика од профил',
        description: '',
        createdAt: now.subtract(const Duration(hours: 4)),
        updatedAt: now.subtract(const Duration(hours: 3)),
        status: TicketStatus.inProgress,
      ),
    ];
  }
}
