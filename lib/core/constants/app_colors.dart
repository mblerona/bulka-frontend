import 'package:flutter/material.dart';

class AppColors {
  // ── SHARED BRAND COLORS ──
  // Core design-system palette, reused across multiple screens/components.

  // Splash Screen, screen background
  // Login Screen, Primary Button background
  static const Color agroGreen700 = Color(0xFF526B5B);

  // Splash Screen, Title text; CTA button text
  // Login Screen, Header Band background; heading text
  static const Color agroForest950 = Color(0xFF23332B);

  // Splash Screen, CTA button background
  // Login Screen, Secondary Button background
  static const Color agroGreen100 = Color(0xFFE8F0E6);

  // Login Screen, secondary/muted text (subtitle, input placeholders, footer)
  static const Color agroInk500 = Color(0xFF68766E);

  // Login Screen, input field border
  static const Color agroBorder300 = Color(0xFFC8D6CD);

  // Splash Screen, Logo backdrop; selected language pill background
  // Login Screen, Body background; Logo backdrop; Input box background; Primary Button text
  static const Color white = Color(0xFFFFFFFF);

  // ── LANGUAGE SWITCH (DS/LanguageSwitch component) ──
  // Shared component, used on the Splash, Login and Register screens.

  // Splash Screen, Login Screen, Register Screen — pill track background
  static const Color languageSwitchTrack = Color(0x2EFFFFFF);

  // Splash Screen, Login Screen, Register Screen — selected pill text
  static const Color agroGreen800 = Color(0xFF155F28);

  // ── CHECKBOX (DS/Checkbox component) ──
  // Register Screen, Terms & Privacy Screen — checked fill
  static const Color agroGreen600 = Color(0xFF94A89A);

  // ── SPLASH SCREEN ONLY ──
  static const Color splashSubtitleText = Color(0xE6FFFFFF);
  static const Color languageLabelText = Color(0xD9FFFFFF);

  // ROLE SCREEN COLORS
  static const Color languageToggleGreen = Color(0xFF33691E);
  static const Color roleScreenBackground = Color(0xFFFAF7F0);
  static const Color black = Color(0xFF1A1A1A);
  static const Color lightGrey = Color(0xFF8C8C8C);


//FORGOT PASSWORD SCREEN BACKGROUND
  static const Color beigeBackground = Color(0xFFFAF6F0);

  // REGISTER SCREEN ONLY
  static const Color registerRoleToggleTrack = Color(0xFFF2F5F2);

  // TERMS & PRIVACY SCREEN ONLY
  static const Color agroCream100 = Color(0xFFF3F6F4);

  // EMAIL VERIFICATION SCREEN ONLY
  static const Color agroGold100 = Color(0xFFD1BFA7);

  // PROFILE SCREEN ONLY
  // Avatar circle background; Role Badge background
  static const Color profileSoftMint = Color(0xFFE8F4EC);
  // Email under name; stat card labels
  static const Color profileSecondaryText = Color(0xFF707070);
  static const Color profileStatCardBackground = Color(0xFFF5FAF6);
  static const Color profileStatCardBorder = Color(0xFFCFE2D5);

  // SETTINGS SCREEN ONLY
  // Language row — selected pill text, on the "Light" surface variant of
  // DS/LanguageSwitch (distinct one-off value in Figma, not the shared
  // agro-green-800 token used by the dark-surface variant elsewhere).
  static const Color settingsLanguageSelectedText = Color(0xFF166028);
  // Delete-account button border/text; DS/Toggle "on" track re-uses
  // agroForest950.
  static const Color settingsDangerColor = Color(0xFFD82830);

  // PROVIDER DASHBOARD SCREEN ONLY
  // "На преглед" (pending review) counter value — a distinct amber, not
  // the same as agroGold100 above (no shared Figma variable for it).
  static const Color dashboardPendingReviewAccent = Color(0xFFF0B828);

  // PROVIDER OFFERS SCREEN ONLY
  // Status pill backgrounds — pendingReview pairs with
  // dashboardPendingReviewAccent above for its text; rejected pairs with
  // settingsDangerColor.
  static const Color listingPendingReviewBadgeBackground = Color(0xFFFFF0D0);
  static const Color listingRejectedBadgeBackground = Color(0xFFFAE3E3);

  // PROVIDER AVAILABILITY CALENDAR SCREEN ONLY
  // "Блокирано" (blocked) cell/legend swatch — plain grey, no shared
  // Figma variable for it. Screen background reuses beigeBackground
  // (exact hex match for Figma's agro-cream-50).
  static const Color calendarBlockedGrey = Color(0xFF999999);

  // ALIASES
  static const Color background = roleScreenBackground;
  static const Color grey = lightGrey;
}
