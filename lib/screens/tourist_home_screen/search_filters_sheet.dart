import 'package:flutter/material.dart';
import 'package:bulka_frontend/blocs/amenities/amenities_bloc.dart';
import 'package:bulka_frontend/blocs/categories/categories_bloc.dart';
import 'package:bulka_frontend/blocs/locale/locale_bloc.dart';
import 'package:bulka_frontend/blocs/regions/regions_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bulka_frontend/core/constants/app_colors.dart';
import 'package:bulka_frontend/core/constants/app_dimensions.dart';
import 'package:bulka_frontend/core/constants/app_strings.dart';
import 'package:bulka_frontend/core/utils/date_range_format.dart';
import 'package:bulka_frontend/core/utils/price_format.dart';
import 'package:bulka_frontend/models/amenity.dart';
import 'package:bulka_frontend/models/listing_search_filter.dart';
import 'package:bulka_frontend/widgets/app_checkbox.dart';
import 'package:bulka_frontend/widgets/labeled_text_field.dart';
import 'package:bulka_frontend/widgets/load_failed_message.dart';
import 'package:bulka_frontend/widgets/primary_button.dart';

/// The Figma "21 – Buyer · Search & Filters (Overlay)" frame's Filter
/// Sheet — a modal bottom sheet over whichever screen opened it
/// (`TouristHomeScreen`, `SearchResultsScreen`). The X, a tap outside or
/// back only closes it, back to that screen, without applying; "Прикажи
/// резултати" pops with the applied [ListingSearchFilter] for the caller
/// to commit. Edits a local *copy* of
/// [initialFilter] so a dismissed sheet never mutates the caller's already
/// -applied filter.
///
/// Locations, categories and amenities are the backend's (`RegionsBloc`,
/// `CategoriesBloc`, `AmenitiesBloc`); the search itself runs on the
/// backend once the filter is applied.
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

const ({double min, double max}) _priceBounds = (
  min: ListingSearchFilter.priceSliderMin,
  max: ListingSearchFilter.priceSliderMax,
);

class _SearchFiltersSheetState extends State<SearchFiltersSheet> {
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
    _priceRange = RangeValues(
      _filter.minPrice ?? _priceBounds.min,
      _filter.maxPrice ?? _priceBounds.max,
    );
    _loadFilterOptions(context);
  }

  /// Lowering the total keeps at least one adult; clearing it clears the
  /// children too.
  void _setTotalGuests(int? total) {
    setState(() {
      _filter.minimumGuests = total;
      _filter.children = total == null
          ? 0
          : _filter.children.clamp(0, total - 1);
    });
  }

  @override
  void dispose() {
    _keywordController.dispose();
    super.dispose();
  }

  void _handleClose() => Navigator.of(context).pop();

  void _handleClear() {
    setState(() {
      _filter.reset();
      _keywordController.text = '';
      _priceRange = RangeValues(_priceBounds.min, _priceBounds.max);
    });
  }

  void _handleApply() {
    const bounds = _priceBounds;
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
    _loadFilterOptions(context);
    final regions = context.read<RegionsBloc>().state.regions;
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
            for (final region in regions)
              ListTile(
                title: Text(region.name),
                onTap: () => Navigator.pop(sheetContext, region.id),
              ),
          ],
        ),
      ),
    );
    if (selected == null) return;
    setState(() {
      _filter.regionId = selected == _allLocationsSentinel ? null : selected;
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

  /// One category at a time; tapping the selected one clears it.
  void _toggleCategory(String categoryId) {
    setState(() {
      _filter.categoryId = _filter.categoryId == categoryId ? null : categoryId;
    });
  }

  void _toggleAmenity(String amenityId) {
    setState(() {
      if (!_filter.amenityIds.remove(amenityId)) {
        _filter.amenityIds.add(amenityId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final regionName = context.select(
      (RegionsBloc bloc) => bloc.state.byId(_filter.regionId)?.name,
    );
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
                      value: regionName ?? AppStrings.filtersAllLocationsOption,
                      onTap: _pickLocation,
                    ),
                    const SizedBox(
                      height: AppDimensions.filtersSheetContentGap,
                    ),
                    _PriceField(
                      bounds: _priceBounds,
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
                    _GuestsField(
                      total: _filter.minimumGuests,
                      children: _filter.children,
                      onTotalChanged: _setTotalGuests,
                      onChildrenChanged: (children) =>
                          setState(() => _filter.children = children),
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
                    _CategoryField(
                      selectedId: _filter.categoryId,
                      onToggle: _toggleCategory,
                    ),
                    const SizedBox(
                      height: AppDimensions.filtersSheetContentGap,
                    ),
                    _AmenityField(
                      selected: _filter.amenityIds,
                      onToggle: _toggleAmenity,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.filtersSheetContentGap),
            _ActionsRow(onClear: _handleClear, onApply: _handleApply),
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

/// The Figma "Guests Field", like the website's "Гости" / "Од нив деца":
/// a total (null = no restriction, shown as "—") and how many of them are
/// children, with the adults left over shown underneath.
class _GuestsField extends StatelessWidget {
  const _GuestsField({
    required this.total,
    required this.children,
    required this.onTotalChanged,
    required this.onChildrenChanged,
  });

  final int? total;
  final int children;
  final ValueChanged<int?> onTotalChanged;
  final ValueChanged<int> onChildrenChanged;

  @override
  Widget build(BuildContext context) {
    final total = this.total;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _fieldLabel(AppStrings.filtersGuestCountLabel),
        const SizedBox(height: AppDimensions.filtersFieldHeadingGap),
        _StepperRow(
          label: AppStrings.filtersGuestsTotalLabel,
          value: total?.toString() ?? '—',
          // Down from 1 clears the filter again.
          onDecrease: total == null
              ? null
              : () => onTotalChanged(total == 1 ? null : total - 1),
          onIncrease: () => onTotalChanged((total ?? 0) + 1),
        ),
        const SizedBox(height: AppDimensions.filtersStepperRowGap),
        _StepperRow(
          label: AppStrings.filtersGuestsChildrenLabel,
          value: '$children',
          onDecrease: children == 0
              ? null
              : () => onChildrenChanged(children - 1),
          // At least one adult.
          onIncrease: total == null || children >= total - 1
              ? null
              : () => onChildrenChanged(children + 1),
        ),
        if (total != null) ...[
          const SizedBox(height: AppDimensions.filtersFieldHeadingGap),
          Text(
            AppStrings.filtersGuestsAdults(total - children),
            style: const TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: AppDimensions.filtersGuestsAdultsFontSize,
              color: AppColors.agroInk500,
            ),
          ),
        ],
      ],
    );
  }
}

/// A [_SelectBox]-styled row with − value + on the right. A null callback
/// disables that button.
class _StepperRow extends StatelessWidget {
  const _StepperRow({
    required this.label,
    required this.value,
    required this.onDecrease,
    required this.onIncrease,
  });

  final String label;
  final String value;
  final VoidCallback? onDecrease;
  final VoidCallback? onIncrease;

  @override
  Widget build(BuildContext context) {
    return Container(
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
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: AppDimensions.dsInputFontSize,
                color: AppColors.agroForest950,
              ),
            ),
          ),
          _StepperButton(
            icon: Icons.remove,
            tooltip: AppStrings.filtersStepperDecrease,
            onTap: onDecrease,
          ),
          const SizedBox(width: AppDimensions.filtersStepperGap),
          SizedBox(
            width: AppDimensions.filtersStepperValueWidth,
            child: Text(
              value,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: AppDimensions.dsInputFontSize,
                color: AppColors.agroForest950,
              ),
            ),
          ),
          const SizedBox(width: AppDimensions.filtersStepperGap),
          _StepperButton(
            icon: Icons.add,
            tooltip: AppStrings.filtersStepperIncrease,
            onTap: onIncrease,
          ),
        ],
      ),
    );
  }
}

class _StepperButton extends StatelessWidget {
  const _StepperButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return Semantics(
      button: true,
      enabled: enabled,
      label: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: AppDimensions.filtersStepperButtonSize,
          height: AppDimensions.filtersStepperButtonSize,
          decoration: BoxDecoration(
            color: enabled ? AppColors.agroGreen100 : AppColors.agroBorder300,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: AppDimensions.filtersStepperIconSize,
            color: enabled ? AppColors.agroForest950 : AppColors.agroInk500,
          ),
        ),
      ),
    );
  }
}

/// The backend's top-level categories (same as Tourist Home's row).
class _CategoryField extends StatelessWidget {
  const _CategoryField({required this.selectedId, required this.onToggle});

  final String? selectedId;
  final ValueChanged<String> onToggle;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<CategoriesBloc>().state;
    final categories = state.topLevel;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _fieldLabel(AppStrings.wizardCategoryLabel),
        const SizedBox(height: AppDimensions.filtersFieldHeadingGap),
        if (categories.isEmpty)
          state.status == CategoriesStatus.failed
              ? LoadFailedMessage(
                  message: AppStrings.homeCategoriesLoadFailed,
                  onRetry: () => _loadFilterOptions(context),
                )
              : const SectionLoadingIndicator(
                  size: AppDimensions.wizardAmenityEmojiFontSize,
                )
        else
          Wrap(
            spacing: AppDimensions.wizardChipGap,
            runSpacing: AppDimensions.wizardChipGap,
            children: [
              for (final category in categories)
                _Pill(
                  label: category.name,
                  isSelected: selectedId == category.id,
                  onTap: () => onToggle(category.id),
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

/// Loads the sheet's regions, categories and amenities in the current
/// language unless they're already loaded (or loading) in it.
void _loadFilterOptions(BuildContext context) {
  final language = context.read<LocaleBloc>().state.locale.languageCode;
  final regions = context.read<RegionsBloc>();
  if (regions.state.needsLoadFor(language)) {
    regions.add(RegionsRequested(language));
  }
  final categories = context.read<CategoriesBloc>();
  if (categories.state.needsLoadFor(language)) {
    categories.add(CategoriesRequested(language));
  }
  final amenities = context.read<AmenitiesBloc>();
  if (amenities.state.needsLoadFor(language)) {
    amenities.add(AmenitiesRequested(language));
  }
}

/// The amenities from `GET /api/amenities` (see [AmenitiesBloc]); the
/// filter stores the chosen ones by `Amenity.id`.
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
              ? LoadFailedMessage(
                  message: AppStrings.filtersAmenitiesLoadFailed,
                  onRetry: () => _loadFilterOptions(context),
                )
              : const SectionLoadingIndicator(
                  size: AppDimensions.wizardAmenityEmojiFontSize,
                ),
        for (var i = 0; i < amenities.length; i++) ...[
          _AmenityRow(
            amenity: amenities[i],
            isSelected: selected.contains(amenities[i].id),
            onChanged: (_) => onToggle(amenities[i].id),
          ),
          if (i != amenities.length - 1)
            const SizedBox(height: AppDimensions.filtersAmenitySectionGap),
        ],
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
  const _ActionsRow({required this.onClear, required this.onApply});

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
            label: AppStrings.filtersShowResultsButton,
            backgroundColor: AppColors.agroGreen600,
            onPressed: onApply,
          ),
        ),
      ],
    );
  }
}
