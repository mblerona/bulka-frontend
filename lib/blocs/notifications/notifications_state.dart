part of 'notifications_bloc.dart';

final class NotificationsState {
  NotificationsState(List<NotificationItem> notifications)
    : notifications = List.unmodifiable(notifications);

  final List<NotificationItem> notifications;

  int get unreadCount => notifications.where((n) => !n.isRead).length;
}
