part of 'chat_bloc.dart';

enum ChatStatus { initial, loading, loaded, failed, notFound }

final class ChatState {
  ChatState({
    List<ChatConversation> conversations = const [],
    this.status = ChatStatus.initial,
    Map<String, ChatConversation> details = const {},
    Map<String, ChatStatus> detailsStatus = const {},
  }) : conversations = List.unmodifiable(conversations),
       details = Map.unmodifiable(details),
       detailsStatus = Map.unmodifiable(detailsStatus);

  /// Newest message first.
  final List<ChatConversation> conversations;
  final ChatStatus status;

  // ── One conversation with its messages, by id ──
  final Map<String, ChatConversation> details;
  final Map<String, ChatStatus> detailsStatus;

  /// A conversation from the list.
  ChatConversation? byId(String id) {
    for (final conversation in conversations) {
      if (conversation.id == id) return conversation;
    }
    return null;
  }

  /// The conversation with its loaded messages, or else the one from the
  /// list (shown while the messages load).
  ChatConversation? detailsFor(String id) => details[id] ?? byId(id);

  ChatStatus detailsStatusFor(String id) =>
      detailsStatus[id] ?? ChatStatus.initial;

  int get totalUnreadMessages =>
      conversations.fold(0, (sum, c) => sum + c.unreadCount);

  /// The same state with [conversations] (and [details]) replaced.
  ChatState copyWith({
    List<ChatConversation>? conversations,
    Map<String, ChatConversation>? details,
    Map<String, ChatStatus>? detailsStatus,
  }) => ChatState(
    conversations: conversations ?? this.conversations,
    status: status,
    details: details ?? this.details,
    detailsStatus: detailsStatus ?? this.detailsStatus,
  );
}
