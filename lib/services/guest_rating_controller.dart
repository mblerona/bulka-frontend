import 'package:flutter/foundation.dart';
import 'package:bulka_frontend/models/guest_rating.dart';
import 'package:bulka_frontend/models/reservation.dart';

/// Single shared source of truth for guest ratings — same `ChangeNotifier`
/// singleton pattern as `ReservationController`/`ProviderListingController`/
/// `AvailabilityController`. A rating always belongs to exactly one
/// `completed` reservation; [hasRating]/[submitRating] are what enforce
/// both the eligibility rule (only completed reservations) and the
/// one-rating-per-reservation rule, so nothing outside this controller
/// needs to reimplement either check.
class GuestRatingController extends ChangeNotifier {
  GuestRatingController._();

  static final GuestRatingController instance = GuestRatingController._();

  final List<GuestRating> _ratings = [];
  int _nextRatingId = 1;

  List<GuestRating> get ratings => List.unmodifiable(_ratings);

  bool hasRating(String reservationId) =>
      _ratings.any((r) => r.reservationId == reservationId);

  GuestRating? ratingForReservation(String reservationId) {
    for (final rating in _ratings) {
      if (rating.reservationId == reservationId) return rating;
    }
    return null;
  }

  /// Returns the created (or, if one already existed, the existing)
  /// [GuestRating] — or null if [reservation] isn't eligible (not
  /// `completed`) or [rating] is out of range. Never creates a second
  /// rating for the same reservation; calling this again for an
  /// already-rated reservation is a safe no-op that just returns what's
  /// already there.
  GuestRating? submitRating({
    required Reservation reservation,
    required int rating,
    String? note,
  }) {
    if (reservation.status != ReservationStatus.completed) return null;
    if (rating < 1 || rating > 5) return null;

    final existing = ratingForReservation(reservation.id);
    if (existing != null) return existing;

    final trimmedNote = note?.trim();
    final created = GuestRating(
      id: '${_nextRatingId++}',
      reservationId: reservation.id,
      guestName: reservation.guestName,
      listingName: reservation.listingName,
      rating: rating,
      note: (trimmedNote == null || trimmedNote.isEmpty) ? null : trimmedNote,
      createdAt: DateTime.now(),
    );
    _ratings.add(created);
    notifyListeners();

    // TODO: once a guest-facing profile/rating surface exists, this is
    // the integration point — every submitted rating must be reflected
    // there (e.g. folded into the guest's average rating). Not
    // implemented here; this feature's scope is Provider-side only, and
    // no Tourist/guest screen exists yet to consume it.

    return created;
  }
}
