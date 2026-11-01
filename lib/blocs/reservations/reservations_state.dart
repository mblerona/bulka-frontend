part of 'reservations_bloc.dart';

final class ReservationsState {
  ReservationsState(List<Reservation> reservations, {this.lastCreated})
    : reservations = List.unmodifiable(reservations);

  /// Newest first.
  final List<Reservation> reservations;

  /// The reservation the most recent [ReservationRequested] created — the
  /// Booking Request screen listens for it to open the confirmation.
  final Reservation? lastCreated;

  /// For routes like /reservations/:id/review. Null if there is none.
  Reservation? byId(String id) {
    for (final reservation in reservations) {
      if (reservation.id == id) return reservation;
    }
    return null;
  }

  List<Reservation> get pending =>
      reservations.where((r) => r.status == ReservationStatus.pending).toList();

  List<Reservation> get completed => reservations
      .where((r) => r.status == ReservationStatus.completed)
      .toList();

  /// Reservations starting in the current month (Provider Dashboard).
  int get monthlyCount {
    final now = DateTime.now();
    return reservations
        .where(
          (r) => r.startDate.year == now.year && r.startDate.month == now.month,
        )
        .length;
  }
}
