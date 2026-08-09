import 'package:flutter/foundation.dart';
import 'package:bulka_frontend/models/create_listing_draft.dart';
import 'package:bulka_frontend/models/provider_listing.dart';

/// Single shared source of truth for a provider's listings — same
/// `ChangeNotifier` singleton pattern as `NotificationsController`/
/// `ChatController`/`SupportTicketController`. Both the Provider
/// Dashboard's "Активни понуди"/"На преглед" counters and the Provider
/// Offers screen's filtered lists are derived from [listings], never
/// separate hardcoded data, so a status change on either screen is
/// reflected on the other automatically.
///
/// [_mockListings] is local/seed data only, clearly isolated in its own
/// method so it can be replaced by a real fetch without touching
/// [listings], [filteredListings], or the counters.
class ProviderListingController extends ChangeNotifier {
  ProviderListingController._() : _listings = _mockListings();

  static final ProviderListingController instance =
      ProviderListingController._();

  List<ProviderListing> _listings;
  int _nextListingId = 10;

  List<ProviderListing> get listings => List.unmodifiable(_listings);

  /// All listings when [status] is null, otherwise just that status —
  /// backs the Provider Offers screen's filter chips. There is exactly
  /// one underlying list; nothing is duplicated per filter.
  List<ProviderListing> filteredListings({ListingStatus? status}) {
    if (status == null) return listings;
    return _listings.where((l) => l.status == status).toList();
  }

  int get activeListingsCount =>
      _listings.where((l) => l.status == ListingStatus.active).length;

  int get pendingReviewListingsCount => _listings
      .where((l) => l.status == ListingStatus.pendingReview)
      .length;

  /// Turns a completed [CreateListingDraft] into a real [ProviderListing]
  /// and prepends it to [_listings] — same "newest first" convention as
  /// `SupportTicketController.createTicket`. New listings always start
  /// `pendingReview` (submissions go through moderation, same as every
  /// other freshly-submitted listing already in the mock data), so
  /// [pendingReviewListingsCount] and the Dashboard/Offers screens that
  /// derive from [listings] update on their own the moment this fires
  /// [notifyListeners] — no separate "created offers" list.
  ProviderListing createListing(CreateListingDraft draft) {
    final now = DateTime.now();
    final listing = ProviderListing(
      id: '${_nextListingId++}',
      title: draft.title.trim(),
      status: ListingStatus.pendingReview,
      location: draft.location.trim(),
      updatedAt: now,
      category: draft.category,
      description: draft.description.trim(),
      price: draft.price ?? 0,
      guestCapacity: draft.guestCapacity,
      roomCount: draft.roomCount,
      bedCount: draft.bedCount,
      amenities: Set.of(draft.amenities),
      photoPaths: draft.photos.map((f) => f.path).toList(),
    );
    _listings = [listing, ..._listings];
    notifyListeners();
    return listing;
  }

  /// The one status-changing action Figma actually wires up on this
  /// screen ("Активирај повторно"). Editing-related actions
  /// ("Уреди"/"Уреди и поднеси повторно") aren't implemented here since
  /// they need an edit form that doesn't exist yet — see the Offers
  /// screen for those TODOs.
  void reactivateListing(String id) {
    final index = _listings.indexWhere((l) => l.id == id);
    if (index == -1) return;
    final now = DateTime.now();
    _listings = [
      for (final l in _listings)
        if (l.id == id)
          l.copyWith(status: ListingStatus.active, updatedAt: now)
        else
          l,
    ];
    notifyListeners();
  }

  static List<ProviderListing> _mockListings() {
    final now = DateTime.now();
    return [
      ProviderListing(
        id: '1',
        title: 'Villa Zdravkovski',
        status: ListingStatus.active,
        location: 'Брајчино, Преспа',
        reservationCount: 5,
        rating: 4.8,
        updatedAt: now.subtract(const Duration(days: 10)),
      ),
      ProviderListing(
        id: '2',
        title: 'Гостинска соба со појадок',
        status: ListingStatus.active,
        location: 'Охрид',
        reservationCount: 3,
        rating: 4.6,
        updatedAt: now.subtract(const Duration(days: 15)),
      ),
      ProviderListing(
        id: '3',
        title: 'Дегустација на домашно вино',
        status: ListingStatus.active,
        location: 'Тиквеш',
        reservationCount: 2,
        rating: 4.9,
        updatedAt: now.subtract(const Duration(days: 20)),
      ),
      ProviderListing(
        id: '4',
        title: 'Тура на фарма',
        status: ListingStatus.active,
        location: 'Брајчино, Преспа',
        reservationCount: 4,
        rating: 4.7,
        updatedAt: now.subtract(const Duration(days: 8)),
      ),
      ProviderListing(
        id: '5',
        title: 'Работилница за сирење',
        status: ListingStatus.active,
        location: 'Крушево',
        reservationCount: 1,
        rating: 5.0,
        updatedAt: now.subtract(const Duration(days: 5)),
      ),
      ProviderListing(
        id: '6',
        title: 'Etno House Galičnik',
        status: ListingStatus.pendingReview,
        location: 'Галичник, Мавровско Езеро',
        updatedAt: now.subtract(const Duration(days: 2)),
      ),
      ProviderListing(
        id: '7',
        title: 'Планинарска тура',
        status: ListingStatus.pendingReview,
        location: 'Маврово',
        updatedAt: now.subtract(const Duration(hours: 10)),
      ),
      ProviderListing(
        id: '8',
        title: 'Prespa',
        status: ListingStatus.rejected,
        location: 'Преспа',
        rejectionReason: 'потребни се дополнителни слики.',
        updatedAt: now.subtract(const Duration(days: 4)),
      ),
      ProviderListing(
        id: '9',
        title: 'Стара Куќа Крушево',
        status: ListingStatus.archived,
        location: 'Крушево',
        updatedAt: now.subtract(const Duration(days: 45)),
      ),
    ];
  }
}
