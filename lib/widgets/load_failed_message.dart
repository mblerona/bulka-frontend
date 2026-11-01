import 'package:flutter/material.dart';
import 'package:bulka_frontend/core/constants/app_colors.dart';
import 'package:bulka_frontend/core/constants/app_dimensions.dart';
import 'package:bulka_frontend/core/constants/app_strings.dart';

/// "Couldn't load X." with a "Try again" link, for data from the backend.
class LoadFailedMessage extends StatelessWidget {
  const LoadFailedMessage({
    super.key,
    required this.message,
    required this.onRetry,
    this.fontSize = AppDimensions.dsInputFontSize,
  });

  final String message;
  final VoidCallback onRetry;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            message,
            style: TextStyle(
              fontSize: fontSize,
              color: AppColors.profileSecondaryText,
            ),
          ),
        ),
        TextButton(
          onPressed: onRetry,
          child: Text(
            AppStrings.retryButton,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: fontSize,
              color: AppColors.agroGreen600,
            ),
          ),
        ),
      ],
    );
  }
}

/// A small spinner for a section that's loading.
class SectionLoadingIndicator extends StatelessWidget {
  const SectionLoadingIndicator({super.key, this.size = 24});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox.square(
        dimension: size,
        child: const CircularProgressIndicator(
          strokeWidth: 2,
          color: AppColors.agroGreen600,
        ),
      ),
    );
  }
}
