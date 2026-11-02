import 'package:bulka_frontend/core/constants/app_strings.dart';
import 'package:bulka_frontend/core/utils/price_format.dart';
import 'package:bulka_frontend/models/public_listing.dart';

/// "★ 4.5 · 3 рецензии", or "No ratings yet".
String listingRatingLine(PublicListing listing) {
  final rating = listing.averageRating;
  if (rating == null) return AppStrings.listingNoRatingsYet;
  return '★ ${rating.toStringAsFixed(1)} · '
      '${listing.reviewCount} ${AppStrings.listingReviewsSuffix}';
}

/// "1.300 ден." / "3.000 ден. / ноќ" / "1.000 ден. / ноќ по лице".
String listingItemPriceLabel(ListingItem item) {
  final price = item.price;
  if (price == null) return '';
  final unit = item.kind == ListingItemKind.accommodation
      ? AppStrings.wizardPricePerNightSuffix
      : AppStrings.wizardPriceSuffix;
  final perPerson = item.perPerson
      ? ' ${AppStrings.listingPerPersonSuffix}'
      : '';
  return '${formatPrice(price)} $unit$perPerson';
}

/// The price to show on a card or the details footer: the listing's own
/// price, else "from" its cheapest item, else "Prices per selected item"
/// (search results don't include item prices).
String listingPriceLabel(PublicListing listing) {
  final own = listing.priceAmount;
  if (own != null) return '${formatPrice(own)} ${AppStrings.wizardPriceSuffix}';
  final cheapest = listing.lowestPricedItem;
  if (cheapest != null) {
    return '${AppStrings.homePricePrefix}${listingItemPriceLabel(cheapest)}';
  }
  return AppStrings.listingPricesPerItem;
}
