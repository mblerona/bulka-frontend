part of 'chat_bloc.dart';

final class ChatState {
  ChatState(List<ChatConversation> conversations)
    : conversations = List.unmodifiable(conversations);

  final List<ChatConversation> conversations;

  ChatConversation? byId(String id) {
    for (final conversation in conversations) {
      if (conversation.id == id) return conversation;
    }
    return null;
  }

  int get totalUnreadMessages =>
      conversations.fold(0, (sum, c) => sum + c.unreadCount);
}
