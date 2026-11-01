import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bulka_frontend/blocs/chat/chat_mock_data.dart';
import 'package:bulka_frontend/models/chat_conversation.dart';
import 'package:bulka_frontend/models/chat_message.dart';

part 'chat_event.dart';
part 'chat_state.dart';

/// Conversations for both roles; the bottom nav's Messages badge shows
/// [ChatState.totalUnreadMessages]. Mock data until the chat API is
/// connected.
class ChatBloc extends Bloc<ChatEvent, ChatState> {
  ChatBloc({List<ChatConversation>? initialConversations})
    : super(ChatState(initialConversations ?? mockConversations())) {
    on<ConversationRead>(_onConversationRead);
    on<ChatMessageSent>(_onMessageSent);
  }

  void _onConversationRead(ConversationRead event, Emitter<ChatState> emit) {
    final conversation = state.byId(event.conversationId);
    if (conversation == null || conversation.unreadCount == 0) return;
    final messages = [
      for (final m in conversation.messages)
        if (!m.isMine && !m.isRead) m.copyWith(isRead: true) else m,
    ];
    emit(
      ChatState([
        for (final c in state.conversations)
          if (c.id == conversation.id) c.copyWith(messages: messages) else c,
      ]),
    );
  }

  void _onMessageSent(ChatMessageSent event, Emitter<ChatState> emit) {
    final text = event.text.trim();
    if (text.isEmpty || state.byId(event.conversationId) == null) return;
    final now = DateTime.now();
    final message = ChatMessage(
      id: '${event.conversationId}_${now.microsecondsSinceEpoch}',
      conversationId: event.conversationId,
      text: text,
      timestamp: now,
      isMine: true,
      isRead: true,
    );
    emit(
      ChatState([
        for (final c in state.conversations)
          if (c.id == event.conversationId)
            c.copyWith(messages: [...c.messages, message])
          else
            c,
      ]),
    );
  }
}
