import 'package:flutter/material.dart';
import 'package:bulka_frontend/blocs/auth/auth_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bulka_frontend/core/routing/app_routes.dart';
import 'package:go_router/go_router.dart';
import 'package:bulka_frontend/core/constants/app_colors.dart';
import 'package:bulka_frontend/core/constants/app_dimensions.dart';
import 'package:bulka_frontend/core/constants/app_strings.dart';
import 'package:bulka_frontend/models/registration_profile.dart';
import 'package:bulka_frontend/widgets/app_checkbox.dart';
import 'package:bulka_frontend/widgets/form_error_text.dart';
import 'package:bulka_frontend/widgets/primary_button.dart';
import 'package:bulka_frontend/widgets/screen_header.dart';

/// Last step before the account is created: once all consents are given,
/// submitting registers the account and moves on to Email Verification.
class TermsPrivacyScreen extends StatefulWidget {
  const TermsPrivacyScreen({
    super.key,
    required this.profile,
    required this.password,
  });

  final RegistrationProfile profile;

  /// Passed separately (not part of [RegistrationProfile]) so it isn't
  /// carried through the rest of the sign-up flow.
  final String password;

  @override
  State<TermsPrivacyScreen> createState() => _TermsPrivacyScreenState();
}

class _TermsPrivacyScreenState extends State<TermsPrivacyScreen> {
  bool _agreedToTerms = false;
  bool _agreedToPrivacy = false;
  bool _agreedToResponsibilities = false;

  /// A function, not the text itself, so a message on screen follows a
  /// language switch.
  String Function()? _errorMessage;

  bool get _allAgreed =>
      _agreedToTerms && _agreedToPrivacy && _agreedToResponsibilities;

  void _handleSubmit() {
    final profile = widget.profile;
    setState(() => _errorMessage = null);
    context.read<AuthBloc>().add(
      AuthRegistrationRequested(
        role: profile.role,
        firstName: profile.firstName,
        lastName: profile.lastName,
        email: profile.email,
        phone: profile.phone,
        password: widget.password,
      ),
    );
  }

  void _handleAuthResult(BuildContext context, AuthState state) {
    if (state.status == AuthOperationStatus.succeeded) {
      if (state.emailVerificationRequired) {
        context.push(AppRoutes.registerVerify, extra: widget.profile);
      } else {
        // Account is already active: registration doesn't sign in, so the
        // user logs in with their new credentials.
        context.go(AppRoutes.login);
      }
    } else if (state.status == AuthOperationStatus.failed) {
      final error = state.error!;
      setState(() => _errorMessage = () => error.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Disabled while the request runs, so it can't be sent twice.
    final isSubmitting = context.select(
      (AuthBloc bloc) => bloc.state.isInProgress(AuthOperation.register),
    );
    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (previous, current) =>
          current.operation == AuthOperation.register &&
          current.status != previous.status,
      listener: _handleAuthResult,
      child: _buildScreen(context, canSubmit: !isSubmitting && _allAgreed),
    );
  }

  Widget _buildScreen(BuildContext context, {required bool canSubmit}) {
    return Scaffold(
      backgroundColor: AppColors.beigeBackground,
      body: Column(
        children: [
          ScreenHeader(
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
                    if (_errorMessage != null) ...[
                      FormErrorText(_errorMessage!()),
                      const SizedBox(height: AppDimensions.dsBodyGap),
                    ],
                    PrimaryButton(
                      label: AppStrings.termsPrivacySubmitButton,
                      onPressed: canSubmit ? _handleSubmit : null,
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
            Text(
              AppStrings.termsPrivacyTermsHeading,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: AppDimensions.termsPrivacyCardHeadingFontSize,
                color: AppColors.agroForest950,
              ),
            ),
            const SizedBox(height: AppDimensions.termsPrivacyCardGap),
            Text(
              AppStrings.termsPrivacyTermsBody,
              style: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: AppDimensions.termsPrivacyCardBodyFontSize,
                color: AppColors.agroInk500,
              ),
            ),
            const SizedBox(height: AppDimensions.termsPrivacyCardGap),
            Text(
              AppStrings.termsPrivacyPolicyHeading,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: AppDimensions.termsPrivacyCardHeadingFontSize,
                color: AppColors.agroForest950,
              ),
            ),
            const SizedBox(height: AppDimensions.termsPrivacyCardGap),
            Text(
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
