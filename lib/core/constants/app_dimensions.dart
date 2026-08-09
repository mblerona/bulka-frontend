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

  // Register Screen, Terms & Privacy Screen, Provider Profile Screen —
  // DS/Checkbox size/border, the gap to its label, and the label's own
  // text size (Regular, ink-900)
  static const double dsCheckboxSize = 20;
  static const double dsCheckboxBorderWidth = 1.5;
  static const double dsCheckboxTextGap = 10;
  static const double dsCheckboxLabelFontSize = 12;

  // Register Screen, Provider Profile Screen — 2-option segmented toggle
  // (Role Toggle / Subject Type Toggle) container padding, option gap and
  // label font size — the two toggles use different colors/option radius,
  // kept per-component below
  static const double dsToggleContainerPadding = 4;
  static const double dsToggleOptionGap = 4;
  static const double dsToggleFontSize = 13;

  // My Tickets Screen, Provider Dashboard Screen — small pill status badge
  // (white bg, colored text) used for ticket/reservation status
  static const double dsStatusPillHorizontalPadding = 10;
  static const double dsStatusPillVerticalPadding = 4;
  static const double dsStatusPillFontSize = 10;

  // Provider Profile Setup Screen, Notifications Screen — Header Band gap
  // used by the "compact header with a subtitle line" variant
  static const double dsHeaderSubtitleGap = 10;

  // Provider Dashboard Screen, Provider Offers Screen — Header Band gap for
  // the "nav-bar root screen" header variant (no back button)
  static const double dsRootHeaderGap = 6;
  // ...and that same variant's Body top padding (24, not the 28 most
  // other screens' Body uses)
  static const double dsRootBodyTopPadding = 24;

  // Provider Profile Setup Screen, New Support Ticket Screen — the same
  // "compact header with a subtitle line" variant's (smaller) title size
  static const double dsHeaderSubtitleTitleFontSize = 22;

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
  static const double registerRoleToggleOptionRadius = 10;
  static const double registerRoleToggleVerticalPadding = 12;

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

  // PROFILE SCREEN ONLY
  static const double profileBodyGap = 28;
  static const double profileBodyBottomPadding = 40;

  static const double profileAvatarRowGap = 14;
  static const double profileAvatarSize = 72;
  static const double profileAvatarInitialsFontSize = 22;

  static const double profileNameColGap = 6;
  static const double profileNameFontSize = 16;
  static const double profileEmailFontSize = 12;

  static const double profileRoleBadgeHorizontalPadding = 10;
  static const double profileRoleBadgeVerticalPadding = 4;
  static const double profileRoleBadgeFontSize = 10;

  static const double profileSectionHeadingFontSize = 14;
  static const double profileFieldsGap = 16;

  static const double profileStatsRowGap = 12;
  static const double profileStatCardWidth = 163;
  static const double profileStatCardPadding = 16;
  static const double profileStatCardGap = 4;
  static const double profileStatNumberFontSize = 20;
  static const double profileStatLabelFontSize = 11;

  // PROVIDER PROFILE SCREEN ONLY
  static const double providerSubjectTypeGap = 10;
  static const double providerSubjectToggleHeight = 48;
  static const double providerSubjectToggleOptionRadius = 11;

  static const double providerChecklistBoxPadding = 16;
  static const double providerChecklistRowGap = 14;
  static const double providerChevronIconSize = 18;

  // PROVIDER PROFILE SETUP SCREEN ONLY (Правно лице / legal entity)
  static const double providerSetupSectionGap = 24;

  static const double providerLogoAvatarSize = 84;
  static const double providerLogoEditBadgeSize = 28;
  static const double providerLogoEditBadgeBorderWidth = 2;
  static const double providerLogoEditBadgeIconSize = 14;
  static const double providerLogoCaptionGap = 10;
  static const double providerLogoCaptionFontSize = 12;

  static const double providerContactsSectionGap = 10;

  static const double providerPhotoTileSize = 106;
  static const double providerPhotoGridGap = 12;
  static const double providerAddPhotoPlusFontSize = 28;

  // ── BOTTOM NAV (DS/Nav/Tourist, DS/Nav/Provider) ──
  static const double bottomNavHeight = 64;
  static const double bottomNavTopPadding = 8;
  static const double bottomNavIndicatorHeight = 3;
  static const double bottomNavIndicatorWidth = 24;
  static const double bottomNavIndicatorGap = 4;
  static const double bottomNavIconSize = 22;
  static const double bottomNavLabelFontSize = 10;

  // ── NOTIFICATIONS SCREEN ──
  static const double notificationsBodyTopPadding = 24;
  static const double notificationsListGap = 12;
  static const double notificationsCardPadding = 14;
  static const double notificationsCardContentGap = 4;
  static const double notificationsCardTitleFontSize = 13;
  static const double notificationsCardTimestampFontSize = 10;
  static const double notificationsCardMessageFontSize = 11;

  // ── BOTTOM NAV BADGE (unread count pill on DS/Nav tabs) ──
  static const double bottomNavBadgeSize = 16;
  static const double bottomNavBadgeFontSize = 9;
  static const double bottomNavBadgeHorizontalPadding = 3;

  // ── SETTINGS SCREEN ──
  static const double settingsSectionGap = 12;

  static const double settingsLanguageRowHeight = 60;
  static const double settingsLanguageRowHorizontalPadding = 16;
  static const double settingsLanguageRowVerticalPadding = 14;
  static const double settingsLanguageRowLabelFontSize = 13;

  static const double settingsPrivacyDescriptionFontSize = 11;

  static const double settingsToggleWidth = 44;
  static const double settingsToggleHeight = 24;
  static const double settingsToggleThumbSize = 18;
  static const double settingsToggleThumbInset = 3;

  // ── CHAT LIST SCREEN ──
  static const double chatListBodyTopPadding = 20;
  static const double chatListRowGap = 8;
  static const double chatListRowHorizontalPadding = 8;
  static const double chatListRowVerticalPadding = 12;
  static const double chatListRowContentGap = 12;
  static const double chatListContentGap = 2;
  static const double chatListMetaGap = 8;

  static const double chatListAvatarSize = 48;
  static const double chatListAvatarInitialsFontSize = 15;

  static const double chatListNameFontSize = 13;
  static const double chatListContextFontSize = 10;
  static const double chatListPreviewFontSize = 11;
  static const double chatListTimestampFontSize = 10;

  static const double chatListBadgeHorizontalPadding = 7;
  static const double chatListBadgeVerticalPadding = 3;
  static const double chatListBadgeFontSize = 10;

  // ── CHAT THREAD SCREEN ──
  static const double chatThreadHeaderHeight = 100;
  static const double chatThreadHeaderBottomPadding = 20;
  static const double chatThreadHeaderGap = 12;
  static const double chatThreadHeaderLogoSize = 22;

  static const double chatThreadAvatarSize = 38;
  static const double chatThreadAvatarInitialsFontSize = 13;
  static const double chatThreadNameFontSize = 15;
  static const double chatThreadContextFontSize = 11;
  static const double chatThreadNameColGap = 2;

  static const double chatThreadBodyVerticalPadding = 20;
  static const double chatThreadBodyGap = 10;
  static const double chatThreadDateDividerFontSize = 10;

  static const double chatThreadBubbleHorizontalPadding = 14;
  static const double chatThreadBubbleVerticalPadding = 10;
  static const double chatThreadBubbleRadius = 16;
  static const double chatThreadBubbleMaxWidth = 240;
  static const double chatThreadBubbleFontSize = 13;

  static const double chatThreadInputBarGap = 10;
  static const double chatThreadInputBarHorizontalPadding = 16;
  static const double chatThreadInputBarVerticalPadding = 12;
  static const double chatThreadInputPillHorizontalPadding = 16;
  static const double chatThreadInputPillVerticalPadding = 10;
  static const double chatThreadInputFontSize = 13;
  static const double chatThreadSendButtonSize = 40;
  static const double chatThreadSendIconFontSize = 16;

  // ── MY TICKETS SCREEN ──
  static const double myTicketsBodyTopPadding = 24;
  static const double myTicketsCardGap = 12;
  static const double myTicketsCardPadding = 16;
  static const double myTicketsCardRowGap = 10;

  static const double myTicketsTicketNumberFontSize = 11;

  static const double myTicketsTitleFontSize = 14;
  static const double myTicketsLastChangedFontSize = 11;

  // ── NEW SUPPORT TICKET SCREEN ──
  static const double newTicketBodyGap = 16;
  static const double newTicketFieldGap = 8;

  static const double newTicketTextareaHeight = 110;

  static const double newTicketAttachmentBoxHeight = 80;
  static const double newTicketAttachmentBoxGap = 4;
  static const double newTicketAttachmentSubtextFontSize = 11;

  static const double newTicketAttachmentRowIconSize = 20;
  static const double newTicketAttachmentRowGap = 10;

  // ── PROVIDER DASHBOARD SCREEN ──
  static const double dashboardBodyGap = 24;
  static const double dashboardSectionGap = 12;

  static const double dashboardCounterCardGap = 10;
  static const double dashboardCounterCardPadding = 14;
  static const double dashboardCounterCardContentGap = 2;
  static const double dashboardCounterValueFontSize = 18;
  static const double dashboardCounterLabelFontSize = 10;

  static const double dashboardReservationCardPadding = 14;
  static const double dashboardReservationCardGap = 10;
  static const double dashboardReservationTitleFontSize = 14;
  static const double dashboardReservationMetaFontSize = 12;
  static const double dashboardReservationListingFontSize = 11;

  static const double dashboardActionButtonRadius = 10;
  static const double dashboardActionButtonVerticalPadding = 9;
  static const double dashboardActionButtonFontSize = 11;
  static const double dashboardActionButtonGap = 10;

  // ── PROVIDER OFFERS SCREEN ──
  static const double offersBodyGap = 20;

  static const double offersFilterChipHorizontalPadding = 12;
  static const double offersFilterChipVerticalPadding = 7;
  static const double offersFilterChipFontSize = 11;
  static const double offersFilterChipGap = 8;

  static const double offersCardImageHeight = 120;
  static const double offersCardInfoPadding = 14;
  static const double offersCardInfoGap = 8;
  static const double offersCardTitleFontSize = 14;
  static const double offersCardMetaFontSize = 11;

  // Reuses dashboard's action-button radius/padding/font (identical spec)
  // for "Уреди"/"Активирај повторно"/etc.

  // ── PROVIDER AVAILABILITY CALENDAR SCREEN ──
  static const double calendarListingContextGap = 12;
  static const double calendarListingContextTopPadding = 20;
  static const double calendarListingContextBottomPadding = 12;
  static const double calendarListingThumbSize = 48;
  static const double calendarListingNameColGap = 2;
  static const double calendarListingLocationFontSize = 11;

  static const double calendarLegendRowGap = 16;
  static const double calendarLegendItemGap = 6;
  static const double calendarLegendSwatchSize = 12;
  static const double calendarLegendSwatchRadius = 4;
  static const double calendarLegendFontSize = 12;
  static const double calendarLegendTopPadding = 4;
  static const double calendarLegendBottomPadding = 16;

  static const double calendarMonthNavHeight = 100;
  static const double calendarMonthNavTopPadding = 8;
  static const double calendarMonthNavBottomPadding = 16;
  static const double calendarNavArrowSize = 32;
  static const double calendarNavArrowFontSize = 18;
  static const double calendarMonthTitleFontSize = 16;

  static const double calendarGridBottomPadding = 12;
  static const double calendarGridRowGap = 6;
  static const double calendarCellGap = 4;
  static const double calendarWeekdayCellHeight = 20;
  static const double calendarWeekdayFontSize = 11;
  static const double calendarCellHeight = 40;
  static const double calendarCellRadius = 8;
  static const double calendarCellFontSize = 13;
  static const double calendarSelectedBorderWidth = 2;

  static const double calendarActionsTopPadding = 12;
  static const double calendarActionsBottomPadding = 32;
  static const double calendarActionsGap = 12;

  // ── CREATE OFFER WIZARD ──
  static const double wizardTopBarTopPadding = 20;
  static const double wizardTopBarBottomPadding = 12;
  static const double wizardCloseFontSize = 16;

  static const double wizardProgressBottomPadding = 20;
  static const double wizardProgressTrackHeight = 6;

  static const double wizardContentTopPadding = 8;
  static const double wizardContentBottomPadding = 24;
  static const double wizardContentGap = 16;
  static const double wizardHeadingFontSize = 24;
  static const double wizardSubtitleFontSize = 14;

  static const double wizardChipGap = 8;
  static const double wizardChipHorizontalPadding = 12;
  static const double wizardChipVerticalPadding = 8;
  static const double wizardChipFontSize = 11;

  static const double wizardStepperRowVerticalPadding = 12;
  static const double wizardStepperLabelFontSize = 16;
  static const double wizardStepperGap = 18;
  static const double wizardStepperButtonSize = 32;
  static const double wizardStepperButtonFontSize = 16;
  static const double wizardStepperValueFontSize = 16;

  static const double wizardAmenityRowGap = 12;
  static const double wizardAmenityRowVerticalPadding = 8;
  static const double wizardAmenityEmojiFontSize = 18;
  static const double wizardAmenityLabelFontSize = 15;

  static const double wizardPhotoTileSize = 108;
  static const double wizardPhotoGridGap = 10;

  static const double wizardMapHeight = 160;
  static const double wizardMapPinFontSize = 26;

  static const double wizardFooterTopPadding = 16;
  static const double wizardFooterBottomPadding = 32;
  static const double wizardFooterBackFontSize = 15;

  static const double wizardReviewRowVerticalPadding = 8;
  static const double wizardReviewLabelFontSize = 14;
  static const double wizardReviewImageHeight = 160;

  // ── CREATE OFFER SUCCESS SCREEN ──
  static const double successTopPadding = 100;
  static const double successBottomPadding = 32;
  static const double successBlockGap = 12;
  static const double successCircleSize = 72;
  static const double successCheckFontSize = 32;
  static const double successHeadingFontSize = 20;
  static const double successSubtitleFontSize = 14;
  static const double successActionsTopPadding = 12;
  static const double successActionsBottomPadding = 32;
  static const double successActionsGap = 12;

  // ── RATE GUEST SCREEN ──
  // Guest Row reuses the Availability Calendar's identical "Listing
  // Context" row spec (calendarListingContext*/calendarListingThumbSize);
  // Content padding reuses the wizard's wizardContent*; Footer reuses
  // wizardFooterTopPadding/wizardFooterBottomPadding — all pixel-identical
  // in Figma. Only the star rating and helper text need new tokens.
  static const double rateGuestAvatarInitialsFontSize = 16;
  static const double rateGuestStarFontSize = 32;
  static const double rateGuestStarGap = 10;
  static const double rateGuestHelperTextFontSize = 12;

  // ── RATING SAVED SCREEN ──
  // Reuses the Create Offer Success screen's successCircleSize/
  // successCheckFontSize/successHeadingFontSize/successBlockGap/
  // successBottomPadding/successActionsTopPadding/
  // successActionsBottomPadding — everything is pixel-identical except
  // the top padding.
  static const double ratingSavedTopPadding = 60;
}
