import 'package:flutter/material.dart';
import 'package:bulka_frontend/core/constants/app_colors.dart';
import 'package:bulka_frontend/core/constants/app_strings.dart';
import 'package:bulka_frontend/models/listing_amenity.dart';

/// A provider's listing lifecycle state. [label]/[badgeBackground]/
/// [badgeTextColor] centralize the Figma status styling here instead of
/// scattering raw status strings or color-picking logic across the
/// widgets that render a listing — same convention as `TicketStatus`/
/// `ReservationStatus`.
enum ListingStatus {
  active,
  pendingReview,
  rejected,
  archived;

  String get label {
    switch (this) {
      case ListingStatus.active:
        return AppStrings.listingStatusActive;
      case ListingStatus.pendingReview:
        return AppStrings.listingStatusPendingReview;
      case ListingStatus.rejected:
        return AppStrings.listingStatusRejected;
      case ListingStatus.archived:
        return AppStrings.listingStatusArchived;
    }
  }

  Color get badgeBackground {
    switch (this) {
      case ListingStatus.active:
        return AppColors.profileSoftMint;
      case ListingStatus.pendingReview:
        return AppColors.listingPendingReviewBadgeBackground;
      case ListingStatus.rejected:
        return AppColors.listingRejectedBadgeBackground;
      case ListingStatus.archived:
        return AppColors.profileStatCardBorder;
    }
  }

  Color get badgeTextColor {
    switch (this) {
      case ListingStatus.active:
        return AppColors.agroInk500;
      case ListingStatus.pendingReview:
        return AppColors.dashboardPendingReviewAccent;
      case ListingStatus.rejected:
        return AppColors.settingsDangerColor;
      case ListingStatus.archived:
        return AppColors.profileSecondaryText;
    }
  }
}

/// A provider's listing/offer.
///
/// `reservationCount`/`rating` only matter for `active` listings,
/// `rejectionReason` only for `rejected` ones; `updatedAt` doubles as
/// "time of last status change" for the pending-review and archived
/// cards' derived messages, so there's no separate `archivedAt`/
/// `createdAt`.
///
/// `category`/`description`/`price`/`guestCapacity`/`roomCount`/
/// `bedCount`/`amenities`/`photoPaths` were added alongside the Create
/// Offer wizard — they're real data the wizard collects and a listing
/// needs to represent, not speculative fields. `photoPaths` are local
/// file-system paths only (no upload yet); easy to swap for remote URLs
/// once real media upload exists.
///
/// `hostSinceYear` — added for the Buyer Listing Details screen's host
/// row ("Тука од 2021"). There's no provider-account model anywhere in
/// this app yet (a listing has no relation back to a provider's profile
/// at all), so this is deliberately nullable and NOT collected by the
/// Create Offer wizard — a freshly published listing has no host-tenure
/// data to show yet, which is honest; only the mock seed data below sets
/// it, standing in for what a real provider-account "joined" date would
/// eventually supply.
class ProviderListing {
  const ProviderListing({
    required this.id,
    required this.title,
    required this.status,
    required this.location,
    required this.updatedAt,
    this.reservationCount = 0,
    this.rating,
    this.rejectionReason,
    this.category = '',
    this.description = '',
    this.price = 0,
    this.guestCapacity = 0,
    this.roomCount = 0,
    this.bedCount = 0,
    this.amenities = const {},
    this.photoPaths = const [],
    this.hostSinceYear,
  });

  final String id;
  final String title;
  final ListingStatus status;
  final String location;
  final DateTime updatedAt;
  final int reservationCount;
  final double? rating;
  final String? rejectionReason;

  final String category;
  final String description;
  final double price;
  final int guestCapacity;
  final int roomCount;
  final int bedCount;
  final Set<ListingAmenity> amenities;
  final List<String> photoPaths;
  final int? hostSinceYear;

  ProviderListing copyWith({
    ListingStatus? status,
    DateTime? updatedAt,
    String? rejectionReason,
  }) {
    return ProviderListing(
      id: id,
      title: title,
      status: status ?? this.status,
      location: location,
      updatedAt: updatedAt ?? this.updatedAt,
      reservationCount: reservationCount,
      rating: rating,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      category: category,
      description: description,
      price: price,
      guestCapacity: guestCapacity,
      roomCount: roomCount,
      bedCount: bedCount,
      amenities: amenities,
      photoPaths: photoPaths,
      hostSinceYear: hostSinceYear,
    );
  }
}
