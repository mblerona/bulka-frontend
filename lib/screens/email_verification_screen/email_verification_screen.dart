import 'package:flutter/material.dart';
import 'package:bulka_frontend/blocs/auth/auth_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bulka_frontend/core/routing/app_routes.dart';
import 'package:go_router/go_router.dart';
import 'package:bulka_frontend/core/constants/app_colors.dart';
import 'package:bulka_frontend/core/constants/app_dimensions.dart';
import 'package:bulka_frontend/core/constants/app_strings.dart';
import 'package:bulka_frontend/models/registration_profile.dart';
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

  /// A function, not the text itself, so a message on screen follows a
  /// language switch.
  String Function()? _errorMessage;

  String get _email => widget.profile.email;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  void _verify() {
    final code = _codeController.text.trim();
    if (code.isEmpty) {
      setState(
        () => _errorMessage = () => AppStrings.emailVerificationErrorEmptyCode,
      );
      return;
    }
    setState(() => _errorMessage = null);
    context.read<AuthBloc>().add(
      AuthEmailVerificationRequested(email: _email, code: code),
    );
  }

  void _resendEmail() {
    context.read<AuthBloc>().add(AuthVerificationEmailResendRequested(_email));
  }

  void _showSnackBar(BuildContext context, String message) {
    // The app-wide messenger, so a message stays visible after navigating.
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _handleAuthResult(BuildContext context, AuthState state) {
    final succeeded = state.status == AuthOperationStatus.succeeded;
    final failed = state.status == AuthOperationStatus.failed;
    switch (state.operation) {
      case AuthOperation.verifyEmail when succeeded:
        _showSnackBar(context, AppStrings.emailVerificationSuccess);
        context.go(AppRoutes.loginWithEmail(_email));
      case AuthOperation.verifyEmail when failed:
        final error = state.error!;
        setState(() => _errorMessage = () => error.message);
      case AuthOperation.resendVerification when succeeded:
        _showSnackBar(context, AppStrings.emailVerificationResent);
      case AuthOperation.resendVerification when failed:
        _showSnackBar(context, state.error!.message);
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Each button is disabled while its own request runs.
    final isVerifying = context.select(
      (AuthBloc bloc) => bloc.state.isInProgress(AuthOperation.verifyEmail),
    );
    final isResending = context.select(
      (AuthBloc bloc) =>
          bloc.state.isInProgress(AuthOperation.resendVerification),
    );
    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (previous, current) =>
          (current.operation == AuthOperation.verifyEmail ||
              current.operation == AuthOperation.resendVerification) &&
          (current.status != previous.status ||
              current.operation != previous.operation),
      listener: _handleAuthResult,
      child: _buildScreen(
        context,
        isVerifying: isVerifying,
        isResending: isResending,
      ),
    );
  }

  Widget _buildScreen(
    BuildContext context, {
    required bool isVerifying,
    required bool isResending,
  }) {
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
                      onPressed: isVerifying ? null : _verify,
                    ),
                    const SizedBox(height: AppDimensions.emailVerificationGap),
                    SecondaryButton(
                      label: AppStrings.emailVerificationResendButton,
                      onPressed: isResending ? null : _resendEmail,
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
