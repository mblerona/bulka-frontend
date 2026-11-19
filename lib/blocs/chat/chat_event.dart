part of 'chat_bloc.dart';

sealed class ChatEvent {
  const ChatEvent();
}

/// Loads the signed-in user's conversations: when the tabs open (for the
/// Messages badge) and each time the chat list opens.
final class ChatConversationsRequested extends ChatEvent {
  const ChatConversationsRequested({this.keepShown = false});

  /// Keep the conversations already shown while the new list loads (so the
  /// Messages badge doesn't drop to 0). Only for a reload by the same user;
  /// when the tabs open (possibly after another account signed in) the old
  /// list is dropped.
  final bool keepShown;
}

/// Loads (or reloads) one conversation's messages, each time its thread
/// opens.
final class ChatConversationDetailsRequested extends ChatEvent {
  const ChatConversationDetailsRequested(this.conversationId);

  final String conversationId;
}

/// The user opened a conversation: its unread count is cleared straight
/// away, and once its messages are loaded the backend is told
/// (`POST /api/chat/conversations/{id}/read`) up to the newest one.
final class ConversationRead extends ChatEvent {
  const ConversationRead(this.conversationId);

  final String conversationId;
}

/// `POST /api/chat/conversations/{id}/messages`; shown as sending straight
/// away.
final class ChatMessageSent extends ChatEvent {
  const ChatMessageSent({required this.conversationId, required this.text});

  final String conversationId;
  final String text;
}

/// Sends a failed message again, with the same `clientMessageKey`.
final class ChatMessageRetried extends ChatEvent {
  const ChatMessageRetried({
    required this.conversationId,
    required this.clientMessageKey,
  });

  final String conversationId;
  final String clientMessageKey;
}
