import 'package:bulka_frontend/core/constants/app_strings.dart';

/// An amenity a listing can offer. An enum instead of scattered booleans
/// (`hasWifi`, `hasParking`, ...) so the Create Offer wizard's Step 4 and
/// `ProviderListing.amenities` both work with one small, closed set of
/// values instead of ad hoc flags.
enum ListingAmenity {
  wifi,
  parking,
  kitchen,
  airConditioning,
  tv,
  fireplace,
  farmAccess,
  hotWater,
  petsAllowed;

  String get label {
    switch (this) {
      case ListingAmenity.wifi:
        return AppStrings.amenityWifi;
      case ListingAmenity.parking:
        return AppStrings.amenityParking;
      case ListingAmenity.kitchen:
        return AppStrings.amenityKitchen;
      case ListingAmenity.airConditioning:
        return AppStrings.amenityAirConditioning;
      case ListingAmenity.tv:
        return AppStrings.amenityTv;
      case ListingAmenity.fireplace:
        return AppStrings.amenityFireplace;
      case ListingAmenity.farmAccess:
        return AppStrings.amenityFarmAccess;
      case ListingAmenity.hotWater:
        return AppStrings.amenityHotWater;
      case ListingAmenity.petsAllowed:
        return AppStrings.amenityPetsAllowed;
    }
  }

  /// The matching `code` from `GET /api/amenities`, or null when the
  /// backend has no such amenity. Lets the search filter (which lists the
  /// backend's amenities) match these app-side listings until listings
  /// come from the backend too.
  String? get backendCode => switch (this) {
    ListingAmenity.wifi => 'wi-fi',
    ListingAmenity.parking => 'parking',
    ListingAmenity.petsAllowed => 'pets-allowed',
    _ => null,
  };

  /// Figma renders each amenity with a full-color emoji glyph (not a
  /// simple line icon), so — same precedent as the chat send button's
  /// literal ">" glyph — this is rendered as text, not a Material icon
  /// substitute.
  String get emoji {
    switch (this) {
      case ListingAmenity.wifi:
        return '📶';
      case ListingAmenity.parking:
        return '🅿️';
      case ListingAmenity.kitchen:
        return '🍳';
      case ListingAmenity.airConditioning:
        return '❄️';
      case ListingAmenity.tv:
        return '📺';
      case ListingAmenity.fireplace:
        return '🔥';
      case ListingAmenity.farmAccess:
        return '🐄';
      case ListingAmenity.hotWater:
        return '🚿';
      case ListingAmenity.petsAllowed:
        return '🐾';
    }
  }
}
