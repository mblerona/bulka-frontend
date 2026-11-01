import 'package:flutter/material.dart';
import 'package:bulka_frontend/core/routing/app_routes.dart';
import 'package:go_router/go_router.dart';
import 'package:bulka_frontend/core/constants/app_colors.dart';
import 'package:bulka_frontend/core/constants/app_dimensions.dart';
import 'package:bulka_frontend/core/constants/app_strings.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bulka_frontend/blocs/locale/locale_bloc.dart';
import 'package:bulka_frontend/core/network/api_exception.dart';
import 'package:bulka_frontend/models/user_role.dart';
import 'package:bulka_frontend/blocs/auth/auth_bloc.dart';
import 'package:bulka_frontend/widgets/form_error_text.dart';
import 'package:bulka_frontend/widgets/labeled_text_field.dart';
import 'package:bulka_frontend/widgets/primary_button.dart';
import 'package:bulka_frontend/widgets/screen_header.dart';
import 'package:bulka_frontend/widgets/secondary_button.dart';

/// Signs in against the backend. The account's role comes from the login
/// response and decides where the user lands (Tourist Home or Provider
/// Dashboard).
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, this.initialEmail});

  /// Pre-fills the email field, e.g. right after email verification.
  final String? initialEmail;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late final _emailController = TextEditingController(
    text: widget.initialEmail,
  );
  final _passwordController = TextEditingController();

  /// A function, not the text itself, so a message on screen follows a
  /// language switch.
  String Function()? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    if (email.isEmpty || password.isEmpty) {
      setState(() => _errorMessage = () => AppStrings.loginErrorEmptyFields);
      return;
    }
    setState(() => _errorMessage = null);
    context.read<AuthBloc>().add(
      AuthLoginRequested(email: email, password: password),
    );
  }

  /// Signed in: go to the account's side of the app. Failed: show why.
  void _handleAuthResult(BuildContext context, AuthState state) {
    if (state.status == AuthOperationStatus.succeeded) {
      context.go(switch (state.user!.role) {
        UserRole.buyer => AppRoutes.home,
        UserRole.owner => AppRoutes.dashboard,
      });
    } else if (state.status == AuthOperationStatus.failed) {
      final error = state.error!;
      setState(() {
        _errorMessage = () => error.kind == ApiErrorKind.unauthorized
            ? AppStrings.loginErrorInvalidCredentials
            : error.message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Disabled while the request runs, so it can't be sent twice.
    final isSubmitting = context.select(
      (AuthBloc bloc) => bloc.state.isInProgress(AuthOperation.login),
    );
    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (previous, current) =>
          current.operation == AuthOperation.login &&
          current.status != previous.status,
      listener: _handleAuthResult,
      child: _buildScreen(context, isSubmitting),
    );
  }

  Widget _buildScreen(BuildContext context, bool isSubmitting) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Column(
        children: [
          ScreenHeader(
            title: AppStrings.loginTitle,
            titleFontSize: AppDimensions.loginTitleFontSize,
            bottomPadding: AppDimensions.loginHeaderBottomPadding,
            contentGap: AppDimensions.loginHeaderRowGap,
            selectedLanguageCode: context.watch<LocaleBloc>().state.switchCode,
            onLanguageChanged: (code) {
              // Saved app-wide; BulkaApp rebuilds every screen.
              context.read<LocaleBloc>().add(LanguageChanged(code));
            },
          ),
          Expanded(
            child: SafeArea(
              top: false,
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(
                  left: AppDimensions.dsBodyHorizontalPadding,
                  right: AppDimensions.dsBodyHorizontalPadding,
                  top: AppDimensions.dsBodyTopPadding,
                  bottom: AppDimensions.loginBodyBottomPadding,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.loginWelcomeBack,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: AppDimensions.loginHeadingFontSize,
                        color: AppColors.agroForest950,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.loginHeadingGap),
                    Text(
                      AppStrings.loginWelcomeBackSubtitle,
                      style: const TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: AppDimensions.dsSubheadingFontSize,
                        color: AppColors.agroInk500,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.dsBodyGap),
                    LabeledTextField(
                      label: AppStrings.emailLabel,
                      hintText: AppStrings.emailPlaceholder,
                      keyboardType: TextInputType.emailAddress,
                      controller: _emailController,
                    ),
                    const SizedBox(height: AppDimensions.dsBodyGap),
                    LabeledTextField(
                      label: AppStrings.passwordLabel,
                      hintText: AppStrings.passwordPlaceholder,
                      obscureText: true,
                      controller: _passwordController,
                    ),
                    const SizedBox(height: AppDimensions.dsBodyGap),
                    GestureDetector(
                      onTap: () => context.push(AppRoutes.forgotPassword),
                      child: Text(
                        AppStrings.loginForgotPassword,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: AppDimensions.loginForgotPasswordFontSize,
                          color: AppColors.agroGreen700,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppDimensions.dsBodyGap * 4),
                    if (_errorMessage != null) ...[
                      FormErrorText(_errorMessage!()),
                      const SizedBox(height: AppDimensions.dsBodyGap),
                    ],
                    PrimaryButton(
                      label: AppStrings.loginSubmitButton,
                      onPressed: isSubmitting ? null : _handleSubmit,
                    ),
                    const SizedBox(height: AppDimensions.dsBodyGap),
                    SecondaryButton(
                      label: AppStrings.loginGoogleButton,
                      onPressed: () {
                        // TODO: wire up Google sign-in.
                      },
                    ),
                    const SizedBox(height: AppDimensions.dsBodyGap),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          AppStrings.loginFooterPrompt,
                          style: const TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: AppDimensions.dsFooterFontSize,
                            color: AppColors.agroInk500,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => context.push(AppRoutes.register),
                          child: Text(
                            AppStrings.loginFooterAction,
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
