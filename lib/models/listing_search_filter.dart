import 'package:bulka_frontend/models/listing_amenity.dart';

/// Tourist Search & Filters' own UI state — the Figma "Filter Sheet"
/// mapped 1:1 to fields, deliberately kept separate from `ProviderListing`
/// itself (this is what the *searcher* is looking for, not listing data).
/// Mutable/edited field-by-field like `CreateListingDraft`, not
/// `copyWith`-based like the app's persisted domain models — this is
/// transient sheet state, not something ever stored.
///
/// `minPrice`/`maxPrice` are null when unrestricted (both ends of the
/// active price range) rather than always carrying concrete numbers —
/// `ProviderListingController.activePriceBounds` supplies the real numbers
/// a slider needs to display, so this model never has to guess or freeze
/// them itself; a backend-provided min/max would replace that getter
/// without this model changing at all.
class ListingSearchFilter {
  ListingSearchFilter();

  String keyword = '';
  String? location;
  double? minPrice;
  double? maxPrice;
  DateTime? startDate;
  DateTime? endDate;

  /// From the Figma "Оценка" chips (Сите/3+★/4+★/4.5+★) — null = "Сите".
  double? minRating;

  /// Values are the same canonical strings as `ProviderListing.category`/
  /// `createOfferCategories` — not a second taxonomy.
  Set<String> categories = {};
  Set<ListingAmenity> amenities = {};

  bool get isActive =>
      keyword.trim().isNotEmpty ||
      location != null ||
      minPrice != null ||
      maxPrice != null ||
      startDate != null ||
      endDate != null ||
      minRating != null ||
      categories.isNotEmpty ||
      amenities.isNotEmpty;

  ListingSearchFilter copy() {
    return ListingSearchFilter()
      ..keyword = keyword
      ..location = location
      ..minPrice = minPrice
      ..maxPrice = maxPrice
      ..startDate = startDate
      ..endDate = endDate
      ..minRating = minRating
      ..categories = Set.of(categories)
      ..amenities = Set.of(amenities);
  }

  void reset() {
    keyword = '';
    location = null;
    minPrice = null;
    maxPrice = null;
    startDate = null;
    endDate = null;
    minRating = null;
    categories = {};
    amenities = {};
  }
}
