/// A single in-app notification. Shaped to map directly onto a future
/// notifications API response (id/title/message/timestamp/isRead) so the
/// mock data in [NotificationsController] can be swapped for real fetched
/// records without changing this model or anything that reads it.
class NotificationItem {
  const NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    this.isRead = false,
  });

  final String id;
  final String title;
  final String message;
  final DateTime timestamp;
  final bool isRead;

  NotificationItem copyWith({bool? isRead}) {
    return NotificationItem(
      id: id,
      title: title,
      message: message,
      timestamp: timestamp,
      isRead: isRead ?? this.isRead,
    );
  }
}
