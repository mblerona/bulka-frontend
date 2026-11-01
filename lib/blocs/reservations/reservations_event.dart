part of 'reservations_bloc.dart';

sealed class ReservationsEvent {
  const ReservationsEvent();
}

/// A Tourist books [listing] from the Booking Request screen.
final class ReservationRequested extends ReservationsEvent {
  const ReservationRequested({
    required this.listing,
    required this.guestName,
    required this.startDate,
    required this.endDate,
    required this.guestCount,
  });

  final ProviderListing listing;
  final String guestName;
  final DateTime startDate;
  final DateTime endDate;
  final int guestCount;
}

/// The Provider accepts a pending request.
final class ReservationAccepted extends ReservationsEvent {
  const ReservationAccepted(this.reservationId);

  final String reservationId;
}

/// The Provider rejects a pending request.
final class ReservationRejected extends ReservationsEvent {
  const ReservationRejected(this.reservationId);

  final String reservationId;
}
