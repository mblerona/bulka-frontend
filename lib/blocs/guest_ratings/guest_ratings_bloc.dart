import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bulka_frontend/models/guest_rating.dart';
import 'package:bulka_frontend/models/reservation.dart';

part 'guest_ratings_event.dart';
part 'guest_ratings_state.dart';

/// Providers' ratings of their guests, after a completed stay.
class GuestRatingsBloc extends Bloc<GuestRatingsEvent, GuestRatingsState> {
  GuestRatingsBloc() : super(GuestRatingsState(const [])) {
    on<GuestRatingSubmitted>(_onRatingSubmitted);
  }

  int _nextRatingId = 1;

  /// Only completed reservations, a 1–5 rating, one rating per reservation.
  void _onRatingSubmitted(
    GuestRatingSubmitted event,
    Emitter<GuestRatingsState> emit,
  ) {
    final reservation = event.reservation;
    if (reservation.status != ReservationStatus.completed) return;
    if (event.rating < 1 || event.rating > 5) return;
    if (state.hasRating(reservation.id)) return;
    final note = event.note?.trim();
    final rating = GuestRating(
      id: '${_nextRatingId++}',
      reservationId: reservation.id,
      guestName: reservation.guestName,
      listingName: reservation.listingName,
      rating: event.rating,
      note: (note == null || note.isEmpty) ? null : note,
      createdAt: DateTime.now(),
    );
    emit(GuestRatingsState([...state.ratings, rating]));
  }
}
