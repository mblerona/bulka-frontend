import 'package:flutter/material.dart';
import 'package:bulka_frontend/core/constants/app_colors.dart';
import 'package:bulka_frontend/core/constants/app_dimensions.dart';

class LabeledTextField extends StatelessWidget {
  const LabeledTextField({
    super.key,
    required this.label,
    required this.hintText,
    this.controller,
    this.obscureText = false,
    this.keyboardType,
  });

  final String label;
  final String hintText;
  final TextEditingController? controller;
  final bool obscureText;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppDimensions.dsRadiusMd),
      borderSide: const BorderSide(color: AppColors.agroBorder300),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: AppDimensions.dsFieldLabelFontSize,
            color: AppColors.agroForest950,
          ),
        ),
        const SizedBox(height: AppDimensions.dsFieldGap),
        TextField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          style: const TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: AppDimensions.dsInputFontSize,
            color: AppColors.agroForest950,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: AppDimensions.dsInputFontSize,
              color: AppColors.agroInk500,
            ),
            filled: true,
            fillColor: AppColors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.dsInputHorizontalPadding,
              vertical: AppDimensions.dsInputVerticalPadding,
            ),
            border: border,
            enabledBorder: border,
            focusedBorder: border.copyWith(
              borderSide: const BorderSide(color: AppColors.agroGreen700),
            ),
          ),
        ),
      ],
    );
  }
}
