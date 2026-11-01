import 'package:flutter/material.dart';
import 'package:bulka_frontend/core/constants/app_colors.dart';
import 'package:bulka_frontend/core/constants/app_dimensions.dart';
import 'package:bulka_frontend/core/constants/app_strings.dart';
import 'package:bulka_frontend/core/network/api_exception.dart';
import 'package:bulka_frontend/screens/login_screen/login_screen.dart';
import 'package:bulka_frontend/services/auth_repository.dart';
import 'package:bulka_frontend/widgets/labeled_text_field.dart';
import 'package:bulka_frontend/widgets/primary_button.dart';
import 'package:bulka_frontend/widgets/screen_header.dart';

/// **Not a Figma screen** — like `BookingRequestScreen`, built from existing
/// app primitives (the same icon/heading/field/button composition as
/// `ForgotPasswordScreen`) because no current-design frame defines a
/// code + new-password entry step. Reconcile against a real frame if one
/// is ever designed; for now this exists purely to connect
/// `POST /api/auth/reset-password` for real.
class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key, required this.email});

  /// Carried forward from [ForgotPasswordScreen] — the account the reset
  /// code was sent to. Not editable here; changing it would mean starting
  /// the forgot-password request over.
  final String email;

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final AuthRepository _authRepository = AuthRepository();
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    for (final c in [
      _codeController,
      _passwordController,
      _confirmPasswordController,
    ]) {
      c.addListener(_onFieldChanged);
    }
  }

  @override
  void dispose() {
    for (final c in [
      _codeController,
      _passwordController,
      _confirmPasswordController,
    ]) {
      c.removeListener(_onFieldChanged);
      c.dispose();
    }
    super.dispose();
  }

  void _onFieldChanged() {
    if (mounted) setState(() {});
  }

  bool get _canSubmit =>
      !_isSubmitting &&
      _codeController.text.trim().isNotEmpty &&
      _passwordController.text.isNotEmpty &&
      _confirmPasswordController.text.isNotEmpty;

  /// `POST /api/auth/reset-password`'s response isn't confirmed live yet
  /// (see `AuthRepository.resetPassword`), but the UI doesn't need
  /// anything from it — a successful call just means the password changed,
  /// so this always returns to `LoginScreen` on success regardless of what
  /// `data` actually contains. The password-match check below is purely
  /// client-side (never sent to the backend) and doesn't depend on any
  /// confirmed response shape.
  Future<void> _handleSubmit() async {
    if (!_canSubmit) return;

    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() => _errorMessage = AppStrings.resetPasswordMismatchError);
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      await _authRepository.resetPassword(
        email: widget.email,
        code: _codeController.text.trim(),
        password: _passwordController.text,
      );
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.resetPasswordSuccessMessage)),
      );
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
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
            title: AppStrings.resetPasswordTitle,
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
                        Icons.lock_reset,
                        color: AppColors.agroForest950,
                        size: AppDimensions.forgotPasswordIconSize,
                      ),
                    ),
                    const SizedBox(
                      height: AppDimensions.forgotPasswordBodyGap,
                    ),
                    Text(
                      AppStrings.resetPasswordHeading,
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
                      AppStrings.resetPasswordSubheading,
                      style: const TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: AppDimensions.dsSubheadingFontSize,
                        color: AppColors.agroInk500,
                      ),
                    ),
                    const SizedBox(
                      height: AppDimensions.forgotPasswordBodyGap,
                    ),
                    Text(
                      widget.email,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: AppDimensions.emailVerificationEmailFontSize,
                        color: AppColors.agroGreen700,
                      ),
                    ),
                    const SizedBox(
                      height: AppDimensions.forgotPasswordBodyGap,
                    ),
                    LabeledTextField(
                      label: AppStrings.resetPasswordCodeLabel,
                      hintText: AppStrings.resetPasswordCodePlaceholder,
                      keyboardType: TextInputType.number,
                      controller: _codeController,
                    ),
                    const SizedBox(
                      height: AppDimensions.forgotPasswordBodyGap,
                    ),
                    LabeledTextField(
                      label: AppStrings.resetPasswordNewPasswordLabel,
                      hintText: AppStrings.passwordPlaceholder,
                      obscureText: true,
                      controller: _passwordController,
                    ),
                    const SizedBox(
                      height: AppDimensions.forgotPasswordBodyGap,
                    ),
                    LabeledTextField(
                      label: AppStrings.registerConfirmPasswordLabel,
                      hintText: AppStrings.passwordPlaceholder,
                      obscureText: true,
                      controller: _confirmPasswordController,
                    ),
                    if (_errorMessage != null) ...[
                      const SizedBox(
                        height: AppDimensions.forgotPasswordBodyGap,
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
                      height: AppDimensions.forgotPasswordBodyGap,
                    ),
                    if (_isSubmitting) ...[
                      const Center(child: CircularProgressIndicator()),
                      const SizedBox(height: AppDimensions.dsBodyGap),
                    ],
                    PrimaryButton(
                      label: AppStrings.resetPasswordSubmitButton,
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
