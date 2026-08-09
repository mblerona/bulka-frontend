import 'package:flutter/foundation.dart';
import 'package:bulka_frontend/models/availability_status.dart';
import 'package:bulka_frontend/models/reservation.dart';
import 'package:bulka_frontend/services/provider_listing_controller.dart';
import 'package:bulka_frontend/services/reservation_controller.dart';

/// Single shared source of truth for a listing's calendar availability —
/// same `ChangeNotifier` singleton pattern as the app's other feature
/// controllers.
///
/// A day's [AvailabilityStatus] is never stored directly: "occupied" is
/// always derived from `ReservationController`'s accepted reservations,
/// and "blocked" is the only state this controller actually stores
/// ([_blockedDatesByListing]), so occupied dates can never be
/// accidentally overwritten as blocked — [blockDates] simply never
/// touches a date that resolves to occupied.
class AvailabilityController extends ChangeNotifier {
  AvailabilityController._();

  static final AvailabilityController instance = AvailabilityController._();

  // listingId -> normalized (date-only) blocked dates for that listing.
  // Seed data reproduces the Figma example (5, 6, 28 Aug 2026 blocked for
  // Villa Zdravkovski, listing id '1').
  final Map<String, Set<DateTime>> _blockedDatesByListing = {
    '1': {DateTime(2026, 8, 5), DateTime(2026, 8, 6), DateTime(2026, 8, 28)},
  };

  /// No-op today — availability is all local/seeded already. Real
  /// implementation would fetch [listingId]'s availability for [month]
  /// here; the screen already calls this on load and on month change, so
  /// wiring a real fetch in later won't require any UI changes.
  Future<void> loadAvailability(String listingId, DateTime month) async {}

  AvailabilityStatus statusForDate(String listingId, DateTime date) {
    final normalized = _normalize(date);
    if (_isOccupied(listingId, normalized)) return AvailabilityStatus.occupied;
    if (_blockedDatesByListing[listingId]?.contains(normalized) ?? false) {
      return AvailabilityStatus.blocked;
    }
    return AvailabilityStatus.available;
  }

  /// Only dates currently [AvailabilityStatus.available] are blocked;
  /// anything else in [dates] (already blocked, or occupied) is silently
  /// skipped rather than overwritten.
  void blockDates(String listingId, Set<DateTime> dates) {
    final toBlock = dates
        .map(_normalize)
        .where(
          (d) => statusForDate(listingId, d) == AvailabilityStatus.available,
        )
        .toSet();
    if (toBlock.isEmpty) return;
    _blockedDatesByListing.putIfAbsent(listingId, () => {}).addAll(toBlock);
    notifyListeners();
  }

  /// Only dates currently [AvailabilityStatus.blocked] are unblocked;
  /// occupied dates were never in [_blockedDatesByListing] to begin with,
  /// so they're structurally unaffected either way.
  void unblockDates(String listingId, Set<DateTime> dates) {
    final blocked = _blockedDatesByListing[listingId];
    if (blocked == null) return;
    final toUnblock = dates.map(_normalize).where(blocked.contains).toSet();
    if (toUnblock.isEmpty) return;
    blocked.removeAll(toUnblock);
    notifyListeners();
  }

  /// Reservations only carry a listing *name* today
  /// (`Reservation.listingName`), not a `listingId` — there's no proper
  /// foreign key yet because the real backend/API contract isn't defined.
  /// This matches by name against `ProviderListingController`'s listing
  /// title as a temporary stand-in. TODO: replace with a real ID-based
  /// relationship once the backend model exists; this is the only place
  /// that name-matching logic lives, so that swap won't touch anything
  /// else in this controller or the calendar UI.
  bool _isOccupied(String listingId, DateTime normalizedDate) {
    final matches = ProviderListingController.instance.listings.where(
      (l) => l.id == listingId,
    );
    if (matches.isEmpty) return false;
    final listingTitle = matches.first.title;

    return ReservationController.instance.reservations.any((r) {
      if (r.status != ReservationStatus.accepted) return false;
      if (r.listingName != listingTitle) return false;
      final start = _normalize(r.startDate);
      final end = _normalize(r.endDate);
      // [start, end) — checkout day itself isn't occupied.
      return !normalizedDate.isBefore(start) && normalizedDate.isBefore(end);
    });
  }

  static DateTime _normalize(DateTime date) =>
      DateTime(date.year, date.month, date.day);
}
