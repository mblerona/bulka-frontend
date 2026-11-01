// Mock seed data until this feature is connected to the backend.
import 'package:bulka_frontend/models/chat_conversation.dart';
import 'package:bulka_frontend/models/chat_message.dart';

List<ChatConversation> mockConversations() {
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
