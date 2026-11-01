// Mock seed data until this feature is connected to the backend.
import 'package:bulka_frontend/models/listing_review.dart';

List<ListingReview> mockReviews() {
  final now = DateTime.now();
  return [
    ListingReview(
      id: '1',
      listingId: '1',
      authorName: 'Марија П.',
      rating: 5,
      comment:
          'Прекрасно место, многу чисто и мирно. Домаќинот беше многу '
          'љубезен.',
      createdAt: now.subtract(const Duration(days: 30)),
    ),
    ListingReview(
      id: '2',
      listingId: '1',
      authorName: 'Стефан Н.',
      rating: 5,
      comment:
          'Одличен поглед и одлична локација за релаксација. Дефинитивно '
          'ќе се вратиме.',
      createdAt: now.subtract(const Duration(days: 45)),
    ),
  ];
}
