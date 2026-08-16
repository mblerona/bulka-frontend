import 'package:flutter/foundation.dart';
import 'package:bulka_frontend/models/listing_review.dart';
import 'package:bulka_frontend/models/provider_listing.dart';
import 'package:bulka_frontend/models/reservation.dart';

/// Single shared source of truth for guest reviews of listings — same
/// `ChangeNotifier` singleton pattern as every other feature controller.
/// Separate from `GuestRatingController` on purpose (see `ListingReview`'s
/// own doc comment): different author, different subject, different UI.
///
/// [_mockReviews] is local/seed data only, isolated in its own method so
/// it can be replaced by a real fetch without touching [reviewsForListing].
class ListingReviewController extends ChangeNotifier {
  ListingReviewController._() : _reviews = _mockReviews();

  static final ListingReviewController instance = ListingReviewController._();

  List<ListingReview> _reviews;
  int _nextReviewId = 100;

  List<ListingReview> reviewsForListing(String listingId) =>
      _reviews.where((r) => r.listingId == listingId).toList();

  bool hasReviewForReservation(String reservationId) =>
      _reviews.any((r) => r.reservationId == reservationId);

  /// The one authoritative rating calculation for a listing — the real
  /// mathematical average of its actual [ListingReview]s when any exist,
  /// never `+=`'d or blended with a phantom review count. Falls back to
  /// [ProviderListing.rating] only when the listing genuinely has no
  /// reviews yet, so listings that predate this feature (or a
  /// freshly-published one) still show something instead of nothing.
  /// Every screen that shows a listing's rating — and the search
  /// filter's rating threshold — reads it through this one method, never
  /// `listing.rating` directly.
  double? effectiveRating(ProviderListing listing) {
    final reviews = reviewsForListing(listing.id);
    if (reviews.isEmpty) return listing.rating;
    final sum = reviews.fold<int>(0, (total, review) => total + review.rating);
    return sum / reviews.length;
  }

  /// Returns the created (or, if one already existed, the existing)
  /// [ListingReview] — or null if [reservation] isn't eligible (not
  /// `completed`) or [rating] is out of range. Never creates a second
  /// review for the same reservation; calling this again for an
  /// already-reviewed reservation is a safe no-op that just returns what's
  /// already there — same shape as `GuestRatingController.submitRating`.
  ListingReview? submitReview({
    required ProviderListing listing,
    required Reservation reservation,
    required String authorName,
    required int rating,
    String? comment,
  }) {
    if (reservation.status != ReservationStatus.completed) return null;
    if (rating < 1 || rating > 5) return null;

    final existing = _reviews
        .where((r) => r.reservationId == reservation.id)
        .toList();
    if (existing.isNotEmpty) return existing.first;

    final trimmedComment = comment?.trim() ?? '';
    final created = ListingReview(
      id: '${_nextReviewId++}',
      listingId: listing.id,
      authorName: authorName,
      rating: rating,
      comment: trimmedComment,
      createdAt: DateTime.now(),
      reservationId: reservation.id,
    );
    _reviews = [created, ..._reviews];
    notifyListeners();
    return created;
  }

  static List<ListingReview> _mockReviews() {
    final now = DateTime.now();
    return [
      ListingReview(
        id: '1',
        listingId: '1',
        authorName: 'Марија П.',
        rating: 5,
        comment:
            'Прекрасно место, многу чисто и мирно. Домаќинот беше многу '
            'љубезен.',
        createdAt: now.subtract(const Duration(days: 30)),
      ),
      ListingReview(
        id: '2',
        listingId: '1',
        authorName: 'Стефан Н.',
        rating: 5,
        comment:
            'Одличен поглед и одлична локација за релаксација. Дефинитивно '
            'ќе се вратиме.',
        createdAt: now.subtract(const Duration(days: 45)),
      ),
    ];
  }
}
