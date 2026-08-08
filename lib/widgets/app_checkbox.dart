import 'package:flutter/material.dart';
import 'package:bulka_frontend/core/constants/app_colors.dart';
import 'package:bulka_frontend/core/constants/app_dimensions.dart';

class AppCheckbox extends StatelessWidget {
  const AppCheckbox({super.key, required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Container(
        width: AppDimensions.dsCheckboxSize,
        height: AppDimensions.dsCheckboxSize,
        decoration: BoxDecoration(
          color: value ? AppColors.agroGreen600 : AppColors.white,
          borderRadius: BorderRadius.circular(AppDimensions.dsRadiusSm),
          border: value
              ? null
              : Border.all(
                  color: AppColors.agroBorder300,
                  width: AppDimensions.dsCheckboxBorderWidth,
                ),
        ),
        child: value
            ? const Icon(Icons.check, size: 12, color: AppColors.white)
            : null,
      ),
    );
  }
}
