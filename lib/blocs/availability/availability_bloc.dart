import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bulka_frontend/blocs/listings/listings_bloc.dart';
import 'package:bulka_frontend/blocs/reservations/reservations_bloc.dart';
import 'package:bulka_frontend/models/availability_status.dart';
import 'package:bulka_frontend/models/reservation.dart';

part 'availability_event.dart';
part 'availability_state.dart';

/// Dates a Provider has blocked on their calendar. Whether a date is
/// booked comes from the reservations, see [AvailabilityState.statusFor].
class AvailabilityBloc extends Bloc<AvailabilityEvent, AvailabilityState> {
  AvailabilityBloc()
    : super(
        AvailabilityState({
          '1': {
            DateTime(2026, 8, 5),
            DateTime(2026, 8, 6),
            DateTime(2026, 8, 28),
          },
        }),
      ) {
    on<AvailabilityMonthRequested>((event, emit) {
      // TODO: load the month from the availability API once connected.
    });
    on<DatesBlocked>(_onDatesBlocked);
    on<DatesUnblocked>(_onDatesUnblocked);
  }

  void _onDatesBlocked(DatesBlocked event, Emitter<AvailabilityState> emit) {
    final current = state.blockedDatesFor(event.listingId);
    final added = event.dates.map(normalizeDate).toSet()..removeAll(current);
    if (added.isEmpty) return;
    emit(state.withBlockedDates(event.listingId, {...current, ...added}));
  }

  void _onDatesUnblocked(
    DatesUnblocked event,
    Emitter<AvailabilityState> emit,
  ) {
    final current = state.blockedDatesFor(event.listingId);
    final remaining = Set.of(current)
      ..removeAll(event.dates.map(normalizeDate));
    if (remaining.length == current.length) return;
    emit(state.withBlockedDates(event.listingId, remaining));
  }
}

/// The date with the time of day removed.
DateTime normalizeDate(DateTime date) =>
    DateTime(date.year, date.month, date.day);
