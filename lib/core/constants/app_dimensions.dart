class AppDimensions {
  // SPLASH SCREEN
  static const double splashHorizontalPadding = 32;
  static const double splashContentGap = 28;
  static const double splashTopSpacerHeight = 120;
  static const double splashMidSpacerHeight = 60;
  static const double splashBottomSpacerHeight = 70;

  static const double splashLogoSize = 148;
  static const double splashLogoMarkWidth = 120;
  static const double splashLogoMarkHeight = 125.3;
  static const double splashLogoMarkTop = 11.35;
  static const double splashLogoMarkLeft = 14;

  static const double splashTitleFontSize = 32;
  static const double splashSubtitleFontSize = 14;
  static const double splashSubtitleMaxWidth = 280;
  static const double languageLabelFontSize = 12;
  static const double ctaFontSize = 15;

  static const double languageSwitchPadding = 3;
  static const double languageSwitchGap = 2;
  static const double languageOptionHorizontalPadding = 10;
  static const double languageOptionVerticalPadding = 6;
  static const double languageOptionFontSize = 11;
  static const double pillBorderRadius = 999;

  static const double ctaBorderRadius = 14;
  static const double ctaVerticalPadding = 16;

  // Natural (non-shrinking) height of the title, subtitle, language label,
  // language switch and CTA button at their fixed design typography — i.e.
  // everything on the splash screen except the logo and the flexible gaps.
  // Used to work out how much vertical room is left for the logo on short
  // screens. Derived from the Figma frame's own element heights, not from
  // any specific device.
  static const double splashFixedContentHeightExcludingLogo = 169;
  static const double splashLogoMinSize = 100;

  // ── SHARED DESIGN-SYSTEM DIMENSIONS ──
  // Header Band, DS/Input/Field, DS/Button, DS/Checkbox and Footer values
  // reused across multiple screens (radius/sm and radius/md in Figma).

  // Login Screen, Forgot Password Screen, Register Screen — Header Band
  static const double dsHeaderHorizontalPadding = 24;
  static const double dsHeaderTopPadding = 56;
  static const double dsBackIconSize = 22;
  static const double dsHeaderTitleRowGap = 10;
  static const double dsHeaderLogoSize = 32;
  static const double dsHeaderLogoMarkSize = 24;
  static const double dsHeaderLogoMarkOffset = 4;

  // Login Screen, Forgot Password Screen, Register Screen — Header Band
  // corners; Register Screen, Terms & Privacy Screen — DS/Checkbox corners
  // (radius/sm)
  static const double dsRadiusSm = 8;

  // Terms & Privacy Screen — Legal Text Card corners (radius/lg)
  static const double dsRadiusLg = 20;

  // Forgot Password Screen, Register Screen — Header Band bottom
  // padding/gap/title size (the "compact" header variant; Login Screen uses
  // its own larger values below)
  static const double dsCompactHeaderBottomPadding = 24;
  static const double dsCompactHeaderGap = 16;
  static const double dsCompactHeaderTitleFontSize = 24;

  // Login Screen, Forgot Password Screen, Register Screen — Body
  static const double dsBodyHorizontalPadding = 24;
  static const double dsBodyTopPadding = 28;
  static const double dsSubheadingFontSize = 13;

  // Register Screen, Terms & Privacy Screen — uniform Body padding
  static const double dsBodyPadding = 24;

  // Login Screen, Register Screen — Body gap
  static const double dsBodyGap = 18;

  // Login Screen, Forgot Password Screen, Register Screen — DS/Input/Field
  static const double dsFieldGap = 6;
  static const double dsFieldLabelFontSize = 12;
  static const double dsInputHorizontalPadding = 14;
  static const double dsInputVerticalPadding = 13;
  static const double dsInputFontSize = 14;

  // Login Screen, Forgot Password Screen, Register Screen — DS/Button,
  // DS/Input radius (radius/md)
  static const double dsRadiusMd = 14;
  static const double dsButtonHorizontalPadding = 24;
  static const double dsButtonVerticalPadding = 14;
  static const double dsButtonFontSize = 14;

  // Login Screen, Forgot Password Screen, Register Screen — Footer row
  static const double dsFooterFontSize = 12;
  static const double dsFooterGap = 4;

  // Register Screen, Terms & Privacy Screen — DS/Checkbox size/border and the
  // gap between a checkbox and its adjacent label text
  static const double dsCheckboxSize = 20;
  static const double dsCheckboxBorderWidth = 1.5;
  static const double dsCheckboxTextGap = 10;

  // LOGIN SCREEN ONLY
  static const double loginHeaderBottomPadding = 28;
  static const double loginHeaderRowGap = 20;
  static const double loginTitleFontSize = 26;

  static const double loginBodyBottomPadding = 28;

  static const double loginHeadingGap = 4;
  static const double loginHeadingFontSize = 20;

  static const double loginForgotPasswordFontSize = 12;

  // FORGOT PASSWORD SCREEN ONLY
  static const double forgotPasswordBodyBottomPadding = 24;
  static const double forgotPasswordBodyGap = 20;

  static const double forgotPasswordHeadingGap = 6;
  static const double forgotPasswordHeadingFontSize = 18;

  static const double forgotPasswordIconWrapSize = 64;
  static const double forgotPasswordIconSize = 28;

  // REGISTER SCREEN ONLY
  static const double registerRoleLabelFontSize = 13;
  static const double registerRoleTogglePadding = 4;
  static const double registerRoleToggleGap = 4;
  static const double registerRoleToggleRadius = 14;
  static const double registerRoleToggleOptionRadius = 10;
  static const double registerRoleToggleVerticalPadding = 12;
  static const double registerRoleToggleFontSize = 13;

  static const double registerTermsFontSize = 12;

  // TERMS & PRIVACY SCREEN ONLY
  static const double termsPrivacyTitleFontSize = 22;
  static const double termsPrivacySubtitleFontSize = 12;

  static const double termsPrivacyBodyGap = 16;
  static const double termsPrivacyBottomSpacerHeight = 20;

  static const double termsPrivacyCardHeight = 380;
  static const double termsPrivacyCardPadding = 18;
  static const double termsPrivacyCardGap = 10;
  static const double termsPrivacyCardHeadingFontSize = 14;
  static const double termsPrivacyCardBodyFontSize = 12;

  static const double termsPrivacyConsentFontSize = 12;

  // ── BADGE (DS/Badge component) ──
  static const double badgeHorizontalPadding = 12;
  static const double badgeVerticalPadding = 6;
  static const double badgeFontSize = 11;

  // EMAIL VERIFICATION SCREEN ONLY
  static const double emailVerificationGap = 20;
  static const double emailVerificationTopSpacerFlex = 149;
  static const double emailVerificationBottomSpacerFlex = 149;

  static const double emailVerificationIconWrapSize = 96;
  static const double emailVerificationIconSize = 40;

  static const double emailVerificationTitleFontSize = 22;
  static const double emailVerificationEmailFontSize = 14;

  static const double emailVerificationSpacerHeight = 30;
  static const double emailVerificationChangeEmailFontSize = 12;
}
