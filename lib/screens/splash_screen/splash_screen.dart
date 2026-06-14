import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: [0.0, 1.0],
          colors: [
            AppColors.backgroundTop,
            AppColors.backgroundBottom,
          ],
        ),
      ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 2),
                _buildLogo(),
                const Spacer(flex: 2),
                _buildTagline(),
                const Spacer(flex: 2),
                _buildStartButton(context),
                const Spacer(flex: 2),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Image.asset(
          'assets/images/flower_logo.png',
          width: 97,
          height: 133,
        ),
        const SizedBox(width: 20),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.appName,
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w700,
                fontSize: 48,
                color: AppColors.white,
              ),
            ),
            Text(
              AppStrings.appSubtitle,
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w400,
                fontSize: 15,
                color: AppColors.subtitleGrey,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTagline() {
    return Text(
      AppStrings.welcomeTagline,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontFamily: 'Montserrat',
        fontWeight: FontWeight.w500,
        fontSize: 12,
        color: AppColors.taglineGreen,
        letterSpacing: 12 * 0.08,
      ),
    );
  }

  Widget _buildStartButton(BuildContext context) {
    return SizedBox(
      width: 270,
      height: 52,
      child: ElevatedButton(
        onPressed: () {
          // TODO: Navigate to Choose Role screen
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.buttonRed,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: Text(
          AppStrings.startButton,
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w500,
            fontSize: 12,
            color: AppColors.white,
            letterSpacing: 12 * 0.08,
          ),
        ),
      ),
    );
  }
}