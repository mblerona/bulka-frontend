part of 'listing_reviews_bloc.dart';

sealed class ListingReviewsEvent {
  const ListingReviewsEvent();
}

/// From the Leave Review screen, after a completed stay.
final class ListingReviewSubmitted extends ListingReviewsEvent {
  const ListingReviewSubmitted({
    required this.listing,
    required this.reservation,
    required this.authorName,
    required this.rating,
    this.comment,
  });

  final ProviderListing listing;
  final Reservation reservation;
  final String authorName;
  final int rating;
  final String? comment;
}
