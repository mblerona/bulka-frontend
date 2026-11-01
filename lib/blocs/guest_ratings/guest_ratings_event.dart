part of 'guest_ratings_bloc.dart';

sealed class GuestRatingsEvent {
  const GuestRatingsEvent();
}

/// From the Rate Guest screen.
final class GuestRatingSubmitted extends GuestRatingsEvent {
  const GuestRatingSubmitted({
    required this.reservation,
    required this.rating,
    this.note,
  });

  final Reservation reservation;
  final int rating;
  final String? note;
}
