import 'package:flutter/material.dart';
import 'package:bulka_frontend/core/routing/app_routes.dart';
import 'package:go_router/go_router.dart';
import 'package:bulka_frontend/core/constants/app_colors.dart';
import 'package:bulka_frontend/core/constants/app_dimensions.dart';
import 'package:bulka_frontend/core/constants/app_strings.dart';
import 'package:bulka_frontend/core/utils/date_range_format.dart';
import 'package:bulka_frontend/models/reservation.dart';
import 'package:bulka_frontend/services/guest_rating_controller.dart';
import 'package:bulka_frontend/widgets/primary_button.dart';
import 'package:bulka_frontend/widgets/screen_header.dart';

/// Rates the guest of one specific completed [reservation]. Only ever
/// reached for a `completed`, not-yet-rated reservation — the Dashboard
/// checks `GuestRatingController.hasRating` before navigating here at
/// all, and `GuestRatingController.submitRating` re-validates both the
/// `completed` status and the no-duplicate rule regardless, so this
/// screen never needs to reimplement either check itself.
class RateGuestScreen extends StatefulWidget {
  const RateGuestScreen({super.key, required this.reservation});

  final Reservation reservation;

  @override
  State<RateGuestScreen> createState() => _RateGuestScreenState();
}

class _RateGuestScreenState extends State<RateGuestScreen> {
  final TextEditingController _noteController = TextEditingController();
  int _rating = 0;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  bool get _isValid => _rating >= 1 && _rating <= 5;

  void _handleSubmit() {
    if (!_isValid) return;
    GuestRatingController.instance.submitRating(
      reservation: widget.reservation,
      rating: _rating,
      note: _noteController.text,
    );
    context.pushReplacement(AppRoutes.ratingSaved);
  }

  @override
  Widget build(BuildContext context) {
    final reservation = widget.reservation;
    final contextLine =
        '${reservation.listingName} · '
        '${formatDateRange(reservation.startDate, reservation.endDate)} '
        '${reservation.startDate.year}';

    return Scaffold(
      backgroundColor: AppColors.beigeBackground,
      body: Column(
        children: [
          ScreenHeader(
            title: AppStrings.rateGuestTitle,
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
                Container(
                  width: AppDimensions.calendarListingThumbSize,
                  height: AppDimensions.calendarListingThumbSize,
                  decoration: const BoxDecoration(
                    color: AppColors.agroGreen100,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    _initialsFor(reservation.guestName),
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: AppDimensions.rateGuestAvatarInitialsFontSize,
                      color: AppColors.agroForest950,
                    ),
                  ),
                ),
                const SizedBox(width: AppDimensions.calendarListingContextGap),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        reservation.guestName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: AppDimensions.profileNameFontSize,
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
                      AppStrings.rateGuestQuestion,
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
                    _NoteField(controller: _noteController),
                    const SizedBox(height: AppDimensions.wizardContentGap),
                    Text(
                      AppStrings.rateGuestHelperText,
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
              label: AppStrings.submitRatingButton,
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

class _NoteField extends StatelessWidget {
  const _NoteField({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          AppStrings.rateGuestNoteLabel,
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
            minLines: 2,
            maxLines: null,
            style: const TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: AppDimensions.dsInputFontSize,
              color: AppColors.agroForest950,
            ),
            decoration: InputDecoration(
              hintText: AppStrings.rateGuestNotePlaceholder,
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

String _initialsFor(String name) {
  final parts = name
      .trim()
      .split(RegExp(r'\s+'))
      .where((p) => p.isNotEmpty)
      .toList();
  if (parts.isEmpty) return '';
  final first = parts.first.characters.first;
  final second = parts.length > 1 ? parts[1].characters.first : '';
  return (first + second).toUpperCase();
}
