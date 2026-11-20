import 'package:flutter/material.dart';
import 'package:bulka_frontend/blocs/auth/auth_bloc.dart';
import 'package:bulka_frontend/blocs/listing_reviews/listing_reviews_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bulka_frontend/core/routing/app_routes.dart';
import 'package:go_router/go_router.dart';
import 'package:bulka_frontend/core/constants/app_colors.dart';
import 'package:bulka_frontend/core/constants/app_dimensions.dart';
import 'package:bulka_frontend/core/constants/app_strings.dart';
import 'package:bulka_frontend/core/utils/date_range_format.dart';
import 'package:bulka_frontend/models/provider_listing.dart';
import 'package:bulka_frontend/models/reservation.dart';
import 'package:bulka_frontend/widgets/primary_button.dart';
import 'package:bulka_frontend/widgets/screen_header.dart';
import 'package:bulka_frontend/widgets/xfile_image.dart';

/// The Figma "27 – Buyer · Остави рецензија" frame — reviews one specific
/// completed [reservation]/[listing] pair, both passed in directly by the
/// caller (`TouristMyReservationsScreen`, which already resolved them by
/// `listingId`) rather than looked up here. Structurally this is the exact
/// mirror image of `RateGuestScreen` (a completed reservation, a 5-star
/// selector, an optional text field, one footer button) and reuses that
/// screen's own tokens almost entirely — see the AppDimensions section
/// this screen's own values live under.
///
/// `ListingReviewsBloc` independently re-validates both
/// eligibility (`status == completed`) and the no-duplicate-review rule
/// regardless of what the caller already checked, so this screen never
/// needs to reimplement either.
class LeaveReviewScreen extends StatefulWidget {
  const LeaveReviewScreen({
    super.key,
    required this.reservation,
    required this.listing,
  });

  final Reservation reservation;
  final ProviderListing listing;

  @override
  State<LeaveReviewScreen> createState() => _LeaveReviewScreenState();
}

class _LeaveReviewScreenState extends State<LeaveReviewScreen> {
  final TextEditingController _reviewController = TextEditingController();
  int _rating = 0;

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  bool get _isValid => _rating >= 1 && _rating <= 5;

  void _handleSubmit() {
    if (!_isValid) return;
    context.read<ListingReviewsBloc>().add(
      ListingReviewSubmitted(
        listing: widget.listing,
        reservation: widget.reservation,
        // The signed-in Tourist; the name the booking was made under if
        // the session is gone.
        authorName:
            context.read<AuthBloc>().state.user?.fullName ??
            widget.reservation.guestName,
        rating: _rating,
        comment: _reviewController.text,
      ),
    );
    context.pushReplacement(AppRoutes.reviewSubmitted);
  }

  @override
  Widget build(BuildContext context) {
    final listing = widget.listing;
    final reservation = widget.reservation;
    final contextLine =
        '${listing.location} · '
        '${formatDateRangeShortWithYear(reservation.startDate, reservation.endDate)}';

    return Scaffold(
      backgroundColor: AppColors.beigeBackground,
      body: Column(
        children: [
          ScreenHeader(
            title: AppStrings.leaveReviewButton,
            titleFontSize: AppDimensions.dsCompactHeaderTitleFontSize,
            bottomPadding: AppDimensions.dsCompactHeaderBottomPadding,
            contentGap: AppDimensions.dsCompactHeaderGap,
          ),
          Padding(
            padding: const EdgeInsets.only(
              left: AppDimensions.dsBodyHorizontalPadding,
              right: AppDimensions.dsBodyHorizontalPadding,
              top: AppDimensions.calendarListingContextTopPadding,
              bottom: AppDimensions.calendarListingContextBottomPadding,
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppDimensions.dsRadiusMd),
                  child: listing.photoPaths.isEmpty
                      ? Container(
                          width: AppDimensions.leaveReviewThumbSize,
                          height: AppDimensions.leaveReviewThumbSize,
                          color: AppColors.agroGold100,
                        )
                      : XFileImage(
                          path: listing.photoPaths.first,
                          width: AppDimensions.leaveReviewThumbSize,
                          height: AppDimensions.leaveReviewThumbSize,
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
                          fontSize:
                              AppDimensions.leaveReviewListingTitleFontSize,
                          color: AppColors.agroForest950,
                        ),
                      ),
                      const SizedBox(
                        height: AppDimensions.calendarListingNameColGap,
                      ),
                      Text(
                        contextLine,
                        style: const TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize:
                              AppDimensions.calendarListingLocationFontSize,
                          color: AppColors.profileSecondaryText,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SafeArea(
              top: false,
              bottom: false,
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(
                  left: AppDimensions.dsBodyHorizontalPadding,
                  right: AppDimensions.dsBodyHorizontalPadding,
                  top: AppDimensions.wizardContentTopPadding,
                  bottom: AppDimensions.wizardContentBottomPadding,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.leaveReviewQuestion,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: AppDimensions.successHeadingFontSize,
                        color: AppColors.agroForest950,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.wizardContentGap),
                    _StarRow(
                      rating: _rating,
                      onChanged: (value) => setState(() => _rating = value),
                    ),
                    const SizedBox(height: AppDimensions.wizardContentGap),
                    _ReviewTextField(controller: _reviewController),
                    const SizedBox(height: AppDimensions.wizardContentGap),
                    Text(
                      AppStrings.leaveReviewDisclaimer,
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: AppDimensions.rateGuestHelperTextFontSize,
                        color: AppColors.profileSecondaryText,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(
              left: AppDimensions.dsBodyHorizontalPadding,
              right: AppDimensions.dsBodyHorizontalPadding,
              top: AppDimensions.wizardFooterTopPadding,
              bottom: AppDimensions.wizardFooterBottomPadding,
            ),
            decoration: const BoxDecoration(
              color: AppColors.white,
              border: Border(top: BorderSide(color: AppColors.agroBorder300)),
            ),
            child: PrimaryButton(
              label: AppStrings.submitReviewButton,
              backgroundColor: AppColors.agroGreen600,
              onPressed: _isValid ? _handleSubmit : null,
            ),
          ),
        ],
      ),
    );
  }
}

class _StarRow extends StatelessWidget {
  const _StarRow({required this.rating, required this.onChanged});

  final int rating;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 1; i <= 5; i++) ...[
          GestureDetector(
            onTap: () => onChanged(i),
            child: Text(
              '★',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: AppDimensions.rateGuestStarFontSize,
                color: i <= rating
                    ? AppColors.agroGold100
                    : AppColors.agroBorder300,
              ),
            ),
          ),
          if (i != 5) const SizedBox(width: AppDimensions.rateGuestStarGap),
        ],
      ],
    );
  }
}

class _ReviewTextField extends StatelessWidget {
  const _ReviewTextField({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          AppStrings.leaveReviewTextLabel,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: AppDimensions.dsFieldLabelFontSize,
            color: AppColors.agroForest950,
          ),
        ),
        const SizedBox(height: AppDimensions.dsFieldGap),
        Container(
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
          child: TextField(
            controller: controller,
            minLines: 3,
            maxLines: null,
            style: const TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: AppDimensions.dsInputFontSize,
              color: AppColors.agroForest950,
            ),
            decoration: InputDecoration(
              hintText: AppStrings.leaveReviewTextPlaceholder,
              hintStyle: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: AppDimensions.dsInputFontSize,
                color: AppColors.profileSecondaryText,
              ),
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ),
      ],
    );
  }
}
