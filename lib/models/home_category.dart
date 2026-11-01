import 'package:bulka_frontend/models/listing_category.dart';

/// One category chip on Tourist Home's "Категории" row: a [ListingCategory]
/// (the same values provider listings use) plus the emoji Figma shows for
/// it on this screen.
class HomeCategory {
  const HomeCategory({required this.category, required this.emoji});

  final ListingCategory category;
  final String emoji;

  String get label => category.shortLabel;
}

/// Same 7 categories, same order, as `createOfferCategories`.
const List<HomeCategory> touristHomeCategories = [
  HomeCategory(category: ListingCategory.accommodation, emoji: '🏠'),
  HomeCategory(category: ListingCategory.gastronomy, emoji: '🍽️'),
  HomeCategory(category: ListingCategory.farmParticipation, emoji: '🚜'),
  HomeCategory(category: ListingCategory.directSales, emoji: '🧺'),
  HomeCategory(category: ListingCategory.farmEducation, emoji: '📚'),
  HomeCategory(category: ListingCategory.farmRecreation, emoji: '🌿'),
  HomeCategory(category: ListingCategory.offFarmTours, emoji: '🥾'),
];
