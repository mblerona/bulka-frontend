import 'package:flutter/material.dart';
import 'package:bulka_frontend/core/constants/app_colors.dart';
import 'package:bulka_frontend/core/constants/app_dimensions.dart';
import 'package:bulka_frontend/core/constants/app_strings.dart';
import 'package:bulka_frontend/core/network/api_exception.dart';
import 'package:bulka_frontend/models/registration_profile.dart';
import 'package:bulka_frontend/models/user_role.dart';
import 'package:bulka_frontend/screens/profile_screen/profile_screen.dart';
import 'package:bulka_frontend/screens/provider_profile_screen/provider_profile_screen.dart';
import 'package:bulka_frontend/screens/register_screen/register_screen.dart';
import 'package:bulka_frontend/services/auth_repository.dart';
import 'package:bulka_frontend/widgets/labeled_text_field.dart';
import 'package:bulka_frontend/widgets/primary_button.dart';
import 'package:bulka_frontend/widgets/secondary_button.dart';
import 'package:bulka_frontend/widgets/status_badge.dart';

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
  final AuthRepository _authRepository = AuthRepository();
  final TextEditingController _codeController = TextEditingController();

  bool _isVerifying = false;
  String? _verifyError;

  bool _isResending = false;
  String? _resendMessage;

  @override
  void initState() {
    super.initState();
    _codeController.addListener(_onCodeChanged);
  }

  @override
  void dispose() {
    _codeController.removeListener(_onCodeChanged);
    _codeController.dispose();
    super.dispose();
  }

  void _onCodeChanged() {
    if (mounted) setState(() {});
  }

  bool get _canSubmitCode =>
      !_isVerifying && _codeController.text.trim().isNotEmpty;

  Future<void> _handleVerify() async {
    if (!_canSubmitCode) return;

    setState(() {
      _isVerifying = true;
      _verifyError = null;
    });

    try {
      await _authRepository.verifyEmail(
        email: widget.profile.email,
        code: _codeController.text.trim(),
      );
      if (!mounted) return;

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => widget.profile.role == UserRole.owner
              ? ProviderProfileScreen(profile: widget.profile)
              : ProfileScreen(profile: widget.profile),
        ),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _isVerifying = false;
        _verifyError = e.message;
      });
    }
  }

  Future<void> _handleResend() async {
    if (_isResending) return;

    setState(() {
      _isResending = true;
      _resendMessage = null;
    });

    try {
      final result = await _authRepository.resendEmailVerification(
        email: widget.profile.email,
      );
      if (!mounted) return;
      setState(() {
        _isResending = false;
        _resendMessage = result.sent
            ? AppStrings.emailVerificationResendSuccess
            : AppStrings.apiErrorUnknown;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _isResending = false;
        _resendMessage = e.message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.beigeBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.splashHorizontalPadding,
          ),
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Fixed height, not the flex-ratio spacer this screen used
                // before it had a scrollable body: `Flexible`'s flex ratio
                // needs a bounded-height ancestor, which `SingleChildScrollView`
                // deliberately doesn't provide — this screen now has more
                // content (the code field + submit button) than reliably
                // fits unscrolled on a short device.
                const SizedBox(
                  height: AppDimensions.emailVerificationTopSpacerFlex,
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
                  widget.profile.email,
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
                const StatusBadge(
                  label: AppStrings.emailVerificationBadge,
                  backgroundColor: AppColors.agroGold100,
                  textColor: AppColors.agroForest950,
                ),
                const SizedBox(height: AppDimensions.emailVerificationGap),
                LabeledTextField(
                  label: AppStrings.emailVerificationCodeLabel,
                  hintText: AppStrings.emailVerificationCodePlaceholder,
                  keyboardType: TextInputType.number,
                  controller: _codeController,
                ),
                if (_verifyError != null) ...[
                  const SizedBox(height: AppDimensions.emailVerificationGap),
                  Text(
                    _verifyError!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: AppDimensions.dsFooterFontSize,
                      color: AppColors.settingsDangerColor,
                    ),
                  ),
                ],
                const SizedBox(height: AppDimensions.emailVerificationGap),
                if (_isVerifying) ...[
                  const Center(child: CircularProgressIndicator()),
                  const SizedBox(height: AppDimensions.dsBodyGap),
                ],
                PrimaryButton(
                  label: AppStrings.emailVerificationSubmitButton,
                  onPressed: _canSubmitCode ? _handleVerify : null,
                ),
                const SizedBox(
                  height: AppDimensions.emailVerificationSpacerHeight,
                ),
                SecondaryButton(
                  label: AppStrings.emailVerificationResendButton,
                  onPressed: _isResending ? null : _handleResend,
                ),
                if (_resendMessage != null) ...[
                  const SizedBox(height: AppDimensions.emailVerificationGap),
                  Text(
                    _resendMessage!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: AppDimensions.dsFooterFontSize,
                      color: AppColors.agroGreen700,
                    ),
                  ),
                ],
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
                      fontSize:
                          AppDimensions.emailVerificationChangeEmailFontSize,
                      color: AppColors.agroInk500,
                    ),
                  ),
                ),
                // See the top spacer's comment above — fixed, not flex.
                const SizedBox(
                  height: AppDimensions.emailVerificationBottomSpacerFlex,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
