import 'package:flutter/material.dart';
import 'package:bulka_frontend/core/routing/app_routes.dart';
import 'package:go_router/go_router.dart';
import 'package:bulka_frontend/core/constants/app_colors.dart';
import 'package:bulka_frontend/core/constants/app_dimensions.dart';
import 'package:bulka_frontend/core/constants/app_strings.dart';
import 'package:bulka_frontend/widgets/primary_button.dart';
import 'package:bulka_frontend/widgets/screen_header.dart';

/// The Figma "Buyer · Рецензијата е испратена" frame — reached only via
/// `pushReplacement` from `LeaveReviewScreen` after a successful submit,
/// so the review form is already gone from the Navigator stack; Back
/// returns to `TouristMyReservationsScreen` (safe, not a resubmit), same
/// pattern as `RatingSavedScreen`/`RateGuestScreen`. "Назад кон
/// резервации" then clears the stack entirely down to a fresh
/// `TouristMyReservationsScreen` on the "Минати" tab.
class ReviewSubmittedScreen extends StatelessWidget {
  const ReviewSubmittedScreen({super.key});

  void _backToReservations(BuildContext context) {
    context.go(AppRoutes.pastReservations);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.beigeBackground,
      body: Column(
        children: [
          ScreenHeader(
            title: AppStrings.reviewSubmittedTitle,
            titleFontSize: AppDimensions.dsCompactHeaderTitleFontSize,
            bottomPadding: AppDimensions.dsCompactHeaderBottomPadding,
            contentGap: AppDimensions.dsCompactHeaderGap,
            onBackPressed: () => _backToReservations(context),
          ),
          Expanded(
            child: SafeArea(
              top: false,
              bottom: false,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                        left: AppDimensions.dsBodyHorizontalPadding,
                        right: AppDimensions.dsBodyHorizontalPadding,
                        top: AppDimensions.ratingSavedTopPadding,
                        bottom: AppDimensions.successBottomPadding,
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: AppDimensions.successCircleSize,
                            height: AppDimensions.successCircleSize,
                            decoration: const BoxDecoration(
                              color: AppColors.agroGreen700,
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: const Text(
                              AppStrings.offerPublishedCheckGlyph,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: AppDimensions.successCheckFontSize,
                                color: AppColors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: AppDimensions.successBlockGap),
                          Text(
                            AppStrings.reviewSubmittedHeading,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: AppDimensions.successHeadingFontSize,
                              color: AppColors.agroForest950,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        left: AppDimensions.dsBodyHorizontalPadding,
                        right: AppDimensions.dsBodyHorizontalPadding,
                        top: AppDimensions.successActionsTopPadding,
                        bottom: AppDimensions.successActionsBottomPadding,
                      ),
                      child: PrimaryButton(
                        label: AppStrings.backToReservationsButton,
                        backgroundColor: AppColors.agroGreen600,
                        onPressed: () => _backToReservations(context),
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
