// GENERATED from lib/l10n/app_mk.arb by
// `dart run tool/gen_app_strings.dart` — edit the .arb files in
// lib/l10n/ (mk is the template), not the getters below. The
// constants at the bottom are kept as-is when regenerating.
import 'package:bulka_frontend/core/l10n/app_locale.dart';
import 'package:bulka_frontend/l10n/app_localizations.dart';

/// All user-facing text, in the language picked in `LocaleBloc`.
///
/// Translated text is a getter (not `const`), so it always returns the
/// current language. Text that's the same in every language (symbols,
/// emoji, sample data) stays `const` at the bottom.
class AppStrings {
  AppStrings._();

  static AppLocalizations get _s => AppLocale.strings;

  static String get splashTitle => _s.splashTitle;
  static String get splashSubtitle => _s.splashSubtitle;
  static String get chooseLanguage => _s.chooseLanguage;
  static String get continueButton => _s.continueButton;
  static String get emailLabel => _s.emailLabel;
  static String get emailPlaceholder => _s.emailPlaceholder;
  static String get passwordLabel => _s.passwordLabel;
  static String get backToLoginAction => _s.backToLoginAction;
  static String get loginTitle => _s.loginTitle;
  static String get loginWelcomeBack => _s.loginWelcomeBack;
  static String get loginWelcomeBackSubtitle => _s.loginWelcomeBackSubtitle;
  static String get loginForgotPassword => _s.loginForgotPassword;
  static String get loginSubmitButton => _s.loginSubmitButton;
  static String get loginGoogleButton => _s.loginGoogleButton;
  static String get loginFooterPrompt => _s.loginFooterPrompt;
  static String get loginFooterAction => _s.loginFooterAction;
  static String get loginErrorEmptyFields => _s.loginErrorEmptyFields;
  static String get loginErrorInvalidCredentials =>
      _s.loginErrorInvalidCredentials;
  static String get loginErrorTwoFactorUnsupported =>
      _s.loginErrorTwoFactorUnsupported;
  static String get loginErrorUnsupportedAccount =>
      _s.loginErrorUnsupportedAccount;
  static String get registerErrorFullName => _s.registerErrorFullName;
  static String get registerErrorEmail => _s.registerErrorEmail;
  static String get registerErrorPhone => _s.registerErrorPhone;
  static String get registerErrorPasswordRules => _s.registerErrorPasswordRules;
  static String get registerErrorPasswordMismatch =>
      _s.registerErrorPasswordMismatch;
  static String get emailVerificationResent => _s.emailVerificationResent;
  static String get apiErrorEmailRequired => _s.apiErrorEmailRequired;
  static String get apiErrorFirstNameRequired => _s.apiErrorFirstNameRequired;
  static String get apiErrorLastNameRequired => _s.apiErrorLastNameRequired;
  static String get apiErrorPhoneRequired => _s.apiErrorPhoneRequired;
  static String get apiErrorPasswordRequired => _s.apiErrorPasswordRequired;
  static String get apiErrorCodeRequired => _s.apiErrorCodeRequired;
  static String get apiErrorTermsRequired => _s.apiErrorTermsRequired;
  static String get apiErrorPrivacyRequired => _s.apiErrorPrivacyRequired;
  static String get apiErrorPasswordTooShort => _s.apiErrorPasswordTooShort;
  static String get apiErrorPasswordNeedsUppercase =>
      _s.apiErrorPasswordNeedsUppercase;
  static String get apiErrorPasswordNeedsLowercase =>
      _s.apiErrorPasswordNeedsLowercase;
  static String get apiErrorPasswordNeedsDigit => _s.apiErrorPasswordNeedsDigit;
  static String get apiErrorPasswordNeedsSpecial =>
      _s.apiErrorPasswordNeedsSpecial;
  static String get apiErrorVerificationCodeInvalid =>
      _s.apiErrorVerificationCodeInvalid;
  static String get apiErrorInvalidInput => _s.apiErrorInvalidInput;
  static String get apiErrorNetwork => _s.apiErrorNetwork;
  static String get apiErrorTimeout => _s.apiErrorTimeout;
  static String get apiErrorUnauthorized => _s.apiErrorUnauthorized;
  static String get apiErrorServer => _s.apiErrorServer;
  static String get apiErrorUnknown => _s.apiErrorUnknown;
  static String get forgotPasswordTitle => _s.forgotPasswordTitle;
  static String get forgotPasswordHeading => _s.forgotPasswordHeading;
  static String get forgotPasswordSubheading => _s.forgotPasswordSubheading;
  static String get forgotPasswordSubmitButton => _s.forgotPasswordSubmitButton;
  static String get forgotPasswordFooterPrompt => _s.forgotPasswordFooterPrompt;
  static String get resetPasswordTitle => _s.resetPasswordTitle;
  static String get resetPasswordHeading => _s.resetPasswordHeading;
  static String get resetPasswordSubheading => _s.resetPasswordSubheading;
  static String get resetPasswordCodeLabel => _s.resetPasswordCodeLabel;
  static String get resetPasswordCodePlaceholder =>
      _s.resetPasswordCodePlaceholder;
  static String get resetPasswordNewPasswordLabel =>
      _s.resetPasswordNewPasswordLabel;
  static String get resetPasswordSubmitButton => _s.resetPasswordSubmitButton;
  static String get resetPasswordSuccess => _s.resetPasswordSuccess;
  static String get registerBusinessNameLabel => _s.registerBusinessNameLabel;
  static String get registerBusinessNamePlaceholder =>
      _s.registerBusinessNamePlaceholder;
  static String get registerErrorBusinessName => _s.registerErrorBusinessName;
  static String get apiErrorBusinessNameRequired =>
      _s.apiErrorBusinessNameRequired;
  static String get apiErrorEmailNotVerified => _s.apiErrorEmailNotVerified;
  static String get registerTitle => _s.registerTitle;
  static String get registerRoleLabel => _s.registerRoleLabel;
  static String get registerRoleGuest => _s.registerRoleGuest;
  static String get registerRoleProvider => _s.registerRoleProvider;
  static String get registerNameLabel => _s.registerNameLabel;
  static String get registerNamePlaceholder => _s.registerNamePlaceholder;
  static String get registerPhoneLabel => _s.registerPhoneLabel;
  static String get registerConfirmPasswordLabel =>
      _s.registerConfirmPasswordLabel;
  static String get registerTermsPrefix => _s.registerTermsPrefix;
  static String get registerTermsOfService => _s.registerTermsOfService;
  static String get registerPrivacyPolicy => _s.registerPrivacyPolicy;
  static String get registerTermsSuffix => _s.registerTermsSuffix;
  static String get registerSubmitButton => _s.registerSubmitButton;
  static String get registerFooterPrompt => _s.registerFooterPrompt;
  static String get termsPrivacyTitle => _s.termsPrivacyTitle;
  static String get termsPrivacySubtitle => _s.termsPrivacySubtitle;
  static String get termsPrivacyTermsHeading => _s.termsPrivacyTermsHeading;
  static String get termsPrivacyTermsBody => _s.termsPrivacyTermsBody;
  static String get termsPrivacyPolicyHeading => _s.termsPrivacyPolicyHeading;
  static String get termsPrivacyPolicyBody => _s.termsPrivacyPolicyBody;
  static String get termsPrivacyConsentTerms => _s.termsPrivacyConsentTerms;
  static String get termsPrivacyConsentPrivacy => _s.termsPrivacyConsentPrivacy;
  static String get termsPrivacyConsentResponsibilities =>
      _s.termsPrivacyConsentResponsibilities;
  static String get termsPrivacySubmitButton => _s.termsPrivacySubmitButton;
  static String get emailVerificationTitle => _s.emailVerificationTitle;
  static String get emailVerificationSentTo => _s.emailVerificationSentTo;
  static String get emailVerificationInstructions =>
      _s.emailVerificationInstructions;
  static String get emailVerificationCodeLabel => _s.emailVerificationCodeLabel;
  static String get emailVerificationCodePlaceholder =>
      _s.emailVerificationCodePlaceholder;
  static String get emailVerificationSubmitButton =>
      _s.emailVerificationSubmitButton;
  static String get emailVerificationErrorEmptyCode =>
      _s.emailVerificationErrorEmptyCode;
  static String get emailVerificationSuccess => _s.emailVerificationSuccess;
  static String get emailVerificationBadge => _s.emailVerificationBadge;
  static String get emailVerificationResendButton =>
      _s.emailVerificationResendButton;
  static String get emailVerificationChangeEmail =>
      _s.emailVerificationChangeEmail;
  static String get profileTitle => _s.profileTitle;
  static String get profilePersonalDataHeading => _s.profilePersonalDataHeading;
  static String get profilePhoneLabel => _s.profilePhoneLabel;
  static String get profileCityLabel => _s.profileCityLabel;
  static String get profileCityPlaceholder => _s.profileCityPlaceholder;
  static String get profileReservationsLabel => _s.profileReservationsLabel;
  static String get profileFavoritePlacesLabel => _s.profileFavoritePlacesLabel;
  static String get profileSaveButton => _s.profileSaveButton;
  static String get providerSubjectTypeLabel => _s.providerSubjectTypeLabel;
  static String get providerSubjectTypeIndividual =>
      _s.providerSubjectTypeIndividual;
  static String get providerSubjectTypeLegal => _s.providerSubjectTypeLegal;
  static String get providerLegalEntityComingSoon =>
      _s.providerLegalEntityComingSoon;
  static String get providerOfferInfoHeading => _s.providerOfferInfoHeading;
  static String get providerOfferNameLabel => _s.providerOfferNameLabel;
  static String get providerOfferNamePlaceholder =>
      _s.providerOfferNamePlaceholder;
  static String get providerCategoryHeading => _s.providerCategoryHeading;
  static String get providerCategoryAccommodation =>
      _s.providerCategoryAccommodation;
  static String get providerCategoryGastronomy => _s.providerCategoryGastronomy;
  static String get providerCategoryFarmParticipation =>
      _s.providerCategoryFarmParticipation;
  static String get providerCategoryDirectSales =>
      _s.providerCategoryDirectSales;
  static String get providerCategoryFarmEducation =>
      _s.providerCategoryFarmEducation;
  static String get providerCategoryFarmRecreation =>
      _s.providerCategoryFarmRecreation;
  static String get providerCategoryOffFarmTours =>
      _s.providerCategoryOffFarmTours;
  static String get providerLocationLabel => _s.providerLocationLabel;
  static String get providerLocationPlaceholder =>
      _s.providerLocationPlaceholder;
  static String get providerActiveOffersLabel => _s.providerActiveOffersLabel;
  static String get providerAverageRatingLabel => _s.providerAverageRatingLabel;
  static String get providerNotVerifiedBadge => _s.providerNotVerifiedBadge;
  static String get providerVerifiedBadge => _s.providerVerifiedBadge;
  static String get providerExampleName => _s.providerExampleName;
  static String get providerSetupTitle => _s.providerSetupTitle;
  static String get providerSetupSubtitle => _s.providerSetupSubtitle;
  static String get providerAddLogoLabel => _s.providerAddLogoLabel;
  static String get providerLegalCompanyNameLabel =>
      _s.providerLegalCompanyNameLabel;
  static String get providerLegalResponsiblePersonLabel =>
      _s.providerLegalResponsiblePersonLabel;
  static String get providerLegalResponsiblePersonPlaceholder =>
      _s.providerLegalResponsiblePersonPlaceholder;
  static String get providerLegalEmailPlaceholder =>
      _s.providerLegalEmailPlaceholder;
  static String get providerLegalBusinessDetailsHeading =>
      _s.providerLegalBusinessDetailsHeading;
  static String get providerLegalTaxIdLabel => _s.providerLegalTaxIdLabel;
  static String get providerLegalCategoryHeading =>
      _s.providerLegalCategoryHeading;
  static String get providerLegalAddressLabel => _s.providerLegalAddressLabel;
  static String get providerLegalAddressPlaceholder =>
      _s.providerLegalAddressPlaceholder;
  static String get providerAdditionalContactsHeading =>
      _s.providerAdditionalContactsHeading;
  static String get providerAdditionalContactLabel =>
      _s.providerAdditionalContactLabel;
  static String get providerAdditionalContactPlaceholder =>
      _s.providerAdditionalContactPlaceholder;
  static String get providerAddContactButton => _s.providerAddContactButton;
  static String get providerSaveAndContinueButton =>
      _s.providerSaveAndContinueButton;
  static String get imageSourceGallery => _s.imageSourceGallery;
  static String get imageSourceCamera => _s.imageSourceCamera;
  static String get navTouristHome => _s.navTouristHome;
  static String get navTouristSearch => _s.navTouristSearch;
  static String get navTouristBookings => _s.navTouristBookings;
  static String get navProviderDashboard => _s.navProviderDashboard;
  static String get navProviderOffers => _s.navProviderOffers;
  static String get navProviderCalendar => _s.navProviderCalendar;
  static String get navMessages => _s.navMessages;
  static String get chatLoadFailed => _s.chatLoadFailed;
  static String get chatEmpty => _s.chatEmpty;
  static String get chatMessagesLoadFailed => _s.chatMessagesLoadFailed;
  static String get chatNoMessages => _s.chatNoMessages;
  static String get chatMessageDeleted => _s.chatMessageDeleted;
  static String get navProfile => _s.navProfile;
  static String get settingsTitle => _s.settingsTitle;
  static String get settingsLanguageHeading => _s.settingsLanguageHeading;
  static String get settingsLanguageRowLabel => _s.settingsLanguageRowLabel;
  static String get settingsNotificationsLabel => _s.settingsNotificationsLabel;
  static String get settingsPrivacyHeading => _s.settingsPrivacyHeading;
  static String get settingsPrivacyDescription => _s.settingsPrivacyDescription;
  static String get settingsDownloadDataButton => _s.settingsDownloadDataButton;
  static String get settingsDeleteAccountButton =>
      _s.settingsDeleteAccountButton;
  static String get settingsLogoutButton => _s.settingsLogoutButton;
  static String get notificationsTitle => _s.notificationsTitle;
  static String get notificationsUnreadSuffix => _s.notificationsUnreadSuffix;
  static String get notificationsLoadFailed => _s.notificationsLoadFailed;
  static String get notificationsEmpty => _s.notificationsEmpty;
  static String get notificationsMarkAllRead => _s.notificationsMarkAllRead;
  static String get timeJustNow => _s.timeJustNow;
  static String get timeMinutesSuffix => _s.timeMinutesSuffix;
  static String get timeHoursSuffix => _s.timeHoursSuffix;
  static String get timeDaysSuffix => _s.timeDaysSuffix;
  static String get chatToday => _s.chatToday;
  static String get chatInputPlaceholder => _s.chatInputPlaceholder;
  static String get myTicketsTitle => _s.myTicketsTitle;
  static String get createTicketButton => _s.createTicketButton;
  static String get ticketStatusOpen => _s.ticketStatusOpen;
  static String get ticketStatusInProgress => _s.ticketStatusInProgress;
  static String get ticketStatusResolved => _s.ticketStatusResolved;
  static String get ticketStatusClosed => _s.ticketStatusClosed;
  static String get ticketsLoadFailed => _s.ticketsLoadFailed;
  static String get ticketsEmpty => _s.ticketsEmpty;
  static String get ticketLastChangedLabel => _s.ticketLastChangedLabel;
  static String get ticketDetailsTitle => _s.ticketDetailsTitle;
  static String get ticketDetailsLoadFailed => _s.ticketDetailsLoadFailed;
  static String get ticketCreatedLabel => _s.ticketCreatedLabel;
  static String get ticketAttachmentLabel => _s.ticketAttachmentLabel;
  static String get newTicketTitle => _s.newTicketTitle;
  static String get newTicketSubtitle => _s.newTicketSubtitle;
  static String get newTicketCategoryLabel => _s.newTicketCategoryLabel;
  static String get newTicketTitleLabel => _s.newTicketTitleLabel;
  static String get newTicketTitlePlaceholder => _s.newTicketTitlePlaceholder;
  static String get newTicketDescriptionLabel => _s.newTicketDescriptionLabel;
  static String get newTicketDescriptionPlaceholder =>
      _s.newTicketDescriptionPlaceholder;
  static String get newTicketAttachmentLabel => _s.newTicketAttachmentLabel;
  static String get newTicketAttachmentOptional =>
      _s.newTicketAttachmentOptional;
  static String get newTicketSubmitButton => _s.newTicketSubmitButton;
  static String get newTicketCategoryReservations =>
      _s.newTicketCategoryReservations;
  static String get newTicketCategoryListings => _s.newTicketCategoryListings;
  static String get newTicketCategoryPayments => _s.newTicketCategoryPayments;
  static String get newTicketCategoryProfile => _s.newTicketCategoryProfile;
  static String get newTicketCategoryOther => _s.newTicketCategoryOther;
  static String get attachmentSourceDocument => _s.attachmentSourceDocument;
  static String get dashboardTitle => _s.dashboardTitle;
  static String get dashboardGreetingPrefix => _s.dashboardGreetingPrefix;
  static String get dashboardAddListingButton => _s.dashboardAddListingButton;
  static String get dashboardListingsSummaryHeading =>
      _s.dashboardListingsSummaryHeading;
  static String get dashboardActiveListingsLabel =>
      _s.dashboardActiveListingsLabel;
  static String get dashboardPendingReviewListingsLabel =>
      _s.dashboardPendingReviewListingsLabel;
  static String get dashboardMonthlyReservationsLabel =>
      _s.dashboardMonthlyReservationsLabel;
  static String get dashboardPendingReservationsHeading =>
      _s.dashboardPendingReservationsHeading;
  static String get dashboardCompletedReservationsHeading =>
      _s.dashboardCompletedReservationsHeading;
  static String get reservationStatusPending => _s.reservationStatusPending;
  static String get reservationStatusAccepted => _s.reservationStatusAccepted;
  static String get reservationStatusAcceptedTourist =>
      _s.reservationStatusAcceptedTourist;
  static String get reservationStatusRejected => _s.reservationStatusRejected;
  static String get reservationStatusCompleted => _s.reservationStatusCompleted;
  static String get reservationStatusCancelled => _s.reservationStatusCancelled;
  static String get reservationGuestSingular => _s.reservationGuestSingular;
  static String get reservationGuestsPlural => _s.reservationGuestsPlural;
  static String get acceptReservationButton => _s.acceptReservationButton;
  static String get rejectReservationButton => _s.rejectReservationButton;
  static String get rateGuestButton => _s.rateGuestButton;
  static String get offersTitle => _s.offersTitle;
  static String get offersSubtitle => _s.offersSubtitle;
  static String get offersFilterAll => _s.offersFilterAll;
  static String get offersFilterActive => _s.offersFilterActive;
  static String get offersFilterPendingReview => _s.offersFilterPendingReview;
  static String get offersFilterRejected => _s.offersFilterRejected;
  static String get listingStatusActive => _s.listingStatusActive;
  static String get listingStatusPendingReview => _s.listingStatusPendingReview;
  static String get listingStatusRejected => _s.listingStatusRejected;
  static String get listingStatusArchived => _s.listingStatusArchived;
  static String get listingReservationsThisMonthLabel =>
      _s.listingReservationsThisMonthLabel;
  static String get listingSubmittedForReviewLabel =>
      _s.listingSubmittedForReviewLabel;
  static String get listingRejectedReasonPrefix =>
      _s.listingRejectedReasonPrefix;
  static String get listingArchivedOnLabel => _s.listingArchivedOnLabel;
  static String get editListingButton => _s.editListingButton;
  static String get editAndResubmitListingButton =>
      _s.editAndResubmitListingButton;
  static String get reactivateListingButton => _s.reactivateListingButton;
  static String get calendarTitle => _s.calendarTitle;
  static String get availabilityStatusAvailable =>
      _s.availabilityStatusAvailable;
  static String get availabilityStatusOccupied => _s.availabilityStatusOccupied;
  static String get availabilityStatusBlocked => _s.availabilityStatusBlocked;
  static String get weekdayMon => _s.weekdayMon;
  static String get weekdayTue => _s.weekdayTue;
  static String get weekdayWed => _s.weekdayWed;
  static String get weekdayThu => _s.weekdayThu;
  static String get weekdayFri => _s.weekdayFri;
  static String get weekdaySat => _s.weekdaySat;
  static String get weekdaySun => _s.weekdaySun;
  static String get blockSelectedDatesButton => _s.blockSelectedDatesButton;
  static String get unblockSelectedDatesButton => _s.unblockSelectedDatesButton;
  static String get wizardHeaderTitle => _s.wizardHeaderTitle;
  static String get wizardStepLabel => _s.wizardStepLabel;
  static String get wizardStepOfLabel => _s.wizardStepOfLabel;
  static String get wizardBackButton => _s.wizardBackButton;
  static String get wizardNextButton => _s.wizardNextButton;
  static String get wizardPublishButton => _s.wizardPublishButton;
  static String get wizardCategoryFarmRecreation =>
      _s.wizardCategoryFarmRecreation;
  static String get wizardCategoryOffFarmTours => _s.wizardCategoryOffFarmTours;
  static String get wizardStep1Heading => _s.wizardStep1Heading;
  static String get wizardStep1Subtitle => _s.wizardStep1Subtitle;
  static String get wizardCategoryLabel => _s.wizardCategoryLabel;
  static String get wizardTitleLabel => _s.wizardTitleLabel;
  static String get wizardTitlePlaceholder => _s.wizardTitlePlaceholder;
  static String get wizardStep2Heading => _s.wizardStep2Heading;
  static String get wizardStep2Subtitle => _s.wizardStep2Subtitle;
  static String get wizardLocationLabel => _s.wizardLocationLabel;
  static String get wizardLocationPlaceholder => _s.wizardLocationPlaceholder;
  static String get wizardStep3Heading => _s.wizardStep3Heading;
  static String get wizardStep3Subtitle => _s.wizardStep3Subtitle;
  static String get wizardGuestsLabel => _s.wizardGuestsLabel;
  static String get wizardRoomsLabel => _s.wizardRoomsLabel;
  static String get wizardBedsLabel => _s.wizardBedsLabel;
  static String get wizardStep4Heading => _s.wizardStep4Heading;
  static String get wizardStep4Subtitle => _s.wizardStep4Subtitle;
  static String get wizardStep5Heading => _s.wizardStep5Heading;
  static String get wizardStep5Subtitle => _s.wizardStep5Subtitle;
  static String get wizardStep6Heading => _s.wizardStep6Heading;
  static String get wizardStep6Subtitle => _s.wizardStep6Subtitle;
  static String get wizardDescriptionLabel => _s.wizardDescriptionLabel;
  static String get wizardDescriptionPlaceholder =>
      _s.wizardDescriptionPlaceholder;
  static String get wizardPriceLabel => _s.wizardPriceLabel;
  static String get wizardPricePlaceholder => _s.wizardPricePlaceholder;
  static String get wizardPriceSuffix => _s.wizardPriceSuffix;
  static String get wizardPricePerNightSuffix => _s.wizardPricePerNightSuffix;
  static String get wizardReviewHeading => _s.wizardReviewHeading;
  static String get wizardReviewSubtitle => _s.wizardReviewSubtitle;
  static String get wizardReviewTitleRow => _s.wizardReviewTitleRow;
  static String get wizardReviewCategoryRow => _s.wizardReviewCategoryRow;
  static String get wizardReviewLocationRow => _s.wizardReviewLocationRow;
  static String get wizardReviewCapacityRow => _s.wizardReviewCapacityRow;
  static String get wizardReviewAmenitiesRow => _s.wizardReviewAmenitiesRow;
  static String get wizardReviewPhotosRow => _s.wizardReviewPhotosRow;
  static String get wizardReviewPriceRow => _s.wizardReviewPriceRow;
  static String get wizardRoomSingular => _s.wizardRoomSingular;
  static String get wizardRoomsPlural => _s.wizardRoomsPlural;
  static String get wizardBedSingular => _s.wizardBedSingular;
  static String get wizardBedsPlural => _s.wizardBedsPlural;
  static String get wizardAmenitySingular => _s.wizardAmenitySingular;
  static String get wizardAmenitiesPlural => _s.wizardAmenitiesPlural;
  static String get wizardPhotoSingular => _s.wizardPhotoSingular;
  static String get wizardPhotosPlural => _s.wizardPhotosPlural;
  static String get wizardDiscardDialogTitle => _s.wizardDiscardDialogTitle;
  static String get wizardDiscardDialogMessage => _s.wizardDiscardDialogMessage;
  static String get wizardDiscardDialogCancel => _s.wizardDiscardDialogCancel;
  static String get wizardDiscardDialogConfirm => _s.wizardDiscardDialogConfirm;
  static String get amenityParking => _s.amenityParking;
  static String get amenityKitchen => _s.amenityKitchen;
  static String get amenityAirConditioning => _s.amenityAirConditioning;
  static String get amenityTv => _s.amenityTv;
  static String get amenityFireplace => _s.amenityFireplace;
  static String get amenityFarmAccess => _s.amenityFarmAccess;
  static String get amenityHotWater => _s.amenityHotWater;
  static String get amenityPetsAllowed => _s.amenityPetsAllowed;
  static String get offerPublishedTitle => _s.offerPublishedTitle;
  static String get offerPublishedHeading => _s.offerPublishedHeading;
  static String get offerPublishedSubtitle => _s.offerPublishedSubtitle;
  static String get offerPublishedViewOffersButton =>
      _s.offerPublishedViewOffersButton;
  static String get offerPublishedGoToDashboardButton =>
      _s.offerPublishedGoToDashboardButton;
  static String get rateGuestTitle => _s.rateGuestTitle;
  static String get rateGuestQuestion => _s.rateGuestQuestion;
  static String get rateGuestNoteLabel => _s.rateGuestNoteLabel;
  static String get rateGuestNotePlaceholder => _s.rateGuestNotePlaceholder;
  static String get rateGuestHelperText => _s.rateGuestHelperText;
  static String get submitRatingButton => _s.submitRatingButton;
  static String get ratingSavedTitle => _s.ratingSavedTitle;
  static String get ratingSavedHeading => _s.ratingSavedHeading;
  static String get homeGreetingPrefix => _s.homeGreetingPrefix;
  static String get homeSubtitle => _s.homeSubtitle;
  static String get homeSearchPlaceholder => _s.homeSearchPlaceholder;
  static String get homeCategoriesHeading => _s.homeCategoriesHeading;
  static String get homeCategoriesLoadFailed => _s.homeCategoriesLoadFailed;
  static String get retryButton => _s.retryButton;
  static String get homeRecommendedHeading => _s.homeRecommendedHeading;
  static String get homePricePrefix => _s.homePricePrefix;
  static String get homeBanner1Title => _s.homeBanner1Title;
  static String get homeBanner1Action => _s.homeBanner1Action;
  static String get homeBanner2Title => _s.homeBanner2Title;
  static String get homeBanner2Action => _s.homeBanner2Action;
  static String get homeBanner3Title => _s.homeBanner3Title;
  static String get homeBanner3Action => _s.homeBanner3Action;
  static String get filtersSheetTitle => _s.filtersSheetTitle;
  static String get filtersKeywordLabel => _s.filtersKeywordLabel;
  static String get filtersKeywordPlaceholder => _s.filtersKeywordPlaceholder;
  static String get filtersLocationLabel => _s.filtersLocationLabel;
  static String get filtersAllLocationsOption => _s.filtersAllLocationsOption;
  static String get filtersPriceRangeLabel => _s.filtersPriceRangeLabel;
  static String get filtersPriceRangeUnit => _s.filtersPriceRangeUnit;
  static String get filtersDateLabel => _s.filtersDateLabel;
  static String get filtersDatePlaceholder => _s.filtersDatePlaceholder;
  static String get filtersRatingLabel => _s.filtersRatingLabel;
  static String get filtersRatingAllOption => _s.filtersRatingAllOption;
  static String get filtersGuestCountLabel => _s.filtersGuestCountLabel;
  static String get filtersAmenityHeading => _s.filtersAmenityHeading;
  static String get filtersAmenitiesLoadFailed => _s.filtersAmenitiesLoadFailed;
  static String get filtersClearButton => _s.filtersClearButton;
  static String get filtersShowResultsButton => _s.filtersShowResultsButton;
  static String get resultsTitle => _s.resultsTitle;
  static String get resultsFiltersChipLabel => _s.resultsFiltersChipLabel;
  static String get resultsRatingChipLabel => _s.resultsRatingChipLabel;
  static String get resultsPriceChipLabel => _s.resultsPriceChipLabel;
  static String get resultsCountSuffix => _s.resultsCountSuffix;
  static String get resultsCountLocationPrefix => _s.resultsCountLocationPrefix;
  static String get resultsSortLabel => _s.resultsSortLabel;
  static String get resultsMapButtonLabel => _s.resultsMapButtonLabel;
  static String get resultsShowDetailsButton => _s.resultsShowDetailsButton;
  static String get resultsReservationsSuffix => _s.resultsReservationsSuffix;
  static String get resultsPricePerNightSuffix => _s.resultsPricePerNightSuffix;
  static String get detailsTitle => _s.detailsTitle;
  static String get detailsHostPrefix => _s.detailsHostPrefix;
  static String get detailsHostSincePrefix => _s.detailsHostSincePrefix;
  static String get detailsAboutHeading => _s.detailsAboutHeading;
  static String get detailsAmenitiesHeading => _s.detailsAmenitiesHeading;
  static String get detailsLocationHeading => _s.detailsLocationHeading;
  static String get detailsReserveButton => _s.detailsReserveButton;
  static String get listingsLoadFailed => _s.listingsLoadFailed;
  static String get listingDetailsLoadFailed => _s.listingDetailsLoadFailed;
  static String get listingPricesPerItem => _s.listingPricesPerItem;
  static String get listingNoRatingsYet => _s.listingNoRatingsYet;
  static String get listingReviewsSuffix => _s.listingReviewsSuffix;
  static String get listingPerPersonSuffix => _s.listingPerPersonSuffix;
  static String get detailsItemsHeading => _s.detailsItemsHeading;
  static String get resultsEmpty => _s.resultsEmpty;
  static String get resultsLoadMore => _s.resultsLoadMore;
  static String get reservationFlowTitle => _s.reservationFlowTitle;
  static String get bookingDatesUnavailableError =>
      _s.bookingDatesUnavailableError;
  static String get bookingRequestSentHeading => _s.bookingRequestSentHeading;
  static String get bookingRequestSentSubtitle => _s.bookingRequestSentSubtitle;
  static String get tripDetailsHeading => _s.tripDetailsHeading;
  static String get checkInLabel => _s.checkInLabel;
  static String get checkOutLabel => _s.checkOutLabel;
  static String get paymentDetailsHeading => _s.paymentDetailsHeading;
  static String get serviceFeeLabel => _s.serviceFeeLabel;
  static String get totalLabel => _s.totalLabel;
  static String get reservationNumberLabel => _s.reservationNumberLabel;
  static String get nightSingular => _s.nightSingular;
  static String get nightsPlural => _s.nightsPlural;
  static String get viewMyReservationsButton => _s.viewMyReservationsButton;
  static String get backToHomeButton => _s.backToHomeButton;
  static String get myReservationsTitle => _s.myReservationsTitle;
  static String get upcomingTabLabel => _s.upcomingTabLabel;
  static String get pastTabLabel => _s.pastTabLabel;
  static String get myReservationsDetailsButton =>
      _s.myReservationsDetailsButton;
  static String get leaveReviewButton => _s.leaveReviewButton;
  static String get myReservationsEmptyUpcoming =>
      _s.myReservationsEmptyUpcoming;
  static String get myReservationsEmptyPast => _s.myReservationsEmptyPast;
  static String get leaveReviewQuestion => _s.leaveReviewQuestion;
  static String get leaveReviewTextLabel => _s.leaveReviewTextLabel;
  static String get leaveReviewTextPlaceholder => _s.leaveReviewTextPlaceholder;
  static String get leaveReviewDisclaimer => _s.leaveReviewDisclaimer;
  static String get submitReviewButton => _s.submitReviewButton;
  static String get reviewSubmittedTitle => _s.reviewSubmittedTitle;
  static String get reviewSubmittedHeading => _s.reviewSubmittedHeading;
  static String get backToReservationsButton => _s.backToReservationsButton;
  static String get welcomeToBulka => _s.welcomeToBulka;
  static String get whoAreYou => _s.whoAreYou;
  static String get chooseProfile => _s.chooseProfile;
  static String get tourist => _s.tourist;
  static String get touristDescription => _s.touristDescription;
  static String get owner => _s.owner;
  static String get ownerDescription => _s.ownerDescription;
  static String get continueText => _s.continueText;
  static String get alreadyAccount => _s.alreadyAccount;
  static String get routeNotFoundTitle => _s.routeNotFoundTitle;
  static String get routeNotFoundMessage => _s.routeNotFoundMessage;
  static String get routeNotFoundButton => _s.routeNotFoundButton;
  static String agoMinutes(int count) => _s.agoMinutes(count);
  static String agoHours(int count) => _s.agoHours(count);
  static String agoDays(int count) => _s.agoDays(count);

  // ── Same in every language ──
  static const String languageCodeMk = 'MK';
  static const String languageCodeSq = 'SQ';
  static const String languageCodeEn = 'EN';
  static const String passwordPlaceholder = '••••••••';
  static const String registerPhonePlaceholder = '+389 70 123 456';
  static const String registerTermsSeparator = ', ';
  static const String emailVerificationExampleEmail =
      'jovan.jovanovski@example.com';
  static const String providerExampleEmail = 'ana.trajkovska@example.com';
  static const String providerExamplePhone = '070 987 654';
  static const String providerLegalTaxIdPlaceholder = '4021998123456';
  static const String providerLegalCompanyNamePlaceholder =
      'Villa Zdravkovski DOOEL';
  static const String amenityWifi = 'Wi-Fi';
  static const String chatSendButtonGlyph = '>';
  static const String wizardCloseGlyph = '✕';
  static const String wizardMapPinGlyph = '📍';
  static const String offerPublishedCheckGlyph = '✓';
  static const String homeGreetingEmoji = '👋';
  static const String homeSearchIconGlyph = '🔍';
  static const String filterIconGlyph = '⚙';
  static const String resultsFiltersChipGlyph = '☰';
  static const String resultsMapButtonGlyph = '🗺';
  static const String detailsHeartOutlineGlyph = '♡';
  static const String detailsHeartFilledGlyph = '♥';
}
