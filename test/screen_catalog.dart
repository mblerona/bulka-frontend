import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bulka_frontend/blocs/auth/auth_bloc.dart';
import 'package:bulka_frontend/blocs/chat/chat_bloc.dart';
import 'package:bulka_frontend/blocs/listings/listings_bloc.dart';
import 'package:bulka_frontend/blocs/locale/locale_bloc.dart';
import 'package:bulka_frontend/blocs/public_listings/public_listings_bloc.dart';
import 'package:bulka_frontend/blocs/reservations/reservations_bloc.dart';
import 'package:bulka_frontend/blocs/support_tickets/support_tickets_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:bulka_frontend/core/constants/app_colors.dart';
import 'package:bulka_frontend/core/constants/app_dimensions.dart';
import 'package:bulka_frontend/core/constants/app_strings.dart';
import 'package:bulka_frontend/core/routing/app_routes.dart';
import 'package:bulka_frontend/models/create_listing_draft.dart';
import 'package:bulka_frontend/models/listing_search_filter.dart';
import 'package:bulka_frontend/models/provider_listing.dart';
import 'package:bulka_frontend/models/registration_profile.dart';
import 'package:bulka_frontend/models/reservation.dart';
import 'package:bulka_frontend/screens/tourist_home_screen/search_filters_sheet.dart';
import 'package:bulka_frontend/widgets/load_failed_message.dart';

/// Test-only list of every screen (formerly the app's Dev Screen Launcher).
/// Each entry opens its screen through its real route (so tab screens
/// appear inside their tab shell, as in the app) with the real app-wide
/// blocs. `all_screens_localized_test.dart` renders each one in every
/// language; it registers this screen at [ScreenCatalog.path].
///
/// To cover a newly implemented screen: give it a route in
/// `app_router.dart`, then add one [ScreenCatalogEntry] to the relevant
/// section in [_sections].
class ScreenCatalog extends StatelessWidget {
  const ScreenCatalog({super.key});

  /// Where the test registers this screen (not an app route).
  static const path = '/test-screen-catalog';

  static const RegistrationProfile _devProfile = RegistrationProfile(
    fullName: 'Дев Тестовски',
    email: 'dev@example.com',
    phone: '070 000 000',
  );

  /// Every entry, for all_screens_localized_test.dart.
  static List<ScreenCatalogEntry> get allEntries => [
    for (final section in _sections) ...section.entries,
  ];

  static ProviderListing _firstAccommodation(BuildContext context) => context
      .read<ListingsBloc>()
      .state
      .active
      .firstWhere((l) => categoryRequiresPrice(l.category));

  /// Books the first accommodation listing as the signed-in user (or an
  /// account-less dev guest when signed out) and returns the new
  /// reservation's id, once [ReservationsBloc] has created it.
  static Future<String> _seedMockBooking(BuildContext context) async {
    final user = context.read<AuthBloc>().state.user;
    final bloc = context.read<ReservationsBloc>();
    final created = bloc.stream.firstWhere((s) => s.lastCreated != null);
    bloc.add(
      ReservationRequested(
        listing: _firstAccommodation(context),
        guestId: user?.id,
        guestName: user?.fullName ?? 'Дев Тестовски',
        startDate: DateTime.now().add(const Duration(days: 10)),
        endDate: DateTime.now().add(const Duration(days: 13)),
        guestCount: 2,
      ),
    );
    return (await created).lastCreated!.id;
  }

  static final List<_CatalogSection> _sections = [
    _CatalogSection('Onboarding / Auth', [
      ScreenCatalogEntry.route('Splash & Language', (_) => AppRoutes.splash),
      ScreenCatalogEntry.route('Login', (_) => AppRoutes.login),
      ScreenCatalogEntry.route('Forgot Password', (_) => AppRoutes.forgotPassword),
      ScreenCatalogEntry.route(
        'Reset Password',
        (_) => AppRoutes.resetPassword('dev@example.com'),
      ),
      ScreenCatalogEntry.route('Register', (_) => AppRoutes.register),
      ScreenCatalogEntry.route(
        'Terms & Privacy',
        (_) => AppRoutes.registerTerms,
        // Empty password on purpose: submitting from here is rejected by
        // the backend instead of creating a real dev@example.com account.
        extra: const SignUpData(profile: _devProfile, password: ''),
      ),
      ScreenCatalogEntry.route(
        'Email Verification',
        (_) => AppRoutes.registerVerify,
      ),
    ]),
    _CatalogSection('Profiles', [
      ScreenCatalogEntry.route('Profile · Tourist', (_) => AppRoutes.profile),
      ScreenCatalogEntry.route(
        'Profile · Provider',
        (_) => AppRoutes.providerProfile,
      ),
    ]),
    _CatalogSection('Tourist', [
      ScreenCatalogEntry.route('Home · Tourist', (_) => AppRoutes.home),
      ScreenCatalogEntry.widget(
        'Search Filters (Sheet) · Tourist',
        (_) => const _SearchFiltersPreviewScreen(),
      ),
      ScreenCatalogEntry.route('Search Results · Tourist', (_) => AppRoutes.search),
      ScreenCatalogEntry.widget(
        'Listing Details (newest listing) · Tourist',
        (_) => const _OpenPublicListingScreen(bookable: false),
      ),
      ScreenCatalogEntry.widget(
        'Booking Request (newest bookable listing) · Tourist',
        (_) => const _OpenPublicListingScreen(bookable: true),
      ),
      ScreenCatalogEntry.route(
        'Reservation Confirmation (mock booking) · Tourist',
        (context) async =>
            AppRoutes.reservationConfirmation(await _seedMockBooking(context)),
      ),
      ScreenCatalogEntry.route(
        'Reservation Details (mock booking) · Tourist',
        (context) async =>
            AppRoutes.reservationDetails(await _seedMockBooking(context)),
      ),
      ScreenCatalogEntry.route(
        // Only the signed-in user's bookings show, so sign in first.
        'My Reservations (seeds one booking for the signed-in user) · Tourist',
        (context) async {
          await _seedMockBooking(context);
          return AppRoutes.reservations;
        },
      ),
      ScreenCatalogEntry.route(
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
      ScreenCatalogEntry.route(
        'Review Submitted · Tourist',
        (_) => AppRoutes.reviewSubmitted,
      ),
    ]),
    _CatalogSection('Provider', [
      ScreenCatalogEntry.route('Dashboard · Provider', (_) => AppRoutes.dashboard),
      ScreenCatalogEntry.route('Offers · Provider', (_) => AppRoutes.offers),
      ScreenCatalogEntry.route(
        'Availability Calendar · Provider',
        (_) => AppRoutes.calendar,
      ),
      ScreenCatalogEntry.route(
        'Create Offer Wizard · Provider',
        (_) => AppRoutes.newOffer,
      ),
      ScreenCatalogEntry.route(
        'Offer Published (Success) · Provider',
        (_) => AppRoutes.offerPublished,
      ),
      ScreenCatalogEntry.route(
        'Rate Guest (first completed reservation) · Provider',
        (context) => AppRoutes.rateGuest(
          context.read<ReservationsBloc>().state.completed.first.id,
        ),
      ),
      ScreenCatalogEntry.route(
        'Rating Saved · Provider',
        (_) => AppRoutes.ratingSaved,
      ),
    ]),
    _CatalogSection('Messaging', [
      ScreenCatalogEntry.route('Chat List', (_) => AppRoutes.messages),
      ScreenCatalogEntry.widget(
        'Chat Thread (first conversation)',
        (_) => const _OpenFirstConversationScreen(),
      ),
    ]),
    _CatalogSection('Support', [
      ScreenCatalogEntry.route('My Tickets', (_) => AppRoutes.tickets),
      ScreenCatalogEntry.route('New Support Ticket', (_) => AppRoutes.newTicket),
      ScreenCatalogEntry.route('Ticket Details (first ticket, or a local one)', (
        context,
      ) async {
        final tickets = context.read<SupportTicketsBloc>();
        if (tickets.state.tickets.isEmpty) {
          tickets.add(
            const SupportTicketCreated(
              category: 'Other',
              title: 'Dev ticket',
              description: 'A ticket created by the dev launcher.',
            ),
          );
          await tickets.stream.firstWhere((s) => s.tickets.isNotEmpty);
        }
        return AppRoutes.ticket(tickets.state.tickets.first.id);
      }),
    ]),
    _CatalogSection('Other', [
      ScreenCatalogEntry.route('Notifications', (_) => AppRoutes.notifications),
      ScreenCatalogEntry.route('Settings', (_) => AppRoutes.settings),
      ScreenCatalogEntry.route(
        'Unknown route (Not Found)',
        (_) => '/does-not-exist',
      ),
    ]),
  ];

  Future<void> _open(BuildContext context, ScreenCatalogEntry entry) async {
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
        title: const Text('Screen catalog'),
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

class _CatalogSection {
  const _CatalogSection(this.title, this.entries);
  final String title;
  final List<ScreenCatalogEntry> entries;
}

/// One launcher row: either a route (most screens) or, for things that
/// aren't routes (the filter sheet), a widget pushed directly.
class ScreenCatalogEntry {
  /// [location] runs when the entry is opened, so it can seed mock data
  /// first (e.g. create a booking and return its confirmation route), using
  /// the blocs from [BuildContext].
  const ScreenCatalogEntry.route(
    this.label,
    FutureOr<String> Function(BuildContext context) this.location, {
    this.extra,
  }) : builder = null;

  const ScreenCatalogEntry.widget(this.label, WidgetBuilder this.builder)
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
/// Loads the conversations from the backend and opens the first one.
class _OpenFirstConversationScreen extends StatefulWidget {
  const _OpenFirstConversationScreen();

  @override
  State<_OpenFirstConversationScreen> createState() =>
      _OpenFirstConversationScreenState();
}

class _OpenFirstConversationScreenState
    extends State<_OpenFirstConversationScreen> {
  bool _opened = false;

  @override
  void initState() {
    super.initState();
    // After the first frame: opening the conversation pops this screen.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final chat = context.read<ChatBloc>();
      if (chat.state.conversations.isEmpty) {
        _load();
      } else {
        _step(chat.state);
      }
    });
  }

  void _load() =>
      context.read<ChatBloc>().add(const ChatConversationsRequested());

  void _step(ChatState state) {
    final first = state.conversations.firstOrNull;
    if (_opened || first == null) return;
    _opened = true;
    final router = GoRouter.of(context);
    Navigator.of(context).pop();
    router.push(AppRoutes.chat(first.id));
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<ChatBloc>().state;
    return BlocListener<ChatBloc, ChatState>(
      listener: (context, state) => _step(state),
      child: Scaffold(
        backgroundColor: AppColors.white,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(
              AppDimensions.dsBodyHorizontalPadding,
            ),
            child: switch (state.status) {
              ChatStatus.failed => LoadFailedMessage(
                message: AppStrings.chatLoadFailed,
                onRetry: _load,
              ),
              ChatStatus.loaded when state.conversations.isEmpty => Text(
                AppStrings.chatEmpty,
              ),
              _ => const SectionLoadingIndicator(),
            },
          ),
        ),
      ),
    );
  }
}

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
