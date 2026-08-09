/// A provider's rating of a guest for one specific completed reservation.
///
/// `guestName`/`listingName` are denormalized copies of the reservation's
/// own fields at rating time — convenient for any future UI that lists
/// ratings without needing to re-join against `ReservationController`,
/// not a second source of truth (the rating is always looked up and
/// created via the originating `Reservation`, never entered by hand).
class GuestRating {
  const GuestRating({
    required this.id,
    required this.reservationId,
    required this.guestName,
    required this.listingName,
    required this.rating,
    this.note,
    required this.createdAt,
  });

  final String id;
  final String reservationId;
  final String guestName;
  final String listingName;

  /// 1–5.
  final int rating;

  /// Trimmed, non-empty, or null — never an empty string.
  final String? note;

  final DateTime createdAt;
}
