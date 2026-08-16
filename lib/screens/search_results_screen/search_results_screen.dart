import 'package:flutter/material.dart';
import 'package:bulka_frontend/core/constants/app_colors.dart';
import 'package:bulka_frontend/core/constants/app_dimensions.dart';
import 'package:bulka_frontend/core/constants/app_strings.dart';
import 'package:bulka_frontend/core/utils/date_range_format.dart';
import 'package:bulka_frontend/core/utils/price_format.dart';
import 'package:bulka_frontend/models/create_listing_draft.dart';
import 'package:bulka_frontend/models/listing_search_filter.dart';
import 'package:bulka_frontend/models/provider_listing.dart';
import 'package:bulka_frontend/screens/listing_details_screen/listing_details_screen.dart';
import 'package:bulka_frontend/screens/tourist_home_screen/search_filters_sheet.dart';
import 'package:bulka_frontend/services/listing_review_controller.dart';
import 'package:bulka_frontend/services/search_controller.dart' as search;
import 'package:bulka_frontend/widgets/app_bottom_nav.dart';
import 'package:bulka_frontend/widgets/screen_header.dart';
import 'package:bulka_frontend/widgets/xfile_image.dart';

/// The Figma "22 – Buyer · Search Results" frame — reads exclusively from
/// `search.SearchController.instance` (the applied `ListingSearchFilter`
/// and its live `matchingListings`, itself always
/// `ProviderListingController.searchListings(filter)`), so this screen
/// never filters anything itself and never holds its own copy of the
/// result set. Reachable only after applying filters from
/// `TouristHomeScreen`'s search bar.
class SearchResultsScreen extends StatefulWidget {
  const SearchResultsScreen({super.key});

  @override
  State<SearchResultsScreen> createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen> {
  final search.SearchController _search = search.SearchController.instance;
  final ListingReviewController _reviewController =
      ListingReviewController.instance;

  @override
  void initState() {
    super.initState();
    _search.addListener(_handleChanged);
    _reviewController.addListener(_handleChanged);
  }

  @override
  void dispose() {
    _search.removeListener(_handleChanged);
    _reviewController.removeListener(_handleChanged);
    super.dispose();
  }

  void _handleChanged() => setState(() {});

  Future<void> _openFilters() async {
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
      builder: (_) => SearchFiltersSheet(initialFilter: _search.filter),
    );
    if (result != null) _search.applyFilter(result);
  }

  void _toggleCategory(String category) {
    final updated = _search.filter.copy();
    if (!updated.categories.remove(category)) {
      updated.categories.add(category);
    }
    _search.applyFilter(updated);
  }

  void _toggleQuickRating() {
    final updated = _search.filter.copy();
    updated.minRating = updated.minRating == 4.0 ? null : 4.0;
    _search.applyFilter(updated);
  }

  @override
  Widget build(BuildContext context) {
    final filter = _search.filter;
    final listings = _search.matchingListings;

    return Scaffold(
      backgroundColor: AppColors.beigeBackground,
      bottomNavigationBar: const TouristBottomNav(selectedIndex: 1),
      body: Column(
        children: [
          const ScreenHeader(
            title: AppStrings.resultsTitle,
            titleFontSize: AppDimensions.dsCompactHeaderTitleFontSize,
            bottomPadding: AppDimensions.dsCompactHeaderBottomPadding,
            contentGap: AppDimensions.dsCompactHeaderGap,
          ),
          Expanded(
            child: SafeArea(
              top: false,
              bottom: false,
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(
                  bottom: AppDimensions.profileBodyBottomPadding,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _TopBar(filter: filter, onFilterTap: _openFilters),
                    _QuickFiltersRow(
                      filter: filter,
                      onFiltersTap: _openFilters,
                      onToggleCategory: _toggleCategory,
                      onToggleRating: _toggleQuickRating,
                      onPriceTap: _openFilters,
                    ),
                    _ResultsHeader(
                      count: listings.length,
                      location: filter.location,
                    ),
                    _ListingsSection(listings: listings),
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

class _TopBar extends StatelessWidget {
  const _TopBar({required this.filter, required this.onFilterTap});

  final ListingSearchFilter filter;
  final VoidCallback onFilterTap;

  String get _summary {
    final parts = <String>[
      if (filter.location != null) filter.location!,
      if (filter.startDate != null && filter.endDate != null)
        formatMkDateRangeShort(filter.startDate!, filter.endDate!),
      // A minimum threshold, not a real booking's exact guest count, so
      // "N+" rather than claiming an exact headcount like Figma's "N
      // гости" example (that's `Reservation.guestCount`, a different
      // concept — already used correctly on the Confirmation/My
      // Reservations screens).
      if (filter.minimumGuests != null)
        '${filter.minimumGuests}+ ${AppStrings.reservationGuestsPlural}',
    ];
    return parts.isEmpty ? AppStrings.homeSearchPlaceholder : parts.join(' · ');
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: AppDimensions.dsBodyHorizontalPadding,
        right: AppDimensions.dsBodyHorizontalPadding,
        top: AppDimensions.resultsTopBarTopPadding,
        bottom: AppDimensions.resultsTopBarBottomPadding,
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.homeSearchHorizontalPadding,
                vertical: AppDimensions.homeSearchVerticalPadding,
              ),
              decoration: BoxDecoration(
                color: AppColors.profileStatCardBackground,
                border: Border.all(color: AppColors.profileStatCardBorder),
                borderRadius: BorderRadius.circular(
                  AppDimensions.pillBorderRadius,
                ),
              ),
              child: Row(
                children: [
                  const Text(
                    AppStrings.homeSearchIconGlyph,
                    style: TextStyle(
                      fontSize: AppDimensions.homeSearchIconFontSize,
                    ),
                  ),
                  const SizedBox(width: AppDimensions.homeSearchGap),
                  Expanded(
                    child: Text(
                      _summary,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: AppDimensions.homeSearchFontSize,
                        color: AppColors.agroForest950,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: AppDimensions.resultsTopBarGap),
          GestureDetector(
            onTap: onFilterTap,
            child: Container(
              width: AppDimensions.resultsFilterIconButtonSize,
              height: AppDimensions.resultsFilterIconButtonSize,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.agroCream100,
                border: Border.all(color: AppColors.agroBorder300),
                borderRadius: BorderRadius.circular(AppDimensions.dsRadiusMd),
              ),
              child: const Text(
                AppStrings.filterIconGlyph,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: AppDimensions.resultsFilterIconGlyphFontSize,
                  color: AppColors.agroForest950,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The Figma frame's exact curated quick-filter set — "Филтри" (reopens
/// the full sheet) + 2 specific categories + a fixed "Оценка 4+" rating
/// toggle + "Цена" (also reopens the full sheet, preserving whatever's
/// already applied, so the price `RangeSlider` can be adjusted) — not all
/// 7 canonical categories abbreviated, and not a second taxonomy: the 2
/// category chips use the same `AppStrings.providerCategory*` values as
/// everywhere else.
class _QuickFiltersRow extends StatelessWidget {
  const _QuickFiltersRow({
    required this.filter,
    required this.onFiltersTap,
    required this.onToggleCategory,
    required this.onToggleRating,
    required this.onPriceTap,
  });

  final ListingSearchFilter filter;
  final VoidCallback onFiltersTap;
  final ValueChanged<String> onToggleCategory;
  final VoidCallback onToggleRating;
  final VoidCallback onPriceTap;

  static const List<String> _quickCategories = [
    AppStrings.providerCategoryAccommodation,
    AppStrings.providerCategoryGastronomy,
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: AppDimensions.resultsQuickFiltersBottomPadding,
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.dsBodyHorizontalPadding,
        ),
        child: Row(
          children: [
            GestureDetector(
              onTap: onFiltersTap,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.wizardChipHorizontalPadding,
                  vertical: AppDimensions.wizardChipVerticalPadding,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.agroBorder300),
                  borderRadius: BorderRadius.circular(
                    AppDimensions.pillBorderRadius,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      AppStrings.resultsFiltersChipGlyph,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: AppDimensions.resultsFiltersChipGlyphFontSize,
                        color: AppColors.agroForest950,
                      ),
                    ),
                    const SizedBox(width: AppDimensions.resultsFiltersChipGap),
                    const Text(
                      AppStrings.resultsFiltersChipLabel,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: AppDimensions.wizardChipFontSize,
                        color: AppColors.agroForest950,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: AppDimensions.wizardChipGap),
            for (var i = 0; i < _quickCategories.length; i++) ...[
              _QuickChip(
                label: _quickCategories[i],
                isSelected: filter.categories.contains(_quickCategories[i]),
                onTap: () => onToggleCategory(_quickCategories[i]),
              ),
              const SizedBox(width: AppDimensions.wizardChipGap),
            ],
            _QuickChip(
              label: AppStrings.resultsRatingChipLabel,
              isSelected: filter.minRating == 4.0,
              onTap: onToggleRating,
            ),
            const SizedBox(width: AppDimensions.wizardChipGap),
            _QuickChip(
              label: AppStrings.resultsPriceChipLabel,
              isSelected: false,
              onTap: onPriceTap,
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickChip extends StatelessWidget {
  const _QuickChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.wizardChipHorizontalPadding,
          vertical: AppDimensions.wizardChipVerticalPadding,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.agroForest950 : AppColors.white,
          border: isSelected
              ? null
              : Border.all(color: AppColors.agroBorder300),
          borderRadius: BorderRadius.circular(AppDimensions.pillBorderRadius),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
            fontSize: AppDimensions.wizardChipFontSize,
            color: isSelected ? AppColors.white : AppColors.agroInk500,
          ),
        ),
      ),
    );
  }
}

class _ResultsHeader extends StatelessWidget {
  const _ResultsHeader({required this.count, required this.location});

  final int count;
  final String? location;

  String get _countLabel {
    final base = '$count ${AppStrings.resultsCountSuffix}';
    if (location == null) return base;
    return '$base ${AppStrings.resultsCountLocationPrefix} $location';
  }

  @override
  Widget build(BuildContext context) {
    // Figma absolute-positions the Map Button overlapping this text block
    // (a design-tool export artifact, not meaningful layout) — a plain
    // Row achieves the same visual result without relying on that.
    return Padding(
      padding: const EdgeInsets.only(
        left: AppDimensions.dsBodyHorizontalPadding,
        right: AppDimensions.dsBodyHorizontalPadding,
        top: AppDimensions.resultsHeaderTopPadding,
        bottom: AppDimensions.resultsHeaderBottomPadding,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _countLabel,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: AppDimensions.homeSectionHeadingFontSize,
                  color: AppColors.agroForest950,
                ),
              ),
              const SizedBox(height: AppDimensions.resultsHeaderTextGap),
              const Text(
                AppStrings.resultsSortLabel,
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: AppDimensions.resultsSortLabelFontSize,
                  color: AppColors.profileSecondaryText,
                ),
              ),
            ],
          ),
          const _MapButton(),
        ],
      ),
    );
  }
}

class _ListingsSection extends StatelessWidget {
  const _ListingsSection({required this.listings});

  final List<ProviderListing> listings;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.dsBodyHorizontalPadding,
        vertical: AppDimensions.resultsListingsSectionVerticalPadding,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < listings.length; i++) ...[
            _ResultListingCard(listing: listings[i]),
            if (i != listings.length - 1)
              const SizedBox(height: AppDimensions.resultsCardGap),
          ],
        ],
      ),
    );
  }
}

class _MapButton extends StatelessWidget {
  const _MapButton();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // TODO: push MapViewScreen once the map architecture is approved —
      // it will read the exact same `search.SearchController.instance`
      // state (filter + matchingListings), no second search triggered.
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.resultsMapButtonHorizontalPadding,
          vertical: AppDimensions.resultsMapButtonVerticalPadding,
        ),
        decoration: BoxDecoration(
          color: AppColors.agroForest950,
          borderRadius: BorderRadius.circular(AppDimensions.pillBorderRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              AppStrings.resultsMapButtonGlyph,
              style: TextStyle(
                fontSize: AppDimensions.resultsMapButtonFontSize,
              ),
            ),
            const SizedBox(width: AppDimensions.wizardChipGap),
            const Text(
              AppStrings.resultsMapButtonLabel,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: AppDimensions.resultsMapButtonFontSize,
                color: AppColors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Renders straight from a `ProviderListing` — same reuse convention as
/// Home's `_ListingCard`, but this frame's own card composition (price as
/// a top-right pill, a reservations+rating meta line, a full-width
/// details button) is different enough that sharing one widget between
/// the two screens would mean branching its whole layout on a flag, so
/// this is a separate widget instead.
class _ResultListingCard extends StatelessWidget {
  const _ResultListingCard({required this.listing});

  final ProviderListing listing;

  String get _priceLabel {
    final suffix = categoryRequiresPrice(listing.category)
        ? AppStrings.resultsPricePerNightSuffix
        : AppStrings.wizardPriceSuffix;
    return '${formatMkPrice(listing.price)} $suffix';
  }

  String get _metaLine {
    final reservations =
        '${listing.reservationCount} ${AppStrings.resultsReservationsSuffix}';
    final rating = ListingReviewController.instance.effectiveRating(listing);
    if (rating == null) return reservations;
    return '$reservations · ${rating.toStringAsFixed(1)} ★';
  }

  void _openDetails(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            ListingDetailsScreen(listing: listing, originTabIndex: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _openDetails(context),
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
                    height: AppDimensions.offersCardImageHeight,
                    color: AppColors.profileSoftMint,
                  )
                : XFileImage(
                    path: listing.photoPaths.first,
                    width: double.infinity,
                    height: AppDimensions.offersCardImageHeight,
                    fit: BoxFit.cover,
                  ),
            Padding(
              padding: const EdgeInsets.all(
                AppDimensions.offersCardInfoPadding,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          listing.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: AppDimensions.offersCardTitleFontSize,
                            color: AppColors.agroForest950,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal:
                              AppDimensions.profileRoleBadgeHorizontalPadding,
                          vertical:
                              AppDimensions.profileRoleBadgeVerticalPadding,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.profileSoftMint,
                          borderRadius: BorderRadius.circular(
                            AppDimensions.pillBorderRadius,
                          ),
                        ),
                        child: Text(
                          _priceLabel,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: AppDimensions.profileRoleBadgeFontSize,
                            color: AppColors.agroInk500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.offersCardInfoGap),
                  Text(
                    listing.location,
                    style: const TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: AppDimensions.offersCardMetaFontSize,
                      color: AppColors.profileSecondaryText,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.offersCardInfoGap),
                  Text(
                    _metaLine,
                    style: const TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: AppDimensions.offersCardMetaFontSize,
                      color: AppColors.profileSecondaryText,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.offersCardInfoGap),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      vertical:
                          AppDimensions.dashboardActionButtonVerticalPadding,
                    ),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      border: Border.all(color: AppColors.agroBorder300),
                      borderRadius: BorderRadius.circular(
                        AppDimensions.dashboardActionButtonRadius,
                      ),
                    ),
                    child: const Text(
                      AppStrings.resultsShowDetailsButton,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: AppDimensions.dashboardActionButtonFontSize,
                        color: AppColors.agroInk500,
                      ),
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
