part of 'listing_reviews_bloc.dart';

final class ListingReviewsState {
  ListingReviewsState(List<ListingReview> reviews)
    : reviews = List.unmodifiable(reviews);

  /// Newest first.
  final List<ListingReview> reviews;

  List<ListingReview> forListing(String listingId) =>
      reviews.where((r) => r.listingId == listingId).toList();

  bool hasReviewForReservation(String reservationId) =>
      reviews.any((r) => r.reservationId == reservationId);

  /// The average of the listing's reviews, or its stored rating when it has
  /// none yet.
  double? effectiveRating(ProviderListing listing) {
    final listingReviews = forListing(listing.id);
    if (listingReviews.isEmpty) return listing.rating;
    final sum = listingReviews.fold<int>(0, (total, r) => total + r.rating);
    return sum / listingReviews.length;
  }
}
