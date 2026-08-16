import 'package:flutter/foundation.dart';
import 'package:bulka_frontend/models/listing_search_filter.dart';
import 'package:bulka_frontend/models/provider_listing.dart';
import 'package:bulka_frontend/services/provider_listing_controller.dart';

/// The "current search" — a single shared source of truth for the
/// `ListingSearchFilter` a Tourist last applied and its matching results,
/// same `ChangeNotifier` singleton pattern as every other feature
/// controller. Exists so Search Results and Map View can be pushed/popped
/// freely (Results → Map → Results, or reopening the filter sheet from
/// either) without losing the applied filter — nothing is carried through
/// constructor arguments that a stacked route could lose.
///
/// [matchingListings] is never cached: it's recomputed from
/// `ProviderListingController.instance.searchListings(filter)` on every
/// read, so a listing changing elsewhere (e.g. a new one going active)
/// is reflected here automatically, exactly like every other screen that
/// derives from [ProviderListingController].
class SearchController extends ChangeNotifier {
  SearchController._();

  static final SearchController instance = SearchController._();

  ListingSearchFilter _filter = ListingSearchFilter();

  ListingSearchFilter get filter => _filter;

  List<ProviderListing> get matchingListings =>
      ProviderListingController.instance.searchListings(_filter);

  void applyFilter(ListingSearchFilter filter) {
    _filter = filter;
    notifyListeners();
  }
}
