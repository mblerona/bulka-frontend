import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:bulka_frontend/core/constants/app_colors.dart';
import 'package:bulka_frontend/core/constants/app_dimensions.dart';
import 'package:bulka_frontend/core/constants/mock_tourist_identity.dart';
import 'package:bulka_frontend/core/routing/app_routes.dart';
import 'package:bulka_frontend/models/create_listing_draft.dart';
import 'package:bulka_frontend/models/listing_search_filter.dart';
import 'package:bulka_frontend/models/provider_listing.dart';
import 'package:bulka_frontend/models/registration_profile.dart';
import 'package:bulka_frontend/models/reservation.dart';
import 'package:bulka_frontend/screens/tourist_home_screen/search_filters_sheet.dart';
import 'package:bulka_frontend/services/chat_controller.dart';
import 'package:bulka_frontend/services/provider_listing_controller.dart';
import 'package:bulka_frontend/services/reservation_controller.dart';

/// Debug-only screen picker. Lists every real screen and opens it through
/// its real route (so tab screens appear inside their tab shell, as in the
/// app) with the real singleton controllers/state.
///
/// Only registered as a route in debug builds (see `app_router.dart`), so
/// it never ships in a release build.
///
/// To add a newly implemented screen: give it a route in `app_router.dart`,
/// then add one [DevScreenEntry] to the relevant section in [_sections].
class DevLauncherScreen extends StatelessWidget {
  const DevLauncherScreen({super.key});

  static const RegistrationProfile _devProfile = RegistrationProfile(
    fullName: 'Дев Тестовски',
    email: 'dev@example.com',
    phone: '070 000 000',
  );

  /// Every entry this launcher opens. Also used by
  /// test/all_screens_localized_test.dart to render each screen in every
  /// language.
  @visibleForTesting
  static List<DevScreenEntry> get allEntries => [
    for (final section in _sections) ...section.entries,
  ];

  static ProviderListing get _firstAccommodation => ProviderListingController
      .instance
      .recommendedListings
      .firstWhere((l) => categoryRequiresPrice(l.category));

  static String _seedMockBooking({required String guestName}) {
    return ReservationController.instance
        .createReservation(
          listing: _firstAccommodation,
          guestName: guestName,
          startDate: DateTime.now().add(const Duration(days: 10)),
          endDate: DateTime.now().add(const Duration(days: 13)),
          guestCount: 2,
        )
        .id;
  }

  static final List<_DevScreenSection> _sections = [
    _DevScreenSection('Onboarding / Auth', [
      DevScreenEntry.route('Splash & Language', () => AppRoutes.splash),
      DevScreenEntry.route('Login', () => AppRoutes.login),
      DevScreenEntry.route('Forgot Password', () => AppRoutes.forgotPassword),
      DevScreenEntry.route('Register', () => AppRoutes.register),
      DevScreenEntry.route(
        'Terms & Privacy',
        () => AppRoutes.registerTerms,
        // Empty password on purpose: submitting from here is rejected by
        // the backend instead of creating a real dev@example.com account.
        extra: const SignUpData(profile: _devProfile, password: ''),
      ),
      DevScreenEntry.route(
        'Email Verification',
        () => AppRoutes.registerVerify,
      ),
    ]),
    _DevScreenSection('Profiles', [
      DevScreenEntry.route('Profile · Tourist', () => AppRoutes.profile),
      DevScreenEntry.route(
        'Profile · Provider',
        () => AppRoutes.providerProfile,
      ),
    ]),
    _DevScreenSection('Tourist', [
      DevScreenEntry.route('Home · Tourist', () => AppRoutes.home),
      DevScreenEntry.widget(
        'Search Filters (Sheet) · Tourist',
        (_) => const _SearchFiltersPreviewScreen(),
      ),
      DevScreenEntry.route('Search Results · Tourist', () => AppRoutes.search),
      DevScreenEntry.route(
        'Listing Details (first active listing) · Tourist',
        () =>
            '${AppRoutes.home}/listings/'
            '${ProviderListingController.instance.recommendedListings.first.id}',
      ),
      DevScreenEntry.route(
        'Booking Request (first accommodation listing) · Tourist',
        () => '${AppRoutes.home}/listings/${_firstAccommodation.id}/book',
      ),
      DevScreenEntry.route(
        'Reservation Confirmation (mock booking) · Tourist',
        () => AppRoutes.reservationConfirmation(
          _seedMockBooking(guestName: 'Дев Тестовски'),
        ),
      ),
      DevScreenEntry.route(
        'My Reservations (seeds one mock booking) · Tourist',
        () {
          _seedMockBooking(guestName: mockTouristGuestName);
          return AppRoutes.reservations;
        },
      ),
      DevScreenEntry.route(
        'Leave Review (first completed reservation) · Tourist',
        () => AppRoutes.leaveReview(
          ReservationController.instance.reservations
              .firstWhere(
                (r) =>
                    r.status == ReservationStatus.completed &&
                    r.listingId != null,
              )
              .id,
        ),
      ),
      DevScreenEntry.route(
        'Review Submitted · Tourist',
        () => AppRoutes.reviewSubmitted,
      ),
    ]),
    _DevScreenSection('Provider', [
      DevScreenEntry.route('Dashboard · Provider', () => AppRoutes.dashboard),
      DevScreenEntry.route('Offers · Provider', () => AppRoutes.offers),
      DevScreenEntry.route(
        'Availability Calendar · Provider',
        () => AppRoutes.calendar,
      ),
      DevScreenEntry.route(
        'Create Offer Wizard · Provider',
        () => AppRoutes.newOffer,
      ),
      DevScreenEntry.route(
        'Offer Published (Success) · Provider',
        () => AppRoutes.offerPublished,
      ),
      DevScreenEntry.route(
        'Rate Guest (first completed reservation) · Provider',
        () => AppRoutes.rateGuest(
          ReservationController.instance.completedReservations.first.id,
        ),
      ),
      DevScreenEntry.route(
        'Rating Saved · Provider',
        () => AppRoutes.ratingSaved,
      ),
    ]),
    _DevScreenSection('Messaging', [
      DevScreenEntry.route('Chat List', () => AppRoutes.messages),
      DevScreenEntry.route(
        'Chat Thread (first mock conversation)',
        () => AppRoutes.chat(ChatController.instance.conversations.first.id),
      ),
    ]),
    _DevScreenSection('Support', [
      DevScreenEntry.route('My Tickets', () => AppRoutes.tickets),
      DevScreenEntry.route('New Support Ticket', () => AppRoutes.newTicket),
    ]),
    _DevScreenSection('Other', [
      DevScreenEntry.route('Notifications', () => AppRoutes.notifications),
      DevScreenEntry.route('Settings', () => AppRoutes.settings),
      DevScreenEntry.route(
        'Unknown route (Not Found)',
        () => '/does-not-exist',
      ),
    ]),
  ];

  void _open(BuildContext context, DevScreenEntry entry) {
    final location = entry.location;
    if (location != null) {
      context.push(location(), extra: entry.extra);
    } else {
      Navigator.of(context).push(MaterialPageRoute(builder: entry.builder!));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dev Screen Launcher'),
        backgroundColor: Colors.black87,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        children: [
          for (final section in _sections) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
              child: Text(
                section.title.toUpperCase(),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  letterSpacing: 0.6,
                  color: Colors.black54,
                ),
              ),
            ),
            for (final entry in section.entries)
              ListTile(
                title: Text(entry.label),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _open(context, entry),
              ),
          ],
        ],
      ),
    );
  }
}

class _DevScreenSection {
  const _DevScreenSection(this.title, this.entries);
  final String title;
  final List<DevScreenEntry> entries;
}

/// One launcher row: either a route (most screens) or, for things that
/// aren't routes (the filter sheet), a widget pushed directly.
class DevScreenEntry {
  /// [location] runs when the entry is opened, so it can seed mock data
  /// first (e.g. create a booking and return its confirmation route).
  const DevScreenEntry.route(
    this.label,
    String Function() this.location, {
    this.extra,
  }) : builder = null;

  const DevScreenEntry.widget(this.label, WidgetBuilder this.builder)
    : location = null,
      extra = null;

  final String label;
  final String Function()? location;
  final Object? extra;
  final WidgetBuilder? builder;
}

/// Opens `SearchFiltersSheet` directly over a blank background — lets the
/// sheet be exercised/tested (state, live result count, apply/close) on
/// its own, without needing to go through `TouristHomeScreen` first.
class _SearchFiltersPreviewScreen extends StatefulWidget {
  const _SearchFiltersPreviewScreen();

  @override
  State<_SearchFiltersPreviewScreen> createState() =>
      _SearchFiltersPreviewScreenState();
}

class _SearchFiltersPreviewScreenState
    extends State<_SearchFiltersPreviewScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _openSheet());
  }

  Future<void> _openSheet() async {
    await showModalBottomSheet<ListingSearchFilter>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimensions.filtersSheetRadius),
        ),
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.92,
      ),
      builder: (_) => SearchFiltersSheet(initialFilter: ListingSearchFilter()),
    );
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(backgroundColor: AppColors.beigeBackground);
  }
}
