/// A single message within a [ChatConversation]. Shaped to map directly
/// onto a future chat API/WebSocket payload (id/conversationId/text/
/// timestamp/isMine/isRead) so the mock data in `ChatController` can be
/// swapped for real fetched/streamed messages without changing this model.
class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.conversationId,
    required this.text,
    required this.timestamp,
    required this.isMine,
    this.isRead = false,
  });

  final String id;
  final String conversationId;
  final String text;
  final DateTime timestamp;

  /// True for messages sent by the current user (outgoing, right-aligned
  /// green bubble); false for messages from the other participant
  /// (incoming, left-aligned cream bubble).
  final bool isMine;

  final bool isRead;

  ChatMessage copyWith({bool? isRead}) {
    return ChatMessage(
      id: id,
      conversationId: conversationId,
      text: text,
      timestamp: timestamp,
      isMine: isMine,
      isRead: isRead ?? this.isRead,
    );
  }
}
