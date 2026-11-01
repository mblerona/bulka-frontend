import 'package:bulka_frontend/core/constants/app_strings.dart';

/// The 7 offer categories. Stored and compared as this enum, never as
/// text, so filtering and matching don't depend on the app's language.
enum ListingCategory {
  accommodation,
  gastronomy,
  farmParticipation,
  directSales,
  farmEducation,
  farmRecreation,
  offFarmTours;

  /// Full name, e.g. on the Provider Profile's category checklist.
  String get label => switch (this) {
    accommodation => AppStrings.providerCategoryAccommodation,
    gastronomy => AppStrings.providerCategoryGastronomy,
    farmParticipation => AppStrings.providerCategoryFarmParticipation,
    directSales => AppStrings.providerCategoryDirectSales,
    farmEducation => AppStrings.providerCategoryFarmEducation,
    farmRecreation => AppStrings.providerCategoryFarmRecreation,
    offFarmTours => AppStrings.providerCategoryOffFarmTours,
  };

  /// Shorter name for chips and cards (Create Offer wizard, Tourist Home,
  /// filters, listing details). Only the two long names differ.
  String get shortLabel => switch (this) {
    farmRecreation => AppStrings.wizardCategoryFarmRecreation,
    offFarmTours => AppStrings.wizardCategoryOffFarmTours,
    _ => label,
  };

  /// Only accommodation charges a nightly price (Create Offer, Step 6).
  bool get requiresPrice => this == accommodation;
}
