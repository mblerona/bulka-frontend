import 'package:flutter/material.dart';
import 'package:bulka_frontend/core/constants/app_colors.dart';
import 'package:bulka_frontend/core/constants/app_strings.dart';

/// A reservation's lifecycle state. [label]/[pillTextColor] centralize the
/// Figma status styling here instead of scattering raw status strings or
/// color-picking logic across the widgets that render a reservation —
/// same convention as `TicketStatus`.
enum ReservationStatus {
  pending,
  accepted,
  rejected,
  completed,
  cancelled;

  String get label {
    switch (this) {
      case ReservationStatus.pending:
        return AppStrings.reservationStatusPending;
      case ReservationStatus.accepted:
        return AppStrings.reservationStatusAccepted;
      case ReservationStatus.rejected:
        return AppStrings.reservationStatusRejected;
      case ReservationStatus.completed:
        return AppStrings.reservationStatusCompleted;
      case ReservationStatus.cancelled:
        return AppStrings.reservationStatusCancelled;
    }
  }

  /// The Tourist-facing label — identical to [label] except `accepted`,
  /// which Figma's My Reservations screen shows as "ПОТВРДЕНА" ("confirmed",
  /// the guest's perspective) rather than [label]'s "ПРИФАТЕНА" ("accepted",
  /// the Provider Dashboard's own perspective on the exact same status).
  String get touristLabel => this == ReservationStatus.accepted
      ? AppStrings.reservationStatusAcceptedTourist
      : label;

  Color get pillTextColor {
    switch (this) {
      case ReservationStatus.pending:
        // Figma's "agro-gold-600" (#D1BFA7) — same hex already defined as
        // AppColors.agroGold100.
        return AppColors.agroGold100;
      case ReservationStatus.accepted:
        return AppColors.agroGreen700;
      case ReservationStatus.rejected:
      case ReservationStatus.cancelled:
        return AppColors.settingsDangerColor;
      case ReservationStatus.completed:
        return AppColors.agroInk500;
    }
  }
}

/// A guest's reservation against one of a provider's listings. Shaped to
/// map directly onto a future reservations API response so the mock data
/// in `ReservationsBloc` can be swapped for real fetched records
/// without changing this model or anything that reads it.
///
/// `listingId` — added alongside the Tourist booking flow, which is the
/// first place a `Reservation` is ever created directly from a real
/// `ProviderListing` in hand. Nullable/optional: older mock reservations
/// (and anything a future backend response might omit) still work with
/// only `listingName`, which remains the field every existing screen
/// (Provider Dashboard, `AvailabilityState.statusFor`) actually reads — this
/// doesn't replace that, just finally gives new reservations a proper
/// foreign key for when something needs one.
///
/// `bookingReference`/`nightlyPriceAtBooking`/`serviceFee`/`totalAmount`
/// are a price/reference *snapshot* taken at booking time — deliberately
/// separate from `id` (`bookingReference` is the human-readable display
/// value shown in the UI; `id` stays the internal domain identity) and
/// deliberately not re-derived from the listing's *current* price later,
/// so a provider editing a listing's price after the fact can never
/// retroactively change what an already-confirmed reservation shows.
/// `numberOfNights` isn't stored — it's trivially `endDate.difference(
/// startDate).inDays` and storing it would risk drifting from the dates.
class Reservation {
  const Reservation({
    required this.id,
    required this.guestName,
    required this.listingName,
    required this.startDate,
    required this.endDate,
    required this.guestCount,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.listingId,
    this.bookingReference,
    this.nightlyPriceAtBooking,
    this.serviceFee,
    this.totalAmount,
  });

  final String id;
  final String guestName;
  final String listingName;
  final DateTime startDate;
  final DateTime endDate;
  final int guestCount;
  final ReservationStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  final String? listingId;
  final String? bookingReference;
  final double? nightlyPriceAtBooking;
  final double? serviceFee;
  final double? totalAmount;

  Reservation copyWith({ReservationStatus? status, DateTime? updatedAt}) {
    return Reservation(
      id: id,
      guestName: guestName,
      listingName: listingName,
      startDate: startDate,
      endDate: endDate,
      guestCount: guestCount,
      status: status ?? this.status,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      listingId: listingId,
      bookingReference: bookingReference,
      nightlyPriceAtBooking: nightlyPriceAtBooking,
      serviceFee: serviceFee,
      totalAmount: totalAmount,
    );
  }
}
