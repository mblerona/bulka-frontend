import 'package:flutter/material.dart';
import 'package:bulka_frontend/core/constants/app_colors.dart';
import 'package:bulka_frontend/core/constants/app_dimensions.dart';
import 'package:bulka_frontend/core/constants/app_strings.dart';

/// DS/LanguageSwitch has two surface variants in Figma: the default (used
/// on the dark Header Band on Splash/Login/Register) and "Light" (used on
/// white/light section backgrounds, e.g. the Settings screen's language
/// row) — same shape/spacing, different track/text colors.
enum LanguageSwitchSurface { dark, light }

class LanguageSwitch extends StatelessWidget {
  const LanguageSwitch({
    super.key,
    required this.selectedLanguageCode,
    required this.onChanged,
    this.surface = LanguageSwitchSurface.dark,
  });

  final String selectedLanguageCode;
  final ValueChanged<String> onChanged;
  final LanguageSwitchSurface surface;

  static const List<String> _languageCodes = [
    AppStrings.languageCodeMk,
    AppStrings.languageCodeSq,
    AppStrings.languageCodeEn,
  ];

  @override
  Widget build(BuildContext context) {
    final isLight = surface == LanguageSwitchSurface.light;
    return Container(
      padding: const EdgeInsets.all(AppDimensions.languageSwitchPadding),
      decoration: BoxDecoration(
        color: isLight
            ? AppColors.agroBorder300
            : AppColors.languageSwitchTrack,
        borderRadius: BorderRadius.circular(AppDimensions.pillBorderRadius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final code in _languageCodes) ...[
            _LanguageOption(
              code: code,
              isSelected: code == selectedLanguageCode,
              isLight: isLight,
              onTap: () => onChanged(code),
            ),
            if (code != _languageCodes.last)
              const SizedBox(width: AppDimensions.languageSwitchGap),
          ],
        ],
      ),
    );
  }
}

class _LanguageOption extends StatelessWidget {
  const _LanguageOption({
    required this.code,
    required this.isSelected,
    required this.isLight,
    required this.onTap,
  });

  final String code;
  final bool isSelected;
  final bool isLight;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color textColor;
    if (isSelected) {
      textColor = isLight
          ? AppColors.settingsLanguageSelectedText
          : AppColors.agroGreen800;
    } else {
      textColor = isLight ? AppColors.agroForest950 : AppColors.white;
    }
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.languageOptionHorizontalPadding,
          vertical: AppDimensions.languageOptionVerticalPadding,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(AppDimensions.pillBorderRadius),
        ),
        child: Text(
          code,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: AppDimensions.languageOptionFontSize,
            color: textColor,
          ),
        ),
      ),
    );
  }
}
