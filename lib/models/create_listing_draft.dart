import 'package:image_picker/image_picker.dart';
import 'package:bulka_frontend/core/constants/app_strings.dart';
import 'package:bulka_frontend/models/listing_amenity.dart';

/// The one category taxonomy the Create Offer wizard uses — reuses 5 of
/// the existing shared `AppStrings.providerCategory*` constants as-is;
/// the other 2 use this wizard's shorter chip labels
/// (`wizardCategoryFarmRecreation`/`wizardCategoryOffFarmTours`) for the
/// *same* categories, not a second, logically separate set.
const List<String> createOfferCategories = [
  AppStrings.providerCategoryAccommodation,
  AppStrings.providerCategoryGastronomy,
  AppStrings.providerCategoryFarmParticipation,
  AppStrings.providerCategoryDirectSales,
  AppStrings.providerCategoryFarmEducation,
  AppStrings.wizardCategoryFarmRecreation,
  AppStrings.wizardCategoryOffFarmTours,
];

/// Centralizes the "does this category charge a nightly price" business
/// rule in one place, per Step 6's "(по ноќ, доколку се работи за
/// сместување)" hint — only accommodation listings require a price to
/// proceed/publish. Nothing else in the wizard checks `category` directly
/// for this.
bool categoryRequiresPrice(String category) =>
    category == AppStrings.providerCategoryAccommodation;

/// Mutable, single shared draft for the entire Create Offer wizard.
/// Deliberately not immutable/copyWith-based like the app's persisted
/// domain models (`ProviderListing` etc.) — this is edited field-by-field
/// across 6 steps by one screen's `State`, closer in spirit to how
/// `ProviderProfileScreen` already manages many fields directly.
///
/// Every field starts at a genuinely blank value — the Figma mockup's
/// filled-looking numbers/checkboxes are illustrative example content
/// (same convention as every other screen's Figma placeholders in this
/// app), not sensible defaults for a brand new listing.
class CreateListingDraft {
  String category = createOfferCategories.first;
  String title = '';
  String location = '';

  int guestCapacity = 1;
  int roomCount = 1;
  int bedCount = 1;

  Set<ListingAmenity> amenities = {};

  List<XFile> photos = [];

  String description = '';
  double? price;

  static const int minPhotos = 5;

  bool get hasMeaningfulContent =>
      title.trim().isNotEmpty ||
      location.trim().isNotEmpty ||
      description.trim().isNotEmpty ||
      photos.isNotEmpty;

  bool get isStep1Valid => title.trim().isNotEmpty;
  bool get isStep2Valid => location.trim().isNotEmpty;
  bool get isStep3Valid => true;
  bool get isStep4Valid => true;
  bool get isStep5Valid => photos.length >= minPhotos;
  bool get isStep6Valid =>
      description.trim().isNotEmpty &&
      (!categoryRequiresPrice(category) || (price != null && price! > 0));
}
