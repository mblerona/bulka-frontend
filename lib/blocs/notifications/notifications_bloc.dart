import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bulka_frontend/blocs/notifications/notifications_mock_data.dart';
import 'package:bulka_frontend/models/notification_item.dart';

part 'notifications_event.dart';
part 'notifications_state.dart';

/// In-app notifications. Mock data until the notifications API is
/// connected.
class NotificationsBloc extends Bloc<NotificationsEvent, NotificationsState> {
  NotificationsBloc({List<NotificationItem>? initialNotifications})
    : super(NotificationsState(initialNotifications ?? mockNotifications())) {
    on<NotificationRead>((event, emit) {
      final isUnread = state.notifications.any(
        (n) => n.id == event.notificationId && !n.isRead,
      );
      if (!isUnread) return;
      emit(
        NotificationsState([
          for (final n in state.notifications)
            if (n.id == event.notificationId) n.copyWith(isRead: true) else n,
        ]),
      );
    });
  }
}
