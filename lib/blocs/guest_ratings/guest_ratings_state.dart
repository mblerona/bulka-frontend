part of 'guest_ratings_bloc.dart';

final class GuestRatingsState {
  GuestRatingsState(List<GuestRating> ratings)
    : ratings = List.unmodifiable(ratings);

  final List<GuestRating> ratings;

  bool hasRating(String reservationId) =>
      ratings.any((r) => r.reservationId == reservationId);

  GuestRating? forReservation(String reservationId) {
    for (final rating in ratings) {
      if (rating.reservationId == reservationId) return rating;
    }
    return null;
  }
}
