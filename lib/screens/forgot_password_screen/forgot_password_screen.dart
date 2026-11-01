import 'package:flutter/material.dart';
import 'package:bulka_frontend/core/constants/app_colors.dart';
import 'package:bulka_frontend/core/constants/app_dimensions.dart';
import 'package:bulka_frontend/core/constants/app_strings.dart';
import 'package:bulka_frontend/core/network/api_exception.dart';
import 'package:bulka_frontend/screens/reset_password_screen/reset_password_screen.dart';
import 'package:bulka_frontend/services/auth_repository.dart';
import 'package:bulka_frontend/widgets/labeled_text_field.dart';
import 'package:bulka_frontend/widgets/primary_button.dart';
import 'package:bulka_frontend/widgets/screen_header.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final AuthRepository _authRepository = AuthRepository();
  final TextEditingController _emailController = TextEditingController();

  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_onFieldChanged);
  }

  @override
  void dispose() {
    _emailController.removeListener(_onFieldChanged);
    _emailController.dispose();
    super.dispose();
  }

  void _onFieldChanged() {
    if (mounted) setState(() {});
  }

  bool get _canSubmit =>
      !_isSubmitting && _emailController.text.trim().isNotEmpty;

  /// `POST /api/auth/forgot-password`'s response isn't confirmed live yet
  /// (see `AuthRepository.forgotPassword`), but the UI doesn't need
  /// anything from it — a successful call just means a reset code was sent,
  /// so this always proceeds to [ResetPasswordScreen] on success regardless
  /// of what `data` actually contains.
  Future<void> _handleSubmit() async {
    if (!_canSubmit) return;

    final email = _emailController.text.trim();
    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      await _authRepository.forgotPassword(email: email);
      if (!mounted) return;
      setState(() => _isSubmitting = false);

      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => ResetPasswordScreen(email: email)),
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
                    const SizedBox(
                      height: AppDimensions.forgotPasswordBodyGap,
                    ),
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
                    const SizedBox(
                      height: AppDimensions.forgotPasswordBodyGap,
                    ),
                    LabeledTextField(
                      label: AppStrings.emailLabel,
                      hintText: AppStrings.emailPlaceholder,
                      keyboardType: TextInputType.emailAddress,
                      controller: _emailController,
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
                      label: AppStrings.forgotPasswordSubmitButton,
                      onPressed: _canSubmit ? _handleSubmit : null,
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
