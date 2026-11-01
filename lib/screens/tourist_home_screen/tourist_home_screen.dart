import 'package:flutter/material.dart';
import 'package:bulka_frontend/core/routing/app_routes.dart';
import 'package:go_router/go_router.dart';
import 'package:bulka_frontend/core/constants/app_colors.dart';
import 'package:bulka_frontend/core/constants/app_dimensions.dart';
import 'package:bulka_frontend/core/constants/app_strings.dart';
import 'package:bulka_frontend/core/utils/price_format.dart';
import 'package:bulka_frontend/models/create_listing_draft.dart';
import 'package:bulka_frontend/models/home_category.dart';
import 'package:bulka_frontend/models/listing_search_filter.dart';
import 'package:bulka_frontend/models/promo_banner.dart';
import 'package:bulka_frontend/models/provider_listing.dart';
import 'package:bulka_frontend/models/registration_profile.dart';
import 'package:bulka_frontend/screens/tourist_home_screen/search_filters_sheet.dart';
import 'package:bulka_frontend/services/provider_listing_controller.dart';
import 'package:bulka_frontend/services/search_controller.dart' as search;
import 'package:bulka_frontend/widgets/xfile_image.dart';

/// Buyer/Tourist "Дома" — the Figma "20 – Buyer · Discover Home" frame.
/// Listings come straight from `ProviderListingController.recommendedListings`
/// (active listings only) — no separate Tourist-side listing collection.
/// The search bar opens the filter sheet (→ Search Results) and each
/// listing card opens Listing Details; category-chip taps remain a clean
/// TODO callback pending a category search/results destination.
class TouristHomeScreen extends StatefulWidget {
  const TouristHomeScreen({
    super.key,
    this.profile = const RegistrationProfile(
      fullName: 'Јована Јованова',
      email: 'jovana@example.com',
      phone: '070 123 456',
    ),
  });

  final RegistrationProfile profile;

  @override
  State<TouristHomeScreen> createState() => _TouristHomeScreenState();
}

class _TouristHomeScreenState extends State<TouristHomeScreen> {
  final ProviderListingController _listingController =
      ProviderListingController.instance;

  @override
  void initState() {
    super.initState();
    _listingController.addListener(_handleChanged);
  }

  @override
  void dispose() {
    _listingController.removeListener(_handleChanged);
    super.dispose();
  }

  void _handleChanged() => setState(() {});

  Future<void> _openFilters() async {
    final current = search.SearchController.instance;
    final result = await showModalBottomSheet<ListingSearchFilter>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimensions.filtersSheetRadius),
        ),
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.92,
      ),
      builder: (_) => SearchFiltersSheet(initialFilter: current.filter),
    );
    if (result == null || !mounted) return;
    current.applyFilter(result);
    context.go(AppRoutes.search);
  }

  String get _firstName {
    final trimmed = widget.profile.fullName.trim();
    if (trimmed.isEmpty) return '';
    return trimmed.split(RegExp(r'\s+')).first;
  }

  @override
  Widget build(BuildContext context) {
    final listings = _listingController.recommendedListings;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: Column(
        children: [
          _HomeHeader(greetingName: _firstName),
          Expanded(
            child: SafeArea(
              top: false,
              bottom: false,
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(
                  top: AppDimensions.dsRootBodyTopPadding,
                  bottom: AppDimensions.profileBodyBottomPadding,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.dsBodyHorizontalPadding,
                      ),
                      child: _SearchBar(onTap: _openFilters),
                    ),
                    const SizedBox(height: AppDimensions.homeBodyGap),
                    const _BannerRow(),
                    const SizedBox(height: AppDimensions.homeBodyGap),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.dsBodyHorizontalPadding,
                      ),
                      child: _sectionHeading(AppStrings.homeCategoriesHeading),
                    ),
                    const SizedBox(height: AppDimensions.dashboardSectionGap),
                    const _CategoryRow(),
                    const SizedBox(height: AppDimensions.homeBodyGap),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.dsBodyHorizontalPadding,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _sectionHeading(AppStrings.homeRecommendedHeading),
                          const SizedBox(
                            height: AppDimensions.dashboardSectionGap,
                          ),
                          for (var i = 0; i < listings.length; i++) ...[
                            _ListingCard(listing: listings[i]),
                            if (i != listings.length - 1)
                              const SizedBox(
                                height: AppDimensions.homeListingCardGap,
                              ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Widget _sectionHeading(String label) {
  return Text(
    label,
    style: const TextStyle(
      fontWeight: FontWeight.w700,
      fontSize: AppDimensions.homeSectionHeadingFontSize,
      color: AppColors.agroForest950,
    ),
  );
}

/// Dark green Header Band — logo + greeting + subtitle, no back button
/// (unlike `ScreenHeader`, which always renders one; this frame's Figma
/// header has none, so a dedicated header is used here instead of forcing
/// `ScreenHeader` to fit).
class _HomeHeader extends StatelessWidget {
  const _HomeHeader({required this.greetingName});

  final String greetingName;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(
        left: AppDimensions.dsHeaderHorizontalPadding,
        right: AppDimensions.dsHeaderHorizontalPadding,
        top: AppDimensions.dsHeaderTopPadding,
        bottom: AppDimensions.dsCompactHeaderBottomPadding,
      ),
      decoration: const BoxDecoration(
        color: AppColors.agroForest950,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(AppDimensions.dsRadiusSm),
          bottomRight: Radius.circular(AppDimensions.dsRadiusSm),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(
                width: AppDimensions.dsHeaderLogoSize,
                height: AppDimensions.dsHeaderLogoSize,
                child: Stack(
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        color: AppColors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                    Positioned(
                      left: AppDimensions.dsHeaderLogoMarkOffset,
                      top: AppDimensions.dsHeaderLogoMarkOffset,
                      width: AppDimensions.dsHeaderLogoMarkSize,
                      height: AppDimensions.dsHeaderLogoMarkSize,
                      child: Image.asset(
                        'assets/images/SplashScreen/logo.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppDimensions.dsHeaderTitleRowGap),
              Expanded(
                child: Text(
                  '${AppStrings.homeGreetingPrefix}$greetingName '
                  '${AppStrings.homeGreetingEmoji}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: AppDimensions.homeHeaderGreetingFontSize,
                    color: AppColors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.dsRootHeaderGap),
          Text(
            AppStrings.homeSubtitle,
            style: TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: AppDimensions.dsSubheadingFontSize,
              color: AppColors.languageLabelText,
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.homeSearchHorizontalPadding,
          vertical: AppDimensions.homeSearchVerticalPadding,
        ),
        decoration: BoxDecoration(
          color: AppColors.profileStatCardBackground,
          border: Border.all(color: AppColors.profileStatCardBorder),
          borderRadius: BorderRadius.circular(AppDimensions.pillBorderRadius),
        ),
        child: Row(
          children: [
            const Text(
              AppStrings.homeSearchIconGlyph,
              style: TextStyle(fontSize: AppDimensions.homeSearchIconFontSize),
            ),
            const SizedBox(width: AppDimensions.homeSearchGap),
            Expanded(
              child: Text(
                AppStrings.homeSearchPlaceholder,
                style: const TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: AppDimensions.homeSearchFontSize,
                  color: AppColors.profileSecondaryText,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Horizontally scrolling promo banners — a real `ListView.builder` over
/// `mockPromoBanners`, so any number of banners works, not two hardcoded
/// side-by-side cards.
class _BannerRow extends StatelessWidget {
  const _BannerRow();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppDimensions.homeBannerHeight,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(
          left: AppDimensions.dsBodyHorizontalPadding,
        ),
        itemCount: mockPromoBanners.length,
        itemBuilder: (context, index) {
          final banner = mockPromoBanners[index];
          final isLast = index == mockPromoBanners.length - 1;
          return Padding(
            padding: EdgeInsets.only(
              right: isLast ? 0 : AppDimensions.homeBannerGap,
            ),
            child: _BannerCard(banner: banner),
          );
        },
      ),
    );
  }
}

class _BannerCard extends StatelessWidget {
  const _BannerCard({required this.banner});

  final PromoBanner banner;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppDimensions.homeBannerWidth,
      padding: const EdgeInsets.all(AppDimensions.homeBannerPadding),
      decoration: BoxDecoration(
        color: banner.backgroundColor,
        borderRadius: BorderRadius.circular(AppDimensions.homeBannerRadius),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: AppDimensions.homeBannerTitleMaxWidth,
            child: Text(
              banner.title,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: AppDimensions.homeBannerTitleFontSize,
                color: AppColors.white,
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.homeBannerContentGap),
          Text(
            banner.actionLabel,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: AppDimensions.homeBannerActionFontSize,
              color: AppColors.white,
            ),
          ),
        ],
      ),
    );
  }
}

/// Data-driven from `touristHomeCategories` — same domain category values
/// `ProviderListing.category`/the Create Offer wizard use, not a second
/// taxonomy. No search-results screen exists yet, so tapping a chip is a
/// clean TODO for now.
class _CategoryRow extends StatelessWidget {
  const _CategoryRow();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.only(
        left: AppDimensions.dsBodyHorizontalPadding,
      ),
      child: Row(
        children: [
          for (var i = 0; i < touristHomeCategories.length; i++) ...[
            _CategoryCard(category: touristHomeCategories[i]),
            if (i != touristHomeCategories.length - 1)
              const SizedBox(width: AppDimensions.homeCategoryRowGap),
          ],
        ],
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({required this.category});

  final HomeCategory category;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // TODO: navigate to category search/results once that screen exists.
      onTap: () {},
      child: Container(
        width: AppDimensions.homeCategoryCardWidth,
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.homeCategoryCardHorizontalPadding,
          vertical: AppDimensions.homeCategoryCardVerticalPadding,
        ),
        decoration: BoxDecoration(
          color: AppColors.profileStatCardBackground,
          border: Border.all(color: AppColors.profileStatCardBorder),
          borderRadius: BorderRadius.circular(AppDimensions.dsRadiusMd),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: AppDimensions.homeCategoryIconAreaHeight,
              child: Center(
                child: Text(
                  category.emoji,
                  style: const TextStyle(
                    fontSize: AppDimensions.homeCategoryEmojiFontSize,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.homeCategoryCardGap),
            Text(
              category.label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: AppDimensions.homeCategoryLabelFontSize,
                color: AppColors.agroForest950,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Renders straight from a `ProviderListing` — title/location/price all
/// come from the listing object, never hardcoded here. Uses the listing's
/// first real photo when one exists, otherwise the Figma placeholder
/// fill (same convention as the Provider Offers screen's listing cards).
class _ListingCard extends StatelessWidget {
  const _ListingCard({required this.listing});

  final ProviderListing listing;

  String get _priceLabel {
    final suffix = categoryRequiresPrice(listing.category)
        ? AppStrings.wizardPricePerNightSuffix
        : AppStrings.wizardPriceSuffix;
    return '${AppStrings.homePricePrefix}'
        '${formatPrice(listing.price)} $suffix';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(AppRoutes.listing(context, listing.id)),
      child: Container(
        width: double.infinity,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: AppColors.profileStatCardBackground,
          border: Border.all(color: AppColors.profileStatCardBorder),
          borderRadius: BorderRadius.circular(AppDimensions.dsRadiusMd),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            listing.photoPaths.isEmpty
                ? Container(
                    width: double.infinity,
                    height: AppDimensions.homeListingCardImageHeight,
                    color: AppColors.profileSoftMint,
                  )
                : XFileImage(
                    path: listing.photoPaths.first,
                    width: double.infinity,
                    height: AppDimensions.homeListingCardImageHeight,
                    fit: BoxFit.cover,
                  ),
            Padding(
              padding: const EdgeInsets.all(
                AppDimensions.homeListingCardPadding,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    listing.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: AppDimensions.homeListingTitleFontSize,
                      color: AppColors.agroForest950,
                    ),
                  ),
                  const SizedBox(
                    height: AppDimensions.homeListingCardContentGap,
                  ),
                  Text(
                    listing.location,
                    style: const TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: AppDimensions.homeListingLocationFontSize,
                      color: AppColors.profileSecondaryText,
                    ),
                  ),
                  const SizedBox(
                    height: AppDimensions.homeListingCardContentGap,
                  ),
                  Text(
                    _priceLabel,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: AppDimensions.homeListingPriceFontSize,
                      color: AppColors.agroInk500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
