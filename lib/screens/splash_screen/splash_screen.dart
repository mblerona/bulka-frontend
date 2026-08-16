import 'package:flutter/material.dart';
import 'package:bulka_frontend/core/constants/app_colors.dart';
import 'package:bulka_frontend/core/constants/app_dimensions.dart';
import 'package:bulka_frontend/core/constants/app_strings.dart';
import 'package:bulka_frontend/screens/login_screen/login_screen.dart';
import 'package:bulka_frontend/widgets/language_switch.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String _selectedLanguageCode = AppStrings.languageCodeMk;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.agroGreen700,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.splashHorizontalPadding,
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final double availableHeight = constraints.maxHeight;

              // The logo is the only fixed-size (non-text) element allowed to
              // shrink. It stays at its full design size as long as the
              // flexible gaps can absorb the shortfall on their own; only
              // once available height drops below what the rest of the
              // content needs does the logo start giving up room, down to a
              // floor that keeps it recognizable.
              final double logoSize =
                  (availableHeight -
                          AppDimensions.splashFixedContentHeightExcludingLogo)
                      .clamp(
                        AppDimensions.splashLogoMinSize,
                        AppDimensions.splashLogoSize,
                      )
                      .toDouble();

              final Widget content = _SplashContent(
                logoSize: logoSize,
                selectedLanguageCode: _selectedLanguageCode,
                onLanguageChanged: (code) {
                  setState(() => _selectedLanguageCode = code);
                },
              );

              // Absolute floor: fixed text/controls + smallest logo, with the
              // flexible gaps collapsed to zero. Only below this point can
              // spacing/logo shrinking alone no longer prevent overflow, so
              // only then does the screen become scrollable.
              final double minPossibleHeight =
                  AppDimensions.splashFixedContentHeightExcludingLogo +
                  AppDimensions.splashLogoMinSize;

              if (availableHeight < minPossibleHeight) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: availableHeight),
                    child: content,
                  ),
                );
              }

              return content;
            },
          ),
        ),
      ),
    );
  }
}

class _SplashContent extends StatelessWidget {
  const _SplashContent({
    required this.logoSize,
    required this.selectedLanguageCode,
    required this.onLanguageChanged,
  });

  final double logoSize;
  final String selectedLanguageCode;
  final ValueChanged<String> onLanguageChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Flexible(
          flex: AppDimensions.splashTopSpacerHeight.round(),
          child: const SizedBox(height: AppDimensions.splashTopSpacerHeight),
        ),
        _SplashLogo(size: logoSize),
        Flexible(
          flex: AppDimensions.splashContentGap.round(),
          child: const SizedBox(height: AppDimensions.splashContentGap),
        ),
        Text(
          AppStrings.splashTitle,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: AppDimensions.splashTitleFontSize,
            color: AppColors.agroForest950,
          ),
        ),
        Flexible(
          flex: AppDimensions.splashContentGap.round(),
          child: const SizedBox(height: AppDimensions.splashContentGap),
        ),
        SizedBox(
          width: AppDimensions.splashSubtitleMaxWidth,
          child: Text(
            AppStrings.splashSubtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: AppDimensions.splashSubtitleFontSize,
              color: AppColors.splashSubtitleText,
            ),
          ),
        ),
        Flexible(
          flex: AppDimensions.splashMidSpacerHeight.round(),
          child: const SizedBox(height: AppDimensions.splashMidSpacerHeight),
        ),
        Text(
          AppStrings.chooseLanguage,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: AppDimensions.languageLabelFontSize,
            color: AppColors.languageLabelText,
          ),
        ),
        Flexible(
          flex: AppDimensions.splashContentGap.round(),
          child: const SizedBox(height: AppDimensions.splashContentGap),
        ),
        LanguageSwitch(
          selectedLanguageCode: selectedLanguageCode,
          onChanged: onLanguageChanged,
        ),
        Flexible(
          flex: AppDimensions.splashContentGap.round(),
          child: const SizedBox(height: AppDimensions.splashContentGap),
        ),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const LoginScreen()));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.agroGreen100,
              foregroundColor: AppColors.agroForest950,
              elevation: 0,
              padding: const EdgeInsets.symmetric(
                vertical: AppDimensions.ctaVerticalPadding,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  AppDimensions.ctaBorderRadius,
                ),
              ),
            ),
            child: Text(
              AppStrings.continueButton,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: AppDimensions.ctaFontSize,
              ),
            ),
          ),
        ),
        Flexible(
          flex: AppDimensions.splashBottomSpacerHeight.round(),
          child: const SizedBox(height: AppDimensions.splashBottomSpacerHeight),
        ),
      ],
    );
  }
}

class _SplashLogo extends StatelessWidget {
  const _SplashLogo({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    final double scale = size / AppDimensions.splashLogoSize;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              color: AppColors.white,
              shape: BoxShape.circle,
            ),
          ),
          Positioned(
            left: AppDimensions.splashLogoMarkLeft * scale,
            top: AppDimensions.splashLogoMarkTop * scale,
            width: AppDimensions.splashLogoMarkWidth * scale,
            height: AppDimensions.splashLogoMarkHeight * scale,
            child: Image.asset(
              'assets/images/SplashScreen/logo.png',
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }
}
