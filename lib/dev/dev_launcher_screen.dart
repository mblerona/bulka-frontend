import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bulka_frontend/blocs/chat/chat_bloc.dart';
import 'package:bulka_frontend/blocs/listings/listings_bloc.dart';
import 'package:bulka_frontend/blocs/locale/locale_bloc.dart';
import 'package:bulka_frontend/blocs/public_listings/public_listings_bloc.dart';
import 'package:bulka_frontend/blocs/reservations/reservations_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:bulka_frontend/core/constants/app_colors.dart';
import 'package:bulka_frontend/core/constants/app_dimensions.dart';
import 'package:bulka_frontend/core/constants/app_strings.dart';
import 'package:bulka_frontend/core/constants/mock_tourist_identity.dart';
import 'package:bulka_frontend/core/routing/app_routes.dart';
import 'package:bulka_frontend/models/create_listing_draft.dart';
import 'package:bulka_frontend/models/listing_search_filter.dart';
import 'package:bulka_frontend/models/provider_listing.dart';
import 'package:bulka_frontend/models/registration_profile.dart';
import 'package:bulka_frontend/models/reservation.dart';
import 'package:bulka_frontend/screens/tourist_home_screen/search_filters_sheet.dart';
import 'package:bulka_frontend/widgets/load_failed_message.dart';

/// Debug-only screen picker. Lists every real screen and opens it through
/// its real route (so tab screens appear inside their tab shell, as in the
/// app) with the real app-wide blocs.
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

  static ProviderListing _firstAccommodation(BuildContext context) => context
      .read<ListingsBloc>()
      .state
      .active
      .firstWhere((l) => categoryRequiresPrice(l.category));

  /// Books the first accommodation listing and returns the new
  /// reservation's id, once [ReservationsBloc] has created it.
  static Future<String> _seedMockBooking(
    BuildContext context, {
    required String guestName,
  }) async {
    final bloc = context.read<ReservationsBloc>();
    final created = bloc.stream.firstWhere((s) => s.lastCreated != null);
    bloc.add(
      ReservationRequested(
        listing: _firstAccommodation(context),
        guestName: guestName,
        startDate: DateTime.now().add(const Duration(days: 10)),
        endDate: DateTime.now().add(const Duration(days: 13)),
        guestCount: 2,
      ),
    );
    return (await created).lastCreated!.id;
  }

  static final List<_DevScreenSection> _sections = [
    _DevScreenSection('Onboarding / Auth', [
      DevScreenEntry.route('Splash & Language', (_) => AppRoutes.splash),
      DevScreenEntry.route('Login', (_) => AppRoutes.login),
      DevScreenEntry.route('Forgot Password', (_) => AppRoutes.forgotPassword),
      DevScreenEntry.route(
        'Reset Password',
        (_) => AppRoutes.resetPassword('dev@example.com'),
      ),
      DevScreenEntry.route('Register', (_) => AppRoutes.register),
      DevScreenEntry.route(
        'Terms & Privacy',
        (_) => AppRoutes.registerTerms,
        // Empty password on purpose: submitting from here is rejected by
        // the backend instead of creating a real dev@example.com account.
        extra: const SignUpData(profile: _devProfile, password: ''),
      ),
      DevScreenEntry.route(
        'Email Verification',
        (_) => AppRoutes.registerVerify,
      ),
    ]),
    _DevScreenSection('Profiles', [
      DevScreenEntry.route('Profile · Tourist', (_) => AppRoutes.profile),
      DevScreenEntry.route(
        'Profile · Provider',
        (_) => AppRoutes.providerProfile,
      ),
    ]),
    _DevScreenSection('Tourist', [
      DevScreenEntry.route('Home · Tourist', (_) => AppRoutes.home),
      DevScreenEntry.widget(
        'Search Filters (Sheet) · Tourist',
        (_) => const _SearchFiltersPreviewScreen(),
      ),
      DevScreenEntry.route('Search Results · Tourist', (_) => AppRoutes.search),
      DevScreenEntry.widget(
        'Listing Details (newest listing) · Tourist',
        (_) => const _OpenPublicListingScreen(bookable: false),
      ),
      DevScreenEntry.widget(
        'Booking Request (newest bookable listing) · Tourist',
        (_) => const _OpenPublicListingScreen(bookable: true),
      ),
      DevScreenEntry.route(
        'Reservation Confirmation (mock booking) · Tourist',
        (context) async => AppRoutes.reservationConfirmation(
          await _seedMockBooking(context, guestName: 'Дев Тестовски'),
        ),
      ),
      DevScreenEntry.route(
        'My Reservations (seeds one mock booking) · Tourist',
        (context) async {
          await _seedMockBooking(context, guestName: mockTouristGuestName);
          return AppRoutes.reservations;
        },
      ),
      DevScreenEntry.route(
        'Leave Review (first completed reservation) · Tourist',
        (context) => AppRoutes.leaveReview(
          context
              .read<ReservationsBloc>()
              .state
              .reservations
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
        (_) => AppRoutes.reviewSubmitted,
      ),
    ]),
    _DevScreenSection('Provider', [
      DevScreenEntry.route('Dashboard · Provider', (_) => AppRoutes.dashboard),
      DevScreenEntry.route('Offers · Provider', (_) => AppRoutes.offers),
      DevScreenEntry.route(
        'Availability Calendar · Provider',
        (_) => AppRoutes.calendar,
      ),
      DevScreenEntry.route(
        'Create Offer Wizard · Provider',
        (_) => AppRoutes.newOffer,
      ),
      DevScreenEntry.route(
        'Offer Published (Success) · Provider',
        (_) => AppRoutes.offerPublished,
      ),
      DevScreenEntry.route(
        'Rate Guest (first completed reservation) · Provider',
        (context) => AppRoutes.rateGuest(
          context.read<ReservationsBloc>().state.completed.first.id,
        ),
      ),
      DevScreenEntry.route(
        'Rating Saved · Provider',
        (_) => AppRoutes.ratingSaved,
      ),
    ]),
    _DevScreenSection('Messaging', [
      DevScreenEntry.route('Chat List', (_) => AppRoutes.messages),
      DevScreenEntry.route(
        'Chat Thread (first mock conversation)',
        (context) => AppRoutes.chat(
          context.read<ChatBloc>().state.conversations.first.id,
        ),
      ),
    ]),
    _DevScreenSection('Support', [
      DevScreenEntry.route('My Tickets', (_) => AppRoutes.tickets),
      DevScreenEntry.route('New Support Ticket', (_) => AppRoutes.newTicket),
    ]),
    _DevScreenSection('Other', [
      DevScreenEntry.route('Notifications', (_) => AppRoutes.notifications),
      DevScreenEntry.route('Settings', (_) => AppRoutes.settings),
      DevScreenEntry.route(
        'Unknown route (Not Found)',
        (_) => '/does-not-exist',
      ),
    ]),
  ];

  Future<void> _open(BuildContext context, DevScreenEntry entry) async {
    final location = entry.location;
    if (location == null) {
      Navigator.of(context).push(MaterialPageRoute(builder: entry.builder!));
      return;
    }
    final path = await location(context);
    if (!context.mounted) return;
    context.push(path, extra: entry.extra);
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
  /// first (e.g. create a booking and return its confirmation route), using
  /// the blocs from [BuildContext].
  const DevScreenEntry.route(
    this.label,
    FutureOr<String> Function(BuildContext context) this.location, {
    this.extra,
  }) : builder = null;

  const DevScreenEntry.widget(this.label, WidgetBuilder this.builder)
    : location = null,
      extra = null;

  final String label;
  final FutureOr<String> Function(BuildContext context)? location;
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

/// Loads the newest backend listings, then opens the first one's details
/// (or, with [bookable], the booking form of the first one that has a
/// nightly item). Listings are opened by slug, which isn't known until
/// they're loaded.
class _OpenPublicListingScreen extends StatefulWidget {
  const _OpenPublicListingScreen({required this.bookable});

  final bool bookable;

  @override
  State<_OpenPublicListingScreen> createState() =>
      _OpenPublicListingScreenState();
}

class _OpenPublicListingScreenState extends State<_OpenPublicListingScreen> {
  bool _opened = false;

  /// Index into the recommended listings of the one being checked for a
  /// bookable item.
  int _candidate = 0;

  String get _language => context.read<LocaleBloc>().state.locale.languageCode;

  @override
  void initState() {
    super.initState();
    // After the first frame: opening a listing pops this screen.
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _step(context.read<PublicListingsBloc>().state),
    );
  }

  void _loadRecommended() {
    context.read<PublicListingsBloc>().add(
      RecommendedListingsRequested(_language),
    );
  }

  /// Moves on as far as [state] allows.
  void _step(PublicListingsState state) {
    if (_opened) return;
    if (state.needsRecommendedFor(_language) &&
        state.recommendedStatus != ListingsLoadStatus.failed) {
      _loadRecommended();
      return;
    }
    if (state.recommendedStatus != ListingsLoadStatus.loaded) return;
    final listings = state.recommended;
    if (listings.isEmpty) return;
    if (!widget.bookable) {
      _open('${AppRoutes.home}/listings/${listings.first.slug}');
      return;
    }
    while (_candidate < listings.length) {
      final slug = listings[_candidate].slug;
      final status = state.detailsStatusFor(slug);
      if (status == ListingsLoadStatus.loading) return;
      final details = state.detailsFor(slug);
      if (details == null && status == ListingsLoadStatus.initial) {
        context.read<PublicListingsBloc>().add(
          ListingDetailsRequested(slug, _language),
        );
        return;
      }
      if (details?.bookableItem != null) {
        _open('${AppRoutes.home}/listings/$slug/book');
        return;
      }
      _candidate++;
    }
  }

  void _open(String location) {
    _opened = true;
    final router = GoRouter.of(context);
    Navigator.of(context).pop();
    router.push(location);
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<PublicListingsBloc>().state;
    final failed = state.recommendedStatus == ListingsLoadStatus.failed;
    final none =
        state.recommendedStatus == ListingsLoadStatus.loaded &&
        (state.recommended.isEmpty ||
            (widget.bookable && _candidate >= state.recommended.length));
    return BlocListener<PublicListingsBloc, PublicListingsState>(
      listener: (context, state) => _step(state),
      child: Scaffold(
        backgroundColor: AppColors.beigeBackground,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(
              AppDimensions.dsBodyHorizontalPadding,
            ),
            child: failed
                ? LoadFailedMessage(
                    message: AppStrings.listingsLoadFailed,
                    onRetry: _loadRecommended,
                  )
                : none
                ? Text(AppStrings.resultsEmpty)
                : const SectionLoadingIndicator(),
          ),
        ),
      ),
    );
  }
}
