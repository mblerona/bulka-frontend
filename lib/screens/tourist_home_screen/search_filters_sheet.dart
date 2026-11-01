import 'package:flutter/material.dart';
import 'package:bulka_frontend/blocs/amenities/amenities_bloc.dart';
import 'package:bulka_frontend/blocs/locale/locale_bloc.dart';
import 'package:bulka_frontend/blocs/search/search_bloc.dart';
import 'package:bulka_frontend/blocs/listings/listings_bloc.dart';
import 'package:bulka_frontend/blocs/listing_reviews/listing_reviews_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bulka_frontend/core/constants/app_colors.dart';
import 'package:bulka_frontend/core/constants/app_dimensions.dart';
import 'package:bulka_frontend/core/constants/app_strings.dart';
import 'package:bulka_frontend/core/utils/date_range_format.dart';
import 'package:bulka_frontend/core/utils/price_format.dart';
import 'package:bulka_frontend/models/listing_category.dart';
import 'package:bulka_frontend/models/create_listing_draft.dart';
import 'package:bulka_frontend/models/amenity.dart';
import 'package:bulka_frontend/models/listing_search_filter.dart';
import 'package:bulka_frontend/widgets/app_checkbox.dart';
import 'package:bulka_frontend/widgets/labeled_text_field.dart';
import 'package:bulka_frontend/widgets/primary_button.dart';

/// The Figma "21 – Buyer · Search & Filters (Overlay)" frame's Filter
/// Sheet — opened as a modal bottom sheet over `TouristHomeScreen` (the X
/// closes without applying; "Прикажи резултати" pops with the applied
/// [ListingSearchFilter] for the caller to commit). Edits a local *copy* of
/// [initialFilter] so a dismissed sheet never mutates the caller's already
/// -applied filter.
class SearchFiltersSheet extends StatefulWidget {
  const SearchFiltersSheet({super.key, required this.initialFilter});

  final ListingSearchFilter initialFilter;

  @override
  State<SearchFiltersSheet> createState() => _SearchFiltersSheetState();
}

/// Not a real "Сите локации"/cancel result — [showModalBottomSheet]
/// resolves to `null` on both an explicit "Сите локации" tap and a
/// barrier dismiss, so this sentinel disambiguates the two.
const String _allLocationsSentinel = '\u0000all-locations';

const List<double?> _ratingOptions = [null, 3.0, 4.0, 4.5];

/// 1, 2, 3, 4, 5+ — only the last (open-ended) option shows a "+"; the
/// others are plain counts even though the underlying filter is still "at
/// least N" (`ListingSearchFilter.minimumGuests`). No "Сите" chip: "1" is
/// already functionally unrestrictive (every real listing has
/// `guestCapacity >= 1`), so tapping the already-selected chip again
/// clears it back to null instead.
const List<int> _guestCountOptions = [1, 2, 3, 4, 5];

class _SearchFiltersSheetState extends State<SearchFiltersSheet> {
  /// The sheet works on a draft filter, so it doesn't need to rebuild when
  /// listings change; it reads them as needed.
  ListingsState get _listings => context.read<ListingsBloc>().state;

  late final ListingSearchFilter _filter;
  late final TextEditingController _keywordController;
  late RangeValues _priceRange;

  @override
  void initState() {
    super.initState();
    _filter = widget.initialFilter.copy();
    _keywordController = TextEditingController(text: _filter.keyword)
      ..addListener(
        () => setState(() => _filter.keyword = _keywordController.text),
      );
    final bounds = _listings.activePriceBounds;
    _priceRange = RangeValues(
      _filter.minPrice ?? bounds.min,
      _filter.maxPrice ?? bounds.max,
    );
    _loadAmenities(context);
  }

  @override
  void dispose() {
    _keywordController.dispose();
    super.dispose();
  }

  int get _resultCount => searchListings(
    filter: _filter,
    listings: _listings,
    reviews: context.read<ListingReviewsBloc>().state,
  ).length;

  void _handleClose() => Navigator.of(context).pop();

  void _handleClear() {
    final bounds = _listings.activePriceBounds;
    setState(() {
      _filter.reset();
      _keywordController.text = '';
      _priceRange = RangeValues(bounds.min, bounds.max);
    });
  }

  void _handleApply() {
    final bounds = _listings.activePriceBounds;
    final applied = _filter.copy()
      ..minPrice = _filter.minPrice != null && _filter.minPrice! <= bounds.min
          ? null
          : _filter.minPrice
      ..maxPrice = _filter.maxPrice != null && _filter.maxPrice! >= bounds.max
          ? null
          : _filter.maxPrice;
    Navigator.of(context).pop(applied);
  }

  void _handlePriceChanged(RangeValues values) {
    setState(() {
      _priceRange = values;
      _filter.minPrice = values.start;
      _filter.maxPrice = values.end;
    });
  }

  Future<void> _pickLocation() async {
    final locations = _listings.activeLocations;
    final selected = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimensions.dsRadiusLg),
        ),
      ),
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(AppStrings.filtersAllLocationsOption),
              onTap: () => Navigator.pop(sheetContext, _allLocationsSentinel),
            ),
            for (final location in locations)
              ListTile(
                title: Text(location),
                onTap: () => Navigator.pop(sheetContext, location),
              ),
          ],
        ),
      ),
    );
    if (selected == null) return;
    setState(() {
      _filter.location = selected == _allLocationsSentinel ? null : selected;
    });
  }

  Future<void> _pickDateRange() async {
    final now = DateTime.now();
    final initialRange = _filter.startDate != null && _filter.endDate != null
        ? DateTimeRange(start: _filter.startDate!, end: _filter.endDate!)
        : null;
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: now.add(const Duration(days: 730)),
      initialDateRange: initialRange,
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(context).colorScheme.copyWith(
            primary: AppColors.agroForest950,
            onPrimary: AppColors.white,
            onSurface: AppColors.agroForest950,
          ),
        ),
        child: child!,
      ),
    );
    if (picked == null) return;
    setState(() {
      _filter.startDate = picked.start;
      _filter.endDate = picked.end;
    });
  }

  void _toggleCategory(ListingCategory category) {
    setState(() {
      if (!_filter.categories.remove(category)) {
        _filter.categories.add(category);
      }
    });
  }

  void _toggleAmenity(String code) {
    setState(() {
      if (!_filter.amenities.remove(code)) {
        _filter.amenities.add(code);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bounds = _listings.activePriceBounds;
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.only(
          left: AppDimensions.dsBodyHorizontalPadding,
          right: AppDimensions.dsBodyHorizontalPadding,
          top: AppDimensions.filtersSheetTopPadding,
          bottom: AppDimensions.filtersSheetBottomPadding,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _Handle(),
            const SizedBox(height: AppDimensions.filtersSheetContentGap),
            _TitleRow(onClose: _handleClose),
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      height: AppDimensions.filtersSheetContentGap,
                    ),
                    LabeledTextField(
                      label: AppStrings.filtersKeywordLabel,
                      hintText: AppStrings.filtersKeywordPlaceholder,
                      controller: _keywordController,
                    ),
                    const SizedBox(
                      height: AppDimensions.filtersSheetContentGap,
                    ),
                    _SelectBox(
                      label: AppStrings.filtersLocationLabel,
                      value:
                          _filter.location ??
                          AppStrings.filtersAllLocationsOption,
                      onTap: _pickLocation,
                    ),
                    const SizedBox(
                      height: AppDimensions.filtersSheetContentGap,
                    ),
                    _PriceField(
                      bounds: bounds,
                      range: _priceRange,
                      onChanged: _handlePriceChanged,
                    ),
                    const SizedBox(
                      height: AppDimensions.filtersSheetContentGap,
                    ),
                    _SelectBox(
                      label: AppStrings.filtersDateLabel,
                      value:
                          _filter.startDate != null && _filter.endDate != null
                          ? formatDateRange(
                              _filter.startDate!,
                              _filter.endDate!,
                            )
                          : AppStrings.filtersDatePlaceholder,
                      onTap: _pickDateRange,
                    ),
                    const SizedBox(
                      height: AppDimensions.filtersSheetContentGap,
                    ),
                    _RatingField(
                      selected: _filter.minRating,
                      onSelect: (rating) =>
                          setState(() => _filter.minRating = rating),
                    ),
                    const SizedBox(
                      height: AppDimensions.filtersSheetContentGap,
                    ),
                    _GuestCountField(
                      selected: _filter.minimumGuests,
                      onSelect: (guests) =>
                          setState(() => _filter.minimumGuests = guests),
                    ),
                    const SizedBox(
                      height: AppDimensions.filtersSheetContentGap,
                    ),
                    _CategoryField(
                      selected: _filter.categories,
                      onToggle: _toggleCategory,
                    ),
                    const SizedBox(
                      height: AppDimensions.filtersSheetContentGap,
                    ),
                    _AmenityField(
                      selected: _filter.amenities,
                      onToggle: _toggleAmenity,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.filtersSheetContentGap),
            _ActionsRow(
              resultCount: _resultCount,
              onClear: _handleClear,
              onApply: _handleApply,
            ),
          ],
        ),
      ),
    );
  }
}

class _Handle extends StatelessWidget {
  const _Handle();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: AppDimensions.filtersHandleWidth,
        height: AppDimensions.filtersHandleHeight,
        decoration: BoxDecoration(
          color: AppColors.profileStatCardBorder,
          borderRadius: BorderRadius.circular(AppDimensions.pillBorderRadius),
        ),
      ),
    );
  }
}

class _TitleRow extends StatelessWidget {
  const _TitleRow({required this.onClose});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          AppStrings.filtersSheetTitle,
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: AppDimensions.filtersTitleFontSize,
            color: AppColors.agroForest950,
          ),
        ),
        GestureDetector(
          onTap: onClose,
          child: const Text(
            AppStrings.wizardCloseGlyph,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: AppDimensions.filtersCloseFontSize,
              color: AppColors.profileSecondaryText,
            ),
          ),
        ),
      ],
    );
  }
}

Widget _fieldLabel(String text) => Text(
  text,
  style: const TextStyle(
    fontWeight: FontWeight.w600,
    fontSize: AppDimensions.dsFieldLabelFontSize,
    color: AppColors.agroForest950,
  ),
);

class _SelectBox extends StatelessWidget {
  const _SelectBox({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _fieldLabel(label),
        const SizedBox(height: AppDimensions.filtersFieldHeadingGap),
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.dsInputHorizontalPadding,
              vertical: AppDimensions.dsInputVerticalPadding,
            ),
            decoration: BoxDecoration(
              color: AppColors.white,
              border: Border.all(color: AppColors.agroBorder300),
              borderRadius: BorderRadius.circular(AppDimensions.dsRadiusMd),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    value,
                    style: const TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: AppDimensions.dsInputFontSize,
                      color: AppColors.agroForest950,
                    ),
                  ),
                ),
                const Icon(
                  Icons.keyboard_arrow_down,
                  size: AppDimensions.filtersChevronIconSize,
                  color: AppColors.agroForest950,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _PriceField extends StatelessWidget {
  const _PriceField({
    required this.bounds,
    required this.range,
    required this.onChanged,
  });

  final ({double min, double max}) bounds;
  final RangeValues range;
  final ValueChanged<RangeValues> onChanged;

  @override
  Widget build(BuildContext context) {
    final safeMax = bounds.max > bounds.min ? bounds.max : bounds.min + 1;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _fieldLabel(AppStrings.filtersPriceRangeLabel),
            Text(
              '${formatPrice(range.start)} – '
              '${formatPrice(range.end)} '
              '${AppStrings.filtersPriceRangeUnit}',
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: AppDimensions.filtersPriceValueFontSize,
                color: AppColors.agroInk500,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.filtersPriceLabelRowGap),
        SizedBox(
          height: AppDimensions.filtersSliderHeight,
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: AppDimensions.filtersSliderTrackHeight,
              activeTrackColor: AppColors.agroForest950,
              inactiveTrackColor: AppColors.agroBorder300,
              thumbColor: AppColors.white,
              overlayColor: Colors.transparent,
              rangeThumbShape: const RoundRangeSliderThumbShape(
                enabledThumbRadius: AppDimensions.filtersSliderThumbRadius,
                elevation: 2,
              ),
            ),
            child: RangeSlider(
              values: RangeValues(
                range.start.clamp(bounds.min, safeMax),
                range.end.clamp(bounds.min, safeMax),
              ),
              min: bounds.min,
              max: safeMax,
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}

class _RatingField extends StatelessWidget {
  const _RatingField({required this.selected, required this.onSelect});

  final double? selected;
  final ValueChanged<double?> onSelect;

  String _label(double? rating) {
    if (rating == null) return AppStrings.filtersRatingAllOption;
    final trimmed = rating == rating.roundToDouble()
        ? rating.toInt().toString()
        : rating.toString();
    return '$trimmed+ ★';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _fieldLabel(AppStrings.filtersRatingLabel),
        const SizedBox(height: AppDimensions.filtersFieldHeadingGap),
        Wrap(
          spacing: AppDimensions.wizardChipGap,
          runSpacing: AppDimensions.wizardChipGap,
          children: [
            for (final rating in _ratingOptions)
              _Pill(
                label: _label(rating),
                isSelected: rating == selected,
                onTap: () => onSelect(rating),
              ),
          ],
        ),
      ],
    );
  }
}

/// Separate from [_RatingField] — its own field, own label, own chip row —
/// though visually identical (reuses [_Pill]), per "Број на гости" being a
/// genuinely distinct filter from "Оценка", not a variant of it.
class _GuestCountField extends StatelessWidget {
  const _GuestCountField({required this.selected, required this.onSelect});

  final int? selected;
  final ValueChanged<int?> onSelect;

  String _label(int guests) =>
      guests == _guestCountOptions.last ? '$guests+' : '$guests';

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _fieldLabel(AppStrings.filtersGuestCountLabel),
        const SizedBox(height: AppDimensions.filtersFieldHeadingGap),
        Wrap(
          spacing: AppDimensions.wizardChipGap,
          runSpacing: AppDimensions.wizardChipGap,
          children: [
            for (final guests in _guestCountOptions)
              _Pill(
                label: _label(guests),
                isSelected: guests == selected,
                // No "Сите" chip to tap back to — tapping the already
                // -selected value clears it instead, so the filter can
                // still be unset without hitting "Избриши филтри".
                onTap: () => onSelect(guests == selected ? null : guests),
              ),
          ],
        ),
      ],
    );
  }
}

class _CategoryField extends StatelessWidget {
  const _CategoryField({required this.selected, required this.onToggle});

  final Set<ListingCategory> selected;
  final ValueChanged<ListingCategory> onToggle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _fieldLabel(AppStrings.wizardCategoryLabel),
        const SizedBox(height: AppDimensions.filtersFieldHeadingGap),
        Wrap(
          spacing: AppDimensions.wizardChipGap,
          runSpacing: AppDimensions.wizardChipGap,
          children: [
            for (final category in createOfferCategories)
              _Pill(
                label: category.shortLabel,
                isSelected: selected.contains(category),
                onTap: () => onToggle(category),
              ),
          ],
        ),
      ],
    );
  }
}

/// Shared visual for the Rating and Category chip rows — Figma's
/// "agro-ink-900" (selected: dark fill, white bold text) vs. unselected
/// (white fill, `agroBorder300` border, `profileSecondaryText` text).
class _Pill extends StatelessWidget {
  const _Pill({
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
            color: isSelected
                ? AppColors.white
                : AppColors.profileSecondaryText,
          ),
        ),
      ),
    );
  }
}

/// Loads the amenities in the current language unless they're already
/// loaded (or loading) in it.
void _loadAmenities(BuildContext context) {
  final language = context.read<LocaleBloc>().state.locale.languageCode;
  final amenities = context.read<AmenitiesBloc>();
  if (amenities.state.needsLoadFor(language)) {
    amenities.add(AmenitiesRequested(language));
  }
}

/// The amenities from `GET /api/amenities` (see [AmenitiesBloc]); the
/// filter stores the chosen ones by `Amenity.code`.
class _AmenityField extends StatelessWidget {
  const _AmenityField({required this.selected, required this.onToggle});

  final Set<String> selected;
  final ValueChanged<String> onToggle;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AmenitiesBloc>().state;
    final amenities = state.amenities;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _fieldLabel(AppStrings.filtersAmenityHeading),
        const SizedBox(height: AppDimensions.filtersAmenitySectionGap),
        if (amenities.isEmpty)
          state.status == AmenitiesStatus.failed
              ? _AmenitiesLoadFailed(onRetry: () => _loadAmenities(context))
              : const Center(
                  child: SizedBox.square(
                    dimension: AppDimensions.wizardAmenityEmojiFontSize,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.agroGreen600,
                    ),
                  ),
                ),
        for (var i = 0; i < amenities.length; i++) ...[
          _AmenityRow(
            amenity: amenities[i],
            isSelected: selected.contains(amenities[i].code),
            onChanged: (_) => onToggle(amenities[i].code),
          ),
          if (i != amenities.length - 1)
            const SizedBox(height: AppDimensions.filtersAmenitySectionGap),
        ],
      ],
    );
  }
}

class _AmenitiesLoadFailed extends StatelessWidget {
  const _AmenitiesLoadFailed({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            AppStrings.filtersAmenitiesLoadFailed,
            style: const TextStyle(
              fontSize: AppDimensions.dsInputFontSize,
              color: AppColors.profileSecondaryText,
            ),
          ),
        ),
        TextButton(
          onPressed: onRetry,
          child: Text(
            AppStrings.retryButton,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: AppDimensions.dsInputFontSize,
              color: AppColors.agroGreen600,
            ),
          ),
        ),
      ],
    );
  }
}

class _AmenityRow extends StatelessWidget {
  const _AmenityRow({
    required this.amenity,
    required this.isSelected,
    required this.onChanged,
  });

  final Amenity amenity;
  final bool isSelected;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Row(
            children: [
              Text(
                amenity.emoji,
                style: const TextStyle(
                  fontSize: AppDimensions.wizardAmenityEmojiFontSize,
                ),
              ),
              const SizedBox(width: AppDimensions.wizardAmenityRowGap),
              Expanded(
                child: Text(
                  amenity.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: AppDimensions.dsInputFontSize,
                    color: AppColors.agroForest950,
                  ),
                ),
              ),
            ],
          ),
        ),
        AppCheckbox(value: isSelected, onChanged: onChanged),
      ],
    );
  }
}

class _ActionsRow extends StatelessWidget {
  const _ActionsRow({
    required this.resultCount,
    required this.onClear,
    required this.onApply,
  });

  final int resultCount;
  final VoidCallback onClear;
  final VoidCallback onApply;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: onClear,
          child: Text(
            AppStrings.filtersClearButton,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: AppDimensions.filtersClearButtonFontSize,
              color: AppColors.profileSecondaryText,
            ),
          ),
        ),
        const SizedBox(width: AppDimensions.filtersActionsGap),
        Expanded(
          child: PrimaryButton(
            label: '${AppStrings.filtersShowResultsButton} ($resultCount)',
            backgroundColor: AppColors.agroGreen600,
            onPressed: onApply,
          ),
        ),
      ],
    );
  }
}
