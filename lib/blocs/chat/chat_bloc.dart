import 'dart:math';

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
/// Sending (`POST .../{id}/messages`) and reading (`POST .../{id}/read`)
/// show their result straight away and undo it if the backend refuses.
class ChatBloc extends Bloc<ChatEvent, ChatState> {
  ChatBloc({Dio? dio, Random? random})
    : _dio = dio ?? ApiClient.instance.dio,
      _random = random ?? Random.secure(),
      super(ChatState()) {
    on<ChatConversationsRequested>(_onRequested);
    on<ChatConversationDetailsRequested>(_onDetailsRequested);
    on<ConversationRead>(_onConversationRead);
    on<ChatMessageSent>(_onMessageSent);
    on<ChatMessageRetried>(_onMessageRetried);
    on<ChatConversationStartRequested>(_onStartRequested);
  }

  final Dio _dio;
  final Random _random;

  /// The backend's answer when sending to a Closed or Blocked conversation.
  static const notActiveErrorCode = 'CHAT_CONVERSATION_NOT_ACTIVE';

  // Increases with every list request, so an older response that arrives
  // late (list or messages) doesn't replace a newer one.
  int _latestRequest = 0;

  Future<void> _onRequested(
    ChatConversationsRequested event,
    Emitter<ChatState> emit,
  ) async {
    final request = ++_latestRequest;
    // Unless asked to keep them, the old list (and messages) are dropped,
    // as they may belong to a previous account.
    emit(
      event.keepShown
          ? state.copyWith(status: ChatStatus.loading)
          : ChatState(status: ChatStatus.loading),
    );
    try {
      final data = await _getData('/api/chat/conversations');
      if (data is! List) throw const ApiException(kind: ApiErrorKind.unknown);
      if (request != _latestRequest) return;
      final conversations = [
        for (final item in data)
          if (item is Map<String, dynamic>)
            _withPendingFrom(
              state.byId(item['id'] as String? ?? ''),
              ChatConversation.fromJson(item),
            ),
      ]..sort((a, b) => b.previewTime.compareTo(a.previewTime));
      // Messages loaded while the list was on its way are kept.
      emit(
        state.copyWith(conversations: conversations, status: ChatStatus.loaded),
      );
    } on ApiException {
      if (request != _latestRequest) return;
      emit(state.copyWith(status: ChatStatus.failed));
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
      final loaded = _withPendingFrom(
        state.details[id],
        ChatConversation.fromJson(data),
      );
      emit(
        state.copyWith(
          details: {...state.details, id: loaded},
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

  /// Clears the unread count straight away. The backend is only told once
  /// the messages are loaded, as it needs the newest message's id (the
  /// thread sends this again then). If the backend refuses, the count
  /// comes back.
  Future<void> _onConversationRead(
    ConversationRead event,
    Emitter<ChatState> emit,
  ) async {
    final id = event.conversationId;
    final details = state.details[id];
    final unreadBefore = max(
      state.byId(id)?.unreadCount ?? 0,
      details?.unreadCount ?? 0,
    );
    if (unreadBefore == 0) return;
    emit(
      _update(
        id,
        (c) => c.copyWith(
          unreadCount: 0,
          messages: [
            for (final m in c.messages)
              if (!m.isMine && !m.isRead) m.copyWith(isRead: true) else m,
          ],
        ),
      ),
    );

    final newest = _newestOnBackend(details);
    if (newest == null) return;
    try {
      await _postData(
        '/api/chat/conversations/${Uri.encodeComponent(id)}/read',
        {'lastReadMessageId': newest.id},
      );
    } on ApiException {
      // Still unread on the backend.
      emit(_update(id, (c) => c.copyWith(unreadCount: unreadBefore)));
    }
  }

  /// The newest message the backend has (not one still being sent).
  static ChatMessage? _newestOnBackend(ChatConversation? conversation) {
    final messages = conversation?.messages ?? const <ChatMessage>[];
    for (final m in messages.reversed) {
      if (!m.isPending && m.id.isNotEmpty) return m;
    }
    return null;
  }

  Future<void> _onMessageSent(
    ChatMessageSent event,
    Emitter<ChatState> emit,
  ) async {
    final text = event.text.trim();
    final id = event.conversationId;
    final conversation = state.detailsFor(id);
    if (text.isEmpty || conversation == null || !conversation.isOpen) return;
    final key = _newMessageKey();
    final message = ChatMessage(
      id: 'local-$key',
      conversationId: id,
      text: text,
      timestamp: DateTime.now(),
      isMine: true,
      isRead: true,
      clientMessageKey: key,
      sendStatus: ChatMessageSendStatus.sending,
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
    await _deliver(id, message, emit);
  }

  Future<void> _onMessageRetried(
    ChatMessageRetried event,
    Emitter<ChatState> emit,
  ) async {
    final id = event.conversationId;
    final key = event.clientMessageKey;
    final conversation = state.detailsFor(id);
    if (conversation == null || !conversation.isOpen) return;
    ChatMessage? failed;
    for (final m in conversation.messages) {
      if (m.clientMessageKey == key &&
          m.sendStatus == ChatMessageSendStatus.failed) {
        failed = m;
      }
    }
    if (failed == null) return;
    emit(
      _updateMessage(
        id,
        key,
        (m) => m.copyWith(sendStatus: ChatMessageSendStatus.sending),
      ),
    );
    await _deliver(id, failed, emit);
  }

  /// Starts (or, if the backend already has one, reuses) a conversation
  /// with the provider. Ignored while another start is in progress.
  Future<void> _onStartRequested(
    ChatConversationStartRequested event,
    Emitter<ChatState> emit,
  ) async {
    if (state.start.status == ChatStartStatus.starting) return;
    final providerId = event.providerProfileId;
    emit(
      state.copyWith(
        start: ChatStart(
          status: ChatStartStatus.starting,
          providerProfileId: providerId,
        ),
      ),
    );
    try {
      final data = await _postData('/api/chat/conversations', {
        'providerProfileId': providerId,
        'initialMessage': null,
      });
      final conversationId = _conversationIdFrom(data);
      if (conversationId == null) {
        throw const ApiException(kind: ApiErrorKind.unknown);
      }
      emit(
        state.copyWith(
          start: ChatStart(
            status: ChatStartStatus.started,
            providerProfileId: providerId,
            conversationId: conversationId,
          ),
        ),
      );
    } on ApiException {
      emit(
        state.copyWith(
          start: ChatStart(
            status: ChatStartStatus.failed,
            providerProfileId: providerId,
          ),
        ),
      );
    }
  }

  /// The new conversation's id. The response isn't documented, so this
  /// takes the conversation itself (`id`), a `conversationId`, or a bare id.
  static String? _conversationIdFrom(Object? data) {
    if (data is String && data.isNotEmpty) return data;
    if (data is! Map<String, dynamic>) return null;
    for (final key in const ['id', 'conversationId']) {
      final value = data[key];
      if (value is String && value.isNotEmpty) return value;
    }
    return null;
  }

  /// Sends [message] (already shown as sending). On success the backend's
  /// copy replaces it; otherwise it's marked failed, and a conversation the
  /// backend says isn't active any more is shown as closed.
  Future<void> _deliver(
    String id,
    ChatMessage message,
    Emitter<ChatState> emit,
  ) async {
    final key = message.clientMessageKey!;
    try {
      final data = await _postData(
        '/api/chat/conversations/${Uri.encodeComponent(id)}/messages',
        {
          'body': message.text,
          'mediaAssetIds': const <String>[],
          'clientMessageKey': key,
        },
      );
      final sent = _sentMessageFrom(data, message);
      emit(_updateMessage(id, key, (_) => sent));
    } on ApiException catch (e) {
      emit(
        _updateMessage(
          id,
          key,
          (m) => m.copyWith(sendStatus: ChatMessageSendStatus.failed),
        ),
      );
      if (e.hasErrorCode(notActiveErrorCode)) {
        emit(
          _update(
            id,
            (c) => c.isOpen
                ? c.copyWith(status: ChatConversationStatus.closed)
                : c,
          ),
        );
      }
    }
  }

  /// The backend's copy of a sent message, if [data] is one. The response
  /// hasn't been seen yet, so anything else just marks [local] sent.
  static ChatMessage _sentMessageFrom(Object? data, ChatMessage local) {
    final sent = local.copyWith(sendStatus: ChatMessageSendStatus.sent);
    if (data is! Map<String, dynamic> || data.containsKey('messages')) {
      return sent;
    }
    final messageId = data['id'];
    if (messageId is! String || messageId.isEmpty) return sent;
    final parsed = ChatMessage.fromJson(data);
    return ChatMessage(
      id: parsed.id,
      conversationId: local.conversationId,
      text: parsed.text.isEmpty ? local.text : parsed.text,
      timestamp: data['createdAtUtc'] is String
          ? parsed.timestamp
          : local.timestamp,
      // Without a sender, it's still the one this device sent.
      isMine: parsed.senderUserId == null,
      isRead: true,
      senderUserId: parsed.senderUserId,
      clientMessageKey: local.clientMessageKey,
    );
  }

  /// [loaded], plus the messages [previous] still has that aren't on the
  /// backend yet (sending or failed), so a reload doesn't lose them.
  static ChatConversation _withPendingFrom(
    ChatConversation? previous,
    ChatConversation loaded,
  ) {
    final pending = [...?previous?.messages.where((m) => m.isPending)];
    if (pending.isEmpty) return loaded;
    final keys = {
      for (final m in loaded.messages)
        if (m.clientMessageKey != null) m.clientMessageKey,
    };
    return loaded.copyWith(
      messages: [
        ...loaded.messages,
        for (final m in pending)
          if (!keys.contains(m.clientMessageKey)) m,
      ],
    );
  }

  /// A random version 4 UUID, for `clientMessageKey`.
  String _newMessageKey() {
    final bytes = List<int>.generate(16, (_) => _random.nextInt(256));
    bytes[6] = (bytes[6] & 0x0f) | 0x40;
    bytes[8] = (bytes[8] & 0x3f) | 0x80;
    final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-'
        '${hex.substring(12, 16)}-${hex.substring(16, 20)}-'
        '${hex.substring(20)}';
  }

  /// [change] applied to the message with [clientMessageKey] in
  /// conversation [id]. If the result has the id of a message already
  /// there (the backend's copy arrived in a reload meanwhile), only one is
  /// kept.
  ChatState _updateMessage(
    String id,
    String clientMessageKey,
    ChatMessage Function(ChatMessage) change,
  ) => _update(id, (c) {
    final seen = <String>{};
    final messages = <ChatMessage>[];
    for (final m in c.messages) {
      final updated = m.clientMessageKey == clientMessageKey ? change(m) : m;
      if (seen.add(updated.id)) messages.add(updated);
    }
    return c.copyWith(messages: messages);
  });

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
  Future<Object?> _getData(String path) => _send(() => _dio.get<Object?>(path));

  /// The envelope's `data` for a POST of [body] to [path].
  Future<Object?> _postData(String path, Map<String, Object?> body) =>
      _send(() => _dio.post<Object?>(path, data: body));

  Future<Object?> _send(Future<Response<Object?>> Function() request) async {
    final Response<Object?> response;
    try {
      response = await request();
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
    final json = response.data;
    // A POST may answer with an empty body.
    if (json == null || json == '') return null;
    if (json is! Map<String, dynamic>) {
      throw const ApiException(kind: ApiErrorKind.unknown);
    }
    final envelope = ApiResponse<Object?>.fromJson(json, (data) => data);
    if (!envelope.success) throw ApiException.fromEnvelope(envelope);
    return envelope.data;
  }
}
