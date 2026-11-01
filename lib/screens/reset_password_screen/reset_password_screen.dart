import 'package:flutter/material.dart';
import 'package:bulka_frontend/blocs/auth/auth_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bulka_frontend/core/routing/app_routes.dart';
import 'package:go_router/go_router.dart';
import 'package:bulka_frontend/core/constants/app_colors.dart';
import 'package:bulka_frontend/core/constants/app_dimensions.dart';
import 'package:bulka_frontend/core/constants/app_strings.dart';
import 'package:bulka_frontend/widgets/form_error_text.dart';
import 'package:bulka_frontend/widgets/labeled_text_field.dart';
import 'package:bulka_frontend/widgets/primary_button.dart';
import 'package:bulka_frontend/widgets/screen_header.dart';

/// Second step of Forgot Password: the code from the email plus the new
/// password. On success the user goes to Login with their email filled in.
///
/// Not a Figma screen: it reuses Forgot Password's layout, since no design
/// exists for this step yet.
class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key, required this.email});

  /// The account the reset code was sent to.
  final String email;

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _codeController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  /// A function, not the text itself, so a message on screen follows a
  /// language switch.
  String Function()? _errorMessage;

  @override
  void dispose() {
    _codeController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  /// Same password rules the backend enforces (see RegisterScreen).
  static bool _isStrongPassword(String password) {
    return password.length >= 8 &&
        RegExp(r'\p{Lu}', unicode: true).hasMatch(password) &&
        RegExp(r'\d').hasMatch(password) &&
        RegExp(r'[^\p{L}\p{N}]', unicode: true).hasMatch(password);
  }

  String Function()? _validate() {
    if (_codeController.text.trim().isEmpty) {
      return () => AppStrings.emailVerificationErrorEmptyCode;
    }
    if (!_isStrongPassword(_passwordController.text)) {
      return () => AppStrings.registerErrorPasswordRules;
    }
    if (_passwordController.text != _confirmPasswordController.text) {
      return () => AppStrings.registerErrorPasswordMismatch;
    }
    return null;
  }

  void _handleSubmit() {
    final error = _validate();
    setState(() => _errorMessage = error);
    if (error != null) return;
    context.read<AuthBloc>().add(
      AuthPasswordResetRequested(
        email: widget.email,
        code: _codeController.text,
        newPassword: _passwordController.text,
      ),
    );
  }

  void _handleAuthResult(BuildContext context, AuthState state) {
    if (state.status == AuthOperationStatus.succeeded) {
      // The app-wide messenger, so the message stays visible on Login.
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text(AppStrings.resetPasswordSuccess)),
        );
      context.go(AppRoutes.loginWithEmail(widget.email));
    } else if (state.status == AuthOperationStatus.failed) {
      final error = state.error!;
      setState(() => _errorMessage = () => error.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Disabled while the request runs, so it can't be sent twice.
    final isSubmitting = context.select(
      (AuthBloc bloc) => bloc.state.isInProgress(AuthOperation.resetPassword),
    );
    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (previous, current) =>
          current.operation == AuthOperation.resetPassword &&
          current.status != previous.status,
      listener: _handleAuthResult,
      child: _buildScreen(context, isSubmitting),
    );
  }

  Widget _buildScreen(BuildContext context, bool isSubmitting) {
    return Scaffold(
      backgroundColor: AppColors.beigeBackground,
      body: Column(
        children: [
          ScreenHeader(
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
                    const SizedBox(height: AppDimensions.forgotPasswordBodyGap),
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
                    const SizedBox(height: AppDimensions.forgotPasswordBodyGap),
                    Text(
                      widget.email,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: AppDimensions.emailVerificationEmailFontSize,
                        color: AppColors.agroGreen700,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.forgotPasswordBodyGap),
                    LabeledTextField(
                      label: AppStrings.resetPasswordCodeLabel,
                      hintText: AppStrings.resetPasswordCodePlaceholder,
                      keyboardType: TextInputType.number,
                      controller: _codeController,
                    ),
                    const SizedBox(height: AppDimensions.forgotPasswordBodyGap),
                    LabeledTextField(
                      label: AppStrings.resetPasswordNewPasswordLabel,
                      hintText: AppStrings.passwordPlaceholder,
                      obscureText: true,
                      controller: _passwordController,
                    ),
                    const SizedBox(height: AppDimensions.forgotPasswordBodyGap),
                    LabeledTextField(
                      label: AppStrings.registerConfirmPasswordLabel,
                      hintText: AppStrings.passwordPlaceholder,
                      obscureText: true,
                      controller: _confirmPasswordController,
                    ),
                    const SizedBox(height: AppDimensions.forgotPasswordBodyGap),
                    if (_errorMessage != null) ...[
                      FormErrorText(_errorMessage!()),
                      const SizedBox(height: AppDimensions.dsBodyGap),
                    ],
                    PrimaryButton(
                      label: AppStrings.resetPasswordSubmitButton,
                      onPressed: isSubmitting ? null : _handleSubmit,
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
