part of 'public_listings_bloc.dart';

enum ListingsLoadStatus { initial, loading, loaded, failed, notFound }

final class PublicListingsState {
  const PublicListingsState({
    this.recommended = const [],
    this.recommendedStatus = ListingsLoadStatus.initial,
    this.recommendedLanguage,
    this.results = const [],
    this.resultsStatus = ListingsLoadStatus.initial,
    this.resultsTotal = 0,
    this.resultsPage = 0,
    this.resultsHasMore = false,
    this.resultsKey,
    this.loadingMoreResults = false,
    this.details = const {},
    this.detailsStatus = const {},
    this.detailsLanguage = const {},
  });

  // ── Home ──
  final List<PublicListing> recommended;
  final ListingsLoadStatus recommendedStatus;
  final String? recommendedLanguage;

  // ── Search Results ──
  final List<PublicListing> results;
  final ListingsLoadStatus resultsStatus;

  /// How many listings match in all (more than [results] until every page
  /// is loaded).
  final int resultsTotal;
  final int resultsPage;
  final bool resultsHasMore;

  /// [searchKey] of the search [results] belong to.
  final String? resultsKey;
  final bool loadingMoreResults;

  // ── Listing Details, by slug ──
  final Map<String, PublicListing> details;
  final Map<String, ListingsLoadStatus> detailsStatus;
  final Map<String, String> detailsLanguage;

  PublicListing? detailsFor(String slug) => details[slug];

  ListingsLoadStatus detailsStatusFor(String slug) =>
      detailsStatus[slug] ?? ListingsLoadStatus.initial;

  /// A loaded listing by id (bookings and reservations refer to it that
  /// way). Only listings whose details were opened have their items.
  PublicListing? byId(String id) {
    for (final listing in details.values) {
      if (listing.id == id) return listing;
    }
    for (final listing in [...results, ...recommended]) {
      if (listing.id == id) return listing;
    }
    return null;
  }

  bool needsRecommendedFor(String languageCode) =>
      recommendedStatus == ListingsLoadStatus.initial ||
      recommendedStatus == ListingsLoadStatus.failed ||
      recommendedLanguage != languageCode;

  bool needsResultsFor(String key) =>
      resultsKey != key || resultsStatus == ListingsLoadStatus.failed;

  bool needsDetailsFor(String slug, String languageCode) {
    final status = detailsStatusFor(slug);
    return status == ListingsLoadStatus.initial ||
        status == ListingsLoadStatus.failed ||
        detailsLanguage[slug] != languageCode;
  }

  PublicListingsState copyWith({
    List<PublicListing>? recommended,
    ListingsLoadStatus? recommendedStatus,
    String? recommendedLanguage,
    List<PublicListing>? results,
    ListingsLoadStatus? resultsStatus,
    int? resultsTotal,
    int? resultsPage,
    bool? resultsHasMore,
    String? resultsKey,
    bool? loadingMoreResults,
  }) {
    return PublicListingsState(
      recommended: recommended ?? this.recommended,
      recommendedStatus: recommendedStatus ?? this.recommendedStatus,
      recommendedLanguage: recommendedLanguage ?? this.recommendedLanguage,
      results: results ?? this.results,
      resultsStatus: resultsStatus ?? this.resultsStatus,
      resultsTotal: resultsTotal ?? this.resultsTotal,
      resultsPage: resultsPage ?? this.resultsPage,
      resultsHasMore: resultsHasMore ?? this.resultsHasMore,
      resultsKey: resultsKey ?? this.resultsKey,
      loadingMoreResults: loadingMoreResults ?? this.loadingMoreResults,
      details: details,
      detailsStatus: detailsStatus,
      detailsLanguage: detailsLanguage,
    );
  }

  /// Updates one listing's details entry. A failed reload keeps the
  /// details already shown.
  PublicListingsState withDetails(
    String slug, {
    required ListingsLoadStatus status,
    PublicListing? listing,
    String? language,
  }) {
    return PublicListingsState(
      recommended: recommended,
      recommendedStatus: recommendedStatus,
      recommendedLanguage: recommendedLanguage,
      results: results,
      resultsStatus: resultsStatus,
      resultsTotal: resultsTotal,
      resultsPage: resultsPage,
      resultsHasMore: resultsHasMore,
      resultsKey: resultsKey,
      loadingMoreResults: loadingMoreResults,
      details: listing == null ? details : {...details, slug: listing},
      detailsStatus: {...detailsStatus, slug: status},
      detailsLanguage: language == null
          ? detailsLanguage
          : {...detailsLanguage, slug: language},
    );
  }
}
