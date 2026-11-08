part of 'notifications_bloc.dart';

enum NotificationsStatus { initial, loading, loaded, failed }

final class NotificationsState {
  NotificationsState({
    List<NotificationItem> notifications = const [],
    this.status = NotificationsStatus.initial,
    this.serverUnreadCount,
  }) : notifications = List.unmodifiable(notifications);

  /// Newest first.
  final List<NotificationItem> notifications;
  final NotificationsStatus status;

  /// From `GET /api/me/notifications/unread-count`; null until it loads or
  /// if it failed.
  final int? serverUnreadCount;

  /// The backend's count when it's known, otherwise the unread ones in
  /// [notifications].
  int get unreadCount =>
      serverUnreadCount ?? notifications.where((n) => !n.isRead).length;
}
