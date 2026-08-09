import 'package:flutter/material.dart';
import 'package:bulka_frontend/core/constants/app_colors.dart';
import 'package:bulka_frontend/core/constants/app_dimensions.dart';

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.backgroundColor = AppColors.agroGreen700,
    this.disabledBackgroundColor = AppColors.agroBorder300,
    this.disabledForegroundColor = AppColors.agroInk500,
  });

  final String label;
  final VoidCallback? onPressed;
  final Color backgroundColor;
  final Color disabledBackgroundColor;
  final Color disabledForegroundColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: AppColors.white,
          disabledBackgroundColor: disabledBackgroundColor,
          disabledForegroundColor: disabledForegroundColor,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.dsButtonHorizontalPadding,
            vertical: AppDimensions.dsButtonVerticalPadding,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.dsRadiusMd),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: AppDimensions.dsButtonFontSize,
          ),
        ),
      ),
    );
  }
}
