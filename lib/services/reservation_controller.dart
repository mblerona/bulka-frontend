import 'package:flutter/foundation.dart';
import 'package:bulka_frontend/core/utils/booking_price.dart';
import 'package:bulka_frontend/models/provider_listing.dart';
import 'package:bulka_frontend/models/reservation.dart';

/// Single shared source of truth for a provider's reservations — same
/// `ChangeNotifier` singleton pattern as the app's other feature
/// controllers. "Резервации кои чекаат" and "Завршени резервации" are
/// derived filters over [reservations], and
/// [monthlyReservationsCount]/counters elsewhere are derived getters —
/// nothing is tracked as a separate hardcoded number.
///
/// [_mockReservations] is local/seed data only, isolated in its own
/// method so it can be replaced by a real reservations API fetch without
/// touching anything else in this class or its callers.
class ReservationController extends ChangeNotifier {
  ReservationController._() : _reservations = _mockReservations();

  static final ReservationController instance = ReservationController._();

  List<Reservation> _reservations;

  // Seeded well above the mock data's plain '1'..'4'/'padding_*' ids so a
  // freshly created reservation's internal id can never collide with one
  // of them; the display-facing `bookingReference` below is generated
  // completely separately (see [_generateBookingReference]) — the two are
  // deliberately different concepts.
  int _nextReservationSequence = 100;
  int _nextBookingReferenceSequence = 40001;

  List<Reservation> get reservations => List.unmodifiable(_reservations);

  List<Reservation> get pendingReservations => _reservations
      .where((r) => r.status == ReservationStatus.pending)
      .toList();

  List<Reservation> get completedReservations => _reservations
      .where((r) => r.status == ReservationStatus.completed)
      .toList();

  int get monthlyReservationsCount {
    final now = DateTime.now();
    return _reservations
        .where(
          (r) => r.startDate.year == now.year && r.startDate.month == now.month,
        )
        .length;
  }

  void acceptReservation(String id) =>
      _updateStatus(id, ReservationStatus.accepted);

  void rejectReservation(String id) =>
      _updateStatus(id, ReservationStatus.rejected);

  void _updateStatus(String id, ReservationStatus status) {
    final index = _reservations.indexWhere((r) => r.id == id);
    if (index == -1) return;
    final now = DateTime.now();
    _reservations = [
      for (final r in _reservations)
        if (r.id == id) r.copyWith(status: status, updatedAt: now) else r,
    ];
    notifyListeners();
  }

  /// The single entry point a Tourist booking creates a real [Reservation]
  /// through — mirrors `ProviderListingController.createListing`'s shape.
  /// Always starts `pending`: this app already has a working
  /// Provider-side accept/reject queue (`acceptReservation`/
  /// `rejectReservation` above, rendered on the Provider Dashboard), so a
  /// Tourist-originated booking goes through exactly that same review
  /// step rather than bypassing it — nothing here talks to the Provider
  /// Dashboard/`AvailabilityController` directly; both simply derive from
  /// [reservations] the moment [notifyListeners] fires, same as every
  /// other reservation already does.
  ///
  /// The price/reference snapshot (`bookingReference`/
  /// `nightlyPriceAtBooking`/`serviceFee`/`totalAmount`) is computed once,
  /// here, from [listing]'s *current* price at booking time — see
  /// `Reservation`'s own doc comment for why that's captured instead of
  /// re-read later. Availability is NOT re-validated here — the caller
  /// (`BookingRequestScreen`) already validated the requested range
  /// against `AvailabilityController` before calling this; this method
  /// trusts a range it's given, the same division of responsibility
  /// `GuestRatingController.submitRating` uses (it re-validates its own
  /// domain-level rules regardless of what the UI already checked, but
  /// doesn't re-derive UI-level state itself).
  Reservation createReservation({
    required ProviderListing listing,
    required String guestName,
    required DateTime startDate,
    required DateTime endDate,
    required int guestCount,
  }) {
    final now = DateTime.now();
    final nights = endDate.difference(startDate).inDays;
    final nightlyPrice = listing.price;
    final subtotal = nightlyPrice * nights;
    final serviceFee = calculateServiceFee(subtotal);

    final reservation = Reservation(
      id: '${_nextReservationSequence++}',
      guestName: guestName,
      listingName: listing.title,
      listingId: listing.id,
      startDate: startDate,
      endDate: endDate,
      guestCount: guestCount,
      status: ReservationStatus.pending,
      createdAt: now,
      updatedAt: now,
      bookingReference: _generateBookingReference(),
      nightlyPriceAtBooking: nightlyPrice,
      serviceFee: serviceFee,
      totalAmount: subtotal + serviceFee,
    );
    _reservations = [reservation, ..._reservations];
    notifyListeners();
    return reservation;
  }

  /// Local-only uniqueness guarantee (checked against every reservation
  /// currently held, not just trusted from the counter) — a real backend
  /// should eventually own generating/guaranteeing this reference.
  /// TODO: replace with a backend-issued booking reference once one
  /// exists.
  String _generateBookingReference() {
    String candidate;
    do {
      candidate = 'RB-${_nextBookingReferenceSequence++}';
    } while (_reservations.any((r) => r.bookingReference == candidate));
    return candidate;
  }

  static List<Reservation> _mockReservations() {
    final now = DateTime.now();
    final thisMonth = DateTime(now.year, now.month);
    // DateTime normalizes month 0 to December of the previous year, so
    // this correctly wraps across a January "now".
    final lastMonth = DateTime(now.year, now.month - 1);

    final seeded = <Reservation>[
      Reservation(
        id: '1',
        guestName: 'Стефан Николовски',
        listingName: 'Villa Zdravkovski',
        listingId: '1',
        startDate: DateTime(thisMonth.year, thisMonth.month, 12),
        endDate: DateTime(thisMonth.year, thisMonth.month, 15),
        guestCount: 2,
        status: ReservationStatus.pending,
        createdAt: now.subtract(const Duration(days: 1)),
        updatedAt: now.subtract(const Duration(days: 1)),
      ),
      Reservation(
        id: '2',
        guestName: 'Ана Трајковска',
        listingName: 'Villa Zdravkovski',
        listingId: '1',
        startDate: DateTime(thisMonth.year, thisMonth.month, 20),
        endDate: DateTime(thisMonth.year, thisMonth.month, 22),
        guestCount: 4,
        status: ReservationStatus.pending,
        createdAt: now.subtract(const Duration(hours: 6)),
        updatedAt: now.subtract(const Duration(hours: 6)),
      ),
      Reservation(
        id: '3',
        guestName: 'Марија Петровска',
        listingName: 'Villa Zdravkovski',
        listingId: '1',
        startDate: DateTime(lastMonth.year, lastMonth.month, 20),
        endDate: DateTime(lastMonth.year, lastMonth.month, 22),
        guestCount: 2,
        status: ReservationStatus.completed,
        createdAt: now.subtract(const Duration(days: 20)),
        updatedAt: now.subtract(const Duration(days: 18)),
      ),
      // Fixed to August 2026 (not relative to `now`, unlike the seed data
      // above) purely so the Provider Availability Calendar's initial
      // August 2026 view has a real accepted reservation to derive
      // "occupied" (12–15 Aug) from, matching the Figma example.
      Reservation(
        id: '4',
        guestName: 'Стефан Николовски',
        listingName: 'Villa Zdravkovski',
        listingId: '1',
        startDate: DateTime(2026, 8, 12),
        endDate: DateTime(2026, 8, 16),
        guestCount: 2,
        status: ReservationStatus.accepted,
        createdAt: DateTime(2026, 7, 20),
        updatedAt: DateTime(2026, 7, 20),
      ),
    ];

    // Padding so `monthlyReservationsCount` derives to the Figma example's
    // 12 from real seed data rather than a hardcoded number — these don't
    // render as cards (only pending/completed reservations do), they only
    // exist to be counted, same as any other reservation would be.
    final guestNames = [
      'Владимир Здравковски',
      'Елена Костова',
      'Горан Илиевски',
      'Христина Митева',
      'Никола Ристовски',
      'Сара Ангеловска',
      'Дејан Павловски',
      'Ивана Стефановска',
      'Александар Јанковски',
      'Билјана Симоновска',
    ];
    for (var i = 0; i < guestNames.length; i++) {
      final day = 1 + (i * 2) % 27;
      seeded.add(
        Reservation(
          id: 'padding_$i',
          guestName: guestNames[i],
          listingName: 'Villa Zdravkovski',
          listingId: '1',
          startDate: DateTime(thisMonth.year, thisMonth.month, day),
          endDate: DateTime(thisMonth.year, thisMonth.month, day + 1),
          guestCount: 2,
          status: ReservationStatus.accepted,
          createdAt: now.subtract(Duration(days: i + 2)),
          updatedAt: now.subtract(Duration(days: i + 2)),
        ),
      );
    }

    return seeded;
  }
}
