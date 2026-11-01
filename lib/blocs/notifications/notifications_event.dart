part of 'notifications_bloc.dart';

sealed class NotificationsEvent {
  const NotificationsEvent();
}

final class NotificationRead extends NotificationsEvent {
  const NotificationRead(this.notificationId);

  final String notificationId;
}
