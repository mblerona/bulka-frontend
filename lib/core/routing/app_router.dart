import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:bulka_frontend/blocs/listings/listings_bloc.dart';
import 'package:bulka_frontend/blocs/reservations/reservations_bloc.dart';
import 'package:bulka_frontend/core/routing/app_routes.dart';
import 'package:bulka_frontend/dev/dev_launcher_screen.dart';
import 'package:bulka_frontend/models/provider_listing.dart';
import 'package:bulka_frontend/models/registration_profile.dart';
import 'package:bulka_frontend/models/reservation.dart';
import 'package:bulka_frontend/screens/booking_request_screen/booking_request_screen.dart';
import 'package:bulka_frontend/screens/chat_list_screen/chat_list_screen.dart';
import 'package:bulka_frontend/screens/chat_thread_screen/chat_thread_screen.dart';
import 'package:bulka_frontend/screens/create_offer_success_screen/create_offer_success_screen.dart';
import 'package:bulka_frontend/screens/create_offer_wizard_screen/create_offer_wizard_screen.dart';
import 'package:bulka_frontend/screens/email_verification_screen/email_verification_screen.dart';
import 'package:bulka_frontend/screens/forgot_password_screen/forgot_password_screen.dart';
import 'package:bulka_frontend/screens/leave_review_screen/leave_review_screen.dart';
import 'package:bulka_frontend/screens/listing_details_screen/listing_details_screen.dart';
import 'package:bulka_frontend/screens/login_screen/login_screen.dart';
import 'package:bulka_frontend/screens/my_tickets_screen/my_tickets_screen.dart';
import 'package:bulka_frontend/screens/new_support_ticket_screen/new_support_ticket_screen.dart';
import 'package:bulka_frontend/screens/notifications_screen/notifications_screen.dart';
import 'package:bulka_frontend/screens/profile_screen/profile_screen.dart';
import 'package:bulka_frontend/screens/provider_availability_calendar_screen/provider_availability_calendar_screen.dart';
import 'package:bulka_frontend/screens/provider_dashboard_screen/provider_dashboard_screen.dart';
import 'package:bulka_frontend/screens/provider_offers_screen/provider_offers_screen.dart';
import 'package:bulka_frontend/screens/provider_profile_screen/provider_profile_screen.dart';
import 'package:bulka_frontend/screens/rate_guest_screen/rate_guest_screen.dart';
import 'package:bulka_frontend/screens/rating_saved_screen/rating_saved_screen.dart';
import 'package:bulka_frontend/screens/register_screen/register_screen.dart';
import 'package:bulka_frontend/screens/reservation_confirmation_screen/reservation_confirmation_screen.dart';
import 'package:bulka_frontend/screens/review_submitted_screen/review_submitted_screen.dart';
import 'package:bulka_frontend/screens/route_not_found_screen/route_not_found_screen.dart';
import 'package:bulka_frontend/screens/search_results_screen/search_results_screen.dart';
import 'package:bulka_frontend/screens/settings_screen/settings_screen.dart';
import 'package:bulka_frontend/screens/splash_screen/splash_screen.dart';
import 'package:bulka_frontend/screens/terms_privacy_screen/terms_privacy_screen.dart';
import 'package:bulka_frontend/screens/tourist_home_screen/tourist_home_screen.dart';
import 'package:bulka_frontend/screens/tourist_my_reservations_screen/tourist_my_reservations_screen.dart';
import 'package:bulka_frontend/widgets/app_bottom_nav.dart';

/// The app's router. Debug builds start on the dev screen launcher,
/// release builds on Splash.
final GoRouter appRouter = createAppRouter();

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'root',
);

/// Clears the current tab back to [tabRoot], then opens [target] (often in
/// another tab). E.g. after booking: clear the Home tab, open the
/// confirmation in Reservations, so coming back to Home doesn't show the
/// old booking form.
///
/// Two steps, a frame apart: a tab only remembers its new location once the
/// tabs have rebuilt.
void resetTabThenGo(String tabRoot, String target) {
  appRouter.go(tabRoot);
  WidgetsBinding.instance.addPostFrameCallback((_) => appRouter.go(target));
}

/// Separate from [appRouter] so tests can start anywhere.
GoRouter createAppRouter({String? initialLocation, Object? initialExtra}) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation:
        initialLocation ?? (kDebugMode ? AppRoutes.dev : AppRoutes.splash),
    initialExtra: initialExtra,
    errorBuilder: (context, state) => const RouteNotFoundScreen(),
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      if (kDebugMode)
        GoRoute(
          path: AppRoutes.dev,
          builder: (context, state) => const DevLauncherScreen(),
        ),

      // ── Sign-in / sign-up ──
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) =>
            LoginScreen(initialEmail: state.uri.queryParameters['email']),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegisterScreen(),
        routes: [
          GoRoute(
            path: 'terms',
            // Without the sign-up data (e.g. the app was restored) there's
            // nothing to submit, so start sign-up again.
            redirect: (context, state) =>
                state.extra is SignUpData ? null : AppRoutes.register,
            builder: (context, state) {
              final data = state.extra! as SignUpData;
              return TermsPrivacyScreen(
                profile: data.profile,
                password: data.password,
              );
            },
          ),
          GoRoute(
            path: 'verify',
            builder: (context, state) {
              final profile = state.extra;
              return profile is RegistrationProfile
                  ? EmailVerificationScreen(profile: profile)
                  : const EmailVerificationScreen();
            },
          ),
        ],
      ),

      // ── Full screen, opened over the tabs ──
      GoRoute(
        path: AppRoutes.messages,
        builder: (context, state) => const ChatListScreen(),
        routes: [
          GoRoute(
            path: ':conversationId',
            builder: (context, state) => ChatThreadScreen(
              conversationId: state.pathParameters['conversationId']!,
            ),
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.providerProfile,
        builder: (context, state) => const ProviderProfileScreen(),
      ),
      GoRoute(
        path: AppRoutes.settings,
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: AppRoutes.notifications,
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: AppRoutes.tickets,
        builder: (context, state) => const MyTicketsScreen(),
        routes: [
          GoRoute(
            path: 'new',
            builder: (context, state) => const NewSupportTicketScreen(),
          ),
        ],
      ),

      // ── Tourist tabs (Messages opens full screen, see TouristShell) ──
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) =>
            TouristShell(navigationShell: shell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.home,
                builder: (context, state) => const TouristHomeScreen(),
                routes: _listingRoutes(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.search,
                builder: (context, state) => const SearchResultsScreen(),
                routes: _listingRoutes(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.reservations,
                builder: (context, state) => TouristMyReservationsScreen(
                  initialTab: state.uri.queryParameters['tab'] == 'past'
                      ? ReservationsTab.past
                      : ReservationsTab.upcoming,
                ),
                routes: [
                  GoRoute(
                    path: 'review-submitted',
                    builder: (context, state) => const ReviewSubmittedScreen(),
                  ),
                  GoRoute(
                    path: ':reservationId/confirmation',
                    builder: (context, state) =>
                        _withReservationAndListing(context, state, (r, l) {
                          return ReservationConfirmationScreen(
                            reservation: r,
                            listing: l,
                          );
                        }),
                  ),
                  GoRoute(
                    path: ':reservationId/review',
                    builder: (context, state) =>
                        _withReservationAndListing(context, state, (r, l) {
                          return LeaveReviewScreen(reservation: r, listing: l);
                        }),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.profile,
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),

      // ── Provider tabs (Messages and Profile open full screen) ──
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) =>
            ProviderShell(navigationShell: shell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.dashboard,
                builder: (context, state) => const ProviderDashboardScreen(),
                routes: [
                  GoRoute(
                    path: 'new-offer',
                    builder: (context, state) =>
                        const CreateOfferWizardScreen(),
                  ),
                  GoRoute(
                    path: 'offer-published',
                    builder: (context, state) =>
                        const CreateOfferSuccessScreen(),
                  ),
                  GoRoute(
                    path: 'rating-saved',
                    builder: (context, state) => const RatingSavedScreen(),
                  ),
                  GoRoute(
                    path: 'rate-guest/:reservationId',
                    builder: (context, state) {
                      final reservation = context
                          .read<ReservationsBloc>()
                          .state
                          .byId(state.pathParameters['reservationId']!);
                      return reservation == null
                          ? const RouteNotFoundScreen()
                          : RateGuestScreen(reservation: reservation);
                    },
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.offers,
                builder: (context, state) => const ProviderOffersScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.calendar,
                builder: (context, state) =>
                    const ProviderAvailabilityCalendarScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

/// Listing details + booking, used under both the Home and Search tabs.
List<RouteBase> _listingRoutes() => [
  GoRoute(
    path: 'listings/:listingId',
    builder: (context, state) => _withListing(
      context,
      state,
      (listing) => ListingDetailsScreen(listing: listing),
    ),
    routes: [
      GoRoute(
        path: 'book',
        builder: (context, state) => _withListing(
          context,
          state,
          (listing) => BookingRequestScreen(listing: listing),
        ),
      ),
    ],
  ),
];

Widget _withListing(
  BuildContext context,
  GoRouterState state,
  Widget Function(ProviderListing listing) build,
) {
  final listing = context.read<ListingsBloc>().state.byId(
    state.pathParameters['listingId']!,
  );
  return listing == null ? const RouteNotFoundScreen() : build(listing);
}

Widget _withReservationAndListing(
  BuildContext context,
  GoRouterState state,
  Widget Function(Reservation reservation, ProviderListing listing) build,
) {
  final reservation = context.read<ReservationsBloc>().state.byId(
    state.pathParameters['reservationId']!,
  );
  final listingId = reservation?.listingId;
  final listing = listingId == null
      ? null
      : context.read<ListingsBloc>().state.byId(listingId);
  if (reservation == null || listing == null) {
    return const RouteNotFoundScreen();
  }
  return build(reservation, listing);
}
