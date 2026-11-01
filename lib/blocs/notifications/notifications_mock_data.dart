// Mock seed data until this feature is connected to the backend.
import 'package:bulka_frontend/models/notification_item.dart';

List<NotificationItem> mockNotifications() {
  final now = DateTime.now();
  return [
    NotificationItem(
      id: '1',
      title: 'Резервацијата е потврдена',
      message:
          'Вашата резервација во Villa Zdravkovski е потврдена за 12–15 '
          'август.',
      timestamp: now.subtract(const Duration(minutes: 2)),
      isRead: false,
    ),
    NotificationItem(
      id: '2',
      title: 'Нова порака',
      message: 'Стефан: Дали има паркинг во близина на имотот?',
      timestamp: now.subtract(const Duration(minutes: 15)),
      isRead: false,
    ),
    NotificationItem(
      id: '3',
      title: 'Потсетување за плаќање',
      message: 'Плаќањето за резервацијата #1042 доспева утре.',
      timestamp: now.subtract(const Duration(hours: 1)),
      isRead: false,
    ),
    NotificationItem(
      id: '4',
      title: 'Одговор од поддршка',
      message: 'Вашето барање #58 е решено од тимот за поддршка.',
      timestamp: now.subtract(const Duration(hours: 3)),
      isRead: true,
    ),
    NotificationItem(
      id: '5',
      title: 'Нова промоција',
      message: '20% попуст за есенски резервации до крајот на месецот.',
      timestamp: now.subtract(const Duration(days: 1)),
      isRead: true,
    ),
  ];
}
