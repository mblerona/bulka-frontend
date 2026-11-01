import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:bulka_frontend/core/constants/app_colors.dart';
import 'package:bulka_frontend/core/constants/app_dimensions.dart';
import 'package:bulka_frontend/core/constants/app_strings.dart';
import 'package:bulka_frontend/core/routing/app_routes.dart';
import 'package:bulka_frontend/widgets/primary_button.dart';

/// Shown for an unknown route, or a route whose listing/reservation id
/// doesn't exist (e.g. an old link).
class RouteNotFoundScreen extends StatelessWidget {
  const RouteNotFoundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.beigeBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.dsBodyPadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.search_off,
                size: AppDimensions.emailVerificationIconSize,
                color: AppColors.agroInk500,
              ),
              const SizedBox(height: AppDimensions.dsBodyGap),
              Text(
                AppStrings.routeNotFoundTitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: AppDimensions.emailVerificationTitleFontSize,
                  color: AppColors.agroForest950,
                ),
              ),
              const SizedBox(height: AppDimensions.dsBodyGap),
              Text(
                AppStrings.routeNotFoundMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: AppDimensions.dsSubheadingFontSize,
                  color: AppColors.agroInk500,
                ),
              ),
              const SizedBox(height: AppDimensions.dsBodyGap * 2),
              PrimaryButton(
                label: AppStrings.routeNotFoundButton,
                onPressed: () => context.go(AppRoutes.splash),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
