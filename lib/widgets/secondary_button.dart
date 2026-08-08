import 'package:flutter/material.dart';
import 'package:bulka_frontend/core/constants/app_colors.dart';
import 'package:bulka_frontend/core/constants/app_dimensions.dart';

class SecondaryButton extends StatelessWidget {
  const SecondaryButton({super.key, required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.agroGreen100,
          foregroundColor: AppColors.agroGreen700,
          elevation: 0,
          side: const BorderSide(color: AppColors.agroBorder300),
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
