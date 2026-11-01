import 'package:flutter/material.dart';
import 'package:bulka_frontend/blocs/auth/auth_bloc.dart';
import 'package:bulka_frontend/blocs/categories/categories_bloc.dart';
import 'package:bulka_frontend/blocs/locale/locale_bloc.dart';
import 'package:bulka_frontend/blocs/search/search_bloc.dart';
import 'package:bulka_frontend/blocs/listings/listings_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
import 'package:bulka_frontend/widgets/xfile_image.dart';

/// Buyer/Tourist "Дома" — the Figma "20 – Buyer · Discover Home" frame.
/// Listings come straight from `ListingsState.active`
/// (active listings only) — no separate Tourist-side listing collection.
/// The search bar opens the filter sheet (→ Search Results) and each
/// listing card opens Listing Details; category-chip taps remain a clean
/// TODO callback pending a category search/results destination.
class TouristHomeScreen extends StatefulWidget {
  const TouristHomeScreen({super.key, this.profile});

  /// Null shows the signed-in user (or the sample guest when nobody is
  /// signed in, e.g. from the dev launcher).
  final RegistrationProfile? profile;

  static const RegistrationProfile _sampleProfile = RegistrationProfile(
    fullName: 'Јована Јованова',
    email: 'jovana@example.com',
    phone: '070 123 456',
  );

  @override
  State<TouristHomeScreen> createState() => _TouristHomeScreenState();
}

class _TouristHomeScreenState extends State<TouristHomeScreen> {
  @override
  void initState() {
    super.initState();
    _loadCategories(context);
  }

  Future<void> _openFilters() async {
    final search = context.read<SearchBloc>();
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
      builder: (_) => SearchFiltersSheet(initialFilter: search.state.filter),
    );
    if (result == null || !mounted) return;
    search.add(SearchFilterApplied(result));
    context.go(AppRoutes.search);
  }

  String _firstNameOf(RegistrationProfile profile) {
    final trimmed = profile.fullName.trim();
    if (trimmed.isEmpty) return '';
    return trimmed.split(RegExp(r'\s+')).first;
  }

  @override
  Widget build(BuildContext context) {
    final listings = context.watch<ListingsBloc>().state.active;
    final user = context.select((AuthBloc bloc) => bloc.state.user);
    final profile =
        widget.profile ??
        (user != null
            ? RegistrationProfile.fromAuthUser(user)
            : TouristHomeScreen._sampleProfile);

    // Category names come translated from the backend, so reload them in
    // the new language.
    return BlocListener<LocaleBloc, LocaleState>(
      listenWhen: (previous, current) => previous.locale != current.locale,
      listener: (context, _) => _loadCategories(context),
      child: _buildScreen(profile, listings),
    );
  }

  Widget _buildScreen(
    RegistrationProfile profile,
    List<ProviderListing> listings,
  ) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Column(
        children: [
          _HomeHeader(greetingName: _firstNameOf(profile)),
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

/// Loads the categories in the current language unless they're already
/// loaded (or loading) in it.
void _loadCategories(BuildContext context) {
  final language = context.read<LocaleBloc>().state.locale.languageCode;
  final categories = context.read<CategoriesBloc>();
  if (categories.state.needsLoadFor(language)) {
    categories.add(CategoriesRequested(language));
  }
}

/// The top-level categories from `GET /api/categories` (see
/// [CategoriesBloc]). No search-results screen exists yet, so tapping a
/// chip is a clean TODO for now.
class _CategoryRow extends StatelessWidget {
  const _CategoryRow();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<CategoriesBloc>().state;
    final categories = state.topLevel;

    if (categories.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.dsBodyHorizontalPadding,
          vertical: AppDimensions.homeCategoryCardVerticalPadding,
        ),
        child: state.status == CategoriesStatus.failed
            ? _CategoriesLoadFailed(onRetry: () => _loadCategories(context))
            : const Center(
                child: SizedBox.square(
                  dimension: AppDimensions.homeCategoryIconAreaHeight,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.agroGreen600,
                  ),
                ),
              ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.only(
        left: AppDimensions.dsBodyHorizontalPadding,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < categories.length; i++) ...[
            _CategoryCard(category: categories[i]),
            if (i != categories.length - 1)
              const SizedBox(width: AppDimensions.homeCategoryRowGap),
          ],
        ],
      ),
    );
  }
}

class _CategoriesLoadFailed extends StatelessWidget {
  const _CategoriesLoadFailed({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            AppStrings.homeCategoriesLoadFailed,
            style: const TextStyle(
              fontSize: AppDimensions.homeCategoryLabelFontSize,
              color: AppColors.profileSecondaryText,
            ),
          ),
        ),
        TextButton(
          onPressed: onRetry,
          child: Text(
            AppStrings.homeCategoriesRetry,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: AppDimensions.homeCategoryLabelFontSize,
              color: AppColors.agroGreen600,
            ),
          ),
        ),
      ],
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
