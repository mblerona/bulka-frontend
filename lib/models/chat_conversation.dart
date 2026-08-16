import 'package:bulka_frontend/models/chat_message.dart';

/// A conversation between the current user and one other participant
/// (a guest, a property owner, or support). [unreadCount] and
/// [latestMessage] are always derived from [messages] — never stored
/// separately — so there is exactly one source of truth for what's
/// unread, matching the same rule the badges elsewhere in the app follow.
class ChatConversation {
  const ChatConversation({
    required this.id,
    required this.participantName,
    required this.avatarInitials,
    required this.messages,
    this.contextLabel,
  });

  final String id;
  final String participantName;
  final String avatarInitials;

  /// Reservation/ticket/listing reference shown under the participant's
  /// name, e.g. "Резервација #1042 · Villa Zdravkovski". Null when a
  /// conversation has no such context.
  final String? contextLabel;

  final List<ChatMessage> messages;

  ChatMessage? get latestMessage => messages.isEmpty ? null : messages.last;

  int get unreadCount => messages.where((m) => !m.isMine && !m.isRead).length;

  ChatConversation copyWith({List<ChatMessage>? messages}) {
    return ChatConversation(
      id: id,
      participantName: participantName,
      avatarInitials: avatarInitials,
      contextLabel: contextLabel,
      messages: messages ?? this.messages,
    );
  }
}
