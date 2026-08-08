import 'package:flutter/material.dart';
import 'package:bulka_frontend/core/constants/app_colors.dart';
import 'package:bulka_frontend/core/constants/app_dimensions.dart';
import 'package:bulka_frontend/core/constants/app_strings.dart';

class LanguageSwitch extends StatelessWidget {
  const LanguageSwitch({
    super.key,
    required this.selectedLanguageCode,
    required this.onChanged,
  });

  final String selectedLanguageCode;
  final ValueChanged<String> onChanged;

  static const List<String> _languageCodes = [
    AppStrings.languageCodeMk,
    AppStrings.languageCodeSq,
    AppStrings.languageCodeEn,
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.languageSwitchPadding),
      decoration: BoxDecoration(
        color: AppColors.languageSwitchTrack,
        borderRadius: BorderRadius.circular(AppDimensions.pillBorderRadius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final code in _languageCodes) ...[
            _LanguageOption(
              code: code,
              isSelected: code == selectedLanguageCode,
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
    required this.onTap,
  });

  final String code;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
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
            color: isSelected ? AppColors.agroGreen800 : AppColors.white,
          ),
        ),
      ),
    );
  }
}
