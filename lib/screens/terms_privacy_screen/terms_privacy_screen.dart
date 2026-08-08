import 'package:flutter/material.dart';
import 'package:bulka_frontend/core/constants/app_colors.dart';
import 'package:bulka_frontend/core/constants/app_dimensions.dart';
import 'package:bulka_frontend/core/constants/app_strings.dart';
import 'package:bulka_frontend/screens/email_verification_screen/email_verification_screen.dart';
import 'package:bulka_frontend/widgets/app_checkbox.dart';
import 'package:bulka_frontend/widgets/primary_button.dart';
import 'package:bulka_frontend/widgets/screen_header.dart';

class TermsPrivacyScreen extends StatefulWidget {
  const TermsPrivacyScreen({super.key});

  @override
  State<TermsPrivacyScreen> createState() => _TermsPrivacyScreenState();
}

class _TermsPrivacyScreenState extends State<TermsPrivacyScreen> {
  bool _agreedToTerms = false;
  bool _agreedToPrivacy = false;
  bool _agreedToResponsibilities = false;

  bool get _canSubmit =>
      _agreedToTerms && _agreedToPrivacy && _agreedToResponsibilities;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.beigeBackground,
      body: Column(
        children: [
          const ScreenHeader(
            title: AppStrings.termsPrivacyTitle,
            titleFontSize: AppDimensions.termsPrivacyTitleFontSize,
            bottomPadding: AppDimensions.dsCompactHeaderBottomPadding,
            contentGap: AppDimensions.dsCompactHeaderGap,
            subtitle: AppStrings.termsPrivacySubtitle,
          ),
          Expanded(
            child: SafeArea(
              top: false,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppDimensions.dsBodyPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _LegalTextCard(),
                    const SizedBox(height: AppDimensions.termsPrivacyBodyGap),
                    _ConsentRow(
                      text: AppStrings.termsPrivacyConsentTerms,
                      value: _agreedToTerms,
                      onChanged: (value) {
                        setState(() => _agreedToTerms = value);
                      },
                    ),
                    const SizedBox(height: AppDimensions.termsPrivacyBodyGap),
                    _ConsentRow(
                      text: AppStrings.termsPrivacyConsentPrivacy,
                      value: _agreedToPrivacy,
                      onChanged: (value) {
                        setState(() => _agreedToPrivacy = value);
                      },
                    ),
                    const SizedBox(height: AppDimensions.termsPrivacyBodyGap),
                    _ConsentRow(
                      text: AppStrings.termsPrivacyConsentResponsibilities,
                      value: _agreedToResponsibilities,
                      onChanged: (value) {
                        setState(() => _agreedToResponsibilities = value);
                      },
                    ),
                    const SizedBox(
                      height: AppDimensions.termsPrivacyBottomSpacerHeight,
                    ),
                    PrimaryButton(
                      label: AppStrings.termsPrivacySubmitButton,
                      onPressed: _canSubmit
                          ? () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) =>
                                      const EmailVerificationScreen(),
                                ),
                              );
                            }
                          : null,
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

class _LegalTextCard extends StatelessWidget {
  const _LegalTextCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: AppDimensions.termsPrivacyCardHeight,
      padding: const EdgeInsets.all(AppDimensions.termsPrivacyCardPadding),
      decoration: BoxDecoration(
        color: AppColors.agroCream100,
        border: Border.all(color: AppColors.agroBorder300),
        borderRadius: BorderRadius.circular(AppDimensions.dsRadiusLg),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              AppStrings.termsPrivacyTermsHeading,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: AppDimensions.termsPrivacyCardHeadingFontSize,
                color: AppColors.agroForest950,
              ),
            ),
            const SizedBox(height: AppDimensions.termsPrivacyCardGap),
            const Text(
              AppStrings.termsPrivacyTermsBody,
              style: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: AppDimensions.termsPrivacyCardBodyFontSize,
                color: AppColors.agroInk500,
              ),
            ),
            const SizedBox(height: AppDimensions.termsPrivacyCardGap),
            const Text(
              AppStrings.termsPrivacyPolicyHeading,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: AppDimensions.termsPrivacyCardHeadingFontSize,
                color: AppColors.agroForest950,
              ),
            ),
            const SizedBox(height: AppDimensions.termsPrivacyCardGap),
            const Text(
              AppStrings.termsPrivacyPolicyBody,
              style: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: AppDimensions.termsPrivacyCardBodyFontSize,
                color: AppColors.agroInk500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConsentRow extends StatelessWidget {
  const _ConsentRow({
    required this.text,
    required this.value,
    required this.onChanged,
  });

  final String text;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppCheckbox(value: value, onChanged: onChanged),
        const SizedBox(width: AppDimensions.dsCheckboxTextGap),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: AppDimensions.termsPrivacyConsentFontSize,
              color: AppColors.agroForest950,
            ),
          ),
        ),
      ],
    );
  }
}
