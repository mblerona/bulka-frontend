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

  /// The Provider's published (live) offers.
  List<ProviderListing> get active => filtered(status: ListingStatus.active);

  int get activeCount => active.length;

  int get pendingReviewCount =>
      listings.where((l) => l.status == ListingStatus.pendingReview).length;
}
