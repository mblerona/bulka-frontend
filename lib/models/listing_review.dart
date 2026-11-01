/// A guest's review of a *listing/property* — deliberately the opposite
/// direction from `GuestRating` (a provider rating a guest after a
/// completed reservation). The two are separate concepts with separate
/// authors and separate subjects; this one is never written by a
/// provider and never reachable from the Provider Rate Guest flow.
class ListingReview {
  const ListingReview({
    required this.id,
    required this.listingId,
    required this.authorName,
    required this.rating,
    required this.comment,
    required this.createdAt,
    this.reservationId,
  });

  final String id;
  final String listingId;
  final String authorName;

  /// Whole stars, 1–5 — matches the Figma "★★★★★" rendering exactly
  /// (repeated glyph count), not a fractional average.
  final int rating;
  final String comment;
  final DateTime createdAt;

  /// The completed `Reservation` this review was written for — the
  /// one-review-per-reservation uniqueness boundary
  /// (`ListingReviewsState.hasReviewForReservation`). Nullable: the
  /// 2 pre-existing mock reviews predate this relationship (neither mock
  /// author actually has a *completed* reservation for that listing in
  /// the mock data) and simply don't participate in the dedup check;
  /// every review created through the real Leave Review flow always has
  /// a real one.
  final String? reservationId;
}
