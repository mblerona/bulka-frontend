import 'package:image_picker/image_picker.dart';
import 'package:bulka_frontend/models/listing_amenity.dart';
import 'package:bulka_frontend/models/listing_category.dart';

/// The categories the Create Offer wizard (and the search filters) offer,
/// in display order. Chips show [ListingCategory.shortLabel].
const List<ListingCategory> createOfferCategories = ListingCategory.values;

/// Whether a listing in [category] charges a nightly price — only
/// accommodation does (Step 6's "по ноќ, доколку се работи за сместување"
/// hint). A listing with no category doesn't.
bool categoryRequiresPrice(ListingCategory? category) =>
    category?.requiresPrice ?? false;

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
  ListingCategory category = createOfferCategories.first;
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
