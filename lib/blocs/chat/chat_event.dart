part of 'chat_bloc.dart';

sealed class ChatEvent {
  const ChatEvent();
}

/// The user opened a conversation: its unread messages become read.
final class ConversationRead extends ChatEvent {
  const ConversationRead(this.conversationId);

  final String conversationId;
}

final class ChatMessageSent extends ChatEvent {
  const ChatMessageSent({required this.conversationId, required this.text});

  final String conversationId;
  final String text;
}
