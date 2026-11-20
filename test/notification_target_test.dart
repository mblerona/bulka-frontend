import 'package:flutter_test/flutter_test.dart';
import 'package:bulka_frontend/core/routing/app_routes.dart';
import 'package:bulka_frontend/models/notification_item.dart';
import 'package:bulka_frontend/models/user_role.dart';
import 'package:bulka_frontend/screens/notifications_screen/notifications_screen.dart';

NotificationItem _notification({String type = '', String? linkUrl}) =>
    NotificationItem(
      id: 'n1',
      title: 'title',
      message: 'message',
      timestamp: DateTime(2026),
      type: type,
      linkUrl: linkUrl,
    );

void main() {
  group('notificationTarget', () {
    test('a booking opens Reservations for a Tourist', () {
      expect(
        notificationTarget(
          _notification(type: 'Booking', linkUrl: '/bookings/b1'),
          UserRole.buyer,
        ),
        AppRoutes.reservations,
      );
    });

    test('a booking opens the Dashboard for a Provider', () {
      expect(
        notificationTarget(_notification(type: 'Booking'), UserRole.owner),
        AppRoutes.dashboard,
      );
    });

    test('a support reply opens its ticket, keeping the id as sent', () {
      expect(
        notificationTarget(
          _notification(type: 'Support', linkUrl: '/support/tickets/AbC9'),
          UserRole.buyer,
        ),
        AppRoutes.ticket('AbC9'),
      );
    });

    test('a support reply without a ticket id opens the tickets list', () {
      expect(
        notificationTarget(_notification(type: 'SupportTicket'), null),
        AppRoutes.tickets,
      );
    });

    test('anything else opens nothing', () {
      expect(
        notificationTarget(
          _notification(type: 'System', linkUrl: '/news'),
          UserRole.buyer,
        ),
        isNull,
      );
    });
  });
}
