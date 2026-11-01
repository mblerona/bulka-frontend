import 'package:flutter/material.dart';
import 'package:bulka_frontend/core/constants/app_colors.dart';
import 'package:bulka_frontend/core/constants/app_dimensions.dart';

/// The red one-line message shown above a form's submit button when
/// validation or the backend request fails.
class FormErrorText extends StatelessWidget {
  const FormErrorText(this.message, {super.key});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Text(
      message,
      style: const TextStyle(
        fontWeight: FontWeight.w500,
        fontSize: AppDimensions.dsFooterFontSize,
        color: AppColors.settingsDangerColor,
      ),
    );
  }
}
