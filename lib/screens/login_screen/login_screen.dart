import 'package:flutter/material.dart';
import 'package:bulka_frontend/core/constants/app_colors.dart';
import 'package:bulka_frontend/core/constants/app_dimensions.dart';
import 'package:bulka_frontend/core/constants/app_strings.dart';
import 'package:bulka_frontend/screens/forgot_password_screen/forgot_password_screen.dart';
import 'package:bulka_frontend/screens/register_screen/register_screen.dart';
import 'package:bulka_frontend/widgets/labeled_text_field.dart';
import 'package:bulka_frontend/widgets/primary_button.dart';
import 'package:bulka_frontend/widgets/screen_header.dart';
import 'package:bulka_frontend/widgets/secondary_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String _selectedLanguageCode = AppStrings.languageCodeMk;

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
                      onPressed: () {
                        // TODO: wire up email/password authentication.
                      },
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
