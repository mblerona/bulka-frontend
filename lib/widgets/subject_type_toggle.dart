import 'package:flutter/material.dart';
import 'package:bulka_frontend/core/constants/app_colors.dart';
import 'package:bulka_frontend/core/constants/app_dimensions.dart';

/// 2-option segmented toggle used to pick a provider's legal subject type.
/// Visually distinct from [RoleToggle] (dark selected pill vs green), even
/// though the two share the same container padding/gap/font-size tokens.
class SubjectTypeToggle extends StatelessWidget {
  const SubjectTypeToggle({
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
      height: AppDimensions.providerSubjectToggleHeight,
      padding: const EdgeInsets.all(AppDimensions.dsToggleContainerPadding),
      decoration: BoxDecoration(
        color: AppColors.profileStatCardBackground,
        border: Border.all(color: AppColors.profileStatCardBorder),
        borderRadius: BorderRadius.circular(AppDimensions.dsRadiusMd),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < options.length; i++) ...[
            Expanded(
              child: _SubjectTypeOption(
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

class _SubjectTypeOption extends StatelessWidget {
  const _SubjectTypeOption({
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
        decoration: BoxDecoration(
          color: isSelected ? AppColors.agroForest950 : Colors.transparent,
          borderRadius: BorderRadius.circular(
            AppDimensions.providerSubjectToggleOptionRadius,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: AppDimensions.dsToggleFontSize,
            color: isSelected ? AppColors.white : AppColors.agroForest950,
          ),
        ),
      ),
    );
  }
}
