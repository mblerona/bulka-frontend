import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bulka_frontend/blocs/listings/listings_bloc.dart';
import 'package:bulka_frontend/blocs/reservations/reservations_bloc.dart';
import 'package:bulka_frontend/core/constants/app_strings.dart';
import 'package:bulka_frontend/core/l10n/app_locale.dart';
import 'package:bulka_frontend/core/routing/app_router.dart';
import 'package:bulka_frontend/core/routing/app_routes.dart';
import 'package:bulka_frontend/main.dart';
import 'package:bulka_frontend/models/create_listing_draft.dart';
import 'package:bulka_frontend/screens/booking_request_screen/booking_request_screen.dart';
import 'package:bulka_frontend/screens/chat_list_screen/chat_list_screen.dart';
import 'package:bulka_frontend/screens/listing_details_screen/listing_details_screen.dart';
import 'package:bulka_frontend/screens/register_screen/register_screen.dart';
import 'package:bulka_frontend/screens/reservation_confirmation_screen/reservation_confirmation_screen.dart';
import 'package:bulka_frontend/screens/route_not_found_screen/route_not_found_screen.dart';
import 'package:bulka_frontend/screens/search_results_screen/search_results_screen.dart';
import 'package:bulka_frontend/screens/tourist_home_screen/tourist_home_screen.dart';

import 'test_helpers.dart';

void main() {
  setUpAll(loadAppFonts);

  setUp(() {
    SharedPreferences.setMockInitialValues({'app.languageCode': 'mk'});
    AppLocale.apply(const Locale('mk'));
  });

  Future<GoRouter> pumpAt(WidgetTester tester, String location) async {
    await usePhoneScreen(tester);
    final router = createAppRouter(initialLocation: location);
    await tester.pumpWidget(BulkaApp(router: router));
    await tester.pumpAndSettle();
    return router;
  }

  Future<void> tapTab(WidgetTester tester, String label) async {
    await tester.tap(find.text(label));
    await tester.pumpAndSettle();
  }

  /// A bloc from the running app.
  T bloc<T extends StateStreamableSource<Object?>>(WidgetTester tester) =>
      tester.element(find.byType(Navigator).first).read<T>();

  testWidgets('each tab keeps its own history', (tester) async {
    final router = await pumpAt(tester, AppRoutes.home);
    final listingId = bloc<ListingsBloc>(tester).state.active.first.id;
    router.push('${AppRoutes.home}/listings/$listingId');
    await tester.pumpAndSettle();
    expect(find.byType(ListingDetailsScreen), findsOneWidget);

    await tapTab(tester, AppStrings.navTouristSearch);
    expect(find.byType(SearchResultsScreen), findsOneWidget);

    // Back on Home: still on the listing it was showing.
    await tapTab(tester, AppStrings.navTouristHome);
    expect(find.byType(ListingDetailsScreen), findsOneWidget);

    // Tapping the current tab again returns to its first screen.
    await tapTab(tester, AppStrings.navTouristHome);
    expect(find.byType(ListingDetailsScreen), findsNothing);
    expect(find.byType(TouristHomeScreen), findsOneWidget);
  });

  testWidgets('Messages tab opens the chat list full screen', (tester) async {
    await pumpAt(tester, AppRoutes.home);
    await tapTab(tester, AppStrings.navMessages);
    expect(find.byType(ChatListScreen), findsOneWidget);
  });

  testWidgets('after booking, the Home tab no longer shows the booking form', (
    tester,
  ) async {
    await usePhoneScreen(tester);
    // resetTabThenGo uses the app-wide router, as the booking screen does.
    appRouter.go(AppRoutes.home);
    await tester.pumpWidget(BulkaApp(router: appRouter));
    await tester.pumpAndSettle();
    final listing = bloc<ListingsBloc>(
      tester,
    ).state.active.firstWhere((l) => categoryRequiresPrice(l.category));
    appRouter.go('${AppRoutes.home}/listings/${listing.id}/book');
    await tester.pumpAndSettle();
    expect(find.byType(BookingRequestScreen), findsOneWidget);

    final reservations = bloc<ReservationsBloc>(tester)
      ..add(
        ReservationRequested(
          listing: listing,
          guestName: 'Test',
          startDate: DateTime.now().add(const Duration(days: 30)),
          endDate: DateTime.now().add(const Duration(days: 32)),
          guestCount: 1,
        ),
      );
    await tester.pump();
    resetTabThenGo(
      AppRoutes.home,
      AppRoutes.reservationConfirmation(reservations.state.lastCreated!.id),
    );
    await tester.pumpAndSettle();
    expect(find.byType(ReservationConfirmationScreen), findsOneWidget);

    await tapTab(tester, AppStrings.navTouristHome);
    expect(find.byType(BookingRequestScreen), findsNothing);
    expect(find.byType(TouristHomeScreen), findsOneWidget);
  });

  testWidgets('an unknown listing id shows Not Found', (tester) async {
    await pumpAt(tester, '${AppRoutes.home}/listings/does-not-exist');
    expect(find.byType(RouteNotFoundScreen), findsOneWidget);
  });

  testWidgets('an unknown path shows Not Found', (tester) async {
    await pumpAt(tester, '/no/such/page');
    expect(find.byType(RouteNotFoundScreen), findsOneWidget);
  });

  testWidgets('Terms without sign-up data goes back to Register', (
    tester,
  ) async {
    await pumpAt(tester, AppRoutes.registerTerms);
    expect(find.byType(RegisterScreen), findsOneWidget);
  });
}
