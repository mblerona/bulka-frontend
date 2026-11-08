import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:bulka_frontend/blocs/app_bloc_providers.dart';
import 'package:bulka_frontend/blocs/auth/auth_bloc.dart';
import 'package:bulka_frontend/blocs/listings/listings_bloc.dart';
import 'package:bulka_frontend/blocs/reservations/reservations_bloc.dart';
import 'package:bulka_frontend/models/auth_user.dart';
import 'package:bulka_frontend/screens/profile_screen/profile_screen.dart';
import 'package:bulka_frontend/screens/provider_dashboard_screen/provider_dashboard_screen.dart';
import 'package:bulka_frontend/screens/provider_profile_screen/provider_profile_screen.dart';
import 'package:bulka_frontend/screens/tourist_home_screen/tourist_home_screen.dart';
import 'package:bulka_frontend/screens/tourist_my_reservations_screen/tourist_my_reservations_screen.dart';

import 'test_helpers.dart';

class _MockAuthBloc extends MockBloc<AuthEvent, AuthState>
    implements AuthBloc {}

const _tourist = AuthUser(
  id: 'u1',
  email: 'ana@example.com',
  roles: ['Buyer'],
  firstName: 'Ана',
  lastName: 'Петровска',
  phone: '071 222 333',
);

const _provider = AuthUser(
  id: 'u2',
  email: 'marko@example.com',
  roles: ['Buyer', 'Provider'],
  firstName: 'Марко',
  lastName: 'Стојанов',
);

Future<void> _pumpSignedIn(
  WidgetTester tester,
  AuthUser user,
  Widget screen,
) async {
  await usePhoneScreen(tester);
  final auth = _MockAuthBloc();
  whenListen(
    auth,
    const Stream<AuthState>.empty(),
    initialState: AuthState(user: user),
  );
  await tester.pumpWidget(
    AppBlocProviders(
      initialLocale: const Locale('mk'),
      // Replaces the real AuthBloc with one that already has a user.
      child: BlocProvider<AuthBloc>.value(
        value: auth,
        child: MaterialApp(home: screen),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() async {
    await loadAppFonts();
    // The dashboard formats reservation dates (done at startup in the app).
    await initializeDateFormatting();
  });

  testWidgets('Tourist Home greets the signed-in user', (tester) async {
    await _pumpSignedIn(tester, _tourist, const TouristHomeScreen());
    expect(find.textContaining('Ана'), findsWidgets);
    expect(find.textContaining('Јована'), findsNothing);
    // Top-level categories from the (fake) backend; sub-categories hidden.
    expect(find.text('Понуда на храна'), findsOneWidget);
    expect(find.text('Соби'), findsNothing);
  });

  testWidgets('Profile shows the signed-in user', (tester) async {
    await _pumpSignedIn(tester, _tourist, const ProfileScreen());
    expect(find.text('Ана Петровска'), findsWidgets);
    expect(find.text('ana@example.com'), findsWidgets);
    expect(find.text('071 222 333'), findsOneWidget);
    expect(find.textContaining('Јована'), findsNothing);
  });

  testWidgets('My Reservations shows only the signed-in Tourist bookings', (
    tester,
  ) async {
    await _pumpSignedIn(tester, _tourist, const TouristMyReservationsScreen());
    final context = tester.element(find.byType(TouristMyReservationsScreen));
    final listings = context.read<ListingsBloc>().state;
    void book(String listingTitle, String guestId) {
      context.read<ReservationsBloc>().add(
        ReservationRequested(
          listing: listings.listings.firstWhere((l) => l.title == listingTitle),
          guestId: guestId,
          // Same name on purpose: ownership is by account, not by name.
          guestName: _tourist.fullName,
          startDate: DateTime.now().add(const Duration(days: 10)),
          endDate: DateTime.now().add(const Duration(days: 12)),
          guestCount: 2,
        ),
      );
    }

    book('Villa Zdravkovski', _tourist.id);
    book('Гостинска соба со појадок', 'someone-else');
    await tester.pumpAndSettle();

    expect(find.text('Villa Zdravkovski'), findsOneWidget);
    expect(find.text('Гостинска соба со појадок'), findsNothing);
  });

  testWidgets('Provider Dashboard greets the signed-in user', (tester) async {
    await _pumpSignedIn(tester, _provider, const ProviderDashboardScreen());
    expect(find.textContaining('Марко Стојанов'), findsOneWidget);
  });

  testWidgets('Provider Profile shows the signed-in user', (tester) async {
    await _pumpSignedIn(tester, _provider, const ProviderProfileScreen());
    expect(find.text('Марко Стојанов'), findsWidgets);
  });
}
