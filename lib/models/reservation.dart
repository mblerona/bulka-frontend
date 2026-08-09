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
/// in `ReservationController` can be swapped for real fetched records
/// without changing this model or anything that reads it.
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
    );
  }
}
