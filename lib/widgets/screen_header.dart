import 'package:flutter/material.dart';
import 'package:bulka_frontend/core/constants/app_colors.dart';
import 'package:bulka_frontend/core/constants/app_dimensions.dart';
import 'package:bulka_frontend/widgets/language_switch.dart';

class ScreenHeader extends StatelessWidget {
  const ScreenHeader({
    super.key,
    required this.title,
    required this.titleFontSize,
    required this.bottomPadding,
    required this.contentGap,
    this.onBackPressed,
    this.selectedLanguageCode,
    this.onLanguageChanged,
    this.subtitle,
  }) : assert(
         (selectedLanguageCode == null) == (onLanguageChanged == null),
         'selectedLanguageCode and onLanguageChanged must be provided together',
       );

  final String title;
  final double titleFontSize;
  final double bottomPadding;
  final double contentGap;
  final VoidCallback? onBackPressed;
  final String? selectedLanguageCode;
  final ValueChanged<String>? onLanguageChanged;
  final String? subtitle;

  bool get _showLanguageSwitch => selectedLanguageCode != null;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        left: AppDimensions.dsHeaderHorizontalPadding,
        right: AppDimensions.dsHeaderHorizontalPadding,
        top: AppDimensions.dsHeaderTopPadding,
        bottom: bottomPadding,
      ),
      decoration: const BoxDecoration(
        color: AppColors.agroForest950,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(AppDimensions.dsRadiusSm),
          bottomRight: Radius.circular(AppDimensions.dsRadiusSm),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.arrow_back,
                  color: AppColors.white,
                  size: AppDimensions.dsBackIconSize,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: onBackPressed ?? () => Navigator.maybePop(context),
              ),
              if (_showLanguageSwitch) ...[
                const Spacer(),
                LanguageSwitch(
                  selectedLanguageCode: selectedLanguageCode!,
                  onChanged: onLanguageChanged!,
                ),
              ],
            ],
          ),
          SizedBox(height: contentGap),
          Row(
            children: [
              SizedBox(
                width: AppDimensions.dsHeaderLogoSize,
                height: AppDimensions.dsHeaderLogoSize,
                child: Stack(
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        color: AppColors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                    Positioned(
                      left: AppDimensions.dsHeaderLogoMarkOffset,
                      top: AppDimensions.dsHeaderLogoMarkOffset,
                      width: AppDimensions.dsHeaderLogoMarkSize,
                      height: AppDimensions.dsHeaderLogoMarkSize,
                      child: Image.asset(
                        'assets/images/SplashScreen/logo.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: AppDimensions.dsHeaderTitleRowGap),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: titleFontSize,
                    color: AppColors.white,
                  ),
                ),
              ),
            ],
          ),
          if (subtitle != null) ...[
            SizedBox(height: contentGap),
            Text(
              subtitle!,
              style: const TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: AppDimensions.termsPrivacySubtitleFontSize,
                color: AppColors.languageLabelText,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
