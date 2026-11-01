import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:bulka_frontend/core/constants/app_colors.dart';
import 'package:bulka_frontend/core/constants/app_dimensions.dart';
import 'package:bulka_frontend/core/constants/app_strings.dart';
import 'package:bulka_frontend/core/l10n/locale_controller.dart';
import 'package:bulka_frontend/models/registration_profile.dart';
import 'package:bulka_frontend/models/user_role.dart';
import 'package:bulka_frontend/widgets/app_checkbox.dart';
import 'package:bulka_frontend/widgets/form_error_text.dart';
import 'package:bulka_frontend/widgets/labeled_text_field.dart';
import 'package:bulka_frontend/widgets/primary_button.dart';
import 'package:bulka_frontend/widgets/role_toggle.dart';
import 'package:bulka_frontend/widgets/screen_header.dart';
import 'package:bulka_frontend/screens/terms_privacy_screen/terms_privacy_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  int _selectedRoleIndex = 0;
  bool _agreedToTerms = false;

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  /// A function, not the text itself, so a message on screen follows a
  /// language switch.
  String Function()? _errorMessage;

  late final TapGestureRecognizer _termsOfServiceRecognizer =
      TapGestureRecognizer()..onTap = () {};
  late final TapGestureRecognizer _privacyPolicyRecognizer =
      TapGestureRecognizer()..onTap = () {};

  // Extend this with any future field-validation requirements; today
  // accepting the terms is the only gate on submission.
  bool get _canSubmit => _agreedToTerms;

  static final _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  /// International format, like the backend requires: "+" and digits.
  /// Spaces and dashes are allowed (the backend accepts them too).
  static bool _isInternationalPhone(String phone) {
    final digitsOnly = phone.replaceAll(RegExp(r'[\s-]'), '');
    return RegExp(r'^\+\d{8,15}$').hasMatch(digitsOnly);
  }

  /// Same password rules the backend enforces.
  static bool _isStrongPassword(String password) {
    return password.length >= 8 &&
        RegExp(r'\p{Lu}', unicode: true).hasMatch(password) &&
        RegExp(r'\d').hasMatch(password) &&
        RegExp(r'[^\p{L}\p{N}]', unicode: true).hasMatch(password);
  }

  /// Returns the first problem with the form (as a function, so its text
  /// follows a language switch), or null when it's valid.
  String Function()? _validate(RegistrationProfile profile) {
    if (profile.firstName.isEmpty || profile.lastName.isEmpty) {
      return () => AppStrings.registerErrorFullName;
    }
    if (!_emailPattern.hasMatch(profile.email)) {
      return () => AppStrings.registerErrorEmail;
    }
    if (!_isInternationalPhone(profile.phone)) {
      return () => AppStrings.registerErrorPhone;
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
    final profile = RegistrationProfile(
      fullName: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      role: _selectedRoleIndex == 0 ? UserRole.buyer : UserRole.owner,
    );
    final error = _validate(profile);
    setState(() => _errorMessage = error);
    if (error != null) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TermsPrivacyScreen(
          profile: profile,
          password: _passwordController.text,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _termsOfServiceRecognizer.dispose();
    _privacyPolicyRecognizer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.beigeBackground,
      body: Column(
        children: [
          ScreenHeader(
            title: AppStrings.registerTitle,
            titleFontSize: AppDimensions.dsCompactHeaderTitleFontSize,
            bottomPadding: AppDimensions.dsCompactHeaderBottomPadding,
            contentGap: AppDimensions.dsCompactHeaderGap,
            selectedLanguageCode: LocaleController.instance.switchCode,
            onLanguageChanged: (code) {
              // Saved app-wide; BulkaApp rebuilds every screen.
              LocaleController.instance.setLanguage(code);
            },
          ),
          Expanded(
            child: SafeArea(
              top: false,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppDimensions.dsBodyPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.registerRoleLabel,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: AppDimensions.registerRoleLabelFontSize,
                        color: AppColors.agroForest950,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.dsBodyGap),
                    RoleToggle(
                      options: [
                        AppStrings.registerRoleGuest,
                        AppStrings.registerRoleProvider,
                      ],
                      selectedIndex: _selectedRoleIndex,
                      onChanged: (index) {
                        setState(() => _selectedRoleIndex = index);
                      },
                    ),
                    const SizedBox(height: AppDimensions.dsBodyGap),
                    LabeledTextField(
                      label: AppStrings.registerNameLabel,
                      hintText: AppStrings.registerNamePlaceholder,
                      controller: _nameController,
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
                      label: AppStrings.registerPhoneLabel,
                      hintText: AppStrings.registerPhonePlaceholder,
                      keyboardType: TextInputType.phone,
                      controller: _phoneController,
                    ),
                    const SizedBox(height: AppDimensions.dsBodyGap),
                    LabeledTextField(
                      label: AppStrings.passwordLabel,
                      hintText: AppStrings.passwordPlaceholder,
                      obscureText: true,
                      controller: _passwordController,
                    ),
                    const SizedBox(height: AppDimensions.dsBodyGap),
                    LabeledTextField(
                      label: AppStrings.registerConfirmPasswordLabel,
                      hintText: AppStrings.passwordPlaceholder,
                      obscureText: true,
                      controller: _confirmPasswordController,
                    ),
                    const SizedBox(height: AppDimensions.dsBodyGap),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppCheckbox(
                          value: _agreedToTerms,
                          onChanged: (value) {
                            setState(() => _agreedToTerms = value);
                          },
                        ),
                        const SizedBox(width: AppDimensions.dsCheckboxTextGap),
                        Expanded(
                          child: Text.rich(
                            TextSpan(
                              style: const TextStyle(
                                fontWeight: FontWeight.w400,
                                fontSize: AppDimensions.registerTermsFontSize,
                                color: AppColors.agroInk500,
                              ),
                              children: [
                                TextSpan(text: AppStrings.registerTermsPrefix),
                                TextSpan(
                                  text: AppStrings.registerTermsOfService,
                                  recognizer: _termsOfServiceRecognizer,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.agroGreen700,
                                  ),
                                ),
                                const TextSpan(
                                  text: AppStrings.registerTermsSeparator,
                                ),
                                TextSpan(
                                  text: AppStrings.registerPrivacyPolicy,
                                  recognizer: _privacyPolicyRecognizer,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.agroGreen700,
                                  ),
                                ),
                                TextSpan(text: AppStrings.registerTermsSuffix),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.dsBodyGap),
                    if (_errorMessage != null) ...[
                      FormErrorText(_errorMessage!()),
                      const SizedBox(height: AppDimensions.dsBodyGap),
                    ],
                    PrimaryButton(
                      label: AppStrings.registerSubmitButton,
                      onPressed: _canSubmit ? _handleSubmit : null,
                    ),
                    const SizedBox(height: AppDimensions.dsBodyGap),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          AppStrings.registerFooterPrompt,
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
