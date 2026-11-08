part of 'notifications_bloc.dart';

sealed class NotificationsEvent {
  const NotificationsEvent();
}

/// Loads the signed-in user's notifications, each time Notifications opens.
final class NotificationsRequested extends NotificationsEvent {
  const NotificationsRequested();
}

/// Loads how many notifications are unread, each time Notifications opens.
final class UnreadNotificationsCountRequested extends NotificationsEvent {
  const UnreadNotificationsCountRequested();
}

/// "Mark all as read"; marks every notification read on the backend.
final class AllNotificationsRead extends NotificationsEvent {
  const AllNotificationsRead();
}

/// The user tapped a notification; marks it read on the backend.
final class NotificationRead extends NotificationsEvent {
  const NotificationRead(this.notificationId);

  final String notificationId;
}
