import 'package:flutter/material.dart';
import 'package:bulka_frontend/core/constants/app_colors.dart';
import 'package:bulka_frontend/core/constants/app_dimensions.dart';
import 'package:bulka_frontend/core/constants/app_strings.dart';
import 'package:bulka_frontend/core/network/api_exception.dart';
import 'package:bulka_frontend/models/registration_profile.dart';
import 'package:bulka_frontend/models/user_role.dart';
import 'package:bulka_frontend/screens/email_verification_screen/email_verification_screen.dart';
import 'package:bulka_frontend/services/auth_repository.dart';
import 'package:bulka_frontend/widgets/app_checkbox.dart';
import 'package:bulka_frontend/widgets/primary_button.dart';
import 'package:bulka_frontend/widgets/screen_header.dart';

class TermsPrivacyScreen extends StatefulWidget {
  const TermsPrivacyScreen({super.key, required this.profile});

  final RegistrationProfile profile;

  @override
  State<TermsPrivacyScreen> createState() => _TermsPrivacyScreenState();
}

class _TermsPrivacyScreenState extends State<TermsPrivacyScreen> {
  final AuthRepository _authRepository = AuthRepository();

  bool _agreedToTerms = false;
  bool _agreedToPrivacy = false;
  bool _agreedToResponsibilities = false;

  bool _isSubmitting = false;
  String? _errorMessage;

  bool get _canSubmit =>
      !_isSubmitting &&
      _agreedToTerms &&
      _agreedToPrivacy &&
      _agreedToResponsibilities;

  /// This is the first point in the flow where terms/privacy consent
  /// actually exists, so it's where the real `/api/auth/register/*` call
  /// belongs — not on `RegisterScreen`, which only collects identity data.
  Future<void> _handleSubmit() async {
    if (!_canSubmit) return;

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      final profile = widget.profile;

      // Both endpoints' responses are now confirmed live:
      // - Buyer: `{ userId, status: "PendingVerification",
      //   emailVerificationRequired: true }`
      // - Provider: `{ userId, providerProfileId,
      //   userStatus: "PendingVerification", providerProfileStatus: "Draft",
      //   emailVerificationRequired: true }`
      // Both mean exactly "go verify your email next", matching the
      // navigation below — see RegisterResult/ProviderRegisterResult if a
      // different status is ever observed.
      if (profile.role == UserRole.owner) {
        await _authRepository.registerProvider(
          email: profile.email,
          password: profile.password,
          firstName: profile.firstName,
          lastName: profile.lastName,
          displayName: profile.displayName,
          businessName: profile.businessName ?? '',
          acceptedTerms: _agreedToTerms,
          acceptedPrivacy: _agreedToPrivacy,
        );
      } else {
        await _authRepository.registerBuyer(
          email: profile.email,
          password: profile.password,
          firstName: profile.firstName,
          lastName: profile.lastName,
          displayName: profile.displayName,
          acceptedTerms: _agreedToTerms,
          acceptedPrivacy: _agreedToPrivacy,
        );
      }

      if (!mounted) return;
      setState(() => _isSubmitting = false);

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => EmailVerificationScreen(profile: widget.profile),
        ),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _errorMessage = e.message;
      });
    }
  }

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
                    if (_errorMessage != null) ...[
                      const SizedBox(
                        height: AppDimensions.termsPrivacyBodyGap,
                      ),
                      Text(
                        _errorMessage!,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: AppDimensions.dsFooterFontSize,
                          color: AppColors.settingsDangerColor,
                        ),
                      ),
                    ],
                    const SizedBox(
                      height: AppDimensions.termsPrivacyBottomSpacerHeight,
                    ),
                    if (_isSubmitting) ...[
                      const Center(child: CircularProgressIndicator()),
                      const SizedBox(height: AppDimensions.dsBodyGap),
                    ],
                    PrimaryButton(
                      label: AppStrings.termsPrivacySubmitButton,
                      onPressed: _canSubmit ? _handleSubmit : null,
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
              fontSize: AppDimensions.dsCheckboxLabelFontSize,
              color: AppColors.agroForest950,
            ),
          ),
        ),
      ],
    );
  }
}
