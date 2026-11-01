import 'package:flutter/material.dart';
import 'package:bulka_frontend/core/constants/app_colors.dart';
import 'package:bulka_frontend/core/constants/app_dimensions.dart';
import 'package:bulka_frontend/core/constants/app_strings.dart';
import 'package:bulka_frontend/screens/provider_dashboard_screen/provider_dashboard_screen.dart';
import 'package:bulka_frontend/screens/provider_offers_screen/provider_offers_screen.dart';
import 'package:bulka_frontend/widgets/app_bottom_nav.dart';
import 'package:bulka_frontend/widgets/primary_button.dart';
import 'package:bulka_frontend/widgets/screen_header.dart';
import 'package:bulka_frontend/widgets/secondary_button.dart';

/// Reached only via `pushReplacement` from the wizard (see
/// `CreateOfferWizardScreen._handlePublish`), so the wizard's 7 steps are
/// already gone from the Navigator stack by the time this shows. Its own
/// actions then clear the stack further, down to just the chosen
/// destination — no leftover chain of wizard/entry screens underneath.
class CreateOfferSuccessScreen extends StatelessWidget {
  const CreateOfferSuccessScreen({super.key});

  void _goToOffers(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const ProviderOffersScreen()),
      (route) => false,
    );
  }

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
            title: AppStrings.offerPublishedTitle,
            titleFontSize: AppDimensions.dsCompactHeaderTitleFontSize,
            bottomPadding: AppDimensions.dsCompactHeaderBottomPadding,
            contentGap: AppDimensions.dsCompactHeaderGap,
            // No draft left to lose by now — same destination as the
            // primary "go to dashboard" action below is a reasonable
            // default for this affordance.
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
                        top: AppDimensions.successTopPadding,
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
                            AppStrings.offerPublishedHeading,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: AppDimensions.successHeadingFontSize,
                              color: AppColors.agroForest950,
                            ),
                          ),
                          const SizedBox(height: AppDimensions.successBlockGap),
                          Text(
                            AppStrings.offerPublishedSubtitle,
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
                    Padding(
                      padding: const EdgeInsets.only(
                        left: AppDimensions.dsBodyHorizontalPadding,
                        right: AppDimensions.dsBodyHorizontalPadding,
                        top: AppDimensions.successActionsTopPadding,
                        bottom: AppDimensions.successActionsBottomPadding,
                      ),
                      child: Column(
                        children: [
                          PrimaryButton(
                            label: AppStrings.offerPublishedViewOffersButton,
                            backgroundColor: AppColors.agroGreen600,
                            onPressed: () => _goToOffers(context),
                          ),
                          const SizedBox(
                            height: AppDimensions.successActionsGap,
                          ),
                          SecondaryButton(
                            label: AppStrings.offerPublishedGoToDashboardButton,
                            onPressed: () => _goToDashboard(context),
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
