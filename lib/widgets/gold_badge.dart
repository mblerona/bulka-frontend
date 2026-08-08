import 'package:flutter/material.dart';
import 'package:bulka_frontend/core/constants/app_colors.dart';
import 'package:bulka_frontend/core/constants/app_dimensions.dart';

class GoldBadge extends StatelessWidget {
  const GoldBadge({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.badgeHorizontalPadding,
        vertical: AppDimensions.badgeVerticalPadding,
      ),
      decoration: BoxDecoration(
        color: AppColors.agroGold100,
        borderRadius: BorderRadius.circular(AppDimensions.pillBorderRadius),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: AppDimensions.badgeFontSize,
          color: AppColors.agroForest950,
        ),
      ),
    );
  }
}
