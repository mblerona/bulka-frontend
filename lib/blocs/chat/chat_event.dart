part of 'chat_bloc.dart';

sealed class ChatEvent {
  const ChatEvent();
}

/// Loads the signed-in user's conversations: when the tabs open (for the
/// Messages badge) and each time the chat list opens.
final class ChatConversationsRequested extends ChatEvent {
  const ChatConversationsRequested();
}

/// Loads (or reloads) one conversation's messages, each time its thread
/// opens.
final class ChatConversationDetailsRequested extends ChatEvent {
  const ChatConversationDetailsRequested(this.conversationId);

  final String conversationId;
}

/// The user opened a conversation: its unread count is cleared. Only on
/// this device for now (`POST /api/chat/conversations/{id}/read` isn't
/// connected).
final class ConversationRead extends ChatEvent {
  const ConversationRead(this.conversationId);

  final String conversationId;
}

/// Only on this device for now (`POST .../{id}/messages` isn't connected).
final class ChatMessageSent extends ChatEvent {
  const ChatMessageSent({required this.conversationId, required this.text});

  final String conversationId;
  final String text;
}
