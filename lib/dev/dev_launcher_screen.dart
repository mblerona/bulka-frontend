import 'package:flutter/material.dart';
import 'package:bulka_frontend/core/constants/app_colors.dart';
import 'package:bulka_frontend/core/constants/app_dimensions.dart';
import 'package:bulka_frontend/core/constants/mock_tourist_identity.dart';
import 'package:bulka_frontend/models/create_listing_draft.dart';
import 'package:bulka_frontend/models/listing_search_filter.dart';
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
import 'package:bulka_frontend/screens/search_results_screen/search_results_screen.dart';
import 'package:bulka_frontend/screens/settings_screen/settings_screen.dart';
import 'package:bulka_frontend/screens/splash_screen/splash_screen.dart';
import 'package:bulka_frontend/screens/terms_privacy_screen/terms_privacy_screen.dart';
import 'package:bulka_frontend/screens/tourist_home_screen/search_filters_sheet.dart';
import 'package:bulka_frontend/screens/tourist_home_screen/tourist_home_screen.dart';
import 'package:bulka_frontend/screens/tourist_my_reservations_screen/tourist_my_reservations_screen.dart';
import 'package:bulka_frontend/services/chat_controller.dart';
import 'package:bulka_frontend/services/provider_listing_controller.dart';
import 'package:bulka_frontend/services/reservation_controller.dart';

/// Debug-only screen picker. Lists every real screen currently implemented
/// in the app and opens it with a plain `Navigator.push` — the actual
/// widget, the actual singleton controllers/state, nothing duplicated or
/// mocked here.
///
/// Only reachable via the `kDebugMode` branch in `main.dart`, so it is
/// never part of the app's real navigation flow and never shows up in a
/// release build.
///
/// To add a newly implemented screen: import it above and append one
/// [_DevScreenEntry] to the relevant section in [_sections] (or add a new
/// section) — no other wiring needed.
class DevLauncherScreen extends StatelessWidget {
  const DevLauncherScreen({super.key});

  static const RegistrationProfile _devProfile = RegistrationProfile(
    fullName: 'Дев Тестовски',
    email: 'dev@example.com',
    phone: '070 000 000',
  );

  static final List<_DevScreenSection> _sections = [
    _DevScreenSection('Onboarding / Auth', [
      _DevScreenEntry('Splash & Language', (_) => const SplashScreen()),
      _DevScreenEntry('Login', (_) => const LoginScreen()),
      _DevScreenEntry('Forgot Password', (_) => const ForgotPasswordScreen()),
      _DevScreenEntry('Register', (_) => const RegisterScreen()),
      _DevScreenEntry(
        'Terms & Privacy',
        // Empty password on purpose: submitting from here is rejected by
        // the backend instead of creating a real dev@example.com account.
        (_) => const TermsPrivacyScreen(profile: _devProfile, password: ''),
      ),
      _DevScreenEntry(
        'Email Verification',
        (_) => const EmailVerificationScreen(),
      ),
    ]),
    _DevScreenSection('Profiles', [
      _DevScreenEntry('Profile · Tourist', (_) => const ProfileScreen()),
      _DevScreenEntry(
        'Profile · Provider',
        (_) => const ProviderProfileScreen(),
      ),
    ]),
    _DevScreenSection('Tourist', [
      _DevScreenEntry('Home · Tourist', (_) => const TouristHomeScreen()),
      _DevScreenEntry(
        'Search Filters (Sheet) · Tourist',
        (_) => const _SearchFiltersPreviewScreen(),
      ),
      _DevScreenEntry(
        'Search Results · Tourist',
        (_) => const SearchResultsScreen(),
      ),
      _DevScreenEntry(
        'Listing Details (first active listing) · Tourist',
        (_) => ListingDetailsScreen(
          listing: ProviderListingController.instance.recommendedListings.first,
        ),
      ),
      _DevScreenEntry(
        'Booking Request (first accommodation listing) · Tourist',
        (_) => BookingRequestScreen(
          listing: ProviderListingController.instance.recommendedListings
              .firstWhere((l) => categoryRequiresPrice(l.category)),
        ),
      ),
      _DevScreenEntry('Reservation Confirmation (mock booking) · Tourist', (_) {
        final listing = ProviderListingController.instance.recommendedListings
            .firstWhere((l) => categoryRequiresPrice(l.category));
        final reservation = ReservationController.instance.createReservation(
          listing: listing,
          guestName: 'Дев Тестовски',
          startDate: DateTime.now().add(const Duration(days: 10)),
          endDate: DateTime.now().add(const Duration(days: 13)),
          guestCount: 2,
        );
        return ReservationConfirmationScreen(
          reservation: reservation,
          listing: listing,
        );
      }),
      _DevScreenEntry('My Reservations (seeds one mock booking) · Tourist', (
        _,
      ) {
        final listing = ProviderListingController.instance.recommendedListings
            .firstWhere((l) => categoryRequiresPrice(l.category));
        ReservationController.instance.createReservation(
          listing: listing,
          guestName: mockTouristGuestName,
          startDate: DateTime.now().add(const Duration(days: 10)),
          endDate: DateTime.now().add(const Duration(days: 13)),
          guestCount: 2,
        );
        return const TouristMyReservationsScreen();
      }),
      _DevScreenEntry('Leave Review (first completed reservation) · Tourist', (
        _,
      ) {
        final reservation = ReservationController.instance.reservations
            .firstWhere((r) => r.status == ReservationStatus.completed);
        final listing = ProviderListingController.instance.listings.firstWhere(
          (l) => l.id == reservation.listingId,
        );
        return LeaveReviewScreen(reservation: reservation, listing: listing);
      }),
      _DevScreenEntry(
        'Review Submitted · Tourist',
        (_) => const ReviewSubmittedScreen(),
      ),
    ]),
    _DevScreenSection('Provider', [
      _DevScreenEntry(
        'Dashboard · Provider',
        (_) => const ProviderDashboardScreen(),
      ),
      _DevScreenEntry('Offers · Provider', (_) => const ProviderOffersScreen()),
      _DevScreenEntry(
        'Availability Calendar · Provider',
        (_) => const ProviderAvailabilityCalendarScreen(),
      ),
      _DevScreenEntry(
        'Create Offer Wizard · Provider',
        (_) => const CreateOfferWizardScreen(),
      ),
      _DevScreenEntry(
        'Offer Published (Success) · Provider',
        (_) => const CreateOfferSuccessScreen(),
      ),
      _DevScreenEntry(
        'Rate Guest (first completed reservation) · Provider',
        (_) => RateGuestScreen(
          reservation:
              ReservationController.instance.completedReservations.first,
        ),
      ),
      _DevScreenEntry(
        'Rating Saved · Provider',
        (_) => const RatingSavedScreen(),
      ),
    ]),
    _DevScreenSection('Messaging', [
      _DevScreenEntry('Chat List', (_) => const ChatListScreen()),
      _DevScreenEntry(
        'Chat Thread (first mock conversation)',
        (_) => ChatThreadScreen(
          conversationId: ChatController.instance.conversations.first.id,
        ),
      ),
    ]),
    _DevScreenSection('Support', [
      _DevScreenEntry('My Tickets', (_) => const MyTicketsScreen()),
      _DevScreenEntry(
        'New Support Ticket',
        (_) => const NewSupportTicketScreen(),
      ),
    ]),
    _DevScreenSection('Other', [
      _DevScreenEntry('Notifications', (_) => const NotificationsScreen()),
      _DevScreenEntry('Settings', (_) => const SettingsScreen()),
    ]),
  ];

  void _open(BuildContext context, _DevScreenEntry entry) {
    Navigator.of(context).push(MaterialPageRoute(builder: entry.builder));
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
  final List<_DevScreenEntry> entries;
}

class _DevScreenEntry {
  const _DevScreenEntry(this.label, this.builder);
  final String label;
  final WidgetBuilder builder;
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
