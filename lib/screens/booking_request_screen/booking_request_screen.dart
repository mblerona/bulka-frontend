import 'package:flutter/material.dart';
import 'package:bulka_frontend/core/constants/app_colors.dart';
import 'package:bulka_frontend/core/constants/app_dimensions.dart';
import 'package:bulka_frontend/core/constants/app_strings.dart';
import 'package:bulka_frontend/core/constants/mock_tourist_identity.dart';
import 'package:bulka_frontend/core/utils/date_range_format.dart';
import 'package:bulka_frontend/models/availability_status.dart';
import 'package:bulka_frontend/models/provider_listing.dart';
import 'package:bulka_frontend/screens/reservation_confirmation_screen/reservation_confirmation_screen.dart';
import 'package:bulka_frontend/services/availability_controller.dart';
import 'package:bulka_frontend/services/reservation_controller.dart';
import 'package:bulka_frontend/widgets/app_bottom_nav.dart';
import 'package:bulka_frontend/widgets/primary_button.dart';
import 'package:bulka_frontend/widgets/screen_header.dart';
import 'package:bulka_frontend/widgets/xfile_image.dart';

/// The minimal date/guest-count input step the Tourist booking flow needs
/// between Listing Details and the Reservation Confirmation screen.
///
/// No current-design Figma frame defines this step — a similarly-named
/// "Calendar Picker" frame exists elsewhere in the file, but belongs to an
/// entirely different, stylistically superseded earlier design pass (a
/// different palette/typography/token set from every screen already built
/// in this app), not the current one. So this reuses the app's own
/// existing primitives instead of inventing new visual language: the same
/// date-range-picker mechanism already used by the Search Filters sheet,
/// and a capacity stepper matching the Create Offer wizard's own
/// guest-count row exactly.
///
/// Only reachable for accommodation-category listings (gated in
/// `ListingDetailsScreen` via `categoryRequiresPrice`) — the whole
/// check-in/check-out + nightly-price model doesn't apply to non-nightly
/// categories.
class BookingRequestScreen extends StatefulWidget {
  const BookingRequestScreen({
    super.key,
    required this.listing,
    this.originTabIndex = 0,
  });

  final ProviderListing listing;

  /// Inherited from `ListingDetailsScreen` — the user is still mid-browse
  /// here, so the navbar keeps showing whichever section (Дома/Пребарај)
  /// they actually started from; only `ReservationConfirmationScreen`
  /// onward switches to Резервации, once a reservation actually exists.
  final int originTabIndex;

  @override
  State<BookingRequestScreen> createState() => _BookingRequestScreenState();
}

class _BookingRequestScreenState extends State<BookingRequestScreen> {
  final AvailabilityController _availability = AvailabilityController.instance;
  final ReservationController _reservationController =
      ReservationController.instance;

  DateTime? _startDate;
  DateTime? _endDate;
  int _guestCount = 1;
  String? _dateError;

  int get _maxGuests =>
      widget.listing.guestCapacity > 0 ? widget.listing.guestCapacity : 1;

  bool get _canSubmit =>
      _startDate != null && _endDate != null && _dateError == null;

  /// Reuses `AvailabilityController.statusForDate` (already shared by the
  /// Provider Availability Calendar) day-by-day over the picked range —
  /// no separate availability logic exists here.
  bool _hasUnavailableDay(DateTime start, DateTime end) {
    for (
      var day = start;
      day.isBefore(end);
      day = day.add(const Duration(days: 1))
    ) {
      if (_availability.statusForDate(widget.listing.id, day) !=
          AvailabilityStatus.available) {
        return true;
      }
    }
    return false;
  }

  Future<void> _pickDates() async {
    final now = DateTime.now();
    final initialRange = _startDate != null && _endDate != null
        ? DateTimeRange(start: _startDate!, end: _endDate!)
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
      _startDate = picked.start;
      _endDate = picked.end;
      _dateError = _hasUnavailableDay(picked.start, picked.end)
          ? AppStrings.bookingDatesUnavailableError
          : null;
    });
  }

  void _adjustGuests(int delta) {
    setState(() {
      _guestCount = (_guestCount + delta).clamp(1, _maxGuests);
    });
  }

  void _handleSubmit() {
    if (!_canSubmit) return;
    final reservation = _reservationController.createReservation(
      listing: widget.listing,
      guestName: mockTouristGuestName,
      startDate: _startDate!,
      endDate: _endDate!,
      guestCount: _guestCount,
    );
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => ReservationConfirmationScreen(
          reservation: reservation,
          listing: widget.listing,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final listing = widget.listing;
    return Scaffold(
      backgroundColor: AppColors.beigeBackground,
      bottomNavigationBar: TouristBottomNav(
        selectedIndex: widget.originTabIndex,
      ),
      body: Column(
        children: [
          const ScreenHeader(
            title: AppStrings.reservationFlowTitle,
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
                  top: AppDimensions.dsRootBodyTopPadding,
                  bottom: AppDimensions.profileBodyBottomPadding,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.dsBodyHorizontalPadding,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _ListingSummaryRow(listing: listing),
                      const SizedBox(height: AppDimensions.wizardContentGap),
                      _SelectBox(
                        label: AppStrings.filtersDateLabel,
                        value: _startDate != null && _endDate != null
                            ? formatMkDateRange(_startDate!, _endDate!)
                            : AppStrings.filtersDatePlaceholder,
                        onTap: _pickDates,
                      ),
                      if (_dateError != null) ...[
                        const SizedBox(
                          height: AppDimensions.filtersFieldHeadingGap,
                        ),
                        Text(
                          _dateError!,
                          style: const TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: AppDimensions.dsFieldLabelFontSize,
                            color: AppColors.settingsDangerColor,
                          ),
                        ),
                      ],
                      const SizedBox(height: AppDimensions.wizardContentGap),
                      _GuestStepperRow(
                        value: _guestCount,
                        max: _maxGuests,
                        onDecrement: () => _adjustGuests(-1),
                        onIncrement: () => _adjustGuests(1),
                      ),
                      const SizedBox(
                        height: AppDimensions.wizardContentGap * 2,
                      ),
                      PrimaryButton(
                        label: AppStrings.detailsReserveButton,
                        backgroundColor: AppColors.agroGreen600,
                        onPressed: _canSubmit ? _handleSubmit : null,
                      ),
                    ],
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

class _ListingSummaryRow extends StatelessWidget {
  const _ListingSummaryRow({required this.listing});

  final ProviderListing listing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: AppDimensions.calendarListingContextTopPadding,
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppDimensions.dsRadiusMd),
            child: listing.photoPaths.isEmpty
                ? Container(
                    width: AppDimensions.calendarListingThumbSize,
                    height: AppDimensions.calendarListingThumbSize,
                    color: AppColors.agroGreen100,
                  )
                : XFileImage(
                    path: listing.photoPaths.first,
                    width: AppDimensions.calendarListingThumbSize,
                    height: AppDimensions.calendarListingThumbSize,
                    fit: BoxFit.cover,
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
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: AppDimensions.dsFieldLabelFontSize,
            color: AppColors.agroForest950,
          ),
        ),
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

class _GuestStepperRow extends StatelessWidget {
  const _GuestStepperRow({
    required this.value,
    required this.max,
    required this.onDecrement,
    required this.onIncrement,
  });

  final int value;
  final int max;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: AppDimensions.wizardStepperRowVerticalPadding,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            AppStrings.wizardGuestsLabel,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: AppDimensions.wizardStepperLabelFontSize,
              color: AppColors.agroForest950,
            ),
          ),
          Row(
            children: [
              _StepperButton(glyph: '–', onTap: value > 1 ? onDecrement : null),
              const SizedBox(width: AppDimensions.wizardStepperGap),
              Text(
                '$value',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: AppDimensions.wizardStepperValueFontSize,
                  color: AppColors.agroForest950,
                ),
              ),
              const SizedBox(width: AppDimensions.wizardStepperGap),
              _StepperButton(
                glyph: '+',
                onTap: value < max ? onIncrement : null,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StepperButton extends StatelessWidget {
  const _StepperButton({required this.glyph, required this.onTap});

  final String glyph;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: enabled ? 1 : 0.4,
        child: Container(
          width: AppDimensions.wizardStepperButtonSize,
          height: AppDimensions.wizardStepperButtonSize,
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.agroBorder300),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            glyph,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: AppDimensions.wizardStepperButtonFontSize,
              color: AppColors.agroForest950,
            ),
          ),
        ),
      ),
    );
  }
}
