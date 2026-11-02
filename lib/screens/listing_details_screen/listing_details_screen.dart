import 'package:flutter/material.dart';
import 'package:bulka_frontend/blocs/favorites/favorites_bloc.dart';
import 'package:bulka_frontend/blocs/listing_reviews/listing_reviews_bloc.dart';
import 'package:bulka_frontend/blocs/locale/locale_bloc.dart';
import 'package:bulka_frontend/blocs/public_listings/public_listings_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:bulka_frontend/core/constants/app_colors.dart';
import 'package:bulka_frontend/core/constants/app_dimensions.dart';
import 'package:bulka_frontend/core/constants/app_strings.dart';
import 'package:bulka_frontend/core/routing/app_routes.dart';
import 'package:bulka_frontend/core/utils/listing_format.dart';
import 'package:bulka_frontend/models/amenity.dart';
import 'package:bulka_frontend/models/listing_review.dart';
import 'package:bulka_frontend/models/public_listing.dart';
import 'package:bulka_frontend/screens/route_not_found_screen/route_not_found_screen.dart';
import 'package:bulka_frontend/widgets/listing_image.dart';
import 'package:bulka_frontend/widgets/load_failed_message.dart';
import 'package:bulka_frontend/widgets/screen_header.dart';

/// Loads the listing [slug] (`PublicListingsBloc`) and builds [builder]
/// with it once loaded: a spinner meanwhile, Not Found for an unknown
/// slug, and an error with "Try again" if loading fails. Reloads after a
/// language switch, since the backend translates the listing.
class PublicListingLoader extends StatefulWidget {
  const PublicListingLoader({
    super.key,
    required this.slug,
    required this.builder,
  });

  final String slug;
  final Widget Function(BuildContext context, PublicListing listing) builder;

  @override
  State<PublicListingLoader> createState() => _PublicListingLoaderState();
}

class _PublicListingLoaderState extends State<PublicListingLoader> {
  @override
  void initState() {
    super.initState();
    _load(context);
  }

  void _load(BuildContext context, {bool force = false}) {
    final language = context.read<LocaleBloc>().state.locale.languageCode;
    final listings = context.read<PublicListingsBloc>();
    if (force || listings.state.needsDetailsFor(widget.slug, language)) {
      listings.add(ListingDetailsRequested(widget.slug, language));
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<PublicListingsBloc>().state;
    final listing = state.detailsFor(widget.slug);
    final status = state.detailsStatusFor(widget.slug);

    final Widget child;
    if (listing != null) {
      child = widget.builder(context, listing);
    } else if (status == ListingsLoadStatus.notFound) {
      child = const RouteNotFoundScreen();
    } else {
      child = Scaffold(
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
              child: Padding(
                padding: const EdgeInsets.all(
                  AppDimensions.dsBodyHorizontalPadding,
                ),
                child: status == ListingsLoadStatus.failed
                    ? Align(
                        alignment: Alignment.topCenter,
                        child: LoadFailedMessage(
                          message: AppStrings.listingDetailsLoadFailed,
                          onRetry: () => _load(context, force: true),
                        ),
                      )
                    : const SectionLoadingIndicator(),
              ),
            ),
          ],
        ),
      );
    }
    return BlocListener<LocaleBloc, LocaleState>(
      listenWhen: (previous, current) => previous.locale != current.locale,
      listener: (context, _) => _load(context),
      child: child,
    );
  }
}

/// The Figma "24 – Buyer · Listing Details" frame, reachable from Tourist
/// Home's recommended cards and Search Results' "Прикажи детали". Shows a
/// listing from the backend; `PublicListingLoader` loads it.
class ListingDetailsScreen extends StatefulWidget {
  const ListingDetailsScreen({super.key, required this.listing});

  final PublicListing listing;

  @override
  State<ListingDetailsScreen> createState() => _ListingDetailsScreenState();
}

class _ListingDetailsScreenState extends State<ListingDetailsScreen> {
  final PageController _photoController = PageController();
  int _photoIndex = 0;

  @override
  void dispose() {
    _photoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final listing = widget.listing;
    // Reviews left through the (still local) booking flow.
    final reviews = context.watch<ListingReviewsBloc>().state.forListing(
      listing.id,
    );
    final isFavorite = context.watch<FavoritesBloc>().state.isFavorite(
      listing.id,
    );

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
                            photos: listing.imageUrls,
                            isFavorite: isFavorite,
                            onFavoriteTap: () => context
                                .read<FavoritesBloc>()
                                .add(FavoriteToggled(listing.id)),
                            pageController: _photoController,
                            currentIndex: _photoIndex,
                            onPageChanged: (i) =>
                                setState(() => _photoIndex = i),
                          ),
                          _TitleBlock(listing: listing),
                          if (listing.providerName != null)
                            _HostRow(name: listing.providerName!),
                          const _SectionDivider(),
                          _DescriptionSection(listing: listing),
                          if (listing.items.isNotEmpty) ...[
                            const _SectionDivider(),
                            _ItemsSection(items: listing.items),
                          ],
                          const _SectionDivider(),
                          if (listing.amenities.isNotEmpty)
                            _AmenitiesSection(amenities: listing.amenities),
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

Widget _sectionHeading(String text) => Text(
  text,
  style: const TextStyle(
    fontWeight: FontWeight.w700,
    fontSize: AppDimensions.detailsSectionHeadingFontSize,
    color: AppColors.agroForest950,
  ),
);

class _HeroGallery extends StatelessWidget {
  const _HeroGallery({
    required this.photos,
    required this.isFavorite,
    required this.onFavoriteTap,
    required this.pageController,
    required this.currentIndex,
    required this.onPageChanged,
  });

  final List<String> photos;
  final bool isFavorite;
  final VoidCallback onFavoriteTap;
  final PageController pageController;
  final int currentIndex;
  final ValueChanged<int> onPageChanged;

  @override
  Widget build(BuildContext context) {
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
                    itemBuilder: (context, index) => ListingImage(
                      url: photos[index],
                      height: AppDimensions.detailsHeroImageHeight,
                      placeholderColor: AppColors.agroGreen100,
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
          if (photos.length > 1)
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

  final PublicListing listing;

  @override
  Widget build(BuildContext context) {
    final category = listing.categories.isEmpty
        ? null
        : listing.categories.first;
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.dsBodyHorizontalPadding,
        vertical: AppDimensions.detailsSectionVerticalPadding,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (category != null) ...[
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
                category.name,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: AppDimensions.wizardChipFontSize,
                  color: AppColors.white,
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.detailsTitleBlockGap),
          ],
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
            listingRatingLine(listing),
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
  const _HostRow({required this.name});

  final String name;

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
              _initialsFor(name),
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: AppDimensions.rateGuestAvatarInitialsFontSize,
                color: AppColors.agroForest950,
              ),
            ),
          ),
          const SizedBox(width: AppDimensions.wizardAmenityRowGap),
          Expanded(
            child: Text(
              '${AppStrings.detailsHostPrefix}$name',
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: AppDimensions.detailsHostNameFontSize,
                color: AppColors.agroForest950,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DescriptionSection extends StatelessWidget {
  const _DescriptionSection({required this.listing});

  final PublicListing listing;

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
          _sectionHeading(AppStrings.detailsAboutHeading),
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

/// What can be booked (rooms, tours, meals) and what each costs.
class _ItemsSection extends StatelessWidget {
  const _ItemsSection({required this.items});

  final List<ListingItem> items;

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
          _sectionHeading(AppStrings.detailsItemsHeading),
          const SizedBox(height: AppDimensions.detailsAmenityListGap),
          for (var i = 0; i < items.length; i++) ...[
            _ItemRow(item: items[i]),
            if (i != items.length - 1)
              const SizedBox(height: AppDimensions.detailsAmenityListGap),
          ],
        ],
      ),
    );
  }
}

class _ItemRow extends StatelessWidget {
  const _ItemRow({required this.item});

  final ListingItem item;

  @override
  Widget build(BuildContext context) {
    final capacity = item.capacity;
    final meta = [
      listingItemPriceLabel(item),
      if (capacity != null) '$capacity ${AppStrings.reservationGuestsPlural}',
    ].where((part) => part.isNotEmpty).join(' · ');
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.offersCardInfoPadding),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: AppColors.agroBorder300),
        borderRadius: BorderRadius.circular(AppDimensions.dsRadiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            item.title,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: AppDimensions.detailsAmenityLabelFontSize,
              color: AppColors.agroForest950,
            ),
          ),
          if (meta.isNotEmpty) ...[
            const SizedBox(height: AppDimensions.chatListContentGap),
            Text(
              meta,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: AppDimensions.detailsReviewCommentFontSize,
                color: AppColors.agroInk500,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _AmenitiesSection extends StatelessWidget {
  const _AmenitiesSection({required this.amenities});

  final List<Amenity> amenities;

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
          _sectionHeading(AppStrings.detailsAmenitiesHeading),
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
                    amenities[i].name,
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

  final PublicListing listing;

  @override
  Widget build(BuildContext context) {
    final address = [
      if (listing.location.isNotEmpty) listing.location,
      ?listing.regionName,
    ].join(', ');
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.dsBodyHorizontalPadding,
        vertical: AppDimensions.detailsSectionVerticalPadding,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _sectionHeading(AppStrings.detailsLocationHeading),
          const SizedBox(height: AppDimensions.wizardAmenityRowGap),
          Container(
            width: double.infinity,
            height: AppDimensions.wizardMapHeight,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.agroGreen100,
              borderRadius: BorderRadius.circular(AppDimensions.dsRadiusMd),
            ),
            // TODO: a real map once a map integration is chosen (the
            // backend already sends each listing's coordinates).
            child: const Text(
              AppStrings.wizardMapPinGlyph,
              style: TextStyle(fontSize: AppDimensions.wizardMapPinFontSize),
            ),
          ),
          const SizedBox(height: AppDimensions.wizardAmenityRowGap),
          Text(
            address,
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

  final PublicListing listing;
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
          _sectionHeading(listingRatingLine(listing)),
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
        // The written review is optional — skip the line for a
        // rating-only review.
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

  final PublicListing listing;

  // The booking form books nights, so only listings with an accommodation
  // item can be booked for now. Others keep the button visible but inert
  // until booking moves to the backend (`/api/bookings/itemized`).
  bool get _bookable => listing.bookableItem != null;

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
                  listingPriceLabel(listing),
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: AppDimensions.detailsFooterPriceFontSize,
                    color: AppColors.agroForest950,
                  ),
                ),
                const SizedBox(height: AppDimensions.chatListContentGap),
                Text(
                  listingRatingLine(listing),
                  style: const TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: AppDimensions.detailsFooterMetaFontSize,
                    color: AppColors.agroInk500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppDimensions.wizardChipGap),
          GestureDetector(
            onTap: _bookable
                ? () => context.push(AppRoutes.booking(context, listing.slug))
                : null,
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
