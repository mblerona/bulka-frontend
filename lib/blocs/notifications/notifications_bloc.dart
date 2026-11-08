import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bulka_frontend/core/network/api_client.dart';
import 'package:bulka_frontend/core/network/api_exception.dart';
import 'package:bulka_frontend/core/network/api_response.dart';
import 'package:bulka_frontend/models/notification_item.dart';

part 'notifications_event.dart';
part 'notifications_state.dart';

/// The signed-in user's in-app notifications, from
/// `GET /api/me/notifications` (dismissed ones are left out), and how many
/// are unread, from `GET /api/me/notifications/unread-count`. Tapping one
/// marks it read with `POST /api/me/notifications/{id}/read`, and "Mark all
/// as read" uses `POST /api/me/notifications/read-all`.
class NotificationsBloc extends Bloc<NotificationsEvent, NotificationsState> {
  NotificationsBloc({Dio? dio})
    : _dio = dio ?? ApiClient.instance.dio,
      super(NotificationsState()) {
    on<NotificationsRequested>(_onRequested);
    on<UnreadNotificationsCountRequested>(_onCountRequested);
    on<NotificationRead>(_onRead);
    on<AllNotificationsRead>(_onAllRead);
  }

  final Dio _dio;

  /// Shows them all read straight away, then tells the backend. If that
  /// fails, the ones that were unread show as unread again.
  Future<void> _onAllRead(
    AllNotificationsRead event,
    Emitter<NotificationsState> emit,
  ) async {
    final wasUnread = {
      for (final n in state.notifications)
        if (!n.isRead) n.id,
    };
    if (wasUnread.isEmpty && (state.serverUnreadCount ?? 0) == 0) return;
    final countBefore = state.serverUnreadCount;
    final list = _latestRequest;
    emit(
      NotificationsState(
        notifications: [
          for (final n in state.notifications) n.copyWith(isRead: true),
        ],
        status: state.status,
        serverUnreadCount: countBefore == null ? null : 0,
      ),
    );

    try {
      // `data.count` is how many it marked; nothing is unread either way.
      await _postData('/api/me/notifications/read-all');
    } on ApiException {
      // A reload since then already has the backend's version.
      if (list != _latestRequest) return;
      emit(
        NotificationsState(
          notifications: [
            for (final n in state.notifications)
              wasUnread.contains(n.id) ? n.copyWith(isRead: false) : n,
          ],
          status: state.status,
          serverUnreadCount: countBefore,
        ),
      );
    }
  }

  /// Shows it read straight away, then tells the backend. If that fails it
  /// shows as unread again, since the backend still has it unread.
  Future<void> _onRead(
    NotificationRead event,
    Emitter<NotificationsState> emit,
  ) async {
    final id = event.notificationId;
    final isUnread = state.notifications.any((n) => n.id == id && !n.isRead);
    if (!isUnread) return;
    final list = _latestRequest;
    emit(_withRead(id, isRead: true));

    try {
      final data = await _postData(
        '/api/me/notifications/${Uri.encodeComponent(id)}/read',
      );
      // A reload since then already has the backend's version.
      if (list != _latestRequest) return;
      if (data is Map<String, dynamic>) {
        final updated = NotificationItem.fromJson(data);
        emit(
          NotificationsState(
            notifications: [
              for (final n in state.notifications) n.id == id ? updated : n,
            ],
            status: state.status,
            serverUnreadCount: state.serverUnreadCount,
          ),
        );
      }
    } on ApiException {
      if (list != _latestRequest) return;
      emit(_withRead(id, isRead: false));
    }
  }

  /// [id] marked read or unread, with the backend's count moved to match.
  NotificationsState _withRead(String id, {required bool isRead}) {
    final count = state.serverUnreadCount;
    return NotificationsState(
      notifications: [
        for (final n in state.notifications)
          n.id == id ? n.copyWith(isRead: isRead) : n,
      ],
      status: state.status,
      serverUnreadCount: count == null
          ? null
          : isRead
          ? (count > 0 ? count - 1 : 0)
          : count + 1,
    );
  }

  // Increase with every request, so an older response that arrives late
  // doesn't replace a newer one. A list reload also invalidates a count
  // still on its way, as it may be for a previous account.
  int _latestRequest = 0;
  int _latestCountRequest = 0;

  Future<void> _onRequested(
    NotificationsRequested event,
    Emitter<NotificationsState> emit,
  ) async {
    final request = ++_latestRequest;
    ++_latestCountRequest;
    // The old list and count are dropped, as they may belong to a previous
    // account.
    emit(NotificationsState(status: NotificationsStatus.loading));
    try {
      final data = await _getData('/api/me/notifications');
      if (data is! List) throw const ApiException(kind: ApiErrorKind.unknown);
      final notifications = [
        for (final item in data)
          if (item is Map<String, dynamic> &&
              !NotificationItem.isDismissed(item))
            NotificationItem.fromJson(item),
      ]..sort((a, b) => b.timestamp.compareTo(a.timestamp));
      if (request != _latestRequest) return;
      emit(
        NotificationsState(
          notifications: notifications,
          status: NotificationsStatus.loaded,
          serverUnreadCount: state.serverUnreadCount,
        ),
      );
    } on ApiException {
      if (request != _latestRequest) return;
      emit(
        NotificationsState(
          status: NotificationsStatus.failed,
          serverUnreadCount: state.serverUnreadCount,
        ),
      );
    }
  }

  /// A failed request leaves the count unknown, so [unreadCount] falls back
  /// to counting the loaded list.
  Future<void> _onCountRequested(
    UnreadNotificationsCountRequested event,
    Emitter<NotificationsState> emit,
  ) async {
    final request = ++_latestCountRequest;
    int? count;
    try {
      final data = await _getData('/api/me/notifications/unread-count');
      final value = data is Map<String, dynamic> ? data['count'] : null;
      if (value is num) count = value.toInt();
    } on ApiException {
      count = null;
    }
    if (request != _latestCountRequest) return;
    emit(
      NotificationsState(
        notifications: state.notifications,
        status: state.status,
        serverUnreadCount: count,
      ),
    );
  }

  /// The envelope's `data` for a GET to [path].
  Future<Object?> _getData(String path) => _send(() => _dio.get(path));

  /// The envelope's `data` for a POST (no body) to [path].
  Future<Object?> _postData(String path) => _send(() => _dio.post(path));

  Future<Object?> _send(Future<Response<Object?>> Function() request) async {
    final Response<Object?> response;
    try {
      response = await request();
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
