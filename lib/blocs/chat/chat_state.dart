part of 'chat_bloc.dart';

enum ChatStatus { initial, loading, loaded, failed, notFound }

enum ChatStartStatus { idle, starting, started, failed }

/// The latest request to start a conversation with a provider.
final class ChatStart {
  const ChatStart({
    this.status = ChatStartStatus.idle,
    this.providerProfileId,
    this.conversationId,
  });

  final ChatStartStatus status;
  final String? providerProfileId;

  /// Once [ChatStartStatus.started]: the conversation to open.
  final String? conversationId;
}

final class ChatState {
  ChatState({
    List<ChatConversation> conversations = const [],
    this.status = ChatStatus.initial,
    Map<String, ChatConversation> details = const {},
    Map<String, ChatStatus> detailsStatus = const {},
    this.start = const ChatStart(),
  }) : conversations = List.unmodifiable(conversations),
       details = Map.unmodifiable(details),
       detailsStatus = Map.unmodifiable(detailsStatus);

  /// Newest message first.
  final List<ChatConversation> conversations;
  final ChatStatus status;

  // ── One conversation with its messages, by id ──
  final Map<String, ChatConversation> details;
  final Map<String, ChatStatus> detailsStatus;

  final ChatStart start;

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

  /// The same state with the given fields replaced.
  ChatState copyWith({
    List<ChatConversation>? conversations,
    ChatStatus? status,
    Map<String, ChatConversation>? details,
    Map<String, ChatStatus>? detailsStatus,
    ChatStart? start,
  }) => ChatState(
    conversations: conversations ?? this.conversations,
    status: status ?? this.status,
    details: details ?? this.details,
    detailsStatus: detailsStatus ?? this.detailsStatus,
    start: start ?? this.start,
  );
}
