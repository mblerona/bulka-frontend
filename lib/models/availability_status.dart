import 'package:flutter/material.dart';
import 'package:bulka_frontend/core/constants/app_colors.dart';
import 'package:bulka_frontend/core/constants/app_strings.dart';

/// A single day's availability for one listing's calendar. [legendLabel]/
/// [cellBackground]/[cellTextColor] centralize the Figma styling here
/// instead of scattering raw colors across the calendar grid widget —
/// same convention as `TicketStatus`/`ReservationStatus`/`ListingStatus`.
/// Status drives color, never the other way around.
enum AvailabilityStatus {
  available,
  occupied,
  blocked;

  String get legendLabel {
    switch (this) {
      case AvailabilityStatus.available:
        return AppStrings.availabilityStatusAvailable;
      case AvailabilityStatus.occupied:
        return AppStrings.availabilityStatusOccupied;
      case AvailabilityStatus.blocked:
        return AppStrings.availabilityStatusBlocked;
    }
  }

  Color get cellBackground {
    switch (this) {
      case AvailabilityStatus.available:
        return AppColors.white;
      case AvailabilityStatus.occupied:
        return AppColors.agroGreen700;
      case AvailabilityStatus.blocked:
        return AppColors.calendarBlockedGrey;
    }
  }

  Color get cellTextColor {
    switch (this) {
      case AvailabilityStatus.available:
        return AppColors.agroForest950;
      case AvailabilityStatus.occupied:
      case AvailabilityStatus.blocked:
        return AppColors.white;
    }
  }

  /// Available cells are outlined instead of filled; occupied/blocked
  /// cells are solid, so they have no border.
  Color? get cellBorderColor =>
      this == AvailabilityStatus.available ? AppColors.agroBorder300 : null;
}
