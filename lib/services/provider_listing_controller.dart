import 'package:flutter/foundation.dart';
import 'package:bulka_frontend/core/constants/app_strings.dart';
import 'package:bulka_frontend/models/create_listing_draft.dart';
import 'package:bulka_frontend/models/listing_amenity.dart';
import 'package:bulka_frontend/models/listing_search_filter.dart';
import 'package:bulka_frontend/models/provider_listing.dart';
import 'package:bulka_frontend/services/listing_review_controller.dart';

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

  /// Deterministic, ranking-free source for Tourist Home's "Препорачано за
  /// вас" section — currently just active listings, in [_listings]' own
  /// order. No personalization/recommendation logic exists yet; this is
  /// the one place that would change if/when it does, without Tourist
  /// Home itself needing to change how it reads listings.
  List<ProviderListing> get recommendedListings =>
      filteredListings(status: ListingStatus.active);

  /// Distinct, sorted active-listing locations — the Tourist Search
  /// Filters sheet's "Локација" options derive from real listing data
  /// instead of a hardcoded, unrelated location list.
  List<String> get activeLocations {
    final set = <String>{
      for (final l in recommendedListings)
        if (l.location.trim().isNotEmpty) l.location,
    };
    return set.toList()..sort();
  }

  /// Real min/max price across active listings, backing the Search
  /// Filters sheet's price `RangeSlider` bounds — never hardcoded. Falls
  /// back to a fixed 0–10000 range only when there are no active listings
  /// with a real price to derive bounds from (e.g. a fresh install before
  /// any listing has been approved).
  ({double min, double max}) get activePriceBounds {
    final prices = [
      for (final l in recommendedListings)
        if (l.price > 0) l.price,
    ];
    if (prices.isEmpty) return (min: 0, max: 10000);
    var min = prices.first;
    var max = prices.first;
    for (final p in prices) {
      if (p < min) min = p;
      if (p > max) max = p;
    }
    if (min == max) max = min + 1;
    return (min: min, max: max);
  }

  /// The one place Tourist search/filter rules live — the sheet's `build()`
  /// never filters directly, so swapping this for a real
  /// `GET /listings?...` call later only touches this method. Always
  /// starts from [recommendedListings] (active only — matching or rejected
  /// listings are never searchable).
  ///
  /// [ListingSearchFilter.startDate]/[endDate] are intentionally not
  /// applied here yet: there is no cross-listing "is this listing free on
  /// date X" query surface today — availability is only tracked per
  /// listing for the Provider's own calendar (`AvailabilityController`),
  /// not exposed for search. TODO: once a real availability query exists,
  /// exclude listings that aren't free for [startDate, endDate] here.
  List<ProviderListing> searchListings(ListingSearchFilter filter) {
    final keyword = filter.keyword.trim().toLowerCase();
    return recommendedListings.where((listing) {
      if (keyword.isNotEmpty) {
        final haystack =
            '${listing.title} ${listing.location} ${listing.description}'
                .toLowerCase();
        if (!haystack.contains(keyword)) return false;
      }
      if (filter.location != null && listing.location != filter.location) {
        return false;
      }
      if (filter.minPrice != null && listing.price < filter.minPrice!) {
        return false;
      }
      if (filter.maxPrice != null && listing.price > filter.maxPrice!) {
        return false;
      }
      if (filter.minRating != null) {
        final rating = ListingReviewController.instance.effectiveRating(
          listing,
        );
        if (rating == null || rating < filter.minRating!) {
          return false;
        }
      }
      if (filter.categories.isNotEmpty &&
          !filter.categories.contains(listing.category)) {
        return false;
      }
      if (filter.amenities.isNotEmpty &&
          !filter.amenities.every(listing.amenities.contains)) {
        return false;
      }
      return true;
    }).toList();
  }

  int get pendingReviewListingsCount =>
      _listings.where((l) => l.status == ListingStatus.pendingReview).length;

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
        category: AppStrings.providerCategoryAccommodation,
        price: 2770,
        description:
            'Пространа традиционална куќа во срцето на Преспа, опкружена со '
            'полиња и поглед кон езерото. Совршена за мирен одмор во '
            'природа, со дрвена тераса, домашна кујна и топла атмосфера за '
            'целото семејство.',
        amenities: const {
          ListingAmenity.wifi,
          ListingAmenity.parking,
          ListingAmenity.kitchen,
          ListingAmenity.airConditioning,
          ListingAmenity.tv,
          ListingAmenity.fireplace,
          ListingAmenity.hotWater,
        },
        guestCapacity: 6,
        hostSinceYear: 2021,
      ),
      ProviderListing(
        id: '2',
        title: 'Гостинска соба со појадок',
        status: ListingStatus.active,
        location: 'Охрид',
        reservationCount: 3,
        rating: 4.6,
        updatedAt: now.subtract(const Duration(days: 15)),
        category: AppStrings.providerCategoryAccommodation,
        price: 1980,
        description:
            'Топла и уредна гостинска соба во стара охридска куќа, само '
            'неколку минути пешачење од езерото. Вклучен домашен појадок '
            'секое утро.',
        amenities: const {
          ListingAmenity.wifi,
          ListingAmenity.hotWater,
          ListingAmenity.petsAllowed,
        },
        guestCapacity: 2,
        hostSinceYear: 2019,
      ),
      ProviderListing(
        id: '3',
        title: 'Дегустација на домашно вино',
        status: ListingStatus.active,
        location: 'Тиквеш',
        reservationCount: 2,
        rating: 4.9,
        updatedAt: now.subtract(const Duration(days: 20)),
        category: AppStrings.providerCategoryGastronomy,
        price: 900,
        description:
            'Дегустација на домашно вино во винарија среде лозјата на '
            'Тиквеш, проследена со домашни мезиња и приказна за традицијата '
            'на семејството.',
        amenities: const {ListingAmenity.parking, ListingAmenity.farmAccess},
        guestCapacity: 8,
        hostSinceYear: 2022,
      ),
      ProviderListing(
        id: '4',
        title: 'Тура на фарма',
        status: ListingStatus.active,
        location: 'Брајчино, Преспа',
        reservationCount: 4,
        rating: 4.7,
        updatedAt: now.subtract(const Duration(days: 8)),
        category: AppStrings.providerCategoryFarmParticipation,
        price: 700,
        description:
            'Поминете еден ден на вистинска фарма — хранење на животните, '
            'берба во градината и учество во секојдневните активности, со '
            'домашен ручек на крајот.',
        amenities: const {
          ListingAmenity.parking,
          ListingAmenity.farmAccess,
          ListingAmenity.petsAllowed,
        },
        guestCapacity: 10,
        hostSinceYear: 2020,
      ),
      ProviderListing(
        id: '5',
        title: 'Работилница за сирење',
        status: ListingStatus.active,
        location: 'Крушево',
        reservationCount: 1,
        rating: 5.0,
        updatedAt: now.subtract(const Duration(days: 5)),
        category: AppStrings.providerCategoryFarmEducation,
        price: 850,
        description:
            'Научете го традиционалниот начин на правење сирење од '
            'крушевските планини, чекор по чекор, и однесете си дома '
            'сопствен производ.',
        amenities: const {ListingAmenity.parking, ListingAmenity.kitchen},
        guestCapacity: 6,
        hostSinceYear: 2023,
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
