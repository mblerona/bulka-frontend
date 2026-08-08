import 'package:flutter/material.dart';
import 'package:bulka_frontend/core/constants/app_colors.dart';
import 'package:bulka_frontend/core/constants/app_dimensions.dart';
import 'package:bulka_frontend/core/constants/app_strings.dart';
import 'package:bulka_frontend/models/tourist_profile.dart';
import 'package:bulka_frontend/screens/profile_screen/profile_screen.dart';
import 'package:bulka_frontend/screens/register_screen/register_screen.dart';
import 'package:bulka_frontend/widgets/gold_badge.dart';
import 'package:bulka_frontend/widgets/secondary_button.dart';

class EmailVerificationScreen extends StatelessWidget {
  const EmailVerificationScreen({
    super.key,
    this.profile = const TouristProfile(
      fullName: 'Јован Јовановски',
      email: AppStrings.emailVerificationExampleEmail,
      phone: '070 123 456',
    ),
  });

  final TouristProfile profile;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.beigeBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.splashHorizontalPadding,
          ),
          child: Column(
            children: [
              Flexible(
                flex: AppDimensions.emailVerificationTopSpacerFlex.round(),
                child: const SizedBox(
                  height: AppDimensions.emailVerificationTopSpacerFlex,
                ),
              ),
              Container(
                width: AppDimensions.emailVerificationIconWrapSize,
                height: AppDimensions.emailVerificationIconWrapSize,
                decoration: const BoxDecoration(
                  color: AppColors.agroGreen100,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.mail_outline,
                  size: AppDimensions.emailVerificationIconSize,
                  color: AppColors.agroForest950,
                ),
              ),
              const SizedBox(height: AppDimensions.emailVerificationGap),
              const Text(
                AppStrings.emailVerificationTitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: AppDimensions.emailVerificationTitleFontSize,
                  color: AppColors.agroForest950,
                ),
              ),
              const SizedBox(height: AppDimensions.emailVerificationGap),
              const Text(
                AppStrings.emailVerificationSentTo,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: AppDimensions.dsSubheadingFontSize,
                  color: AppColors.agroInk500,
                ),
              ),
              const SizedBox(height: AppDimensions.emailVerificationGap),
              Text(
                profile.email,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: AppDimensions.emailVerificationEmailFontSize,
                  color: AppColors.agroGreen700,
                ),
              ),
              const SizedBox(height: AppDimensions.emailVerificationGap),
              const Text(
                AppStrings.emailVerificationInstructions,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: AppDimensions.dsSubheadingFontSize,
                  color: AppColors.agroInk500,
                ),
              ),
              const SizedBox(height: AppDimensions.emailVerificationGap),
              const GoldBadge(label: AppStrings.emailVerificationBadge),
              const SizedBox(
                height: AppDimensions.emailVerificationSpacerHeight,
              ),
              SecondaryButton(
                label: AppStrings.emailVerificationResendButton,
                onPressed: () {
                  // TODO: wire up resending the verification email.
                },
              ),
              const SizedBox(height: AppDimensions.emailVerificationGap),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const RegisterScreen()),
                  );
                },
                child: const Text(
                  AppStrings.emailVerificationChangeEmail,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: AppDimensions.emailVerificationChangeEmailFontSize,
                    color: AppColors.agroInk500,
                  ),
                ),
              ),
              const SizedBox(height: AppDimensions.emailVerificationGap),
              // TEMPORARY: stands in for automatic navigation once the
              // backend confirms email verification. Remove once that check
              // exists and can drive this navigation automatically.
              OutlinedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ProfileScreen(profile: profile),
                    ),
                  );
                },
                child: const Text('Продолжи (привремено)'),
              ),
              Flexible(
                flex: AppDimensions.emailVerificationBottomSpacerFlex.round(),
                child: const SizedBox(
                  height: AppDimensions.emailVerificationBottomSpacerFlex,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
