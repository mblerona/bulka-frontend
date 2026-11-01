import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:bulka_frontend/models/registration_profile.dart';

/// Every route path in the app. Screens navigate with these
/// (`context.go(AppRoutes.home)`, `context.push(AppRoutes.chat(id))`), never
/// with hard-coded strings. The routes themselves are in `app_router.dart`.
abstract final class AppRoutes {
  // ── Outside the tabs (full screen, no bottom nav) ──
  static const splash = '/';
  static const dev = '/dev';
  static const login = '/login';
  static const forgotPassword = '/forgot-password';
  static const register = '/register';

  /// Needs [SignUpData] as `extra` (never in the URL: it holds the password).
  static const registerTerms = '/register/terms';

  /// Takes the [RegistrationProfile] as `extra`.
  static const registerVerify = '/register/verify';
  static const messages = '/messages';
  static const providerProfile = '/provider-profile';
  static const settings = '/settings';
  static const notifications = '/notifications';
  static const tickets = '/tickets';
  static const newTicket = '/tickets/new';

  /// Reset Password for the account the reset code was emailed to.
  static String resetPassword(String email) => Uri(
    path: '$forgotPassword/reset',
    queryParameters: {'email': email},
  ).toString();

  /// Login with the email field already filled in.
  static String loginWithEmail(String email) =>
      Uri(path: login, queryParameters: {'email': email}).toString();
  static String chat(String conversationId) => '$messages/$conversationId';

  // ── Tourist tabs ──
  static const home = '/home';
  static const search = '/search';
  static const reservations = '/reservations';
  static const profile = '/profile';

  /// My Reservations opened on the "Past" tab.
  static const pastReservations = '$reservations?tab=past';
  static const reviewSubmitted = '$reservations/review-submitted';
  static String reservationConfirmation(String reservationId) =>
      '$reservations/$reservationId/confirmation';
  static String leaveReview(String reservationId) =>
      '$reservations/$reservationId/review';

  /// Listings open inside whichever tab you're in (Home or Search), so the
  /// bottom nav keeps that tab selected and back returns to it.
  static String listing(BuildContext context, String listingId) =>
      '${listingTabRoot(context)}/listings/$listingId';
  static String booking(BuildContext context, String listingId) =>
      '${listing(context, listingId)}/book';

  /// [search] when [context] is inside the Search tab, otherwise [home].
  static String listingTabRoot(BuildContext context) =>
      GoRouterState.of(context).uri.path.startsWith(search) ? search : home;

  // ── Provider tabs ──
  static const dashboard = '/dashboard';
  static const offers = '/offers';
  static const calendar = '/calendar';
  static const newOffer = '$dashboard/new-offer';
  static const offerPublished = '$dashboard/offer-published';
  static const ratingSaved = '$dashboard/rating-saved';
  static String rateGuest(String reservationId) =>
      '$dashboard/rate-guest/$reservationId';
}

/// What the Register screen hands to Terms & Privacy. Passed in memory as
/// GoRouter `extra` because it contains the password.
class SignUpData {
  const SignUpData({required this.profile, required this.password});

  final RegistrationProfile profile;
  final String password;
}
