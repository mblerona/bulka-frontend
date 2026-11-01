part of 'listings_bloc.dart';

final class ListingsState {
  ListingsState(List<ProviderListing> listings)
    : listings = List.unmodifiable(listings);

  /// Newest first.
  final List<ProviderListing> listings;

  /// For routes like /home/listings/:id. Null if there is no such listing.
  ProviderListing? byId(String id) {
    for (final listing in listings) {
      if (listing.id == id) return listing;
    }
    return null;
  }

  /// All listings when [status] is null, otherwise just that status —
  /// the Provider Offers screen's filter chips.
  List<ProviderListing> filtered({ListingStatus? status}) => status == null
      ? listings
      : listings.where((l) => l.status == status).toList();

  /// What Tourists can browse and book.
  List<ProviderListing> get active => filtered(status: ListingStatus.active);

  int get activeCount => active.length;

  int get pendingReviewCount =>
      listings.where((l) => l.status == ListingStatus.pendingReview).length;

  /// Sorted, distinct locations of active listings (search filter choices).
  List<String> get activeLocations {
    final set = <String>{
      for (final l in active)
        if (l.location.trim().isNotEmpty) l.location,
    };
    return set.toList()..sort();
  }

  /// The lowest and highest active price, for the search price slider.
  ({double min, double max}) get activePriceBounds {
    final prices = [
      for (final l in active)
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
}
