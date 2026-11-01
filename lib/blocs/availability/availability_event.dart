part of 'availability_bloc.dart';

sealed class AvailabilityEvent {
  const AvailabilityEvent();
}

/// The calendar opened [month] for [listingId]. Does nothing yet: it's
/// where loading from the backend will go.
final class AvailabilityMonthRequested extends AvailabilityEvent {
  const AvailabilityMonthRequested({
    required this.listingId,
    required this.month,
  });

  final String listingId;
  final DateTime month;
}

/// Send only dates that are currently available (see
/// [AvailabilityState.statusFor]); booked dates can't be blocked.
final class DatesBlocked extends AvailabilityEvent {
  const DatesBlocked({required this.listingId, required this.dates});

  final String listingId;
  final Set<DateTime> dates;
}

final class DatesUnblocked extends AvailabilityEvent {
  const DatesUnblocked({required this.listingId, required this.dates});

  final String listingId;
  final Set<DateTime> dates;
}
