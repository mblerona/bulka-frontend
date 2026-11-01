import 'package:flutter/material.dart';
import 'package:bulka_frontend/core/constants/app_colors.dart';
import 'package:bulka_frontend/core/constants/app_dimensions.dart';
import 'package:bulka_frontend/core/constants/app_strings.dart';
import 'package:bulka_frontend/core/utils/date_range_format.dart';
import 'package:bulka_frontend/core/utils/price_format.dart';
import 'package:bulka_frontend/models/provider_listing.dart';
import 'package:bulka_frontend/models/reservation.dart';
import 'package:bulka_frontend/screens/tourist_home_screen/tourist_home_screen.dart';
import 'package:bulka_frontend/screens/tourist_my_reservations_screen/tourist_my_reservations_screen.dart';
import 'package:bulka_frontend/widgets/app_bottom_nav.dart';
import 'package:bulka_frontend/widgets/primary_button.dart';
import 'package:bulka_frontend/widgets/screen_header.dart';
import 'package:bulka_frontend/widgets/secondary_button.dart';
import 'package:bulka_frontend/widgets/xfile_image.dart';

/// The Figma "25 – Buyer · Booking Confirmed" frame — reached only after
/// `ReservationController.createReservation` has already created a real
/// [reservation]; this screen never creates one itself, only displays the
/// completed result.
///
/// Per the app's actual reservation lifecycle, a Tourist booking always
/// starts `pending` (the same Provider Dashboard accept/reject queue every
/// other reservation already goes through — see
/// `ReservationController.createReservation`'s own doc comment), so the
/// heading/subtitle text is deliberately NOT Figma's literal "Резервацијата
/// е потврдена!" (which would misrepresent a still-pending booking as
/// provider-approved) — only the wording differs; the layout/styling below
/// is otherwise an exact match.
class ReservationConfirmationScreen extends StatelessWidget {
  const ReservationConfirmationScreen({
    super.key,
    required this.reservation,
    required this.listing,
  });

  final Reservation reservation;
  final ProviderListing listing;

  int get _nights =>
      reservation.endDate.difference(reservation.startDate).inDays;

  void _backToHome(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const TouristHomeScreen()),
      (route) => false,
    );
  }

  // Same stack-clearing rationale as `_backToHome` — the booking form is
  // already submitted, so there's no path back to it from here either.
  void _viewMyReservations(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const TouristMyReservationsScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final nights = _nights;
    final nightlyPrice = reservation.nightlyPriceAtBooking ?? listing.price;
    final subtotal = nightlyPrice * nights;
    final serviceFee = reservation.serviceFee ?? 0;
    final total = reservation.totalAmount ?? (subtotal + serviceFee);

    // The reservation is already created — there is no safe "back"
    // destination that isn't the (already-submitted) booking form, so both
    // the system back gesture and the header's own back arrow are treated
    // like "Назад кон почетна" instead.
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _backToHome(context);
      },
      child: Scaffold(
        backgroundColor: AppColors.beigeBackground,
        bottomNavigationBar: const TouristBottomNav(selectedIndex: 2),
        body: Column(
          children: [
            ScreenHeader(
              title: AppStrings.reservationFlowTitle,
              titleFontSize: AppDimensions.dsCompactHeaderTitleFontSize,
              bottomPadding: AppDimensions.dsCompactHeaderBottomPadding,
              contentGap: AppDimensions.dsCompactHeaderGap,
              onBackPressed: () => _backToHome(context),
            ),
            Expanded(
              child: SafeArea(
                top: false,
                bottom: false,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _SuccessBlock(),
                      _ListingCardRow(listing: listing),
                      const _SectionDivider(),
                      _TripDetailsSection(reservation: reservation),
                      const _SectionDivider(),
                      _PriceBreakdownSection(
                        nightlyPrice: nightlyPrice,
                        nights: nights,
                        subtotal: subtotal,
                        serviceFee: serviceFee,
                        total: total,
                      ),
                      const _SectionDivider(),
                      _ReferenceSection(reservation: reservation),
                      _ActionsSection(
                        onViewReservations: () => _viewMyReservations(context),
                        onBackHome: () => _backToHome(context),
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

class _SuccessBlock extends StatelessWidget {
  const _SuccessBlock();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: AppDimensions.dsBodyHorizontalPadding,
        right: AppDimensions.dsBodyHorizontalPadding,
        top: AppDimensions.confirmationSuccessTopPadding,
        bottom: AppDimensions.successBottomPadding,
      ),
      child: SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: AppDimensions.successCircleSize,
              height: AppDimensions.successCircleSize,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: AppColors.agroGreen700,
                shape: BoxShape.circle,
              ),
              child: const Text(
                '✓',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: AppDimensions.successCheckFontSize,
                  color: AppColors.white,
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.successBlockGap),
            Text(
              AppStrings.bookingRequestSentHeading,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: AppDimensions.successHeadingFontSize,
                color: AppColors.agroForest950,
              ),
            ),
            const SizedBox(height: AppDimensions.successBlockGap),
            Text(
              AppStrings.bookingRequestSentSubtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: AppDimensions.successSubtitleFontSize,
                color: AppColors.agroInk500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ListingCardRow extends StatelessWidget {
  const _ListingCardRow({required this.listing});

  final ProviderListing listing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.dsBodyHorizontalPadding,
        8,
        AppDimensions.dsBodyHorizontalPadding,
        AppDimensions.detailsSectionVerticalPadding,
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppDimensions.dsRadiusMd),
            child: listing.photoPaths.isEmpty
                ? Container(
                    width: AppDimensions.confirmationThumbSize,
                    height: AppDimensions.confirmationThumbSize,
                    color: AppColors.agroGreen100,
                  )
                : XFileImage(
                    path: listing.photoPaths.first,
                    width: AppDimensions.confirmationThumbSize,
                    height: AppDimensions.confirmationThumbSize,
                    fit: BoxFit.cover,
                  ),
          ),
          const SizedBox(width: AppDimensions.calendarListingContextGap),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  listing.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: AppDimensions.detailsHostNameFontSize,
                    color: AppColors.agroForest950,
                  ),
                ),
                const SizedBox(height: AppDimensions.chatListContentGap),
                Text(
                  listing.location,
                  style: const TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: AppDimensions.offersCardMetaFontSize,
                    color: AppColors.profileSecondaryText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Widget _detailRow(String label, String value, {bool boldValue = true}) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        label,
        style: const TextStyle(
          fontWeight: FontWeight.w400,
          fontSize: AppDimensions.detailsBodyFontSize,
          color: AppColors.profileSecondaryText,
        ),
      ),
      Text(
        value,
        style: TextStyle(
          fontWeight: boldValue ? FontWeight.w600 : FontWeight.w400,
          fontSize: AppDimensions.detailsBodyFontSize,
          color: AppColors.agroForest950,
        ),
      ),
    ],
  );
}

class _TripDetailsSection extends StatelessWidget {
  const _TripDetailsSection({required this.reservation});

  final Reservation reservation;

  String get _guestsValue {
    final suffix = reservation.guestCount == 1
        ? AppStrings.reservationGuestSingular
        : AppStrings.reservationGuestsPlural;
    return '${reservation.guestCount} $suffix';
  }

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
            AppStrings.tripDetailsHeading,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: AppDimensions.detailsSectionHeadingFontSize,
              color: AppColors.agroForest950,
            ),
          ),
          const SizedBox(height: AppDimensions.detailsAmenityListGap),
          _detailRow(
            AppStrings.checkInLabel,
            formatDateShort(reservation.startDate),
          ),
          const SizedBox(height: AppDimensions.detailsAmenityListGap),
          _detailRow(
            AppStrings.checkOutLabel,
            formatDateShort(reservation.endDate),
          ),
          const SizedBox(height: AppDimensions.detailsAmenityListGap),
          _detailRow(AppStrings.wizardGuestsLabel, _guestsValue),
        ],
      ),
    );
  }
}

class _PriceBreakdownSection extends StatelessWidget {
  const _PriceBreakdownSection({
    required this.nightlyPrice,
    required this.nights,
    required this.subtotal,
    required this.serviceFee,
    required this.total,
  });

  final double nightlyPrice;
  final int nights;
  final double subtotal;
  final double serviceFee;
  final double total;

  @override
  Widget build(BuildContext context) {
    final nightsWord = nights == 1
        ? AppStrings.nightSingular
        : AppStrings.nightsPlural;
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
            AppStrings.paymentDetailsHeading,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: AppDimensions.detailsSectionHeadingFontSize,
              color: AppColors.agroForest950,
            ),
          ),
          const SizedBox(height: AppDimensions.detailsAmenityListGap),
          _detailRow(
            '${formatPrice(nightlyPrice)} ${AppStrings.wizardPriceSuffix} '
                'x $nights $nightsWord',
            '${formatPrice(subtotal)} ${AppStrings.wizardPriceSuffix}',
          ),
          const SizedBox(height: AppDimensions.detailsAmenityListGap),
          _detailRow(
            AppStrings.serviceFeeLabel,
            '${formatPrice(serviceFee)} ${AppStrings.wizardPriceSuffix}',
          ),
          const SizedBox(height: AppDimensions.detailsAmenityListGap),
          Container(height: 1, color: AppColors.agroBorder300),
          const SizedBox(height: AppDimensions.detailsAmenityListGap),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppStrings.totalLabel,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: AppDimensions.confirmationTotalFontSize,
                  color: AppColors.agroForest950,
                ),
              ),
              Text(
                '${formatPrice(total)} ${AppStrings.wizardPriceSuffix}',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: AppDimensions.confirmationTotalFontSize,
                  color: AppColors.agroForest950,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ReferenceSection extends StatelessWidget {
  const _ReferenceSection({required this.reservation});

  final Reservation reservation;

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
            AppStrings.reservationNumberLabel,
            style: TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: AppDimensions.dsFieldLabelFontSize,
              color: AppColors.profileSecondaryText,
            ),
          ),
          const SizedBox(height: AppDimensions.chatListContentGap),
          Text(
            '#${reservation.bookingReference}',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: AppDimensions.detailsHostNameFontSize,
              color: AppColors.agroForest950,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionsSection extends StatelessWidget {
  const _ActionsSection({
    required this.onViewReservations,
    required this.onBackHome,
  });

  final VoidCallback onViewReservations;
  final VoidCallback onBackHome;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.dsBodyHorizontalPadding,
        AppDimensions.successActionsTopPadding,
        AppDimensions.dsBodyHorizontalPadding,
        AppDimensions.successActionsBottomPadding,
      ),
      child: Column(
        children: [
          PrimaryButton(
            label: AppStrings.viewMyReservationsButton,
            backgroundColor: AppColors.agroGreen600,
            onPressed: onViewReservations,
          ),
          const SizedBox(height: AppDimensions.successActionsGap),
          SecondaryButton(
            label: AppStrings.backToHomeButton,
            onPressed: onBackHome,
          ),
        ],
      ),
    );
  }
}
