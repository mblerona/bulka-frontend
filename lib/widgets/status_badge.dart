import 'package:flutter/material.dart';
import 'package:bulka_frontend/core/constants/app_dimensions.dart';

/// DS/Badge — a small pill-shaped status indicator. Figma reuses this same
/// component with different colors per status (e.g. gold for "pending",
/// mint for "verified"), so background/text color are passed in per use.
class StatusBadge extends StatelessWidget {
  const StatusBadge({
    super.key,
    required this.label,
    required this.backgroundColor,
    required this.textColor,
    this.horizontalPadding = AppDimensions.badgeHorizontalPadding,
    this.verticalPadding = AppDimensions.badgeVerticalPadding,
    this.fontSize = AppDimensions.badgeFontSize,
  });

  final String label;
  final Color backgroundColor;
  final Color textColor;
  final double horizontalPadding;
  final double verticalPadding;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: verticalPadding,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppDimensions.pillBorderRadius),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: fontSize,
          color: textColor,
        ),
      ),
    );
  }
}
