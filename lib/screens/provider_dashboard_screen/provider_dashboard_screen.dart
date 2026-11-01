import 'package:flutter/material.dart';
import 'package:bulka_frontend/core/routing/app_routes.dart';
import 'package:go_router/go_router.dart';
import 'package:bulka_frontend/core/constants/app_colors.dart';
import 'package:bulka_frontend/core/constants/app_dimensions.dart';
import 'package:bulka_frontend/core/constants/app_strings.dart';
import 'package:bulka_frontend/core/utils/date_range_format.dart';
import 'package:bulka_frontend/models/reservation.dart';
import 'package:bulka_frontend/services/guest_rating_controller.dart';
import 'package:bulka_frontend/services/provider_listing_controller.dart';
import 'package:bulka_frontend/services/reservation_controller.dart';
import 'package:bulka_frontend/widgets/primary_button.dart';
import 'package:bulka_frontend/widgets/screen_header.dart';
import 'package:bulka_frontend/widgets/status_badge.dart';

class ProviderDashboardScreen extends StatefulWidget {
  const ProviderDashboardScreen({super.key});

  @override
  State<ProviderDashboardScreen> createState() =>
      _ProviderDashboardScreenState();
}

class _ProviderDashboardScreenState extends State<ProviderDashboardScreen> {
  final ProviderListingController _listingController =
      ProviderListingController.instance;
  final ReservationController _reservationController =
      ReservationController.instance;
  final GuestRatingController _ratingController =
      GuestRatingController.instance;

  @override
  void initState() {
    super.initState();
    _listingController.addListener(_handleChanged);
    _reservationController.addListener(_handleChanged);
    _ratingController.addListener(_handleChanged);
  }

  @override
  void dispose() {
    _listingController.removeListener(_handleChanged);
    _reservationController.removeListener(_handleChanged);
    _ratingController.removeListener(_handleChanged);
    super.dispose();
  }

  /// Only navigates into the rating form for a reservation that hasn't
  /// been rated yet — Figma has no "already rated" visual state, so
  /// there's nothing to show here yet (see the TODO on `_RateGuestAction`
  /// below); this just makes sure a second tap can't re-open the form and
  /// attempt a duplicate submission.
  void _handleRateGuest(Reservation reservation) {
    if (_ratingController.hasRating(reservation.id)) return;
    context.push(AppRoutes.rateGuest(reservation.id));
  }

  void _handleChanged() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final listings = _listingController.listings;
    final greetingName = listings.isNotEmpty ? listings.first.title : '';
    final pending = _reservationController.pendingReservations;
    final completed = _reservationController.completedReservations;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: Column(
        children: [
          ScreenHeader(
            title: AppStrings.dashboardTitle,
            subtitle: '${AppStrings.dashboardGreetingPrefix}$greetingName',
            titleFontSize: AppDimensions.dsHeaderSubtitleTitleFontSize,
            bottomPadding: AppDimensions.dsCompactHeaderBottomPadding,
            contentGap: AppDimensions.dsRootHeaderGap,
            subtitleFontSize: AppDimensions.dsSubheadingFontSize,
          ),
          Expanded(
            child: SafeArea(
              top: false,
              bottom: false,
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(
                  left: AppDimensions.dsBodyHorizontalPadding,
                  right: AppDimensions.dsBodyHorizontalPadding,
                  top: AppDimensions.dsRootBodyTopPadding,
                  bottom: AppDimensions.profileBodyBottomPadding,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    PrimaryButton(
                      label: AppStrings.dashboardAddListingButton,
                      backgroundColor: AppColors.agroGreen600,
                      onPressed: () => context.push(AppRoutes.newOffer),
                    ),
                    const SizedBox(height: AppDimensions.dashboardBodyGap),
                    _sectionHeading(AppStrings.dashboardListingsSummaryHeading),
                    const SizedBox(height: AppDimensions.dashboardSectionGap),
                    Row(
                      children: [
                        _CounterCard(
                          value: '${_listingController.activeListingsCount}',
                          label: AppStrings.dashboardActiveListingsLabel,
                          valueColor: AppColors.agroInk500,
                        ),
                        const SizedBox(
                          width: AppDimensions.dashboardCounterCardGap,
                        ),
                        _CounterCard(
                          value:
                              '${_listingController.pendingReviewListingsCount}',
                          label: AppStrings.dashboardPendingReviewListingsLabel,
                          valueColor: AppColors.dashboardPendingReviewAccent,
                        ),
                        const SizedBox(
                          width: AppDimensions.dashboardCounterCardGap,
                        ),
                        _CounterCard(
                          value:
                              '${_reservationController.monthlyReservationsCount}',
                          label: AppStrings.dashboardMonthlyReservationsLabel,
                          valueColor: AppColors.agroInk500,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.dashboardBodyGap),
                    _sectionHeading(
                      AppStrings.dashboardPendingReservationsHeading,
                    ),
                    const SizedBox(height: AppDimensions.dashboardSectionGap),
                    for (var i = 0; i < pending.length; i++) ...[
                      _ReservationCard(
                        reservation: pending[i],
                        actions: _PendingActions(
                          onAccept: () => _reservationController
                              .acceptReservation(pending[i].id),
                          onReject: () => _reservationController
                              .rejectReservation(pending[i].id),
                        ),
                      ),
                      if (i != pending.length - 1)
                        const SizedBox(
                          height: AppDimensions.dashboardSectionGap,
                        ),
                    ],
                    const SizedBox(height: AppDimensions.dashboardBodyGap),
                    _sectionHeading(
                      AppStrings.dashboardCompletedReservationsHeading,
                    ),
                    const SizedBox(height: AppDimensions.dashboardSectionGap),
                    for (var i = 0; i < completed.length; i++) ...[
                      _ReservationCard(
                        reservation: completed[i],
                        // TODO: once a design exists for an "already
                        // rated" state, show it here instead of the
                        // still-tappable "Оцени гостин" for reservations
                        // where `_ratingController.hasRating(...)` is
                        // already true (e.g. a rated indicator/"view
                        // rating" action) — for now the button always
                        // reads "Оцени гостин", but `_handleRateGuest`
                        // safely refuses to reopen the form for one that
                        // already has a rating.
                        actions: _RateGuestAction(
                          onTap: () => _handleRateGuest(completed[i]),
                        ),
                      ),
                      if (i != completed.length - 1)
                        const SizedBox(
                          height: AppDimensions.dashboardSectionGap,
                        ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeading(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: AppDimensions.profileSectionHeadingFontSize,
        color: AppColors.agroForest950,
      ),
    );
  }
}

class _CounterCard extends StatelessWidget {
  const _CounterCard({
    required this.value,
    required this.label,
    required this.valueColor,
  });

  final String value;
  final String label;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(
          AppDimensions.dashboardCounterCardPadding,
        ),
        decoration: BoxDecoration(
          color: AppColors.profileStatCardBackground,
          border: Border.all(color: AppColors.profileStatCardBorder),
          borderRadius: BorderRadius.circular(AppDimensions.dsRadiusMd),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: AppDimensions.dashboardCounterValueFontSize,
                color: valueColor,
              ),
            ),
            const SizedBox(
              height: AppDimensions.dashboardCounterCardContentGap,
            ),
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: AppDimensions.dashboardCounterLabelFontSize,
                color: AppColors.profileSecondaryText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReservationCard extends StatelessWidget {
  const _ReservationCard({required this.reservation, required this.actions});

  final Reservation reservation;
  final Widget actions;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(
        AppDimensions.dashboardReservationCardPadding,
      ),
      decoration: BoxDecoration(
        color: AppColors.profileStatCardBackground,
        border: Border.all(color: AppColors.profileStatCardBorder),
        borderRadius: BorderRadius.circular(AppDimensions.dsRadiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  reservation.guestName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: AppDimensions.dashboardReservationTitleFontSize,
                    color: AppColors.agroForest950,
                  ),
                ),
              ),
              StatusBadge(
                label: reservation.status.label,
                backgroundColor: AppColors.white,
                textColor: reservation.status.pillTextColor,
                horizontalPadding: AppDimensions.dsStatusPillHorizontalPadding,
                verticalPadding: AppDimensions.dsStatusPillVerticalPadding,
                fontSize: AppDimensions.dsStatusPillFontSize,
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.dashboardReservationCardGap),
          Text(
            '${formatDateRange(reservation.startDate, reservation.endDate)} · '
            '${_guestCountLabel(reservation.guestCount)}',
            style: const TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: AppDimensions.dashboardReservationMetaFontSize,
              color: AppColors.profileSecondaryText,
            ),
          ),
          const SizedBox(height: AppDimensions.dashboardReservationCardGap),
          Text(
            reservation.listingName,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: AppDimensions.dashboardReservationListingFontSize,
              color: AppColors.agroInk500,
            ),
          ),
          const SizedBox(height: AppDimensions.dashboardReservationCardGap),
          actions,
        ],
      ),
    );
  }
}

class _PendingActions extends StatelessWidget {
  const _PendingActions({required this.onAccept, required this.onReject});

  final VoidCallback onAccept;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _DashboardActionButton(
            label: AppStrings.acceptReservationButton,
            filled: true,
            onTap: onAccept,
          ),
        ),
        const SizedBox(width: AppDimensions.dashboardActionButtonGap),
        Expanded(
          child: _DashboardActionButton(
            label: AppStrings.rejectReservationButton,
            filled: false,
            onTap: onReject,
          ),
        ),
      ],
    );
  }
}

class _RateGuestAction extends StatelessWidget {
  const _RateGuestAction({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: _DashboardActionButton(
        label: AppStrings.rateGuestButton,
        filled: true,
        onTap: onTap,
      ),
    );
  }
}

class _DashboardActionButton extends StatelessWidget {
  const _DashboardActionButton({
    required this.label,
    required this.filled,
    required this.onTap,
  });

  final String label;
  final bool filled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: AppDimensions.dashboardActionButtonVerticalPadding,
        ),
        decoration: BoxDecoration(
          color: filled ? AppColors.agroForest950 : AppColors.white,
          border: filled
              ? null
              : Border.all(color: AppColors.profileStatCardBorder),
          borderRadius: BorderRadius.circular(
            AppDimensions.dashboardActionButtonRadius,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: AppDimensions.dashboardActionButtonFontSize,
            color: filled ? AppColors.white : AppColors.agroForest950,
          ),
        ),
      ),
    );
  }
}

String _guestCountLabel(int count) {
  final suffix = count == 1
      ? AppStrings.reservationGuestSingular
      : AppStrings.reservationGuestsPlural;
  return '$count $suffix';
}
