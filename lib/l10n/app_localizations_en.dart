// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get splashTitle => 'Agro Eco Tourism';

  @override
  String get splashSubtitle =>
      'Discover the beauty of rural tourism in Macedonia';

  @override
  String get chooseLanguage => 'Choose a language';

  @override
  String get continueButton => 'Continue';

  @override
  String get emailLabel => 'Email';

  @override
  String get emailPlaceholder => 'youremail@example.com';

  @override
  String get passwordLabel => 'Password';

  @override
  String get backToLoginAction => 'Log in';

  @override
  String get loginTitle => 'Log in';

  @override
  String get loginWelcomeBack => 'Welcome back!';

  @override
  String get loginWelcomeBackSubtitle => 'Log in to your account';

  @override
  String get loginForgotPassword => 'Forgot password?';

  @override
  String get loginSubmitButton => 'LOG IN';

  @override
  String get loginGoogleButton => 'CONTINUE WITH GOOGLE';

  @override
  String get loginFooterPrompt => 'Don\'t have an account? ';

  @override
  String get loginFooterAction => 'Sign up';

  @override
  String get loginErrorEmptyFields => 'Enter your email and password.';

  @override
  String get loginErrorInvalidCredentials => 'Incorrect email or password.';

  @override
  String get loginErrorTwoFactorUnsupported =>
      'This account has two-factor authentication turned on, which the app doesn\'t support yet.';

  @override
  String get registerErrorFullName => 'Enter your first and last name.';

  @override
  String get registerErrorEmail => 'Enter a valid email address.';

  @override
  String get registerErrorPhone =>
      'Enter a phone number in international format, e.g. +389 70 123 456.';

  @override
  String get registerErrorPasswordRules =>
      'The password must have at least 8 characters, an uppercase letter, a digit and a special character.';

  @override
  String get registerErrorPasswordMismatch => 'The passwords don\'t match.';

  @override
  String get emailVerificationResent => 'We\'ve sent a new verification email.';

  @override
  String get apiErrorEmailRequired => 'Email is required.';

  @override
  String get apiErrorFirstNameRequired => 'First name is required.';

  @override
  String get apiErrorLastNameRequired => 'Last name is required.';

  @override
  String get apiErrorPhoneRequired => 'Phone number is required.';

  @override
  String get apiErrorPasswordRequired => 'Password is required.';

  @override
  String get apiErrorCodeRequired => 'The verification code is required.';

  @override
  String get apiErrorTermsRequired => 'You must accept the Terms of Service.';

  @override
  String get apiErrorPrivacyRequired => 'You must accept the Privacy Policy.';

  @override
  String get apiErrorPasswordTooShort =>
      'The password must have at least 8 characters.';

  @override
  String get apiErrorPasswordNeedsUppercase =>
      'The password must contain an uppercase letter.';

  @override
  String get apiErrorPasswordNeedsLowercase =>
      'The password must contain a lowercase letter.';

  @override
  String get apiErrorPasswordNeedsDigit => 'The password must contain a digit.';

  @override
  String get apiErrorPasswordNeedsSpecial =>
      'The password must contain a special character.';

  @override
  String get apiErrorVerificationCodeInvalid =>
      'The verification code is incorrect. Check your email and try again.';

  @override
  String get apiErrorInvalidInput =>
      'Some of the details you entered aren\'t valid. Check them and try again.';

  @override
  String get apiErrorNetwork =>
      'No internet connection. Check your connection and try again.';

  @override
  String get apiErrorTimeout =>
      'The server isn\'t responding. Please try again.';

  @override
  String get apiErrorUnauthorized =>
      'Your session has expired. Please log in again.';

  @override
  String get apiErrorServer =>
      'Something went wrong on the server. Please try again later.';

  @override
  String get apiErrorUnknown =>
      'An unexpected error occurred. Please try again.';

  @override
  String get forgotPasswordTitle => 'Forgot password';

  @override
  String get forgotPasswordHeading => 'Reset your password';

  @override
  String get forgotPasswordSubheading =>
      'Enter your email and we\'ll send you a code to reset your password.';

  @override
  String get forgotPasswordSubmitButton => 'SEND CODE';

  @override
  String get forgotPasswordFooterPrompt => 'Remembered your password? ';

  @override
  String get resetPasswordTitle => 'New password';

  @override
  String get resetPasswordHeading => 'Enter a new password';

  @override
  String get resetPasswordSubheading =>
      'Enter the code we emailed you and choose a new password.';

  @override
  String get resetPasswordCodeLabel => 'Reset code';

  @override
  String get resetPasswordCodePlaceholder => 'Enter the code from the email';

  @override
  String get resetPasswordNewPasswordLabel => 'New password';

  @override
  String get resetPasswordSubmitButton => 'RESET PASSWORD';

  @override
  String get resetPasswordSuccess =>
      'Your password was changed. Please log in.';

  @override
  String get registerBusinessNameLabel => 'Business name';

  @override
  String get registerBusinessNamePlaceholder => 'Agro Eco Farm LLC';

  @override
  String get registerErrorBusinessName => 'Enter your business name.';

  @override
  String get apiErrorBusinessNameRequired => 'Business name is required.';

  @override
  String get apiErrorEmailNotVerified =>
      'Your email isn\'t confirmed yet. Enter the code we sent you.';

  @override
  String get registerTitle => 'Sign up';

  @override
  String get registerRoleLabel => 'Choose a profile type';

  @override
  String get registerRoleGuest => 'Guest';

  @override
  String get registerRoleProvider => 'Provider';

  @override
  String get registerNameLabel => 'First and last name';

  @override
  String get registerNamePlaceholder => 'Jovan Jovanovski';

  @override
  String get registerPhoneLabel => 'Phone';

  @override
  String get registerConfirmPasswordLabel => 'Confirm password';

  @override
  String get registerTermsPrefix => 'I agree to the ';

  @override
  String get registerTermsOfService => 'Terms of Service';

  @override
  String get registerPrivacyPolicy => 'Privacy Policy';

  @override
  String get registerTermsSuffix => ' and the User Responsibilities.';

  @override
  String get registerSubmitButton => 'SIGN UP';

  @override
  String get registerFooterPrompt => 'Already have an account? ';

  @override
  String get termsPrivacyTitle => 'Terms and policies';

  @override
  String get termsPrivacySubtitle => 'Please read before continuing';

  @override
  String get termsPrivacyTermsHeading => '1. Terms of Service';

  @override
  String get termsPrivacyTermsBody =>
      'By using the platform you agree that offers are published by providers and that the platform acts as an intermediary between the provider and the guest. Reservations are subject to the cancellation policies defined for each offer. The platform reserves the right to moderate, approve or remove content that does not comply with the community rules.\n\nUsers agree to provide accurate and up-to-date information when registering and using the services.';

  @override
  String get termsPrivacyPolicyHeading => '2. Privacy Policy';

  @override
  String get termsPrivacyPolicyBody =>
      'Personal data is processed in accordance with the applicable data protection regulations and is used solely for reservations, communication and improving the service.';

  @override
  String get termsPrivacyConsentTerms =>
      'I have read and agree to the Terms of Service.';

  @override
  String get termsPrivacyConsentPrivacy =>
      'I have read and agree to the Privacy Policy.';

  @override
  String get termsPrivacyConsentResponsibilities =>
      'I accept the user\'s responsibilities when booking and paying.';

  @override
  String get termsPrivacySubmitButton => 'ACCEPT AND CONTINUE';

  @override
  String get emailVerificationTitle => 'Verify your email';

  @override
  String get emailVerificationSentTo => 'We sent a verification code to';

  @override
  String get emailVerificationInstructions =>
      'Enter the code from the email to activate your profile and continue using the app.';

  @override
  String get emailVerificationCodeLabel => 'Verification code';

  @override
  String get emailVerificationCodePlaceholder => 'Enter the code';

  @override
  String get emailVerificationSubmitButton => 'VERIFY';

  @override
  String get emailVerificationErrorEmptyCode =>
      'Enter the code from the email.';

  @override
  String get emailVerificationSuccess =>
      'Your email is verified. Log in to continue.';

  @override
  String get emailVerificationBadge => 'NOT VERIFIED';

  @override
  String get emailVerificationResendButton => 'SEND AGAIN';

  @override
  String get emailVerificationChangeEmail => 'Change email';

  @override
  String get profileTitle => 'My profile';

  @override
  String get profilePersonalDataHeading => 'Personal details';

  @override
  String get profilePhoneLabel => 'Phone number';

  @override
  String get profileCityLabel => 'City / Location';

  @override
  String get profileCityPlaceholder => 'Ohrid, North Macedonia';

  @override
  String get profileReservationsLabel => 'Reservations';

  @override
  String get profileFavoritePlacesLabel => 'Favourite places';

  @override
  String get profileSaveButton => 'Save changes';

  @override
  String get providerSubjectTypeLabel => 'Entity type';

  @override
  String get providerSubjectTypeIndividual => 'Individual';

  @override
  String get providerSubjectTypeLegal => 'Legal entity';

  @override
  String get providerLegalEntityComingSoon =>
      'Fields for legal entities will be available soon.';

  @override
  String get providerOfferInfoHeading => 'Offer information';

  @override
  String get providerOfferNameLabel => 'Offer / experience name';

  @override
  String get providerOfferNamePlaceholder => 'Guest room with breakfast';

  @override
  String get providerCategoryHeading => 'Offer category';

  @override
  String get providerCategoryAccommodation => 'Accommodation';

  @override
  String get providerCategoryGastronomy => 'Gastronomy';

  @override
  String get providerCategoryFarmParticipation => 'Hands-on farm activities';

  @override
  String get providerCategoryDirectSales => 'Direct sales';

  @override
  String get providerCategoryFarmEducation => 'Farm education';

  @override
  String get providerCategoryFarmRecreation =>
      'Recreation and relaxation on the farm';

  @override
  String get providerCategoryOffFarmTours =>
      'Tours and activities off the farm';

  @override
  String get providerLocationLabel => 'Location';

  @override
  String get providerLocationPlaceholder => 'Krushevo';

  @override
  String get providerActiveOffersLabel => 'Active offers';

  @override
  String get providerAverageRatingLabel => 'Average rating';

  @override
  String get providerNotVerifiedBadge => 'NOT VERIFIED';

  @override
  String get providerVerifiedBadge => 'VERIFIED';

  @override
  String get providerExampleName => 'Ana Trajkovska';

  @override
  String get providerSetupTitle => 'Profile setup';

  @override
  String get providerSetupSubtitle =>
      'Enter the basic details for your profile';

  @override
  String get providerAddLogoLabel => 'Add logo';

  @override
  String get providerLegalCompanyNameLabel => 'Company / business owner name';

  @override
  String get providerLegalResponsiblePersonLabel => 'Responsible person';

  @override
  String get providerLegalResponsiblePersonPlaceholder =>
      'Vladimir Zdravkovski';

  @override
  String get providerLegalEmailPlaceholder => 'For example: contact@company.mk';

  @override
  String get providerLegalBusinessDetailsHeading => 'Business details';

  @override
  String get providerLegalTaxIdLabel => 'Tax ID (EDB)';

  @override
  String get providerLegalCategoryHeading => 'Business category';

  @override
  String get providerLegalAddressLabel => 'Business address';

  @override
  String get providerLegalAddressPlaceholder => 'Brajchino, Prespa';

  @override
  String get providerAdditionalContactsHeading => 'Additional contacts';

  @override
  String get providerAdditionalContactLabel => 'Contact (phone or email)';

  @override
  String get providerAdditionalContactPlaceholder =>
      'Enter a phone number or email';

  @override
  String get providerAddContactButton => '+ Add contact';

  @override
  String get providerSaveAndContinueButton => 'Save and continue';

  @override
  String get imageSourceGallery => 'Gallery';

  @override
  String get imageSourceCamera => 'Camera';

  @override
  String get navTouristHome => 'Home';

  @override
  String get navTouristSearch => 'Search';

  @override
  String get navTouristBookings => 'Bookings';

  @override
  String get navProviderDashboard => 'Dashboard';

  @override
  String get navProviderOffers => 'Offers';

  @override
  String get navProviderCalendar => 'Calendar';

  @override
  String get navMessages => 'Messages';

  @override
  String get navProfile => 'Profile';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsLanguageHeading => 'App language';

  @override
  String get settingsLanguageRowLabel => 'Choose a language';

  @override
  String get settingsNotificationsLabel => 'Notifications';

  @override
  String get settingsPrivacyHeading => 'Privacy and data';

  @override
  String get settingsPrivacyDescription =>
      'In line with the GDPR, you can download or delete your personal data.';

  @override
  String get settingsDownloadDataButton => 'Download my data';

  @override
  String get settingsDeleteAccountButton => 'Request account deletion';

  @override
  String get settingsLogoutButton => 'Log out';

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get notificationsUnreadSuffix => 'unread notifications';

  @override
  String get timeJustNow => 'now';

  @override
  String get timeMinutesSuffix => 'min';

  @override
  String get timeHoursSuffix => 'h';

  @override
  String get timeDaysSuffix => 'd';

  @override
  String get chatToday => 'Today';

  @override
  String get chatInputPlaceholder => 'Write a message...';

  @override
  String get myTicketsTitle => 'My tickets';

  @override
  String get createTicketButton => 'Create a new ticket';

  @override
  String get ticketStatusOpen => 'OPEN';

  @override
  String get ticketStatusInProgress => 'IN PROGRESS';

  @override
  String get ticketStatusResolved => 'RESOLVED';

  @override
  String get ticketLastChangedLabel => 'Last updated';

  @override
  String get newTicketTitle => 'New support ticket';

  @override
  String get newTicketSubtitle =>
      'Describe the problem and we\'ll get back to you soon';

  @override
  String get newTicketCategoryLabel => 'Category';

  @override
  String get newTicketTitleLabel => 'Title';

  @override
  String get newTicketTitlePlaceholder => 'E.g. Payment problem';

  @override
  String get newTicketDescriptionLabel => 'Problem description';

  @override
  String get newTicketDescriptionPlaceholder =>
      'Describe in detail what happened, when, and which listing or reservation it concerns...';

  @override
  String get newTicketAttachmentLabel => 'Attach an image or document';

  @override
  String get newTicketAttachmentOptional => '(optional)';

  @override
  String get newTicketSubmitButton => 'Send request';

  @override
  String get newTicketCategoryReservations => 'Reservations';

  @override
  String get newTicketCategoryListings => 'Listings';

  @override
  String get newTicketCategoryPayments => 'Payment';

  @override
  String get newTicketCategoryProfile => 'Profile';

  @override
  String get newTicketCategoryOther => 'Other';

  @override
  String get attachmentSourceDocument => 'Document';

  @override
  String get dashboardTitle => 'Dashboard';

  @override
  String get dashboardGreetingPrefix => 'Welcome, ';

  @override
  String get dashboardAddListingButton => '+ Add a new offer';

  @override
  String get dashboardListingsSummaryHeading => 'Offers overview';

  @override
  String get dashboardActiveListingsLabel => 'Active offers';

  @override
  String get dashboardPendingReviewListingsLabel => 'In review';

  @override
  String get dashboardMonthlyReservationsLabel => 'Reservations this month';

  @override
  String get dashboardPendingReservationsHeading => 'Pending reservations';

  @override
  String get dashboardCompletedReservationsHeading => 'Completed reservations';

  @override
  String get reservationStatusPending => 'PENDING';

  @override
  String get reservationStatusAccepted => 'ACCEPTED';

  @override
  String get reservationStatusAcceptedTourist => 'CONFIRMED';

  @override
  String get reservationStatusRejected => 'REJECTED';

  @override
  String get reservationStatusCompleted => 'COMPLETED';

  @override
  String get reservationStatusCancelled => 'CANCELLED';

  @override
  String get reservationGuestSingular => 'guest';

  @override
  String get reservationGuestsPlural => 'guests';

  @override
  String get acceptReservationButton => 'Accept';

  @override
  String get rejectReservationButton => 'Reject';

  @override
  String get rateGuestButton => 'Rate guest';

  @override
  String get offersTitle => 'My offers';

  @override
  String get offersSubtitle => 'Manage your offers and their status';

  @override
  String get offersFilterAll => 'All';

  @override
  String get offersFilterActive => 'Active';

  @override
  String get offersFilterPendingReview => 'In review';

  @override
  String get offersFilterRejected => 'Rejected';

  @override
  String get listingStatusActive => 'ACTIVE';

  @override
  String get listingStatusPendingReview => 'IN REVIEW';

  @override
  String get listingStatusRejected => 'REJECTED';

  @override
  String get listingStatusArchived => 'ARCHIVED';

  @override
  String get listingReservationsThisMonthLabel => 'reservations this month';

  @override
  String get listingSubmittedForReviewLabel => 'Submitted for review';

  @override
  String get listingRejectedReasonPrefix => 'Rejected: ';

  @override
  String get listingArchivedOnLabel => 'Archived';

  @override
  String get editListingButton => 'Edit';

  @override
  String get editAndResubmitListingButton => 'Edit and resubmit';

  @override
  String get reactivateListingButton => 'Reactivate';

  @override
  String get calendarTitle => 'Availability calendar';

  @override
  String get availabilityStatusAvailable => 'Available';

  @override
  String get availabilityStatusOccupied => 'Booked';

  @override
  String get availabilityStatusBlocked => 'Blocked';

  @override
  String get weekdayMon => 'Mon';

  @override
  String get weekdayTue => 'Tue';

  @override
  String get weekdayWed => 'Wed';

  @override
  String get weekdayThu => 'Thu';

  @override
  String get weekdayFri => 'Fri';

  @override
  String get weekdaySat => 'Sat';

  @override
  String get weekdaySun => 'Sun';

  @override
  String get blockSelectedDatesButton => 'Block selected dates';

  @override
  String get unblockSelectedDatesButton => 'Unblock selected dates';

  @override
  String get wizardHeaderTitle => 'New offer';

  @override
  String get wizardStepLabel => 'Step';

  @override
  String get wizardStepOfLabel => 'of';

  @override
  String get wizardBackButton => 'Back';

  @override
  String get wizardNextButton => 'Next';

  @override
  String get wizardPublishButton => 'Publish';

  @override
  String get wizardCategoryFarmRecreation => 'Recreation and relaxation';

  @override
  String get wizardCategoryOffFarmTours => 'Off-farm tours';

  @override
  String get wizardStep1Heading => 'Tell us about your offer';

  @override
  String get wizardStep1Subtitle =>
      'Choose a category and give your offer a title.';

  @override
  String get wizardCategoryLabel => 'Category';

  @override
  String get wizardTitleLabel => 'Offer title';

  @override
  String get wizardTitlePlaceholder => 'E.g. Guest room with breakfast';

  @override
  String get wizardStep2Heading => 'Where is your offer located?';

  @override
  String get wizardStep2Subtitle =>
      'Your address will only be shared with guests after they book.';

  @override
  String get wizardLocationLabel => 'Address / settlement';

  @override
  String get wizardLocationPlaceholder => 'Brajchino, Prespa';

  @override
  String get wizardStep3Heading => 'How many guests can you host?';

  @override
  String get wizardStep3Subtitle => 'You can change this later.';

  @override
  String get wizardGuestsLabel => 'Guests';

  @override
  String get wizardRoomsLabel => 'Rooms';

  @override
  String get wizardBedsLabel => 'Beds';

  @override
  String get wizardStep4Heading => 'Tell guests what you offer';

  @override
  String get wizardStep4Subtitle => 'Select everything you offer.';

  @override
  String get wizardStep5Heading => 'Add photos';

  @override
  String get wizardStep5Subtitle =>
      'At least 5 photos are needed to publish the offer.';

  @override
  String get wizardStep6Heading => 'Describe your offer';

  @override
  String get wizardStep6Subtitle =>
      'Briefly describe what you offer and set a price.';

  @override
  String get wizardDescriptionLabel => 'Description';

  @override
  String get wizardDescriptionPlaceholder =>
      'A spacious traditional house in the heart of Prespa...';

  @override
  String get wizardPriceLabel => 'Price (per night, if it\'s accommodation)';

  @override
  String get wizardPricePlaceholder => '2,770 MKD';

  @override
  String get wizardPriceSuffix => 'MKD';

  @override
  String get wizardPricePerNightSuffix => 'MKD / night';

  @override
  String get wizardReviewHeading => 'Review';

  @override
  String get wizardReviewSubtitle =>
      'Check the details before publishing the offer.';

  @override
  String get wizardReviewTitleRow => 'Title';

  @override
  String get wizardReviewCategoryRow => 'Category';

  @override
  String get wizardReviewLocationRow => 'Location';

  @override
  String get wizardReviewCapacityRow => 'Capacity';

  @override
  String get wizardReviewAmenitiesRow => 'Amenities';

  @override
  String get wizardReviewPhotosRow => 'Photos';

  @override
  String get wizardReviewPriceRow => 'Price';

  @override
  String get wizardRoomSingular => 'room';

  @override
  String get wizardRoomsPlural => 'rooms';

  @override
  String get wizardBedSingular => 'bed';

  @override
  String get wizardBedsPlural => 'beds';

  @override
  String get wizardAmenitySingular => 'amenity';

  @override
  String get wizardAmenitiesPlural => 'amenities';

  @override
  String get wizardPhotoSingular => 'photo';

  @override
  String get wizardPhotosPlural => 'photos';

  @override
  String get wizardDiscardDialogTitle => 'Leave this offer?';

  @override
  String get wizardDiscardDialogMessage =>
      'The information you entered won\'t be saved.';

  @override
  String get wizardDiscardDialogCancel => 'Cancel';

  @override
  String get wizardDiscardDialogConfirm => 'Leave';

  @override
  String get amenityParking => 'Free parking';

  @override
  String get amenityKitchen => 'Equipped kitchen';

  @override
  String get amenityAirConditioning => 'Air conditioning';

  @override
  String get amenityTv => 'TV';

  @override
  String get amenityFireplace => 'Fireplace';

  @override
  String get amenityFarmAccess => 'Farm access';

  @override
  String get amenityHotWater => 'Hot water';

  @override
  String get amenityPetsAllowed => 'Pets allowed';

  @override
  String get offerPublishedTitle => 'Offer published';

  @override
  String get offerPublishedHeading => 'Your offer is published!';

  @override
  String get offerPublishedSubtitle =>
      'Your offer is now visible to guests on the platform.';

  @override
  String get offerPublishedViewOffersButton => 'View my offers';

  @override
  String get offerPublishedGoToDashboardButton => 'Go to dashboard';

  @override
  String get rateGuestTitle => 'Rate guest';

  @override
  String get rateGuestQuestion => 'How was the guest\'s stay?';

  @override
  String get rateGuestNoteLabel => 'Note (optional)';

  @override
  String get rateGuestNotePlaceholder =>
      'E.g. Great guest, left the house tidy.';

  @override
  String get rateGuestHelperText =>
      'Under the platform rules, a guest can only be rated after a completed service with an existing reservation.';

  @override
  String get submitRatingButton => 'Submit rating';

  @override
  String get ratingSavedTitle => 'Rating';

  @override
  String get ratingSavedHeading => 'Your rating is saved!';

  @override
  String get homeGreetingPrefix => 'Hi, ';

  @override
  String get homeSubtitle => 'Find your next rural experience';

  @override
  String get homeSearchPlaceholder => 'Search destinations, offers...';

  @override
  String get homeCategoriesHeading => 'Categories';

  @override
  String get homeRecommendedHeading => 'Recommended for you';

  @override
  String get homePricePrefix => 'from ';

  @override
  String get homeBanner1Title => 'Up to 20% off selected offers';

  @override
  String get homeBanner1Action => 'See them →';

  @override
  String get homeBanner2Title => 'New offers this week';

  @override
  String get homeBanner2Action => 'Explore →';

  @override
  String get homeBanner3Title => 'Guest favourite: Villa Zdravkovski';

  @override
  String get homeBanner3Action => 'Book →';

  @override
  String get filtersSheetTitle => 'Filters';

  @override
  String get filtersKeywordLabel => 'Keyword';

  @override
  String get filtersKeywordPlaceholder => 'E.g. house with a pool';

  @override
  String get filtersLocationLabel => 'Location';

  @override
  String get filtersAllLocationsOption => 'All locations';

  @override
  String get filtersPriceRangeLabel => 'Price range';

  @override
  String get filtersPriceRangeUnit => 'MKD';

  @override
  String get filtersDateLabel => 'Dates of stay';

  @override
  String get filtersDatePlaceholder => 'Choose dates';

  @override
  String get filtersRatingLabel => 'Rating';

  @override
  String get filtersRatingAllOption => 'All';

  @override
  String get filtersGuestCountLabel => 'Number of guests';

  @override
  String get filtersAmenityHeading => 'Amenities';

  @override
  String get filtersClearButton => 'Clear filters';

  @override
  String get filtersShowResultsButton => 'Show results';

  @override
  String get resultsTitle => 'Results';

  @override
  String get resultsFiltersChipLabel => 'Filters';

  @override
  String get resultsRatingChipLabel => 'Rating 4+';

  @override
  String get resultsPriceChipLabel => 'Price';

  @override
  String get resultsCountSuffix => 'offers';

  @override
  String get resultsCountLocationPrefix => 'in';

  @override
  String get resultsSortLabel => 'Sorted by relevance';

  @override
  String get resultsMapButtonLabel => 'Map';

  @override
  String get resultsShowDetailsButton => 'Show details';

  @override
  String get resultsReservationsSuffix => 'reservations';

  @override
  String get resultsPricePerNightSuffix => 'MKD/night';

  @override
  String get detailsTitle => 'Details';

  @override
  String get detailsHostPrefix => 'Host: ';

  @override
  String get detailsHostSincePrefix => 'Here since ';

  @override
  String get detailsAboutHeading => 'About this offer';

  @override
  String get detailsAmenitiesHeading => 'What\'s included?';

  @override
  String get detailsLocationHeading => 'Where is it?';

  @override
  String get detailsReserveButton => 'Book';

  @override
  String get reservationFlowTitle => 'Reservation';

  @override
  String get bookingDatesUnavailableError =>
      'The selected dates aren\'t available for this offer.';

  @override
  String get bookingRequestSentHeading =>
      'Your reservation request has been sent!';

  @override
  String get bookingRequestSentSubtitle =>
      'You\'ll get an email as soon as the provider confirms your reservation.';

  @override
  String get tripDetailsHeading => 'Stay details';

  @override
  String get checkInLabel => 'Check-in';

  @override
  String get checkOutLabel => 'Check-out';

  @override
  String get paymentDetailsHeading => 'Payment details';

  @override
  String get serviceFeeLabel => 'Service fee';

  @override
  String get totalLabel => 'Total';

  @override
  String get reservationNumberLabel => 'Reservation number';

  @override
  String get nightSingular => 'night';

  @override
  String get nightsPlural => 'nights';

  @override
  String get viewMyReservationsButton => 'View my reservations';

  @override
  String get backToHomeButton => 'Back to home';

  @override
  String get myReservationsTitle => 'My reservations';

  @override
  String get upcomingTabLabel => 'Upcoming';

  @override
  String get pastTabLabel => 'Past';

  @override
  String get myReservationsDetailsButton => 'View details';

  @override
  String get leaveReviewButton => 'Leave a review';

  @override
  String get myReservationsEmptyUpcoming => 'No upcoming reservations.';

  @override
  String get myReservationsEmptyPast => 'No past reservations.';

  @override
  String get leaveReviewQuestion => 'How was your stay?';

  @override
  String get leaveReviewTextLabel => 'Your review';

  @override
  String get leaveReviewTextPlaceholder =>
      'Share your experience with future guests...';

  @override
  String get leaveReviewDisclaimer =>
      'You can only leave a review after a valid completed reservation, through the mobile or web app.';

  @override
  String get submitReviewButton => 'Submit review';

  @override
  String get reviewSubmittedTitle => 'Review';

  @override
  String get reviewSubmittedHeading => 'Thank you for your review!';

  @override
  String get backToReservationsButton => 'Back to reservations';

  @override
  String get welcomeToBulka => 'Welcome to Bulka';

  @override
  String get whoAreYou => 'Who are you?';

  @override
  String get chooseProfile => 'Choose your profile type';

  @override
  String get tourist => 'Tourist';

  @override
  String get touristDescription => 'Search and book unique experiences';

  @override
  String get owner => 'Property/service owner';

  @override
  String get ownerDescription => 'List and manage your offers';

  @override
  String get continueText => 'CONTINUE';

  @override
  String get alreadyAccount => 'Already have an account? Log in';

  @override
  String get routeNotFoundTitle => 'Page not found';

  @override
  String get routeNotFoundMessage =>
      'This page doesn\'t exist or is no longer available.';

  @override
  String get routeNotFoundButton => 'GO TO START';

  @override
  String agoMinutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count minutes ago',
      one: '1 minute ago',
    );
    return '$_temp0';
  }

  @override
  String agoHours(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count hours ago',
      one: '1 hour ago',
    );
    return '$_temp0';
  }

  @override
  String agoDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days ago',
      one: '1 day ago',
    );
    return '$_temp0';
  }
}
