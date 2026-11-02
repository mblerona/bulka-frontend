import 'package:flutter/material.dart';
import 'package:bulka_frontend/blocs/categories/categories_bloc.dart';
import 'package:bulka_frontend/blocs/locale/locale_bloc.dart';
import 'package:bulka_frontend/blocs/public_listings/public_listings_bloc.dart';
import 'package:bulka_frontend/blocs/regions/regions_bloc.dart';
import 'package:bulka_frontend/blocs/search/search_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bulka_frontend/core/routing/app_routes.dart';
import 'package:go_router/go_router.dart';
import 'package:bulka_frontend/core/constants/app_colors.dart';
import 'package:bulka_frontend/core/constants/app_dimensions.dart';
import 'package:bulka_frontend/core/constants/app_strings.dart';
import 'package:bulka_frontend/core/utils/date_range_format.dart';
import 'package:bulka_frontend/core/utils/listing_format.dart';
import 'package:bulka_frontend/models/listing_search_filter.dart';
import 'package:bulka_frontend/models/public_listing.dart';
import 'package:bulka_frontend/screens/tourist_home_screen/search_filters_sheet.dart';
import 'package:bulka_frontend/widgets/listing_image.dart';
import 'package:bulka_frontend/widgets/load_failed_message.dart';
import 'package:bulka_frontend/widgets/screen_header.dart';

/// The Figma "22 – Buyer · Search Results" frame — shows the filter in
/// `SearchBloc` and the listings the backend returns for it
/// (`PublicListingsBloc`). Whenever the filter or the language changes, it
/// asks for a new search.
class SearchResultsScreen extends StatefulWidget {
  const SearchResultsScreen({super.key});

  @override
  State<SearchResultsScreen> createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen> {
  ListingSearchFilter get _filter => context.read<SearchBloc>().state.filter;

  @override
  void initState() {
    super.initState();
    _search();
  }

  /// Searches the current filter unless its results are already on hand.
  void _search() {
    final language = context.read<LocaleBloc>().state.locale.languageCode;
    final listings = context.read<PublicListingsBloc>();
    if (listings.state.needsResultsFor(searchKey(_filter, language))) {
      listings.add(ListingSearchRequested(_filter, language));
    }
    // The quick-filter chips and the location name need these.
    final categories = context.read<CategoriesBloc>();
    if (categories.state.needsLoadFor(language)) {
      categories.add(CategoriesRequested(language));
    }
    final regions = context.read<RegionsBloc>();
    if (_filter.regionId != null && regions.state.needsLoadFor(language)) {
      regions.add(RegionsRequested(language));
    }
  }

  void _applyFilter(ListingSearchFilter filter) =>
      context.read<SearchBloc>().add(SearchFilterApplied(filter));

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
      builder: (_) => SearchFiltersSheet(initialFilter: _filter),
    );
    if (result != null && mounted) _applyFilter(result);
  }

  void _toggleCategory(String categoryId) {
    final updated = _filter.copy();
    updated.categoryId = updated.categoryId == categoryId ? null : categoryId;
    _applyFilter(updated);
  }

  void _toggleQuickRating() {
    final updated = _filter.copy();
    updated.minRating = updated.minRating == 4.0 ? null : 4.0;
    _applyFilter(updated);
  }

  @override
  Widget build(BuildContext context) {
    final filter = context.watch<SearchBloc>().state.filter;
    final results = context.watch<PublicListingsBloc>().state;
    final regionName = context.select(
      (RegionsBloc bloc) => bloc.state.byId(filter.regionId)?.name,
    );

    return MultiBlocListener(
      listeners: [
        BlocListener<SearchBloc, SearchState>(listener: (_, _) => _search()),
        BlocListener<LocaleBloc, LocaleState>(
          listenWhen: (previous, current) => previous.locale != current.locale,
          listener: (_, _) => _search(),
        ),
      ],
      child: Scaffold(
        backgroundColor: AppColors.beigeBackground,
        body: Column(
          children: [
            ScreenHeader(
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
                      _TopBar(
                        filter: filter,
                        regionName: regionName,
                        onFilterTap: _openFilters,
                      ),
                      _QuickFiltersRow(
                        filter: filter,
                        onFiltersTap: _openFilters,
                        onToggleCategory: _toggleCategory,
                        onToggleRating: _toggleQuickRating,
                        onPriceTap: _openFilters,
                      ),
                      _ResultsHeader(
                        count:
                            results.resultsStatus == ListingsLoadStatus.loaded
                            ? results.resultsTotal
                            : null,
                        location: regionName,
                      ),
                      _ListingsSection(
                        state: results,
                        onRetry: () => context.read<PublicListingsBloc>().add(
                          ListingSearchRequested(
                            filter,
                            context
                                .read<LocaleBloc>()
                                .state
                                .locale
                                .languageCode,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.filter,
    required this.regionName,
    required this.onFilterTap,
  });

  final ListingSearchFilter filter;
  final String? regionName;
  final VoidCallback onFilterTap;

  String get _summary {
    final keyword = filter.keyword.trim();
    final parts = <String>[
      if (keyword.isNotEmpty) keyword,
      ?regionName,
      if (filter.startDate != null && filter.endDate != null)
        formatDateRangeShort(filter.startDate!, filter.endDate!),
      // A minimum threshold, not a real booking's exact guest count, so
      // "N+".
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
            child: GestureDetector(
              onTap: onFilterTap,
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

/// The Figma frame's quick-filter set — "Филтри" (reopens the full
/// sheet) + the first 2 categories + a fixed "Оценка 4+" rating toggle +
/// "Цена" (also reopens the full sheet, so the price slider can be
/// adjusted).
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

  @override
  Widget build(BuildContext context) {
    final quickCategories = context
        .watch<CategoriesBloc>()
        .state
        .topLevel
        .take(2)
        .toList();
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
                    Text(
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
            for (final category in quickCategories) ...[
              _QuickChip(
                label: category.name,
                isSelected: filter.categoryId == category.id,
                onTap: () => onToggleCategory(category.id),
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
              isSelected: filter.minPrice != null || filter.maxPrice != null,
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

  /// Null while the search is loading (or failed).
  final int? count;
  final String? location;

  String get _countLabel {
    final base = '${count ?? '…'} ${AppStrings.resultsCountSuffix}';
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
          Expanded(
            child: Column(
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
                Text(
                  AppStrings.resultsSortLabel,
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: AppDimensions.resultsSortLabelFontSize,
                    color: AppColors.profileSecondaryText,
                  ),
                ),
              ],
            ),
          ),
          const _MapButton(),
        ],
      ),
    );
  }
}

class _ListingsSection extends StatelessWidget {
  const _ListingsSection({required this.state, required this.onRetry});

  final PublicListingsState state;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final listings = state.results;
    final Widget content;
    if (state.resultsStatus == ListingsLoadStatus.failed) {
      content = LoadFailedMessage(
        message: AppStrings.listingsLoadFailed,
        onRetry: onRetry,
      );
    } else if (state.resultsStatus != ListingsLoadStatus.loaded) {
      content = const SectionLoadingIndicator();
    } else if (listings.isEmpty) {
      content = Text(
        AppStrings.resultsEmpty,
        style: const TextStyle(
          fontSize: AppDimensions.offersCardMetaFontSize,
          color: AppColors.profileSecondaryText,
        ),
      );
    } else {
      content = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < listings.length; i++) ...[
            _ResultListingCard(listing: listings[i]),
            if (i != listings.length - 1)
              const SizedBox(height: AppDimensions.resultsCardGap),
          ],
          if (state.resultsHasMore) ...[
            const SizedBox(height: AppDimensions.resultsCardGap),
            Center(
              child: state.loadingMoreResults
                  ? const SectionLoadingIndicator()
                  : TextButton(
                      onPressed: () => context.read<PublicListingsBloc>().add(
                        const MoreSearchResultsRequested(),
                      ),
                      child: Text(
                        AppStrings.resultsLoadMore,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: AppDimensions.dashboardActionButtonFontSize,
                          color: AppColors.agroGreen600,
                        ),
                      ),
                    ),
            ),
          ],
        ],
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.dsBodyHorizontalPadding,
        vertical: AppDimensions.resultsListingsSectionVerticalPadding,
      ),
      child: content,
    );
  }
}

class _MapButton extends StatelessWidget {
  const _MapButton();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // TODO: push MapViewScreen once the map architecture is approved —
      // the backend has `/api/listings/map-clusters` for it.
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
            Text(
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

/// One search result. Same reuse convention as Home's `_ListingCard`, but
/// this frame's own card composition (price as a top-right pill, a
/// rating line, a full-width details button) is different enough to be a
/// separate widget.
class _ResultListingCard extends StatelessWidget {
  const _ResultListingCard({required this.listing});

  final PublicListing listing;

  void _openDetails(BuildContext context) {
    context.push(AppRoutes.listing(context, listing.slug));
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
            ListingImage(
              url: listing.coverImageUrl,
              height: AppDimensions.offersCardImageHeight,
            ),
            Padding(
              padding: const EdgeInsets.all(
                AppDimensions.offersCardInfoPadding,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    listing.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: AppDimensions.offersCardTitleFontSize,
                      color: AppColors.agroForest950,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.offersCardInfoGap),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal:
                          AppDimensions.profileRoleBadgeHorizontalPadding,
                      vertical: AppDimensions.profileRoleBadgeVerticalPadding,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.profileSoftMint,
                      borderRadius: BorderRadius.circular(
                        AppDimensions.pillBorderRadius,
                      ),
                    ),
                    child: Text(
                      listingPriceLabel(listing),
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: AppDimensions.profileRoleBadgeFontSize,
                        color: AppColors.agroInk500,
                      ),
                    ),
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
                    listingRatingLine(listing),
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
                    child: Text(
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
