import 'package:flutter/material.dart';
import 'package:bulka_frontend/core/constants/app_colors.dart';
import 'package:bulka_frontend/core/constants/app_dimensions.dart';
import 'package:bulka_frontend/core/constants/app_strings.dart';
import 'package:bulka_frontend/screens/login_screen/login_screen.dart';
import 'package:bulka_frontend/services/auth_controller.dart';
import 'package:bulka_frontend/widgets/language_switch.dart';
import 'package:bulka_frontend/widgets/screen_header.dart';
import 'package:bulka_frontend/widgets/secondary_button.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _selectedLanguageCode = AppStrings.languageCodeMk;
  bool _notificationsEnabled = true;

  Future<void> _handleLogout() async {
    await AuthController.instance.logout();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Column(
        children: [
          const ScreenHeader(
            title: AppStrings.settingsTitle,
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
                  bottom: AppDimensions.profileBodyBottomPadding,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionHeading(AppStrings.settingsLanguageHeading),
                    const SizedBox(height: AppDimensions.settingsSectionGap),
                    Container(
                      width: double.infinity,
                      height: AppDimensions.settingsLanguageRowHeight,
                      padding: const EdgeInsets.symmetric(
                        horizontal:
                            AppDimensions.settingsLanguageRowHorizontalPadding,
                        vertical:
                            AppDimensions.settingsLanguageRowVerticalPadding,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.profileStatCardBackground,
                        border: Border.all(
                          color: AppColors.profileStatCardBorder,
                        ),
                        borderRadius: BorderRadius.circular(
                          AppDimensions.dsRadiusMd,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            AppStrings.settingsLanguageRowLabel,
                            style: TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize: AppDimensions
                                  .settingsLanguageRowLabelFontSize,
                              color: AppColors.agroForest950,
                            ),
                          ),
                          LanguageSwitch(
                            selectedLanguageCode: _selectedLanguageCode,
                            surface: LanguageSwitchSurface.light,
                            onChanged: (code) {
                              setState(() => _selectedLanguageCode = code);
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppDimensions.profileBodyGap),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _sectionHeading(AppStrings.settingsNotificationsLabel),
                        _SettingsToggle(
                          value: _notificationsEnabled,
                          onChanged: (value) {
                            setState(() => _notificationsEnabled = value);
                            // TODO: persist the notifications preference
                            // once a backend/settings store exists.
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.profileBodyGap),
                    _sectionHeading(AppStrings.settingsPrivacyHeading),
                    const SizedBox(height: AppDimensions.settingsSectionGap),
                    const Text(
                      AppStrings.settingsPrivacyDescription,
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize:
                            AppDimensions.settingsPrivacyDescriptionFontSize,
                        color: AppColors.profileSecondaryText,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.settingsSectionGap),
                    SecondaryButton(
                      label: AppStrings.settingsDownloadDataButton,
                      // TODO: wire up once data export exists on the backend.
                      onPressed: () {},
                    ),
                    const SizedBox(height: AppDimensions.settingsSectionGap),
                    SecondaryButton(
                      label: AppStrings.settingsDeleteAccountButton,
                      backgroundColor: AppColors.agroCream100,
                      borderColor: AppColors.settingsDangerColor,
                      textColor: AppColors.settingsDangerColor,
                      // TODO: wire up once account deletion exists on the
                      // backend — this should also need a confirmation step.
                      onPressed: () {},
                    ),
                    const SizedBox(height: AppDimensions.profileBodyGap),
                    SecondaryButton(
                      label: AppStrings.settingsLogoutButton,
                      onPressed: _handleLogout,
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

  Widget _sectionHeading(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: AppDimensions.profileSectionHeadingFontSize,
        color: AppColors.agroForest950,
      ),
    );
  }
}

/// DS/Toggle — a small on/off pill switch. Built from scratch rather than
/// Flutter's Material [Switch] because that widget can't be shrunk to
/// Figma's exact 44x24 track without distorting the thumb.
class _SettingsToggle extends StatelessWidget {
  const _SettingsToggle({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: AppDimensions.settingsToggleWidth,
        height: AppDimensions.settingsToggleHeight,
        padding: const EdgeInsets.all(AppDimensions.settingsToggleThumbInset),
        decoration: BoxDecoration(
          color: value ? AppColors.agroForest950 : AppColors.agroBorder300,
          borderRadius: BorderRadius.circular(AppDimensions.pillBorderRadius),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 150),
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: AppDimensions.settingsToggleThumbSize,
            height: AppDimensions.settingsToggleThumbSize,
            decoration: const BoxDecoration(
              color: AppColors.white,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}
