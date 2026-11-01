import 'package:flutter/material.dart';
import 'package:bulka_frontend/core/constants/app_colors.dart';
import 'package:bulka_frontend/core/constants/app_dimensions.dart';
import 'package:bulka_frontend/core/constants/app_strings.dart';
import 'package:bulka_frontend/screens/provider_dashboard_screen/provider_dashboard_screen.dart';
import 'package:bulka_frontend/widgets/app_bottom_nav.dart';
import 'package:bulka_frontend/widgets/primary_button.dart';
import 'package:bulka_frontend/widgets/screen_header.dart';

/// Reached only via `pushReplacement` from `RateGuestScreen` after a
/// successful submit, so the rating form is already gone from the
/// Navigator stack — Back can't return to it and trigger a resubmit.
/// "Оди на контролна табла" then clears the stack entirely down to a
/// fresh `ProviderDashboardScreen`, same pattern as
/// `CreateOfferSuccessScreen`.
class RatingSavedScreen extends StatelessWidget {
  const RatingSavedScreen({super.key});

  void _goToDashboard(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const ProviderDashboardScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.beigeBackground,
      bottomNavigationBar: const ProviderBottomNav(selectedIndex: 0),
      body: Column(
        children: [
          ScreenHeader(
            title: AppStrings.ratingSavedTitle,
            titleFontSize: AppDimensions.dsCompactHeaderTitleFontSize,
            bottomPadding: AppDimensions.dsCompactHeaderBottomPadding,
            contentGap: AppDimensions.dsCompactHeaderGap,
            onBackPressed: () => _goToDashboard(context),
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
                            AppStrings.ratingSavedHeading,
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
                        label: AppStrings.offerPublishedGoToDashboardButton,
                        backgroundColor: AppColors.agroGreen600,
                        onPressed: () => _goToDashboard(context),
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
