import 'package:bulka_frontend/core/constants/app_strings.dart';

/// One category chip on Tourist Home's "Категории" row.
///
/// [value] is deliberately one of the exact same strings
/// `createOfferCategories` (see `create_listing_draft.dart`) uses as a
/// provider listing's `category` — Tourist browsing categories and
/// Provider listing categories are the same domain values, not a second,
/// parallel taxonomy. This just pairs each existing value with the emoji
/// Figma renders for it on this screen.
class HomeCategory {
  const HomeCategory({required this.value, required this.emoji});

  final String value;
  final String emoji;
}

/// Same 7 values, same order, as `createOfferCategories`.
const List<HomeCategory> touristHomeCategories = [
  HomeCategory(value: AppStrings.providerCategoryAccommodation, emoji: '🏠'),
  HomeCategory(value: AppStrings.providerCategoryGastronomy, emoji: '🍽️'),
  HomeCategory(
    value: AppStrings.providerCategoryFarmParticipation,
    emoji: '🚜',
  ),
  HomeCategory(value: AppStrings.providerCategoryDirectSales, emoji: '🧺'),
  HomeCategory(value: AppStrings.providerCategoryFarmEducation, emoji: '📚'),
  HomeCategory(value: AppStrings.wizardCategoryFarmRecreation, emoji: '🌿'),
  HomeCategory(value: AppStrings.wizardCategoryOffFarmTours, emoji: '🥾'),
];
