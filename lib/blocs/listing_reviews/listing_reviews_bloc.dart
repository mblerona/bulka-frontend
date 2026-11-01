import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bulka_frontend/blocs/listing_reviews/listing_reviews_mock_data.dart';
import 'package:bulka_frontend/models/listing_review.dart';
import 'package:bulka_frontend/models/provider_listing.dart';
import 'package:bulka_frontend/models/reservation.dart';

part 'listing_reviews_event.dart';
part 'listing_reviews_state.dart';

/// Tourists' reviews of listings. Mock data until the reviews API is
/// connected.
class ListingReviewsBloc
    extends Bloc<ListingReviewsEvent, ListingReviewsState> {
  ListingReviewsBloc({List<ListingReview>? initialReviews})
    : super(ListingReviewsState(initialReviews ?? mockReviews())) {
    on<ListingReviewSubmitted>(_onReviewSubmitted);
  }

  int _nextReviewId = 100;

  /// Re-checks the rules itself, whatever the screen already checked: only
  /// completed reservations, a 1–5 rating, and one review per reservation.
  void _onReviewSubmitted(
    ListingReviewSubmitted event,
    Emitter<ListingReviewsState> emit,
  ) {
    if (event.reservation.status != ReservationStatus.completed) return;
    if (event.rating < 1 || event.rating > 5) return;
    if (state.hasReviewForReservation(event.reservation.id)) return;
    final review = ListingReview(
      id: '${_nextReviewId++}',
      listingId: event.listing.id,
      authorName: event.authorName,
      rating: event.rating,
      comment: event.comment?.trim() ?? '',
      createdAt: DateTime.now(),
      reservationId: event.reservation.id,
    );
    emit(ListingReviewsState([review, ...state.reviews]));
  }
}
