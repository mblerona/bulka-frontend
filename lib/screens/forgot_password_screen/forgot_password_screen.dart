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

/// Asks the backend to email a password-reset code, then moves on to
/// Reset Password where the code and the new password are entered.
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();

  /// A function, not the text itself, so a message on screen follows a
  /// language switch.
  String Function()? _errorMessage;

  static final _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    final email = _emailController.text.trim();
    if (!_emailPattern.hasMatch(email)) {
      setState(() => _errorMessage = () => AppStrings.registerErrorEmail);
      return;
    }
    setState(() => _errorMessage = null);
    context.read<AuthBloc>().add(AuthPasswordResetCodeRequested(email));
  }

  void _handleAuthResult(BuildContext context, AuthState state) {
    if (state.status == AuthOperationStatus.succeeded) {
      context.push(AppRoutes.resetPassword(_emailController.text.trim()));
    } else if (state.status == AuthOperationStatus.failed) {
      final error = state.error!;
      setState(() => _errorMessage = () => error.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Disabled while the request runs, so it can't be sent twice.
    final isSubmitting = context.select(
      (AuthBloc bloc) =>
          bloc.state.isInProgress(AuthOperation.requestPasswordReset),
    );
    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (previous, current) =>
          current.operation == AuthOperation.requestPasswordReset &&
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
                      controller: _emailController,
                    ),
                    const SizedBox(height: AppDimensions.forgotPasswordBodyGap),
                    if (_errorMessage != null) ...[
                      FormErrorText(_errorMessage!()),
                      const SizedBox(height: AppDimensions.dsBodyGap),
                    ],
                    PrimaryButton(
                      label: AppStrings.forgotPasswordSubmitButton,
                      onPressed: isSubmitting ? null : _handleSubmit,
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
