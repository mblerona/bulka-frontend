/// A single in-app notification, from `GET /api/me/notifications`.
class NotificationItem {
  const NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    this.isRead = false,
    this.type = '',
    this.linkUrl,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      message: json['body'] as String? ?? '',
      timestamp: _parseDate(json['createdAtUtc']) ?? DateTime.now(),
      isRead: _parseDate(json['readAtUtc']) != null,
      type: json['type'] as String? ?? '',
      linkUrl: json['linkUrl'] as String?,
    );
  }

  /// Whether the user has dismissed it (`dismissedAtUtc` is set); those
  /// aren't shown.
  static bool isDismissed(Map<String, dynamic> json) =>
      _parseDate(json['dismissedAtUtc']) != null;

  static DateTime? _parseDate(Object? value) =>
      value is String ? DateTime.tryParse(value) : null;

  final String id;
  final String title;
  final String message;
  final DateTime timestamp;
  final bool isRead;

  /// The backend's category, e.g. "Booking".
  final String type;

  /// The backend's web path for what it's about, e.g. `/bookings/{id}`.
  /// Not opened anywhere yet.
  final String? linkUrl;

  NotificationItem copyWith({bool? isRead}) {
    return NotificationItem(
      id: id,
      title: title,
      message: message,
      timestamp: timestamp,
      isRead: isRead ?? this.isRead,
      type: type,
      linkUrl: linkUrl,
    );
  }
}
