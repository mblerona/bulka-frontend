import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:bulka_frontend/core/constants/app_colors.dart';
import 'package:bulka_frontend/core/constants/app_dimensions.dart';
import 'package:bulka_frontend/core/constants/app_strings.dart';
import 'package:bulka_frontend/models/tourist_profile.dart';
import 'package:bulka_frontend/models/user_role.dart';
import 'package:bulka_frontend/widgets/app_checkbox.dart';
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
  String _selectedLanguageCode = AppStrings.languageCodeMk;
  int _selectedRoleIndex = 0;
  bool _agreedToTerms = false;

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  late final TapGestureRecognizer _termsOfServiceRecognizer =
      TapGestureRecognizer()..onTap = () {};
  late final TapGestureRecognizer _privacyPolicyRecognizer =
      TapGestureRecognizer()..onTap = () {};

  // Extend this with any future field-validation requirements; today
  // accepting the terms is the only gate on submission.
  bool get _canSubmit => _agreedToTerms;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
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
            selectedLanguageCode: _selectedLanguageCode,
            onLanguageChanged: (code) {
              setState(() => _selectedLanguageCode = code);
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
                      options: const [
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
                    ),
                    const SizedBox(height: AppDimensions.dsBodyGap),
                    LabeledTextField(
                      label: AppStrings.registerConfirmPasswordLabel,
                      hintText: AppStrings.passwordPlaceholder,
                      obscureText: true,
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
                                const TextSpan(
                                  text: AppStrings.registerTermsPrefix,
                                ),
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
                                const TextSpan(
                                  text: AppStrings.registerTermsSuffix,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.dsBodyGap),
                    PrimaryButton(
                      label: AppStrings.registerSubmitButton,
                      onPressed: _canSubmit
                          ? () {
                              final profile = TouristProfile(
                                fullName: _nameController.text,
                                email: _emailController.text,
                                phone: _phoneController.text,
                                role: _selectedRoleIndex == 0
                                    ? UserRole.buyer
                                    : UserRole.owner,
                              );
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) =>
                                      TermsPrivacyScreen(profile: profile),
                                ),
                              );
                            }
                          : null,
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
