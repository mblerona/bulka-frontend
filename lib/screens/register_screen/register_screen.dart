import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:bulka_frontend/core/constants/app_colors.dart';
import 'package:bulka_frontend/core/constants/app_dimensions.dart';
import 'package:bulka_frontend/core/constants/app_strings.dart';
import 'package:bulka_frontend/models/registration_profile.dart';
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

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _displayNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _businessNameController = TextEditingController();

  late final TapGestureRecognizer _termsOfServiceRecognizer =
      TapGestureRecognizer()..onTap = () {};
  late final TapGestureRecognizer _privacyPolicyRecognizer =
      TapGestureRecognizer()..onTap = () {};

  bool get _isProvider => _selectedRoleIndex == 1;

  bool get _canSubmit =>
      _agreedToTerms &&
      _emailController.text.trim().isNotEmpty &&
      _passwordController.text.isNotEmpty &&
      _firstNameController.text.trim().isNotEmpty &&
      _lastNameController.text.trim().isNotEmpty &&
      _displayNameController.text.trim().isNotEmpty &&
      (!_isProvider || _businessNameController.text.trim().isNotEmpty);

  @override
  void initState() {
    super.initState();
    for (final c in [
      _firstNameController,
      _lastNameController,
      _displayNameController,
      _emailController,
      _passwordController,
      _businessNameController,
    ]) {
      c.addListener(_onFieldChanged);
    }
  }

  void _onFieldChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _displayNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _businessNameController.dispose();
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
                      label: AppStrings.registerFirstNameLabel,
                      hintText: AppStrings.registerFirstNamePlaceholder,
                      controller: _firstNameController,
                    ),
                    const SizedBox(height: AppDimensions.dsBodyGap),
                    LabeledTextField(
                      label: AppStrings.registerLastNameLabel,
                      hintText: AppStrings.registerLastNamePlaceholder,
                      controller: _lastNameController,
                    ),
                    const SizedBox(height: AppDimensions.dsBodyGap),
                    LabeledTextField(
                      label: AppStrings.registerDisplayNameLabel,
                      hintText: AppStrings.registerDisplayNamePlaceholder,
                      controller: _displayNameController,
                    ),
                    if (_isProvider) ...[
                      const SizedBox(height: AppDimensions.dsBodyGap),
                      LabeledTextField(
                        label: AppStrings.registerBusinessNameLabel,
                        hintText: AppStrings.registerBusinessNamePlaceholder,
                        controller: _businessNameController,
                      ),
                    ],
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
                              final firstName = _firstNameController.text
                                  .trim();
                              final lastName = _lastNameController.text
                                  .trim();
                              final profile = RegistrationProfile(
                                fullName: '$firstName $lastName'.trim(),
                                email: _emailController.text.trim(),
                                phone: _phoneController.text,
                                role: _isProvider
                                    ? UserRole.owner
                                    : UserRole.buyer,
                                firstName: firstName,
                                lastName: lastName,
                                displayName: _displayNameController.text
                                    .trim(),
                                password: _passwordController.text,
                                businessName: _isProvider
                                    ? _businessNameController.text.trim()
                                    : null,
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
