import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bulka_frontend/core/network/api_client.dart';
import 'package:bulka_frontend/core/network/api_exception.dart';
import 'package:bulka_frontend/core/network/api_response.dart';
import 'package:bulka_frontend/core/network/public_api.dart';
import 'package:bulka_frontend/models/listing_search_filter.dart';
import 'package:bulka_frontend/models/public_listing.dart';

part 'public_listings_event.dart';
part 'public_listings_state.dart';

/// The published listings Tourists browse, from the backend: Home's
/// recommended list, search results and Listing Details.
///
/// The Provider's own offers are a different thing (`ListingsBloc`, still
/// sample data until they move to `/api/provider/itemized-listings`).
class PublicListingsBloc
    extends Bloc<PublicListingsEvent, PublicListingsState> {
  PublicListingsBloc({Dio? dio})
    : _dio = dio ?? ApiClient.instance.dio,
      super(const PublicListingsState()) {
    on<RecommendedListingsRequested>(_onRecommendedRequested);
    on<ListingSearchRequested>(_onSearchRequested);
    on<MoreSearchResultsRequested>(_onMoreResultsRequested);
    on<ListingDetailsRequested>(_onDetailsRequested);
  }

  static const int recommendedCount = 6;
  static const int searchPageSize = 20;

  final Dio _dio;

  // Increase with every request, so an older response that arrives late
  // (e.g. after a quick filter change) doesn't replace a newer one.
  int _latestRecommended = 0;
  int _latestSearch = 0;

  /// What the current results were searched with, for "show more".
  ListingSearchFilter? _searchFilter;

  Future<void> _onRecommendedRequested(
    RecommendedListingsRequested event,
    Emitter<PublicListingsState> emit,
  ) async {
    final request = ++_latestRecommended;
    emit(
      state.copyWith(
        recommendedStatus: ListingsLoadStatus.loading,
        recommendedLanguage: event.languageCode,
      ),
    );
    try {
      final page = await _search(
        listingSearchQuery(
          ListingSearchFilter(),
          page: 1,
          pageSize: recommendedCount,
        ),
      );
      if (request != _latestRecommended) return;
      emit(
        state.copyWith(
          recommended: page.items,
          recommendedStatus: ListingsLoadStatus.loaded,
        ),
      );
    } on ApiException {
      if (request != _latestRecommended) return;
      emit(state.copyWith(recommendedStatus: ListingsLoadStatus.failed));
    }
  }

  Future<void> _onSearchRequested(
    ListingSearchRequested event,
    Emitter<PublicListingsState> emit,
  ) async {
    final request = ++_latestSearch;
    final filter = event.filter.copy();
    _searchFilter = filter;
    emit(
      state.copyWith(
        results: const [],
        resultsStatus: ListingsLoadStatus.loading,
        resultsTotal: 0,
        resultsPage: 0,
        resultsKey: searchKey(filter, event.languageCode),
        loadingMoreResults: false,
      ),
    );
    try {
      final page = await _search(
        listingSearchQuery(filter, page: 1, pageSize: searchPageSize),
      );
      if (request != _latestSearch) return;
      final items = _refineByRating(page.items, filter);
      emit(
        state.copyWith(
          results: items,
          resultsStatus: ListingsLoadStatus.loaded,
          resultsTotal: page.totalCount - (page.items.length - items.length),
          resultsPage: 1,
          resultsHasMore: page.hasMore,
        ),
      );
    } on ApiException {
      if (request != _latestSearch) return;
      emit(state.copyWith(resultsStatus: ListingsLoadStatus.failed));
    }
  }

  Future<void> _onMoreResultsRequested(
    MoreSearchResultsRequested event,
    Emitter<PublicListingsState> emit,
  ) async {
    final filter = _searchFilter;
    if (filter == null ||
        !state.resultsHasMore ||
        state.loadingMoreResults ||
        state.resultsStatus != ListingsLoadStatus.loaded) {
      return;
    }
    final request = _latestSearch;
    final nextPage = state.resultsPage + 1;
    emit(state.copyWith(loadingMoreResults: true));
    try {
      final page = await _search(
        listingSearchQuery(filter, page: nextPage, pageSize: searchPageSize),
      );
      if (request != _latestSearch) return;
      // Skip anything already shown, in case the list shifted meanwhile.
      final shown = {for (final l in state.results) l.id};
      final fresh = _refineByRating(
        page.items,
        filter,
      ).where((l) => !shown.contains(l.id)).toList();
      emit(
        state.copyWith(
          results: [...state.results, ...fresh],
          resultsTotal: state.resultsTotal - (page.items.length - fresh.length),
          resultsPage: nextPage,
          resultsHasMore: page.hasMore && fresh.isNotEmpty,
          loadingMoreResults: false,
        ),
      );
    } on ApiException {
      if (request != _latestSearch) return;
      emit(state.copyWith(loadingMoreResults: false));
    }
  }

  Future<void> _onDetailsRequested(
    ListingDetailsRequested event,
    Emitter<PublicListingsState> emit,
  ) async {
    final slug = event.slug;
    emit(
      state.withDetails(
        slug,
        status: ListingsLoadStatus.loading,
        language: event.languageCode,
      ),
    );
    try {
      final data = await getPublicData(_dio, '/api/listings/$slug');
      if (data is! Map<String, dynamic>) {
        throw const ApiException(kind: ApiErrorKind.unknown);
      }
      final items = data['mode'] == 'Itemized'
          ? await _itemsFor(slug)
          : const <ListingItem>[];
      emit(
        state.withDetails(
          slug,
          status: ListingsLoadStatus.loaded,
          listing: PublicListing.fromDetailJson(data, items: items),
        ),
      );
    } on ApiException catch (e) {
      emit(
        state.withDetails(
          slug,
          status:
              e.statusCode == 404 || e.hasErrorCode('PUBLIC_LISTING_NOT_FOUND')
              ? ListingsLoadStatus.notFound
              : ListingsLoadStatus.failed,
        ),
      );
    }
  }

  /// The items and their prices. Details still show without them if this
  /// fails, just without prices.
  Future<List<ListingItem>> _itemsFor(String slug) async {
    try {
      final data = await getPublicData(_dio, '/api/itemized-listings/$slug');
      if (data is! Map<String, dynamic>) return const [];
      return [
        for (final item in data['items'] as List<dynamic>? ?? const [])
          if (item is Map<String, dynamic>) ListingItem.fromJson(item),
      ];
    } on ApiException {
      return const [];
    }
  }

  Future<PaginatedResponse<PublicListing>> _search(
    Map<String, Object?> query,
  ) async {
    final data = await getPublicData(_dio, '/api/listings', query: query);
    if (data is! Map<String, dynamic>) {
      throw const ApiException(kind: ApiErrorKind.unknown);
    }
    return PaginatedResponse.fromJson(data, PublicListing.fromSearchJson);
  }

  /// The backend's `minRating` is a whole number, so "4.5+" is sent as 4
  /// and narrowed here.
  static List<PublicListing> _refineByRating(
    List<PublicListing> listings,
    ListingSearchFilter filter,
  ) {
    final minRating = filter.minRating;
    if (minRating == null || minRating == minRating.floorToDouble()) {
      return listings;
    }
    return listings.where((l) => (l.averageRating ?? 0) >= minRating).toList();
  }
}

/// The `GET /api/listings` query for [filter]. Only set fields are sent.
Map<String, Object?> listingSearchQuery(
  ListingSearchFilter filter, {
  required int page,
  required int pageSize,
}) {
  final keyword = filter.keyword.trim();
  final start = filter.startDate;
  final end = filter.endDate;
  return {
    // Prices are in denars. The backend also only honours page/pageSize
    // when a filter is present, and this one never excludes anything.
    'currencyCode': 'MKD',
    'sort': 'newest',
    'page': page,
    'pageSize': pageSize,
    if (keyword.isNotEmpty) 'q': keyword,
    if (filter.regionId != null) 'regionId': filter.regionId,
    if (filter.categoryId != null) 'categoryId': filter.categoryId,
    if (filter.amenityIds.isNotEmpty)
      'amenityIds': (filter.amenityIds.toList()..sort()).join(','),
    if (filter.minPrice != null || filter.maxPrice != null) ...{
      'minPrice': (filter.minPrice ?? ListingSearchFilter.priceSliderMin)
          .round(),
      'maxPrice': (filter.maxPrice ?? ListingSearchFilter.priceSliderMax)
          .round(),
    },
    if (filter.minRating != null) 'minRating': filter.minRating!.floor(),
    if (filter.minimumGuests != null) 'guests': filter.minimumGuests,
    // Whole days in the phone's time zone, as the website sends them.
    if (start != null)
      'availabilityFromUtc': DateTime(
        start.year,
        start.month,
        start.day,
      ).toUtc().toIso8601String(),
    if (end != null)
      'availabilityToUtc': DateTime(
        end.year,
        end.month,
        end.day,
        23,
        59,
        59,
        999,
      ).toUtc().toIso8601String(),
  };
}

/// Identifies a search (filter + language), so screens can tell whether
/// the results on hand are for what they show.
String searchKey(ListingSearchFilter filter, String languageCode) {
  final query = listingSearchQuery(filter, page: 1, pageSize: 1);
  return '$languageCode ${jsonEncode(query)}';
}
