import 'package:flutter/material.dart';
import 'package:bulka_frontend/core/constants/app_colors.dart';
import 'package:bulka_frontend/core/constants/app_dimensions.dart';
import 'package:bulka_frontend/core/constants/app_strings.dart';
import 'package:bulka_frontend/models/user_role.dart';
import 'package:bulka_frontend/screens/forgot_password_screen/forgot_password_screen.dart';
import 'package:bulka_frontend/screens/provider_dashboard_screen/provider_dashboard_screen.dart';
import 'package:bulka_frontend/screens/register_screen/register_screen.dart';
import 'package:bulka_frontend/screens/tourist_home_screen/tourist_home_screen.dart';
import 'package:bulka_frontend/services/session_controller.dart';
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

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final SessionController _session = SessionController.instance;

  /// Set only when login succeeds but the account's backend role has no app
  /// destination yet — a distinct, screen-local concern from
  /// [SessionController.errorMessage], which is about login itself failing.
  String? _unsupportedRoleMessage;

  @override
  void initState() {
    super.initState();
    _session.addListener(_onSessionChanged);
    _emailController.addListener(_onFieldChanged);
    _passwordController.addListener(_onFieldChanged);
  }

  @override
  void dispose() {
    _session.removeListener(_onSessionChanged);
    _emailController.removeListener(_onFieldChanged);
    _passwordController.removeListener(_onFieldChanged);
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onSessionChanged() {
    if (mounted) setState(() {});
  }

  void _onFieldChanged() {
    if (mounted) setState(() {});
  }

  bool get _canSubmit =>
      !_session.isLoading &&
      _emailController.text.trim().isNotEmpty &&
      _passwordController.text.isNotEmpty;

  Future<void> _handleSubmit() async {
    if (!_canSubmit) return;

    setState(() => _unsupportedRoleMessage = null);

    final success = await _session.login(
      _emailController.text.trim(),
      _passwordController.text,
    );
    if (!mounted || !success) return;

    switch (_session.appRole) {
      case UserRole.buyer:
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const TouristHomeScreen()),
          (route) => false,
        );
        break;
      case UserRole.owner:
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const ProviderDashboardScreen()),
          (route) => false,
        );
        break;
      case null:
        // Logged in successfully (e.g. an Admin account), but this backend
        // role has no app destination yet — see backend_role_mapper.dart.
        // Stay on Login rather than silently guessing Buyer.
        setState(() {
          _unsupportedRoleMessage = AppStrings.loginUnsupportedRole;
        });
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayedError = _session.errorMessage ?? _unsupportedRoleMessage;

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
                    if (displayedError != null) ...[
                      const SizedBox(height: AppDimensions.dsBodyGap),
                      Text(
                        displayedError,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: AppDimensions.dsFooterFontSize,
                          color: AppColors.settingsDangerColor,
                        ),
                      ),
                    ],
                    const SizedBox(height: AppDimensions.dsBodyGap * 4),
                    if (_session.isLoading) ...[
                      const Center(child: CircularProgressIndicator()),
                      const SizedBox(height: AppDimensions.dsBodyGap),
                    ],
                    PrimaryButton(
                      label: AppStrings.loginSubmitButton,
                      onPressed: _canSubmit ? _handleSubmit : null,
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
