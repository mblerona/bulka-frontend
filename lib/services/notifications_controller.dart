import 'package:flutter/foundation.dart';
import 'package:bulka_frontend/models/notification_item.dart';

/// Single shared source of truth for the signed-in user's notifications.
///
/// Both the Notifications screen and the unread badge on the bottom nav
/// bar (Tourist and Provider alike — it's the same user's inbox either
/// way) read from this one [instance], so marking a notification as read
/// anywhere updates both immediately via [ChangeNotifier].
///
/// There's no notifications API yet, so [_notifications] starts out as
/// local mock data reproducing the Figma example. Swapping in real data
/// later only means replacing [_mockNotifications] (and [markAsRead]'s
/// body with an API call) — nothing that reads [notifications] or
/// [unreadCount] needs to change.
class NotificationsController extends ChangeNotifier {
  NotificationsController._() : _notifications = _mockNotifications();

  static final NotificationsController instance = NotificationsController._();

  List<NotificationItem> _notifications;

  List<NotificationItem> get notifications => List.unmodifiable(_notifications);

  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  void markAsRead(String id) {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index == -1 || _notifications[index].isRead) return;
    _notifications = [
      for (final n in _notifications)
        if (n.id == id) n.copyWith(isRead: true) else n,
    ];
    notifyListeners();
  }

  static List<NotificationItem> _mockNotifications() {
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
}
