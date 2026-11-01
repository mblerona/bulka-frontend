import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bulka_frontend/blocs/reservations/reservations_mock_data.dart';
import 'package:bulka_frontend/core/utils/booking_price.dart';
import 'package:bulka_frontend/models/provider_listing.dart';
import 'package:bulka_frontend/models/reservation.dart';

part 'reservations_event.dart';
part 'reservations_state.dart';

/// Every reservation — the Tourist's bookings and the Provider's incoming
/// requests. Mock data until the bookings API is connected.
class ReservationsBloc extends Bloc<ReservationsEvent, ReservationsState> {
  ReservationsBloc({List<Reservation>? initialReservations})
    : super(ReservationsState(initialReservations ?? mockReservations())) {
    on<ReservationRequested>(_onReservationRequested);
    on<ReservationAccepted>(
      (event, emit) =>
          _updateStatus(event.reservationId, ReservationStatus.accepted, emit),
    );
    on<ReservationRejected>(
      (event, emit) =>
          _updateStatus(event.reservationId, ReservationStatus.rejected, emit),
    );
  }

  // Seeded well above the mock data's plain '1'..'4'/'padding_*' ids so a
  // new reservation's id can never collide with one of them. The
  // display-facing booking reference is a separate sequence on purpose.
  int _nextReservationSequence = 100;
  int _nextBookingReferenceSequence = 40001;

  /// A Tourist booking: prices are fixed at booking time. The new
  /// reservation is in [ReservationsState.lastCreated].
  void _onReservationRequested(
    ReservationRequested event,
    Emitter<ReservationsState> emit,
  ) {
    final now = DateTime.now();
    final nights = event.endDate.difference(event.startDate).inDays;
    final nightlyPrice = event.listing.price;
    final subtotal = nightlyPrice * nights;
    final serviceFee = calculateServiceFee(subtotal);
    final reservation = Reservation(
      id: '${_nextReservationSequence++}',
      guestName: event.guestName,
      listingName: event.listing.title,
      listingId: event.listing.id,
      startDate: event.startDate,
      endDate: event.endDate,
      guestCount: event.guestCount,
      status: ReservationStatus.pending,
      createdAt: now,
      updatedAt: now,
      bookingReference: _generateBookingReference(),
      nightlyPriceAtBooking: nightlyPrice,
      serviceFee: serviceFee,
      totalAmount: subtotal + serviceFee,
    );
    emit(
      ReservationsState([
        reservation,
        ...state.reservations,
      ], lastCreated: reservation),
    );
  }

  void _updateStatus(
    String id,
    ReservationStatus status,
    Emitter<ReservationsState> emit,
  ) {
    if (state.byId(id) == null) return;
    final now = DateTime.now();
    emit(
      ReservationsState([
        for (final r in state.reservations)
          if (r.id == id) r.copyWith(status: status, updatedAt: now) else r,
      ], lastCreated: state.lastCreated),
    );
  }

  String _generateBookingReference() {
    String candidate;
    do {
      candidate = 'RB-${_nextBookingReferenceSequence++}';
    } while (state.reservations.any((r) => r.bookingReference == candidate));
    return candidate;
  }
}
