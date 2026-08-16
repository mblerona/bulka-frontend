import 'package:flutter/material.dart';
import 'package:bulka_frontend/core/constants/app_colors.dart';
import 'package:bulka_frontend/core/constants/app_dimensions.dart';
import 'package:bulka_frontend/core/constants/app_strings.dart';
import 'package:bulka_frontend/models/user_role.dart';
import 'package:bulka_frontend/screens/forgot_password_screen/forgot_password_screen.dart';
import 'package:bulka_frontend/screens/register_screen/register_screen.dart';
import 'package:bulka_frontend/screens/tourist_home_screen/tourist_home_screen.dart';
import 'package:bulka_frontend/widgets/labeled_text_field.dart';
import 'package:bulka_frontend/widgets/primary_button.dart';
import 'package:bulka_frontend/widgets/screen_header.dart';
import 'package:bulka_frontend/widgets/secondary_button.dart';

/// [role] is deliberately nullable and has no default — this app has no
/// backend yet, so Login itself has no way to know an account's role
/// unless whoever opened it already does (e.g. the Dev Launcher's
/// "Login · Tourist" / "Login · Provider" entries below). When it's null,
/// the real destination is a TODO for backend authentication, which is
/// what should determine the account's role and post-login destination —
/// this screen must not silently guess Buyer.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, this.role});

  final UserRole? role;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String _selectedLanguageCode = AppStrings.languageCodeMk;

  /// TEMPORARY: stands in for real email/password authentication — there's
  /// no backend yet, so this can only act on whichever [UserRole] the
  /// caller already told this screen about (see the class doc). A Tourist
  /// login goes straight to Home; a Provider login intentionally stays a
  /// TODO (no post-login Provider destination decided here — untouched);
  /// an unknown role also stays a TODO, since guessing would be exactly
  /// the "fake authentication success" this is meant to avoid.
  void _handleSubmit(BuildContext context) {
    switch (widget.role) {
      case UserRole.buyer:
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const TouristHomeScreen()),
          (route) => false,
        );
        break;
      case UserRole.owner:
        // TODO: wire up the Provider post-login destination.
        break;
      case null:
        // TODO: once real authentication exists, let the backend response
        // determine the account's role and destination.
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Column(
        children: [
          ScreenHeader(
            title: AppStrings.loginTitle,
            titleFontSize: AppDimensions.loginTitleFontSize,
            bottomPadding: AppDimensions.loginHeaderBottomPadding,
            contentGap: AppDimensions.loginHeaderRowGap,
            selectedLanguageCode: _selectedLanguageCode,
            onLanguageChanged: (code) {
              setState(() => _selectedLanguageCode = code);
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
                    ),
                    const SizedBox(height: AppDimensions.dsBodyGap),
                    LabeledTextField(
                      label: AppStrings.passwordLabel,
                      hintText: AppStrings.passwordPlaceholder,
                      obscureText: true,
                    ),
                    const SizedBox(height: AppDimensions.dsBodyGap),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const ForgotPasswordScreen(),
                          ),
                        );
                      },
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
                    PrimaryButton(
                      label: AppStrings.loginSubmitButton,
                      onPressed: () => _handleSubmit(context),
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
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const RegisterScreen(),
                              ),
                            );
                          },
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
