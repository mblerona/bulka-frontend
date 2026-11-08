import 'package:bulka_frontend/models/chat_message.dart';

/// Where a conversation stands on the backend. Anything unrecognized is
/// treated as [open].
enum ChatConversationStatus {
  open,
  closed,
  blocked;

  static ChatConversationStatus fromApi(String? value) {
    switch (value) {
      case 'Closed':
        return ChatConversationStatus.closed;
      case 'Blocked':
        return ChatConversationStatus.blocked;
      default:
        return ChatConversationStatus.open;
    }
  }
}

/// A conversation between a Buyer and a Provider, from
/// `GET /api/chat/conversations`.
///
/// The list only has the last message's text and time and the unread
/// count; [messages] is filled by `GET /api/chat/conversations/{id}` (its
/// first page only, for now) plus any sent on this device.
class ChatConversation {
  ChatConversation({
    required this.id,
    required this.buyerName,
    required this.providerName,
    this.buyerUserId,
    this.title,
    this.status = ChatConversationStatus.open,
    DateTime? startedAt,
    this.lastMessageText,
    this.lastMessageAt,
    this.unreadCount = 0,
    this.messages = const [],
  }) : startedAt = startedAt ?? DateTime.now();

  /// From the list, or from `GET /api/chat/conversations/{id}`, which also
  /// has the first page of `messages` (newest first; kept oldest first).
  factory ChatConversation.fromJson(Map<String, dynamic> json) {
    final page = json['messages'];
    final items = page is Map<String, dynamic> ? page['items'] : null;
    return ChatConversation(
      id: json['id'] as String? ?? '',
      buyerUserId: json['buyerUserId'] as String?,
      buyerName: json['buyerDisplayName'] as String? ?? '',
      providerName: json['providerDisplayName'] as String? ?? '',
      title: json['title'] as String?,
      status: ChatConversationStatus.fromApi(json['status'] as String?),
      startedAt: _parseDate(json['startedAtUtc']),
      lastMessageText: json['lastMessageBody'] as String?,
      lastMessageAt: _parseDate(json['lastMessageAtUtc']),
      unreadCount: (json['unreadCount'] as num?)?.toInt() ?? 0,
      messages: [
        if (items is List)
          for (final item in items)
            if (item is Map<String, dynamic>) ChatMessage.fromJson(item),
      ]..sort((a, b) => a.timestamp.compareTo(b.timestamp)),
    );
  }

  static DateTime? _parseDate(Object? value) =>
      value is String ? DateTime.tryParse(value) : null;

  final String id;

  /// The Buyer's user id: tells whether the signed-in user is the Buyer or
  /// the Provider here.
  final String? buyerUserId;
  final String buyerName;
  final String providerName;

  /// What it's about, e.g. the provider's business or listing. Shown under
  /// the other person's name.
  final String? title;
  final ChatConversationStatus status;
  final DateTime startedAt;
  final String? lastMessageText;
  final DateTime? lastMessageAt;

  /// Messages from the other person the signed-in user hasn't read.
  final int unreadCount;
  final List<ChatMessage> messages;

  /// The other person's name, for the user with [myUserId]: the Provider's
  /// when they're the Buyer, otherwise the Buyer's.
  String participantNameFor(String? myUserId) {
    final isBuyer = myUserId != null && myUserId == buyerUserId;
    final name = isBuyer ? providerName : buyerName;
    return name.isNotEmpty ? name : (isBuyer ? buyerName : providerName);
  }

  /// Up to two initials of [name], e.g. "LP" for "Local Provider".
  static String initialsOf(String name) {
    final words = name.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty);
    return words
        .take(2)
        .map((w) => String.fromCharCode(w.runes.first))
        .join()
        .toUpperCase();
  }

  /// The newest message's text: one sent here, or else the backend's.
  String? get previewText =>
      messages.isNotEmpty ? messages.last.text : lastMessageText;

  /// When the newest message was sent.
  DateTime get previewTime => messages.isNotEmpty
      ? messages.last.timestamp
      : (lastMessageAt ?? startedAt);

  ChatConversation copyWith({List<ChatMessage>? messages, int? unreadCount}) {
    return ChatConversation(
      id: id,
      buyerUserId: buyerUserId,
      buyerName: buyerName,
      providerName: providerName,
      title: title,
      status: status,
      startedAt: startedAt,
      lastMessageText: lastMessageText,
      lastMessageAt: lastMessageAt,
      unreadCount: unreadCount ?? this.unreadCount,
      messages: messages ?? this.messages,
    );
  }
}
