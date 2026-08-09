import 'package:flutter/foundation.dart';
import 'package:bulka_frontend/models/chat_conversation.dart';
import 'package:bulka_frontend/models/chat_message.dart';

/// Single shared source of truth for the signed-in user's conversations —
/// mirrors `NotificationsController`'s shape exactly (same singleton +
/// `ChangeNotifier` pattern, no new state-management package). Both roles'
/// bottom nav bars badge from the same [instance], since Tourist and
/// Provider share one inbox for the same user.
///
/// There's no chat API/WebSocket yet, so [_conversations] starts out as
/// local mock data reproducing the Figma example. Swapping in a real
/// backend later only means replacing [_mockConversations] (and
/// [markConversationRead]/[sendMessage]'s bodies with API/socket calls) —
/// nothing that reads [conversations] or [totalUnreadMessages] needs to
/// change.
class ChatController extends ChangeNotifier {
  ChatController._() : _conversations = _mockConversations();

  static final ChatController instance = ChatController._();

  List<ChatConversation> _conversations;

  List<ChatConversation> get conversations => List.unmodifiable(_conversations);

  ChatConversation conversationById(String id) =>
      _conversations.firstWhere((c) => c.id == id);

  int get totalUnreadMessages =>
      _conversations.fold(0, (sum, c) => sum + c.unreadCount);

  /// Idempotent — calling this on an already-read conversation (e.g. from
  /// both the Chat List tap and defensively again in Chat Thread) is a
  /// no-op and does not fire a redundant [notifyListeners].
  void markConversationRead(String id) {
    final index = _conversations.indexWhere((c) => c.id == id);
    if (index == -1) return;
    final conversation = _conversations[index];
    if (conversation.unreadCount == 0) return;
    final updatedMessages = [
      for (final m in conversation.messages)
        if (!m.isMine && !m.isRead) m.copyWith(isRead: true) else m,
    ];
    _conversations = [
      for (final c in _conversations)
        if (c.id == id) c.copyWith(messages: updatedMessages) else c,
    ];
    notifyListeners();
  }

  void sendMessage(String conversationId, String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;
    final index = _conversations.indexWhere((c) => c.id == conversationId);
    if (index == -1) return;
    final newMessage = ChatMessage(
      id: '${conversationId}_${DateTime.now().microsecondsSinceEpoch}',
      conversationId: conversationId,
      text: trimmed,
      timestamp: DateTime.now(),
      isMine: true,
      isRead: true,
    );
    _conversations = [
      for (final c in _conversations)
        if (c.id == conversationId)
          c.copyWith(messages: [...c.messages, newMessage])
        else
          c,
    ];
    notifyListeners();
  }

  static List<ChatConversation> _mockConversations() {
    final now = DateTime.now();
    return [
      ChatConversation(
        id: '1',
        participantName: 'Стефан Николовски',
        avatarInitials: 'СН',
        contextLabel: 'Резервација #1042 · Villa Zdravkovski',
        messages: [
          ChatMessage(
            id: '1_1',
            conversationId: '1',
            text: 'Здраво! Ви пишувам во врска со резервацијата #1042.',
            timestamp: now.subtract(const Duration(minutes: 20)),
            isMine: false,
            isRead: true,
          ),
          ChatMessage(
            id: '1_2',
            conversationId: '1',
            text: 'Дали има паркинг во близина на имотот?',
            timestamp: now.subtract(const Duration(minutes: 15)),
            isMine: false,
            isRead: false,
          ),
          ChatMessage(
            id: '1_3',
            conversationId: '1',
            text:
                'Здраво Стефан! Да, имаме бесплатен паркинг простор веднаш '
                'до куќата.',
            timestamp: now.subtract(const Duration(minutes: 14)),
            isMine: true,
            isRead: true,
          ),
          ChatMessage(
            id: '1_4',
            conversationId: '1',
            text: 'Одлично, ви благодарам! До кога треба да пристигнеме?',
            timestamp: now.subtract(const Duration(minutes: 13)),
            isMine: false,
            isRead: false,
          ),
          ChatMessage(
            id: '1_5',
            conversationId: '1',
            text: 'Check-in е достапен од 14:00 часот. Ве очекуваме!',
            timestamp: now.subtract(const Duration(minutes: 12)),
            isMine: true,
            isRead: true,
          ),
        ],
      ),
      ChatConversation(
        id: '2',
        participantName: 'Марија Петровска',
        avatarInitials: 'МП',
        contextLabel: 'Оглас · Куќа во Маврово',
        messages: [
          ChatMessage(
            id: '2_1',
            conversationId: '2',
            text: 'Ви благодарам, ќе стигнеме околу 14ч.',
            timestamp: now.subtract(const Duration(hours: 1)),
            isMine: false,
            isRead: true,
          ),
        ],
      ),
      ChatConversation(
        id: '3',
        participantName: 'Служба за поддршка',
        avatarInitials: 'СП',
        contextLabel: 'Тикет #58',
        messages: [
          ChatMessage(
            id: '3_1',
            conversationId: '3',
            text: 'Вашето барање е решено. Ако имате...',
            timestamp: now.subtract(const Duration(hours: 3)),
            isMine: false,
            isRead: true,
          ),
        ],
      ),
      ChatConversation(
        id: '4',
        participantName: 'Дамјан Стојановски',
        avatarInitials: 'ДС',
        contextLabel: 'Резервација #987 · Etno House Galičnik',
        messages: [
          ChatMessage(
            id: '4_1',
            conversationId: '4',
            text: 'Може ли да го поместиме терминот?',
            timestamp: now.subtract(const Duration(days: 1)),
            isMine: false,
            isRead: false,
          ),
        ],
      ),
    ];
  }
}
