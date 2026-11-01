// Mock seed data until this feature is connected to the backend.
import 'package:bulka_frontend/models/support_ticket.dart';

List<SupportTicket> mockTickets() {
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
