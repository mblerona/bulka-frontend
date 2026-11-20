/// Tourist Search & Filters' own UI state — the Figma "Filter Sheet"
/// mapped 1:1 to fields. Sent to `GET /api/listings` by
/// `PublicListingsBloc` (see `listingSearchQuery`), so every field holds
/// what the backend filters on: ids, not translated names.
///
/// Mutable/edited field-by-field like `CreateListingDraft`: this is
/// transient sheet state, never stored.
///
/// `minPrice`/`maxPrice` are null when unrestricted (both ends of
/// [priceSliderMin]..[priceSliderMax]).
class ListingSearchFilter {
  ListingSearchFilter();

  /// The price slider's range, in MKD. Fixed: the listing search doesn't
  /// return prices to derive it from (itemized listings price each item).
  static const double priceSliderMin = 0;
  static const double priceSliderMax = 20000;

  String keyword = '';

  /// `Region.id` from `GET /api/regions`; null = all locations.
  String? regionId;
  double? minPrice;
  double? maxPrice;
  DateTime? startDate;
  DateTime? endDate;

  /// From the Figma "Оценка" chips (Сите/3+★/4+★/4.5+★) — null = "Сите".
  double? minRating;

  /// "Вкупно гости", children included — null = unset (no restriction).
  /// A minimum the listing must fit, not a booking's exact headcount.
  /// Sent as `guests`.
  int? minimumGuests;

  /// "Од нив деца": how many of [minimumGuests] are children, so adults =
  /// [minimumGuests] - [children]. Always 0 while [minimumGuests] is null
  /// and at most [minimumGuests] - 1 (at least one adult). Not sent: the
  /// backend only filters on the total.
  int children = 0;

  int? get adults => minimumGuests == null ? null : minimumGuests! - children;

  /// A top-level `HomeCategory.id`; null = all. One at a time: the backend
  /// filters by a single category.
  String? categoryId;

  /// `Amenity.id`s from `GET /api/amenities`.
  Set<String> amenityIds = {};

  bool get isActive =>
      keyword.trim().isNotEmpty ||
      regionId != null ||
      minPrice != null ||
      maxPrice != null ||
      startDate != null ||
      endDate != null ||
      minRating != null ||
      minimumGuests != null ||
      categoryId != null ||
      amenityIds.isNotEmpty;

  ListingSearchFilter copy() {
    return ListingSearchFilter()
      ..keyword = keyword
      ..regionId = regionId
      ..minPrice = minPrice
      ..maxPrice = maxPrice
      ..startDate = startDate
      ..endDate = endDate
      ..minRating = minRating
      ..minimumGuests = minimumGuests
      ..children = children
      ..categoryId = categoryId
      ..amenityIds = Set.of(amenityIds);
  }

  void reset() {
    keyword = '';
    regionId = null;
    minPrice = null;
    maxPrice = null;
    startDate = null;
    endDate = null;
    minRating = null;
    minimumGuests = null;
    children = 0;
    categoryId = null;
    amenityIds = {};
  }
}
