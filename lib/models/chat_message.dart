/// A single message within a [ChatConversation], from the `messages` of
/// `GET /api/chat/conversations/{id}`, or one sent on this device.
class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.conversationId,
    required this.text,
    required this.timestamp,
    required this.isMine,
    this.isRead = false,
    this.senderUserId,
    this.isDeleted = false,
  });

  /// Messages the backend sends are already read or counted in the
  /// conversation's `unreadCount`, so they start read here.
  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] as String? ?? '',
      conversationId: json['conversationId'] as String? ?? '',
      text: json['body'] as String? ?? '',
      timestamp: _parseDate(json['createdAtUtc']) ?? DateTime.now(),
      isMine: false,
      isRead: true,
      senderUserId: json['senderUserId'] as String?,
      isDeleted: _parseDate(json['deletedAtUtc']) != null,
    );
  }

  static DateTime? _parseDate(Object? value) =>
      value is String ? DateTime.tryParse(value) : null;

  final String id;
  final String conversationId;
  final String text;
  final DateTime timestamp;

  /// True for a message sent on this device. For one from the backend, use
  /// [isMineFor].
  final bool isMine;

  final bool isRead;

  /// Who sent it (from the backend); null for one sent on this device.
  final String? senderUserId;

  /// Deleted on the backend (`deletedAtUtc` set); shown as "deleted".
  final bool isDeleted;

  /// Whether the user with [myUserId] sent it (outgoing, right-aligned
  /// green bubble) rather than the other person (incoming, left-aligned
  /// cream bubble).
  bool isMineFor(String? myUserId) =>
      isMine || (myUserId != null && senderUserId == myUserId);

  ChatMessage copyWith({bool? isRead}) {
    return ChatMessage(
      id: id,
      conversationId: conversationId,
      text: text,
      timestamp: timestamp,
      isMine: isMine,
      isRead: isRead ?? this.isRead,
      senderUserId: senderUserId,
      isDeleted: isDeleted,
    );
  }
}
