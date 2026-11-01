import 'package:flutter/material.dart';
import 'package:bulka_frontend/core/routing/app_routes.dart';
import 'package:go_router/go_router.dart';
import 'package:bulka_frontend/core/constants/app_colors.dart';
import 'package:bulka_frontend/core/constants/app_dimensions.dart';
import 'package:bulka_frontend/core/constants/app_strings.dart';
import 'package:bulka_frontend/core/network/api_exception.dart';
import 'package:bulka_frontend/models/registration_profile.dart';
import 'package:bulka_frontend/services/auth_controller.dart';
import 'package:bulka_frontend/widgets/form_error_text.dart';
import 'package:bulka_frontend/widgets/labeled_text_field.dart';
import 'package:bulka_frontend/widgets/primary_button.dart';
import 'package:bulka_frontend/widgets/secondary_button.dart';
import 'package:bulka_frontend/widgets/status_badge.dart';

/// The user types in the code from the verification email. Once the
/// backend confirms it, they go to Login with their email filled in
/// (verifying doesn't sign them in).
class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({
    super.key,
    this.profile = const RegistrationProfile(
      fullName: 'Јован Јовановски',
      email: AppStrings.emailVerificationExampleEmail,
      phone: '070 123 456',
    ),
  });

  final RegistrationProfile profile;

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  final _codeController = TextEditingController();
  bool _isVerifying = false;
  bool _isResending = false;

  /// A function, not the text itself, so a message on screen follows a
  /// language switch.
  String Function()? _errorMessage;

  String get _email => widget.profile.email;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    final code = _codeController.text.trim();
    if (code.isEmpty) {
      setState(
        () => _errorMessage = () => AppStrings.emailVerificationErrorEmptyCode,
      );
      return;
    }

    setState(() {
      _isVerifying = true;
      _errorMessage = null;
    });
    try {
      await AuthController.instance.verifyEmail(email: _email, code: code);
      if (!mounted) return;
      // The app-wide messenger, so the message stays visible on Login.
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text(AppStrings.emailVerificationSuccess)),
        );
      context.go(AppRoutes.loginWithEmail(_email));
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _isVerifying = false;
        _errorMessage = () => e.message;
      });
    }
  }

  Future<void> _resendEmail() async {
    setState(() => _isResending = true);
    String message;
    try {
      await AuthController.instance.resendEmailVerification(_email);
      message = AppStrings.emailVerificationResent;
    } on ApiException catch (e) {
      message = e.message;
    }
    if (!mounted) return;
    setState(() => _isResending = false);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.beigeBackground,
      body: SafeArea(
        // Scrollable so the keyboard can't push the code field and buttons
        // off screen; on tall screens the spacers still center the content.
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.splashHorizontalPadding,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    Flexible(
                      flex: AppDimensions.emailVerificationTopSpacerFlex
                          .round(),
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
                    Text(
                      AppStrings.emailVerificationTitle,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: AppDimensions.emailVerificationTitleFontSize,
                        color: AppColors.agroForest950,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.emailVerificationGap),
                    Text(
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
                      _email,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: AppDimensions.emailVerificationEmailFontSize,
                        color: AppColors.agroGreen700,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.emailVerificationGap),
                    Text(
                      AppStrings.emailVerificationInstructions,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: AppDimensions.dsSubheadingFontSize,
                        color: AppColors.agroInk500,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.emailVerificationGap),
                    StatusBadge(
                      label: AppStrings.emailVerificationBadge,
                      backgroundColor: AppColors.agroGold100,
                      textColor: AppColors.agroForest950,
                    ),
                    const SizedBox(
                      height: AppDimensions.emailVerificationSpacerHeight,
                    ),
                    LabeledTextField(
                      label: AppStrings.emailVerificationCodeLabel,
                      hintText: AppStrings.emailVerificationCodePlaceholder,
                      controller: _codeController,
                    ),
                    const SizedBox(height: AppDimensions.emailVerificationGap),
                    if (_errorMessage != null) ...[
                      Align(
                        alignment: Alignment.centerLeft,
                        child: FormErrorText(_errorMessage!()),
                      ),
                      const SizedBox(
                        height: AppDimensions.emailVerificationGap,
                      ),
                    ],
                    PrimaryButton(
                      label: AppStrings.emailVerificationSubmitButton,
                      onPressed: _isVerifying ? null : _verify,
                    ),
                    const SizedBox(height: AppDimensions.emailVerificationGap),
                    SecondaryButton(
                      label: AppStrings.emailVerificationResendButton,
                      onPressed: _isResending ? null : _resendEmail,
                    ),
                    const SizedBox(height: AppDimensions.emailVerificationGap),
                    GestureDetector(
                      onTap: () => context.go(AppRoutes.register),
                      child: Text(
                        AppStrings.emailVerificationChangeEmail,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: AppDimensions
                              .emailVerificationChangeEmailFontSize,
                          color: AppColors.agroInk500,
                        ),
                      ),
                    ),
                    Flexible(
                      flex: AppDimensions.emailVerificationBottomSpacerFlex
                          .round(),
                      child: const SizedBox(
                        height: AppDimensions.emailVerificationBottomSpacerFlex,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
