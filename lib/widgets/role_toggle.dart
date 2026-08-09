import 'package:flutter/material.dart';
import 'package:bulka_frontend/core/constants/app_colors.dart';
import 'package:bulka_frontend/core/constants/app_dimensions.dart';

class RoleToggle extends StatelessWidget {
  const RoleToggle({
    super.key,
    required this.options,
    required this.selectedIndex,
    required this.onChanged,
  });

  final List<String> options;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.dsToggleContainerPadding),
      decoration: BoxDecoration(
        color: AppColors.registerRoleToggleTrack,
        borderRadius: BorderRadius.circular(AppDimensions.dsRadiusMd),
      ),
      child: Row(
        children: [
          for (var i = 0; i < options.length; i++) ...[
            Expanded(
              child: _RoleOption(
                label: options[i],
                isSelected: i == selectedIndex,
                onTap: () => onChanged(i),
              ),
            ),
            if (i != options.length - 1)
              const SizedBox(width: AppDimensions.dsToggleOptionGap),
          ],
        ],
      ),
    );
  }
}

class _RoleOption extends StatelessWidget {
  const _RoleOption({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: AppDimensions.registerRoleToggleVerticalPadding,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.agroGreen700 : Colors.transparent,
          borderRadius: BorderRadius.circular(
            AppDimensions.registerRoleToggleOptionRadius,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: AppDimensions.dsToggleFontSize,
            color: isSelected ? AppColors.white : AppColors.agroInk500,
          ),
        ),
      ),
    );
  }
}
