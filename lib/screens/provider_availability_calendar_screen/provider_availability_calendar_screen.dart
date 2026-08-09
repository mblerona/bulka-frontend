import 'package:flutter/material.dart';
import 'package:bulka_frontend/core/constants/app_colors.dart';
import 'package:bulka_frontend/core/constants/app_dimensions.dart';
import 'package:bulka_frontend/core/constants/app_strings.dart';
import 'package:bulka_frontend/core/utils/date_range_format.dart';
import 'package:bulka_frontend/models/availability_status.dart';
import 'package:bulka_frontend/models/provider_listing.dart';
import 'package:bulka_frontend/services/availability_controller.dart';
import 'package:bulka_frontend/services/provider_listing_controller.dart';
import 'package:bulka_frontend/services/reservation_controller.dart';
import 'package:bulka_frontend/widgets/app_bottom_nav.dart';
import 'package:bulka_frontend/widgets/primary_button.dart';
import 'package:bulka_frontend/widgets/screen_header.dart';
import 'package:bulka_frontend/widgets/secondary_button.dart';

const List<String> _weekdayLabels = [
  AppStrings.weekdayMon,
  AppStrings.weekdayTue,
  AppStrings.weekdayWed,
  AppStrings.weekdayThu,
  AppStrings.weekdayFri,
  AppStrings.weekdaySat,
  AppStrings.weekdaySun,
];

class ProviderAvailabilityCalendarScreen extends StatefulWidget {
  const ProviderAvailabilityCalendarScreen({super.key});

  @override
  State<ProviderAvailabilityCalendarScreen> createState() =>
      _ProviderAvailabilityCalendarScreenState();
}

class _ProviderAvailabilityCalendarScreenState
    extends State<ProviderAvailabilityCalendarScreen> {
  final AvailabilityController _availability = AvailabilityController.instance;
  final ReservationController _reservations = ReservationController.instance;

  // No listing picker exists in Figma yet — use the provider's first
  // (currently only) listing. Once multiple listings/a picker exist, this
  // becomes the one place a `selectedListingId` would be swapped in.
  late final ProviderListing _listing =
      ProviderListingController.instance.listings.first;

  // Figma's example opens on August 2026; real prev/next navigation from
  // here regenerates the grid via DateTime, not a hardcoded layout.
  DateTime _visibleMonth = DateTime(2026, 8);

  final Set<DateTime> _selectedDates = {};

  @override
  void initState() {
    super.initState();
    _availability.addListener(_handleChanged);
    _reservations.addListener(_handleChanged);
    _availability.loadAvailability(_listing.id, _visibleMonth);
  }

  @override
  void dispose() {
    _availability.removeListener(_handleChanged);
    _reservations.removeListener(_handleChanged);
    super.dispose();
  }

  void _handleChanged() => setState(() {});

  void _changeMonth(int delta) {
    setState(() {
      _visibleMonth = DateTime(_visibleMonth.year, _visibleMonth.month + delta);
      _selectedDates.clear();
    });
    _availability.loadAvailability(_listing.id, _visibleMonth);
  }

  void _toggleSelection(DateTime date, AvailabilityStatus status) {
    if (status == AvailabilityStatus.occupied) return;
    setState(() {
      if (!_selectedDates.remove(date)) {
        _selectedDates.add(date);
      }
    });
  }

  bool get _canBlock => _selectedDates.any(
    (d) =>
        _availability.statusForDate(_listing.id, d) ==
        AvailabilityStatus.available,
  );

  bool get _canUnblock => _selectedDates.any(
    (d) =>
        _availability.statusForDate(_listing.id, d) ==
        AvailabilityStatus.blocked,
  );

  void _handleBlock() {
    _availability.blockDates(_listing.id, _selectedDates);
    setState(() => _selectedDates.clear());
  }

  void _handleUnblock() {
    _availability.unblockDates(_listing.id, _selectedDates);
    setState(() => _selectedDates.clear());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.beigeBackground,
      bottomNavigationBar: const ProviderBottomNav(selectedIndex: 2),
      body: Column(
        children: [
          const ScreenHeader(
            title: AppStrings.calendarTitle,
            titleFontSize: AppDimensions.dsCompactHeaderTitleFontSize,
            bottomPadding: AppDimensions.dsCompactHeaderBottomPadding,
            contentGap: AppDimensions.dsCompactHeaderGap,
          ),
          Expanded(
            child: SafeArea(
              top: false,
              bottom: false,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ListingContext(listing: _listing),
                    const _Legend(),
                    _MonthNav(
                      month: _visibleMonth,
                      onPrevious: () => _changeMonth(-1),
                      onNext: () => _changeMonth(1),
                    ),
                    _CalendarGrid(
                      month: _visibleMonth,
                      listingId: _listing.id,
                      availability: _availability,
                      selectedDates: _selectedDates,
                      onToggle: _toggleSelection,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        left: AppDimensions.dsBodyHorizontalPadding,
                        right: AppDimensions.dsBodyHorizontalPadding,
                        top: AppDimensions.calendarActionsTopPadding,
                        bottom: AppDimensions.calendarActionsBottomPadding,
                      ),
                      child: Column(
                        children: [
                          PrimaryButton(
                            label: AppStrings.blockSelectedDatesButton,
                            backgroundColor: AppColors.agroGreen600,
                            onPressed: _canBlock ? _handleBlock : null,
                          ),
                          const SizedBox(
                            height: AppDimensions.calendarActionsGap,
                          ),
                          SecondaryButton(
                            label: AppStrings.unblockSelectedDatesButton,
                            onPressed: _canUnblock ? _handleUnblock : null,
                          ),
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

class _ListingContext extends StatelessWidget {
  const _ListingContext({required this.listing});

  final ProviderListing listing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: AppDimensions.dsBodyHorizontalPadding,
        right: AppDimensions.dsBodyHorizontalPadding,
        top: AppDimensions.calendarListingContextTopPadding,
        bottom: AppDimensions.calendarListingContextBottomPadding,
      ),
      child: Row(
        children: [
          Container(
            width: AppDimensions.calendarListingThumbSize,
            height: AppDimensions.calendarListingThumbSize,
            decoration: BoxDecoration(
              color: AppColors.agroGreen100,
              borderRadius: BorderRadius.circular(AppDimensions.dsRadiusMd),
            ),
          ),
          const SizedBox(width: AppDimensions.calendarListingContextGap),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                listing.title,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: AppDimensions.profileNameFontSize,
                  color: AppColors.agroForest950,
                ),
              ),
              const SizedBox(height: AppDimensions.calendarListingNameColGap),
              Text(
                listing.location,
                style: const TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: AppDimensions.calendarListingLocationFontSize,
                  color: AppColors.profileSecondaryText,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: AppDimensions.dsBodyHorizontalPadding,
        right: AppDimensions.dsBodyHorizontalPadding,
        top: AppDimensions.calendarLegendTopPadding,
        bottom: AppDimensions.calendarLegendBottomPadding,
      ),
      child: Row(
        children: [
          for (final status in AvailabilityStatus.values) ...[
            _LegendItem(status: status),
            if (status != AvailabilityStatus.values.last)
              const SizedBox(width: AppDimensions.calendarLegendRowGap),
          ],
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.status});

  final AvailabilityStatus status;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: AppDimensions.calendarLegendSwatchSize,
          height: AppDimensions.calendarLegendSwatchSize,
          decoration: BoxDecoration(
            color: status.cellBackground,
            borderRadius: BorderRadius.circular(
              AppDimensions.calendarLegendSwatchRadius,
            ),
            border: status.cellBorderColor != null
                ? Border.all(color: status.cellBorderColor!)
                : null,
          ),
        ),
        const SizedBox(width: AppDimensions.calendarLegendItemGap),
        Text(
          status.legendLabel,
          style: const TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: AppDimensions.calendarLegendFontSize,
            color: AppColors.profileSecondaryText,
          ),
        ),
      ],
    );
  }
}

class _MonthNav extends StatelessWidget {
  const _MonthNav({
    required this.month,
    required this.onPrevious,
    required this.onNext,
  });

  final DateTime month;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final monthName = mkMonthNames[month.month - 1];
    final title = '${monthName[0].toUpperCase()}${monthName.substring(1)} '
        '${month.year}';
    return Container(
      width: double.infinity,
      height: AppDimensions.calendarMonthNavHeight,
      padding: const EdgeInsets.only(
        left: AppDimensions.dsBodyHorizontalPadding,
        right: AppDimensions.dsBodyHorizontalPadding,
        top: AppDimensions.calendarMonthNavTopPadding,
        bottom: AppDimensions.calendarMonthNavBottomPadding,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _NavArrow(glyph: '‹', onTap: onPrevious),
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: AppDimensions.calendarMonthTitleFontSize,
              color: AppColors.agroForest950,
            ),
          ),
          _NavArrow(glyph: '›', onTap: onNext),
        ],
      ),
    );
  }
}

class _NavArrow extends StatelessWidget {
  const _NavArrow({required this.glyph, required this.onTap});

  final String glyph;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: AppDimensions.calendarNavArrowSize,
        height: AppDimensions.calendarNavArrowSize,
        child: Center(
          child: Text(
            glyph,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: AppDimensions.calendarNavArrowFontSize,
              color: AppColors.agroForest950,
            ),
          ),
        ),
      ),
    );
  }
}

class _CalendarGrid extends StatelessWidget {
  const _CalendarGrid({
    required this.month,
    required this.listingId,
    required this.availability,
    required this.selectedDates,
    required this.onToggle,
  });

  final DateTime month;
  final String listingId;
  final AvailabilityController availability;
  final Set<DateTime> selectedDates;
  final void Function(DateTime date, AvailabilityStatus status) onToggle;

  List<List<int?>> _buildWeeks() {
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final leadingBlanks =
        (DateTime(month.year, month.month, 1).weekday - DateTime.monday) % 7;
    final totalCells = leadingBlanks + daysInMonth;
    final weeksCount = (totalCells / 7).ceil();
    final cells = List<int?>.filled(weeksCount * 7, null);
    for (var day = 1; day <= daysInMonth; day++) {
      cells[leadingBlanks + day - 1] = day;
    }
    return [
      for (var w = 0; w < weeksCount; w++) cells.sublist(w * 7, w * 7 + 7),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final weeks = _buildWeeks();
    return Padding(
      padding: const EdgeInsets.only(
        left: AppDimensions.dsBodyHorizontalPadding,
        right: AppDimensions.dsBodyHorizontalPadding,
        bottom: AppDimensions.calendarGridBottomPadding,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              for (final label in _weekdayLabels)
                Expanded(
                  child: SizedBox(
                    height: AppDimensions.calendarWeekdayCellHeight,
                    child: Center(
                      child: Text(
                        label,
                        style: const TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: AppDimensions.calendarWeekdayFontSize,
                          color: AppColors.profileSecondaryText,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          for (final week in weeks) ...[
            const SizedBox(height: AppDimensions.calendarGridRowGap),
            Row(
              children: [
                for (var i = 0; i < week.length; i++) ...[
                  Expanded(
                    child: week[i] == null
                        ? const SizedBox(height: AppDimensions.calendarCellHeight)
                        : _DayCell(
                            date: DateTime(month.year, month.month, week[i]!),
                            day: week[i]!,
                            listingId: listingId,
                            availability: availability,
                            selectedDates: selectedDates,
                            onToggle: onToggle,
                          ),
                  ),
                  if (i != week.length - 1)
                    const SizedBox(width: AppDimensions.calendarCellGap),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.date,
    required this.day,
    required this.listingId,
    required this.availability,
    required this.selectedDates,
    required this.onToggle,
  });

  final DateTime date;
  final int day;
  final String listingId;
  final AvailabilityController availability;
  final Set<DateTime> selectedDates;
  final void Function(DateTime date, AvailabilityStatus status) onToggle;

  @override
  Widget build(BuildContext context) {
    final status = availability.statusForDate(listingId, date);
    final isSelected = selectedDates.contains(date);
    final isSelectable = status != AvailabilityStatus.occupied;

    final Border? border;
    if (isSelected) {
      border = Border.all(
        color: AppColors.agroForest950,
        width: AppDimensions.calendarSelectedBorderWidth,
      );
    } else if (status.cellBorderColor != null) {
      border = Border.all(color: status.cellBorderColor!);
    } else {
      border = null;
    }

    return GestureDetector(
      onTap: isSelectable ? () => onToggle(date, status) : null,
      child: Container(
        height: AppDimensions.calendarCellHeight,
        decoration: BoxDecoration(
          color: status.cellBackground,
          borderRadius: BorderRadius.circular(AppDimensions.calendarCellRadius),
          border: border,
        ),
        alignment: Alignment.center,
        child: Text(
          '$day',
          style: TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: AppDimensions.calendarCellFontSize,
            color: status.cellTextColor,
          ),
        ),
      ),
    );
  }
}
