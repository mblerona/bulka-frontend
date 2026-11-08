import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bulka_frontend/core/network/api_client.dart';
import 'package:bulka_frontend/core/network/api_exception.dart';
import 'package:bulka_frontend/core/network/api_response.dart';
import 'package:bulka_frontend/models/chat_conversation.dart';
import 'package:bulka_frontend/models/chat_message.dart';

part 'chat_event.dart';
part 'chat_state.dart';

/// The signed-in user's conversations, from `GET /api/chat/conversations`
/// (both roles use it), and one conversation's messages from
/// `GET /api/chat/conversations/{id}`. The bottom nav's Messages badge
/// shows [ChatState.totalUnreadMessages].
///
/// Reading a conversation and sending messages are still local only, so
/// both are undone by the next load.
class ChatBloc extends Bloc<ChatEvent, ChatState> {
  ChatBloc({Dio? dio})
    : _dio = dio ?? ApiClient.instance.dio,
      super(ChatState()) {
    on<ChatConversationsRequested>(_onRequested);
    on<ChatConversationDetailsRequested>(_onDetailsRequested);
    on<ConversationRead>(_onConversationRead);
    on<ChatMessageSent>(_onMessageSent);
  }

  final Dio _dio;

  // Increases with every list request, so an older response that arrives
  // late (list or messages) doesn't replace a newer one.
  int _latestRequest = 0;

  Future<void> _onRequested(
    ChatConversationsRequested event,
    Emitter<ChatState> emit,
  ) async {
    final request = ++_latestRequest;
    // The old list (and messages) are dropped, as they may belong to a
    // previous account.
    emit(ChatState(status: ChatStatus.loading));
    try {
      final data = await _getData('/api/chat/conversations');
      if (data is! List) throw const ApiException(kind: ApiErrorKind.unknown);
      final conversations = [
        for (final item in data)
          if (item is Map<String, dynamic>) ChatConversation.fromJson(item),
      ]..sort((a, b) => b.previewTime.compareTo(a.previewTime));
      if (request != _latestRequest) return;
      emit(
        ChatState(
          conversations: conversations,
          status: ChatStatus.loaded,
          // Messages loaded while the list was on its way are kept.
          details: state.details,
          detailsStatus: state.detailsStatus,
        ),
      );
    } on ApiException {
      if (request != _latestRequest) return;
      emit(
        ChatState(
          status: ChatStatus.failed,
          details: state.details,
          detailsStatus: state.detailsStatus,
        ),
      );
    }
  }

  /// Loads the first page of messages only (`page`/`totalPages` in the
  /// response). A failed reload keeps the messages already shown.
  Future<void> _onDetailsRequested(
    ChatConversationDetailsRequested event,
    Emitter<ChatState> emit,
  ) async {
    final id = event.conversationId;
    final request = _latestRequest;
    emit(
      state.copyWith(
        detailsStatus: {...state.detailsStatus, id: ChatStatus.loading},
      ),
    );
    try {
      final data = await _getData(
        '/api/chat/conversations/${Uri.encodeComponent(id)}',
      );
      if (data is! Map<String, dynamic>) {
        throw const ApiException(kind: ApiErrorKind.unknown);
      }
      if (request != _latestRequest) return;
      emit(
        state.copyWith(
          details: {...state.details, id: ChatConversation.fromJson(data)},
          detailsStatus: {...state.detailsStatus, id: ChatStatus.loaded},
        ),
      );
    } on ApiException catch (e) {
      if (request != _latestRequest) return;
      emit(
        state.copyWith(
          detailsStatus: {
            ...state.detailsStatus,
            id: e.statusCode == 404 ? ChatStatus.notFound : ChatStatus.failed,
          },
        ),
      );
    }
  }

  void _onConversationRead(ConversationRead event, Emitter<ChatState> emit) {
    final conversation = state.detailsFor(event.conversationId);
    if (conversation == null || conversation.unreadCount == 0) return;
    ChatConversation read(ChatConversation c) => c.copyWith(
      unreadCount: 0,
      messages: [
        for (final m in c.messages)
          if (!m.isMine && !m.isRead) m.copyWith(isRead: true) else m,
      ],
    );
    emit(_update(event.conversationId, read));
  }

  void _onMessageSent(ChatMessageSent event, Emitter<ChatState> emit) {
    final text = event.text.trim();
    final id = event.conversationId;
    if (text.isEmpty || state.detailsFor(id) == null) return;
    final now = DateTime.now();
    final message = ChatMessage(
      id: '${id}_${now.microsecondsSinceEpoch}',
      conversationId: id,
      text: text,
      timestamp: now,
      isMine: true,
      isRead: true,
    );
    final updated = _update(
      id,
      (c) => c.copyWith(messages: [...c.messages, message]),
    );
    // The conversation moves to the top, as it now has the newest message.
    final moved = updated.byId(id);
    emit(
      moved == null
          ? updated
          : updated.copyWith(
              conversations: [
                moved,
                for (final c in updated.conversations)
                  if (c.id != id) c,
              ],
            ),
    );
  }

  /// [change] applied to conversation [id] in both the list and the
  /// loaded messages.
  ChatState _update(
    String id,
    ChatConversation Function(ChatConversation) change,
  ) {
    final details = state.details[id];
    return state.copyWith(
      conversations: [
        for (final c in state.conversations) c.id == id ? change(c) : c,
      ],
      details: details == null
          ? state.details
          : {...state.details, id: change(details)},
    );
  }

  /// The envelope's `data` for a GET to [path].
  Future<Object?> _getData(String path) async {
    final Response<Object?> response;
    try {
      response = await _dio.get<Object?>(path);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
    final json = response.data;
    if (json is! Map<String, dynamic>) {
      throw const ApiException(kind: ApiErrorKind.unknown);
    }
    final envelope = ApiResponse<Object?>.fromJson(json, (data) => data);
    if (!envelope.success) throw ApiException.fromEnvelope(envelope);
    return envelope.data;
  }
}
