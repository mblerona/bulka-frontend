import 'package:flutter/material.dart';
import 'package:bulka_frontend/core/constants/app_colors.dart';
import 'package:bulka_frontend/core/constants/app_dimensions.dart';
import 'package:bulka_frontend/core/constants/app_strings.dart';
import 'package:bulka_frontend/widgets/labeled_text_field.dart';
import 'package:bulka_frontend/widgets/primary_button.dart';
import 'package:bulka_frontend/widgets/screen_header.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.beigeBackground,
      body: Column(
        children: [
          ScreenHeader(
            title: AppStrings.forgotPasswordTitle,
            titleFontSize: AppDimensions.dsCompactHeaderTitleFontSize,
            bottomPadding: AppDimensions.dsCompactHeaderBottomPadding,
            contentGap: AppDimensions.dsCompactHeaderGap,
          ),
          Expanded(
            child: SafeArea(
              top: false,
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(
                  left: AppDimensions.dsBodyHorizontalPadding,
                  right: AppDimensions.dsBodyHorizontalPadding,
                  top: AppDimensions.dsBodyTopPadding,
                  bottom: AppDimensions.forgotPasswordBodyBottomPadding,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: AppDimensions.forgotPasswordIconWrapSize,
                      height: AppDimensions.forgotPasswordIconWrapSize,
                      decoration: const BoxDecoration(
                        color: AppColors.agroGreen100,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.key,
                        color: AppColors.agroForest950,
                        size: AppDimensions.forgotPasswordIconSize,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.forgotPasswordBodyGap),
                    Text(
                      AppStrings.forgotPasswordHeading,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: AppDimensions.forgotPasswordHeadingFontSize,
                        color: AppColors.agroForest950,
                      ),
                    ),
                    const SizedBox(
                      height: AppDimensions.forgotPasswordHeadingGap,
                    ),
                    Text(
                      AppStrings.forgotPasswordSubheading,
                      style: const TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: AppDimensions.dsSubheadingFontSize,
                        color: AppColors.agroInk500,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.forgotPasswordBodyGap),
                    LabeledTextField(
                      label: AppStrings.emailLabel,
                      hintText: AppStrings.emailPlaceholder,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: AppDimensions.forgotPasswordBodyGap),
                    PrimaryButton(
                      label: AppStrings.forgotPasswordSubmitButton,
                      onPressed: () {
                        // TODO: wire up the password-reset code request.
                      },
                    ),
                    const SizedBox(
                      height: AppDimensions.forgotPasswordBodyGap * 4,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          AppStrings.forgotPasswordFooterPrompt,
                          style: const TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: AppDimensions.dsFooterFontSize,
                            color: AppColors.agroInk500,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.maybePop(context),
                          child: Text(
                            AppStrings.backToLoginAction,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: AppDimensions.dsFooterFontSize,
                              color: AppColors.agroGreen700,
                            ),
                          ),
                        ),
                      ],
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
