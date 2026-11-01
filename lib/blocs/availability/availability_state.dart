part of 'availability_bloc.dart';

final class AvailabilityState {
  AvailabilityState(Map<String, Set<DateTime>> blockedDatesByListing)
    : _blocked = Map.unmodifiable({
        for (final entry in blockedDatesByListing.entries)
          entry.key: Set<DateTime>.unmodifiable(entry.value),
      });

  final Map<String, Set<DateTime>> _blocked;

  Set<DateTime> blockedDatesFor(String listingId) =>
      _blocked[listingId] ?? const {};

  AvailabilityState withBlockedDates(String listingId, Set<DateTime> dates) =>
      AvailabilityState({..._blocked, listingId: dates});

  /// Booked (an accepted reservation covers the night), blocked by the
  /// Provider, or available.
  AvailabilityStatus statusFor(
    String listingId,
    DateTime date, {
    required ListingsState listings,
    required ReservationsState reservations,
  }) {
    final day = normalizeDate(date);
    if (_isBooked(listingId, day, listings, reservations)) {
      return AvailabilityStatus.occupied;
    }
    if (blockedDatesFor(listingId).contains(day)) {
      return AvailabilityStatus.blocked;
    }
    return AvailabilityStatus.available;
  }

  static bool _isBooked(
    String listingId,
    DateTime day,
    ListingsState listings,
    ReservationsState reservations,
  ) {
    // Mock reservations only know the listing's title, not its id.
    final listing = listings.byId(listingId);
    if (listing == null) return false;
    return reservations.reservations.any((r) {
      if (r.status != ReservationStatus.accepted) return false;
      if (r.listingName != listing.title) return false;
      return !day.isBefore(normalizeDate(r.startDate)) &&
          day.isBefore(normalizeDate(r.endDate));
    });
  }
}
