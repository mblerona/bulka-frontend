import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:bulka_frontend/core/constants/app_colors.dart';
import 'package:bulka_frontend/core/constants/app_dimensions.dart';
import 'package:bulka_frontend/core/constants/app_strings.dart';
import 'package:bulka_frontend/core/routing/app_routes.dart';
import 'package:bulka_frontend/core/utils/price_format.dart';
import 'package:bulka_frontend/models/create_listing_draft.dart';
import 'package:bulka_frontend/models/listing_amenity.dart';
import 'package:bulka_frontend/models/listing_review.dart';
import 'package:bulka_frontend/models/provider_listing.dart';
import 'package:bulka_frontend/services/favorites_controller.dart';
import 'package:bulka_frontend/services/listing_review_controller.dart';
import 'package:bulka_frontend/services/provider_listing_controller.dart';
import 'package:bulka_frontend/widgets/screen_header.dart';
import 'package:bulka_frontend/widgets/xfile_image.dart';

/// The Figma "24 – Buyer · Listing Details" frame — the one reusable
/// Buyer details screen, reachable from both `TouristHomeScreen`'s
/// recommended cards and `SearchResultsScreen`'s "Прикажи детали". Both
/// callers already hold the exact `ProviderListing` they render, so this
/// takes it directly rather than looking anything up by title.
///
/// [listing] is only the *initial* value: [_ListingDetailsScreenState._listing]
/// re-resolves it by id from `ProviderListingController.instance` on every
/// rebuild (falling back to the constructor value if it's ever no longer
/// in the list), so this never holds a second, potentially-stale copy of
/// the listing's data.
class ListingDetailsScreen extends StatefulWidget {
  const ListingDetailsScreen({super.key, required this.listing});

  final ProviderListing listing;

  @override
  State<ListingDetailsScreen> createState() => _ListingDetailsScreenState();
}

class _ListingDetailsScreenState extends State<ListingDetailsScreen> {
  final ProviderListingController _listingController =
      ProviderListingController.instance;
  final FavoritesController _favorites = FavoritesController.instance;
  final ListingReviewController _reviewController =
      ListingReviewController.instance;

  final PageController _photoController = PageController();
  int _photoIndex = 0;

  @override
  void initState() {
    super.initState();
    _listingController.addListener(_handleChanged);
    _favorites.addListener(_handleChanged);
    _reviewController.addListener(_handleChanged);
  }

  @override
  void dispose() {
    _listingController.removeListener(_handleChanged);
    _favorites.removeListener(_handleChanged);
    _reviewController.removeListener(_handleChanged);
    _photoController.dispose();
    super.dispose();
  }

  void _handleChanged() => setState(() {});

  ProviderListing get _listing => _listingController.listings.firstWhere(
    (l) => l.id == widget.listing.id,
    orElse: () => widget.listing,
  );

  @override
  Widget build(BuildContext context) {
    final listing = _listing;
    final reviews = _reviewController.reviewsForListing(listing.id);
    final presentAmenities = ListingAmenity.values
        .where(listing.amenities.contains)
        .toList();
    final isFavorite = _favorites.isFavorite(listing.id);

    return Scaffold(
      backgroundColor: AppColors.beigeBackground,
      body: Column(
        children: [
          ScreenHeader(
            title: AppStrings.detailsTitle,
            titleFontSize: AppDimensions.dsCompactHeaderTitleFontSize,
            bottomPadding: AppDimensions.dsCompactHeaderBottomPadding,
            contentGap: AppDimensions.dsCompactHeaderGap,
          ),
          Expanded(
            child: SafeArea(
              top: false,
              bottom: false,
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _HeroGallery(
                            listing: listing,
                            isFavorite: isFavorite,
                            onFavoriteTap: () => _favorites.toggle(listing.id),
                            pageController: _photoController,
                            currentIndex: _photoIndex,
                            onPageChanged: (i) =>
                                setState(() => _photoIndex = i),
                          ),
                          _TitleBlock(listing: listing),
                          _HostRow(listing: listing),
                          const _SectionDivider(),
                          _DescriptionSection(listing: listing),
                          const _SectionDivider(),
                          if (presentAmenities.isNotEmpty)
                            _AmenitiesSection(amenities: presentAmenities),
                          _LocationSection(listing: listing),
                          if (reviews.isNotEmpty) ...[
                            const _SectionDivider(),
                            _ReviewsSection(listing: listing, reviews: reviews),
                          ],
                        ],
                      ),
                    ),
                  ),
                  _BookingFooter(listing: listing),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String _ratingReservationsLine(ProviderListing listing) {
  final reservations =
      '${listing.reservationCount} ${AppStrings.resultsReservationsSuffix}';
  final rating = ListingReviewController.instance.effectiveRating(listing);
  if (rating == null) return reservations;
  return '★ ${rating.toStringAsFixed(1)} · $reservations';
}

String _initialsFor(String name) {
  final parts = name
      .trim()
      .split(RegExp(r'\s+'))
      .where((p) => p.isNotEmpty)
      .toList();
  if (parts.isEmpty) return '';
  final first = parts.first.characters.first;
  final second = parts.length > 1 ? parts[1].characters.first : '';
  return (first + second).toUpperCase();
}

class _SectionDivider extends StatelessWidget {
  const _SectionDivider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.dsBodyHorizontalPadding,
      ),
      child: Container(height: 1, color: AppColors.agroBorder300),
    );
  }
}

class _HeroGallery extends StatelessWidget {
  const _HeroGallery({
    required this.listing,
    required this.isFavorite,
    required this.onFavoriteTap,
    required this.pageController,
    required this.currentIndex,
    required this.onPageChanged,
  });

  final ProviderListing listing;
  final bool isFavorite;
  final VoidCallback onFavoriteTap;
  final PageController pageController;
  final int currentIndex;
  final ValueChanged<int> onPageChanged;

  @override
  Widget build(BuildContext context) {
    final photos = listing.photoPaths;
    return SizedBox(
      height: AppDimensions.detailsHeroImageHeight,
      child: Stack(
        children: [
          Positioned.fill(
            child: photos.isEmpty
                ? Container(color: AppColors.agroGreen100)
                : PageView.builder(
                    controller: pageController,
                    onPageChanged: onPageChanged,
                    itemCount: photos.length,
                    itemBuilder: (context, index) => XFileImage(
                      path: photos[index],
                      width: double.infinity,
                      height: AppDimensions.detailsHeroImageHeight,
                      fit: BoxFit.cover,
                    ),
                  ),
          ),
          Positioned(
            top: AppDimensions.detailsHeroOverlayInset,
            right: AppDimensions.detailsHeroOverlayInset,
            child: GestureDetector(
              onTap: onFavoriteTap,
              child: Container(
                width: AppDimensions.detailsHeartButtonSize,
                height: AppDimensions.detailsHeartButtonSize,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: AppColors.detailsHeartButtonBackground,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  isFavorite
                      ? AppStrings.detailsHeartFilledGlyph
                      : AppStrings.detailsHeartOutlineGlyph,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: AppDimensions.detailsHeartGlyphFontSize,
                    color: AppColors.agroForest950,
                  ),
                ),
              ),
            ),
          ),
          if (photos.isNotEmpty)
            Positioned(
              bottom: AppDimensions.detailsHeroOverlayInset,
              right: AppDimensions.detailsHeroOverlayInset,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal:
                      AppDimensions.detailsPhotoCounterHorizontalPadding,
                  vertical: AppDimensions.detailsPhotoCounterVerticalPadding,
                ),
                decoration: BoxDecoration(
                  color: AppColors.detailsPhotoCounterBackground,
                  borderRadius: BorderRadius.circular(
                    AppDimensions.pillBorderRadius,
                  ),
                ),
                child: Text(
                  '${currentIndex + 1} / ${photos.length}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: AppDimensions.detailsPhotoCounterFontSize,
                    color: AppColors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _TitleBlock extends StatelessWidget {
  const _TitleBlock({required this.listing});

  final ProviderListing listing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.dsBodyHorizontalPadding,
        vertical: AppDimensions.detailsSectionVerticalPadding,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.wizardChipHorizontalPadding,
              vertical: AppDimensions.wizardChipVerticalPadding,
            ),
            decoration: BoxDecoration(
              color: AppColors.agroForest950,
              borderRadius: BorderRadius.circular(
                AppDimensions.pillBorderRadius,
              ),
            ),
            child: Text(
              listing.category?.shortLabel ?? '',
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: AppDimensions.wizardChipFontSize,
                color: AppColors.white,
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.detailsTitleBlockGap),
          Text(
            listing.title,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: AppDimensions.detailsTitleFontSize,
              color: AppColors.agroForest950,
            ),
          ),
          const SizedBox(height: AppDimensions.detailsTitleBlockGap),
          Text(
            listing.location,
            style: const TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: AppDimensions.detailsLocationFontSize,
              color: AppColors.profileSecondaryText,
            ),
          ),
          const SizedBox(height: AppDimensions.detailsTitleBlockGap),
          Text(
            _ratingReservationsLine(listing),
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: AppDimensions.detailsRatingLineFontSize,
              color: AppColors.agroForest950,
            ),
          ),
          const SizedBox(height: AppDimensions.detailsTitleBlockGap),
          Container(height: 1, color: AppColors.agroBorder300),
        ],
      ),
    );
  }
}

class _HostRow extends StatelessWidget {
  const _HostRow({required this.listing});

  final ProviderListing listing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.dsBodyHorizontalPadding,
        vertical: AppDimensions.detailsSectionVerticalPadding,
      ),
      child: Row(
        children: [
          Container(
            width: AppDimensions.chatListAvatarSize,
            height: AppDimensions.chatListAvatarSize,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: AppColors.agroGreen100,
              shape: BoxShape.circle,
            ),
            child: Text(
              _initialsFor(listing.title),
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: AppDimensions.rateGuestAvatarInitialsFontSize,
                color: AppColors.agroForest950,
              ),
            ),
          ),
          const SizedBox(width: AppDimensions.wizardAmenityRowGap),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${AppStrings.detailsHostPrefix}${listing.title}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: AppDimensions.detailsHostNameFontSize,
                    color: AppColors.agroForest950,
                  ),
                ),
                if (listing.hostSinceYear != null) ...[
                  const SizedBox(height: AppDimensions.chatListContentGap),
                  Text(
                    '${AppStrings.detailsHostSincePrefix}${listing.hostSinceYear}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: AppDimensions.detailsHostSinceFontSize,
                      color: AppColors.profileSecondaryText,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DescriptionSection extends StatelessWidget {
  const _DescriptionSection({required this.listing});

  final ProviderListing listing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.dsBodyHorizontalPadding,
        vertical: AppDimensions.detailsSectionVerticalPadding,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            AppStrings.detailsAboutHeading,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: AppDimensions.detailsSectionHeadingFontSize,
              color: AppColors.agroForest950,
            ),
          ),
          const SizedBox(height: AppDimensions.detailsDescriptionGap),
          Text(
            listing.description,
            style: const TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: AppDimensions.detailsBodyFontSize,
              height: AppDimensions.detailsBodyLineHeight,
              color: AppColors.agroInk500,
            ),
          ),
        ],
      ),
    );
  }
}

class _AmenitiesSection extends StatelessWidget {
  const _AmenitiesSection({required this.amenities});

  final List<ListingAmenity> amenities;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.dsBodyHorizontalPadding,
        vertical: AppDimensions.detailsSectionVerticalPadding,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            AppStrings.detailsAmenitiesHeading,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: AppDimensions.detailsSectionHeadingFontSize,
              color: AppColors.agroForest950,
            ),
          ),
          const SizedBox(height: AppDimensions.detailsAmenityListGap),
          for (var i = 0; i < amenities.length; i++) ...[
            Row(
              children: [
                Text(
                  amenities[i].emoji,
                  style: const TextStyle(
                    fontSize: AppDimensions.wizardAmenityEmojiFontSize,
                  ),
                ),
                const SizedBox(width: AppDimensions.wizardAmenityRowGap),
                Expanded(
                  child: Text(
                    amenities[i].label,
                    style: const TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: AppDimensions.detailsAmenityLabelFontSize,
                      color: AppColors.agroForest950,
                    ),
                  ),
                ),
              ],
            ),
            if (i != amenities.length - 1)
              const SizedBox(height: AppDimensions.detailsAmenityListGap),
          ],
        ],
      ),
    );
  }
}

class _LocationSection extends StatelessWidget {
  const _LocationSection({required this.listing});

  final ProviderListing listing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.dsBodyHorizontalPadding,
        vertical: AppDimensions.detailsSectionVerticalPadding,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            AppStrings.detailsLocationHeading,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: AppDimensions.detailsSectionHeadingFontSize,
              color: AppColors.agroForest950,
            ),
          ),
          const SizedBox(height: AppDimensions.wizardAmenityRowGap),
          Container(
            width: double.infinity,
            height: AppDimensions.wizardMapHeight,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.agroGreen100,
              borderRadius: BorderRadius.circular(AppDimensions.dsRadiusMd),
            ),
            // TODO: replace with a real interactive map once listing
            // coordinates + a map integration exist (pending the same
            // architecture decision as Search Results' Map View) — this
            // mirrors the Create Offer wizard's own location-step
            // placeholder exactly in the meantime.
            child: const Text(
              AppStrings.wizardMapPinGlyph,
              style: TextStyle(fontSize: AppDimensions.wizardMapPinFontSize),
            ),
          ),
          const SizedBox(height: AppDimensions.wizardAmenityRowGap),
          Text(
            listing.location,
            style: const TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: AppDimensions.detailsAddressFontSize,
              color: AppColors.profileSecondaryText,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewsSection extends StatelessWidget {
  const _ReviewsSection({required this.listing, required this.reviews});

  final ProviderListing listing;
  final List<ListingReview> reviews;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.dsBodyHorizontalPadding,
        vertical: AppDimensions.detailsSectionVerticalPadding,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _ratingReservationsLine(listing),
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: AppDimensions.detailsSectionHeadingFontSize,
              color: AppColors.agroForest950,
            ),
          ),
          const SizedBox(height: AppDimensions.detailsReviewCardGap),
          for (var i = 0; i < reviews.length; i++) ...[
            _ReviewCard(review: reviews[i]),
            if (i != reviews.length - 1)
              const SizedBox(height: AppDimensions.detailsReviewCardGap),
          ],
        ],
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({required this.review});

  final ListingReview review;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '${review.authorName}  ${'★' * review.rating}',
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: AppDimensions.detailsReviewAuthorFontSize,
            color: AppColors.agroForest950,
          ),
        ),
        // The written review is optional (Leave Review's text field isn't
        // required) — skip the line entirely rather than showing blank
        // space for a rating-only review.
        if (review.comment.isNotEmpty) ...[
          const SizedBox(height: AppDimensions.detailsReviewCardInternalGap),
          Text(
            review.comment,
            style: const TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: AppDimensions.detailsReviewCommentFontSize,
              color: AppColors.profileSecondaryText,
            ),
          ),
        ],
      ],
    );
  }
}

class _BookingFooter extends StatelessWidget {
  const _BookingFooter({required this.listing});

  final ProviderListing listing;

  String get _priceLabel {
    final suffix = categoryRequiresPrice(listing.category)
        ? AppStrings.wizardPricePerNightSuffix
        : AppStrings.wizardPriceSuffix;
    return '${formatPrice(listing.price)} $suffix';
  }

  // The check-in/check-out + nightly-price booking flow only makes sense
  // for nightly-priced (accommodation) listings — same category gate
  // `categoryRequiresPrice` already uses everywhere else in the app.
  // Other categories don't have a booking flow/design yet, so the button
  // stays visible but inert rather than forcing a fake nights-based
  // reservation onto data that isn't nightly-priced.
  bool get _bookable => categoryRequiresPrice(listing.category);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.dsBodyHorizontalPadding,
        vertical: AppDimensions.detailsFooterVerticalPadding,
      ),
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(top: BorderSide(color: AppColors.agroBorder300)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _priceLabel,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: AppDimensions.detailsFooterPriceFontSize,
                    color: AppColors.agroForest950,
                  ),
                ),
                const SizedBox(height: AppDimensions.chatListContentGap),
                Text(
                  _ratingReservationsLine(listing),
                  style: const TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: AppDimensions.detailsFooterMetaFontSize,
                    color: AppColors.agroInk500,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: _bookable
                ? () => context.push(AppRoutes.booking(context, listing.id))
                // TODO: this category has no booking flow/design yet —
                // only accommodation listings book via check-in/check-out
                // dates today.
                : () {},
            child: Opacity(
              opacity: _bookable ? 1 : 0.5,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.dsButtonHorizontalPadding,
                  vertical: AppDimensions.dsButtonVerticalPadding,
                ),
                decoration: BoxDecoration(
                  color: AppColors.agroGreen600,
                  borderRadius: BorderRadius.circular(AppDimensions.dsRadiusMd),
                ),
                child: Text(
                  AppStrings.detailsReserveButton,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: AppDimensions.dsButtonFontSize,
                    color: AppColors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
