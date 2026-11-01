// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Macedonian (`mk`).
class AppLocalizationsMk extends AppLocalizations {
  AppLocalizationsMk([String locale = 'mk']) : super(locale);

  @override
  String get splashTitle => 'Агро Еко Туризам';

  @override
  String get splashSubtitle =>
      'Откријте ја убавината на руралниот туризам во Македонија';

  @override
  String get chooseLanguage => 'Изберете јазик';

  @override
  String get continueButton => 'Продолжи';

  @override
  String get emailLabel => 'Е-пошта';

  @override
  String get emailPlaceholder => 'tvojotmejl@example.com';

  @override
  String get passwordLabel => 'Лозинка';

  @override
  String get backToLoginAction => 'Најавете се';

  @override
  String get loginTitle => 'Најава';

  @override
  String get loginWelcomeBack => 'Добредојдовте назад!';

  @override
  String get loginWelcomeBackSubtitle => 'Најавете се на вашата сметка';

  @override
  String get loginForgotPassword => 'Заборавена лозинка?';

  @override
  String get loginSubmitButton => 'НАЈАВИ СЕ';

  @override
  String get loginGoogleButton => 'ПРОДОЛЖИ СО GOOGLE';

  @override
  String get loginFooterPrompt => 'Немате сметка? ';

  @override
  String get loginFooterAction => 'Регистрирајте се';

  @override
  String get loginErrorEmptyFields => 'Внесете е-пошта и лозинка.';

  @override
  String get loginErrorInvalidCredentials => 'Погрешна е-пошта или лозинка.';

  @override
  String get loginErrorTwoFactorUnsupported =>
      'Оваа сметка има вклучена двофакторска автентикација, која сè уште не е поддржана во апликацијата.';

  @override
  String get loginErrorUnsupportedAccount =>
      'Апликацијата е само за туристи и понудувачи. Оваа сметка не може да се користи тука.';

  @override
  String get registerErrorFullName => 'Внесете име и презиме.';

  @override
  String get registerErrorEmail => 'Внесете валидна е-пошта.';

  @override
  String get registerErrorPhone =>
      'Внесете телефонски број во меѓународен формат, на пр. +389 70 123 456.';

  @override
  String get registerErrorPasswordRules =>
      'Лозинката мора да има најмалку 8 знаци, голема буква, бројка и специјален знак.';

  @override
  String get registerErrorPasswordMismatch => 'Лозинките не се совпаѓаат.';

  @override
  String get emailVerificationResent => 'Испративме нова порака за потврда.';

  @override
  String get apiErrorEmailRequired => 'Е-поштата е задолжителна.';

  @override
  String get apiErrorFirstNameRequired => 'Името е задолжително.';

  @override
  String get apiErrorLastNameRequired => 'Презимето е задолжително.';

  @override
  String get apiErrorPhoneRequired => 'Телефонскиот број е задолжителен.';

  @override
  String get apiErrorPasswordRequired => 'Лозинката е задолжителна.';

  @override
  String get apiErrorCodeRequired => 'Кодот за потврда е задолжителен.';

  @override
  String get apiErrorTermsRequired =>
      'Мора да ги прифатите условите за користење.';

  @override
  String get apiErrorPrivacyRequired =>
      'Мора да ја прифатите политиката за приватност.';

  @override
  String get apiErrorPasswordTooShort =>
      'Лозинката мора да има најмалку 8 знаци.';

  @override
  String get apiErrorPasswordNeedsUppercase =>
      'Лозинката мора да содржи голема буква.';

  @override
  String get apiErrorPasswordNeedsLowercase =>
      'Лозинката мора да содржи мала буква.';

  @override
  String get apiErrorPasswordNeedsDigit => 'Лозинката мора да содржи бројка.';

  @override
  String get apiErrorPasswordNeedsSpecial =>
      'Лозинката мора да содржи специјален знак.';

  @override
  String get apiErrorVerificationCodeInvalid =>
      'Кодот за потврда не е точен. Проверете ја е-поштата и обидете се повторно.';

  @override
  String get apiErrorInvalidInput =>
      'Некои од внесените податоци не се точни. Проверете ги и обидете се повторно.';

  @override
  String get apiErrorNetwork =>
      'Нема интернет конекција. Проверете ја врската и обидете се повторно.';

  @override
  String get apiErrorTimeout => 'Серверот не одговара. Обидете се повторно.';

  @override
  String get apiErrorUnauthorized => 'Сесијата истече. Најавете се повторно.';

  @override
  String get apiErrorServer =>
      'Настана грешка на серверот. Обидете се подоцна.';

  @override
  String get apiErrorUnknown =>
      'Настана неочекувана грешка. Обидете се повторно.';

  @override
  String get forgotPasswordTitle => 'Заборавена лозинка';

  @override
  String get forgotPasswordHeading => 'Ресетирајте ја лозинката';

  @override
  String get forgotPasswordSubheading =>
      'Внесете ја вашата е-пошта и ќе ви испратиме код за ресетирање на лозинката.';

  @override
  String get forgotPasswordSubmitButton => 'ИСПРАТИ КОД';

  @override
  String get forgotPasswordFooterPrompt => 'Се сетивте на лозинката? ';

  @override
  String get resetPasswordTitle => 'Нова лозинка';

  @override
  String get resetPasswordHeading => 'Внесете нова лозинка';

  @override
  String get resetPasswordSubheading =>
      'Внесете го кодот што ви го испративме по е-пошта и изберете нова лозинка.';

  @override
  String get resetPasswordCodeLabel => 'Код за ресетирање';

  @override
  String get resetPasswordCodePlaceholder => 'Внесете го кодот од е-поштата';

  @override
  String get resetPasswordNewPasswordLabel => 'Нова лозинка';

  @override
  String get resetPasswordSubmitButton => 'РЕСЕТИРАЈ ЛОЗИНКА';

  @override
  String get resetPasswordSuccess =>
      'Лозинката е успешно променета. Најавете се.';

  @override
  String get registerBusinessNameLabel => 'Име на бизнисот';

  @override
  String get registerBusinessNamePlaceholder => 'Агро Еко Фарма ДООЕЛ';

  @override
  String get registerErrorBusinessName => 'Внесете го името на бизнисот.';

  @override
  String get apiErrorBusinessNameRequired =>
      'Името на бизнисот е задолжително.';

  @override
  String get apiErrorEmailNotVerified =>
      'Е-поштата сè уште не е потврдена. Внесете го кодот што ви го испративме.';

  @override
  String get registerTitle => 'Регистрација';

  @override
  String get registerRoleLabel => 'Изберете тип на профил';

  @override
  String get registerRoleGuest => 'Гостин';

  @override
  String get registerRoleProvider => 'Понудувач';

  @override
  String get registerNameLabel => 'Име и презиме';

  @override
  String get registerNamePlaceholder => 'Јован Јовановски';

  @override
  String get registerPhoneLabel => 'Телефон';

  @override
  String get registerConfirmPasswordLabel => 'Потврди лозинка';

  @override
  String get registerTermsPrefix => 'Се согласувам со ';

  @override
  String get registerTermsOfService => 'Условите за користење';

  @override
  String get registerPrivacyPolicy => 'Политиката за приватност';

  @override
  String get registerTermsSuffix => ' и Одговорностите на корисникот.';

  @override
  String get registerSubmitButton => 'РЕГИСТРИРАЈ СЕ';

  @override
  String get registerFooterPrompt => 'Веќе имате сметка? ';

  @override
  String get termsPrivacyTitle => 'Услови и правила';

  @override
  String get termsPrivacySubtitle => 'Ве молиме прочитајте пред да продолжите';

  @override
  String get termsPrivacyTermsHeading => '1. Услови за користење';

  @override
  String get termsPrivacyTermsBody =>
      'Со користење на платформата се согласувате дека понудите се објавуваат од страна на понудувачите и дека платформата делува како посредник меѓу понудувачот и гостинот. Резервациите подлежат на политиките за откажување дефинирани за секоја понуда. Платформата задржува право да модерира, одобрува или отстранува содржина што не е во согласност со правилата на заедницата.\n\nКорисниците се обврзуваат да внесуваат точни и ажурирани податоци при регистрација и користење на услугите.';

  @override
  String get termsPrivacyPolicyHeading => '2. Политика на приватност';

  @override
  String get termsPrivacyPolicyBody =>
      'Личните податоци се обработуваат согласно важечките прописи за заштита на лични податоци и се користат исклучиво за целите на резервација, комуникација и подобрување на услугата.';

  @override
  String get termsPrivacyConsentTerms =>
      'Ги прочитав и се согласувам со Условите за користење.';

  @override
  String get termsPrivacyConsentPrivacy =>
      'Ја прочитав и се согласувам со Политиката за приватност.';

  @override
  String get termsPrivacyConsentResponsibilities =>
      'Ги прифаќам одговорностите на корисникот при резервација и плаќање.';

  @override
  String get termsPrivacySubmitButton => 'ПРИФАТИ И ПРОДОЛЖИ';

  @override
  String get emailVerificationTitle => 'Потврдете ја вашата е-пошта';

  @override
  String get emailVerificationSentTo => 'Испративме код за потврда до';

  @override
  String get emailVerificationInstructions =>
      'Внесете го кодот од е-поштата за да го активирате вашиот профил и да продолжите со користење на апликацијата.';

  @override
  String get emailVerificationCodeLabel => 'Код за потврда';

  @override
  String get emailVerificationCodePlaceholder => 'Внесете го кодот';

  @override
  String get emailVerificationSubmitButton => 'ПОТВРДИ';

  @override
  String get emailVerificationErrorEmptyCode =>
      'Внесете го кодот од е-поштата.';

  @override
  String get emailVerificationSuccess =>
      'Е-поштата е потврдена. Најавете се за да продолжите.';

  @override
  String get emailVerificationBadge => 'НЕ Е ПОТВРДЕНО';

  @override
  String get emailVerificationResendButton => 'ИСПРАТИ ПОВТОРНО';

  @override
  String get emailVerificationChangeEmail => 'Промени е-пошта';

  @override
  String get profileTitle => 'Мојот профил';

  @override
  String get profilePersonalDataHeading => 'Лични податоци';

  @override
  String get profilePhoneLabel => 'Телефонски број';

  @override
  String get profileCityLabel => 'Град / Локација';

  @override
  String get profileCityPlaceholder => 'Охрид, Северна Македонија';

  @override
  String get profileReservationsLabel => 'Резервации';

  @override
  String get profileFavoritePlacesLabel => 'Омилени места';

  @override
  String get profileSaveButton => 'Зачувај промени';

  @override
  String get providerSubjectTypeLabel => 'Тип на субјект';

  @override
  String get providerSubjectTypeIndividual => 'Физичко лице';

  @override
  String get providerSubjectTypeLegal => 'Правно лице';

  @override
  String get providerLegalEntityComingSoon =>
      'Полињата за правни лица ќе бидат достапни наскоро.';

  @override
  String get providerOfferInfoHeading => 'Информации за понудата';

  @override
  String get providerOfferNameLabel => 'Име на понуда / искуство';

  @override
  String get providerOfferNamePlaceholder => 'Гостинска соба со појадок';

  @override
  String get providerCategoryHeading => 'Категорија на понуда';

  @override
  String get providerCategoryAccommodation => 'Сместување';

  @override
  String get providerCategoryGastronomy => 'Гастрономија';

  @override
  String get providerCategoryFarmParticipation => 'Активно учество на фарма';

  @override
  String get providerCategoryDirectSales => 'Директна продажба';

  @override
  String get providerCategoryFarmEducation => 'Едукација на фарма';

  @override
  String get providerCategoryFarmRecreation =>
      'Рекреација и релаксација на фарма';

  @override
  String get providerCategoryOffFarmTours =>
      'Тури и активности надвор од фарма';

  @override
  String get providerLocationLabel => 'Локација';

  @override
  String get providerLocationPlaceholder => 'Крушево';

  @override
  String get providerActiveOffersLabel => 'Активни понуди';

  @override
  String get providerAverageRatingLabel => 'Просечна оценка';

  @override
  String get providerNotVerifiedBadge => 'НЕ Е ВЕРИФИКУВАН';

  @override
  String get providerVerifiedBadge => 'ВЕРИФИКУВАН';

  @override
  String get providerExampleName => 'Ана Трајковска';

  @override
  String get providerSetupTitle => 'Поставување профил';

  @override
  String get providerSetupSubtitle =>
      'Внесете ги основните податоци за вашиот профил';

  @override
  String get providerAddLogoLabel => 'Додади лого';

  @override
  String get providerLegalCompanyNameLabel =>
      'Име на компанија / носител на дејност';

  @override
  String get providerLegalResponsiblePersonLabel => 'Одговорно лице';

  @override
  String get providerLegalResponsiblePersonPlaceholder =>
      'Владимир Здравковски';

  @override
  String get providerLegalEmailPlaceholder => 'На пример: контакт@company.mk';

  @override
  String get providerLegalBusinessDetailsHeading => 'Деловни податоци';

  @override
  String get providerLegalTaxIdLabel => 'ЕДБ / Даночен број';

  @override
  String get providerLegalCategoryHeading => 'Категорија на дејност';

  @override
  String get providerLegalAddressLabel => 'Адреса на бизнисот';

  @override
  String get providerLegalAddressPlaceholder => 'Брајчино, Преспа';

  @override
  String get providerAdditionalContactsHeading => 'Дополнителни контакти';

  @override
  String get providerAdditionalContactLabel => 'Контакт (телефон или е-пошта)';

  @override
  String get providerAdditionalContactPlaceholder =>
      'Внесете телефон или е-пошта';

  @override
  String get providerAddContactButton => '+ Додади контакт';

  @override
  String get providerSaveAndContinueButton => 'Зачувај и продолжи';

  @override
  String get imageSourceGallery => 'Галерија';

  @override
  String get imageSourceCamera => 'Камера';

  @override
  String get navTouristHome => 'Дома';

  @override
  String get navTouristSearch => 'Пребарај';

  @override
  String get navTouristBookings => 'Резервации';

  @override
  String get navProviderDashboard => 'Табла';

  @override
  String get navProviderOffers => 'Понуди';

  @override
  String get navProviderCalendar => 'Календар';

  @override
  String get navMessages => 'Пораки';

  @override
  String get navProfile => 'Профил';

  @override
  String get settingsTitle => 'Поставки';

  @override
  String get settingsLanguageHeading => 'Јазик на апликацијата';

  @override
  String get settingsLanguageRowLabel => 'Изберете јазик';

  @override
  String get settingsNotificationsLabel => 'Известувања';

  @override
  String get settingsPrivacyHeading => 'Приватност и податоци';

  @override
  String get settingsPrivacyDescription =>
      'Во согласност со GDPR можете да ги преземете или избришете вашите лични податоци.';

  @override
  String get settingsDownloadDataButton => 'Преземи ги моите податоци';

  @override
  String get settingsDeleteAccountButton => 'Побарај бришење на сметката';

  @override
  String get settingsLogoutButton => 'Одјава';

  @override
  String get notificationsTitle => 'Известувања';

  @override
  String get notificationsUnreadSuffix => 'непрочитани известувања';

  @override
  String get timeJustNow => 'сега';

  @override
  String get timeMinutesSuffix => 'мин';

  @override
  String get timeHoursSuffix => 'ч';

  @override
  String get timeDaysSuffix => 'ден';

  @override
  String get chatToday => 'Денес';

  @override
  String get chatInputPlaceholder => 'Напишете порака...';

  @override
  String get myTicketsTitle => 'Мои тикети';

  @override
  String get createTicketButton => 'Креирај нов тикет';

  @override
  String get ticketStatusOpen => 'ОТВОРЕН';

  @override
  String get ticketStatusInProgress => 'ВО ТЕК';

  @override
  String get ticketStatusResolved => 'РЕШЕН';

  @override
  String get ticketLastChangedLabel => 'Последна промена';

  @override
  String get newTicketTitle => 'Нов тикет за поддршка';

  @override
  String get newTicketSubtitle =>
      'Опишете го проблемот и ќе ви одговориме наскоро';

  @override
  String get newTicketCategoryLabel => 'Категорија';

  @override
  String get newTicketTitleLabel => 'Наслов';

  @override
  String get newTicketTitlePlaceholder => 'На пр. Проблем со плаќање';

  @override
  String get newTicketDescriptionLabel => 'Опис на проблемот';

  @override
  String get newTicketDescriptionPlaceholder =>
      'Опишете детално што се случи, кога и на кој оглас или резервација се однесува...';

  @override
  String get newTicketAttachmentLabel => 'Прикачи слика или документ';

  @override
  String get newTicketAttachmentOptional => '(опционално)';

  @override
  String get newTicketSubmitButton => 'Испрати барање';

  @override
  String get newTicketCategoryReservations => 'Резервации';

  @override
  String get newTicketCategoryListings => 'Огласи';

  @override
  String get newTicketCategoryPayments => 'Плаќање';

  @override
  String get newTicketCategoryProfile => 'Профил';

  @override
  String get newTicketCategoryOther => 'Друго';

  @override
  String get attachmentSourceDocument => 'Документ';

  @override
  String get dashboardTitle => 'Контролна табла';

  @override
  String get dashboardGreetingPrefix => 'Добредојдовте, ';

  @override
  String get dashboardAddListingButton => '+ Додади нова понуда';

  @override
  String get dashboardListingsSummaryHeading => 'Преглед на понуди';

  @override
  String get dashboardActiveListingsLabel => 'Активни понуди';

  @override
  String get dashboardPendingReviewListingsLabel => 'На преглед';

  @override
  String get dashboardMonthlyReservationsLabel => 'Резервации овој месец';

  @override
  String get dashboardPendingReservationsHeading => 'Резервации кои чекаат';

  @override
  String get dashboardCompletedReservationsHeading => 'Завршени резервации';

  @override
  String get reservationStatusPending => 'НА ЧЕКАЊЕ';

  @override
  String get reservationStatusAccepted => 'ПРИФАТЕНА';

  @override
  String get reservationStatusAcceptedTourist => 'ПОТВРДЕНА';

  @override
  String get reservationStatusRejected => 'ОДБИЕНА';

  @override
  String get reservationStatusCompleted => 'ЗАВРШЕНА';

  @override
  String get reservationStatusCancelled => 'ОТКАЖАНА';

  @override
  String get reservationGuestSingular => 'гостин';

  @override
  String get reservationGuestsPlural => 'гости';

  @override
  String get acceptReservationButton => 'Прифати';

  @override
  String get rejectReservationButton => 'Одбиј';

  @override
  String get rateGuestButton => 'Оцени гостин';

  @override
  String get offersTitle => 'Моите понуди';

  @override
  String get offersSubtitle => 'Управувајте со вашите понуди и нивниот статус';

  @override
  String get offersFilterAll => 'Сите';

  @override
  String get offersFilterActive => 'Активни';

  @override
  String get offersFilterPendingReview => 'На преглед';

  @override
  String get offersFilterRejected => 'Одбиени';

  @override
  String get listingStatusActive => 'АКТИВНА';

  @override
  String get listingStatusPendingReview => 'НА ПРЕГЛЕД';

  @override
  String get listingStatusRejected => 'ОДБИЕНО';

  @override
  String get listingStatusArchived => 'АРХИВИРАНО';

  @override
  String get listingReservationsThisMonthLabel => 'резервации овој месец';

  @override
  String get listingSubmittedForReviewLabel => 'Испратено на преглед';

  @override
  String get listingRejectedReasonPrefix => 'Одбиено: ';

  @override
  String get listingArchivedOnLabel => 'Архивирано на';

  @override
  String get editListingButton => 'Уреди';

  @override
  String get editAndResubmitListingButton => 'Уреди и поднеси повторно';

  @override
  String get reactivateListingButton => 'Активирај повторно';

  @override
  String get calendarTitle => 'Календар на достапност';

  @override
  String get availabilityStatusAvailable => 'Слободно';

  @override
  String get availabilityStatusOccupied => 'Зафатено';

  @override
  String get availabilityStatusBlocked => 'Блокирано';

  @override
  String get weekdayMon => 'Пон';

  @override
  String get weekdayTue => 'Вт';

  @override
  String get weekdayWed => 'Ср';

  @override
  String get weekdayThu => 'Чет';

  @override
  String get weekdayFri => 'Пет';

  @override
  String get weekdaySat => 'Саб';

  @override
  String get weekdaySun => 'Нед';

  @override
  String get blockSelectedDatesButton => 'Блокирај избрани датуми';

  @override
  String get unblockSelectedDatesButton => 'Отклучи избрани датуми';

  @override
  String get wizardHeaderTitle => 'Нова понуда';

  @override
  String get wizardStepLabel => 'Чекор';

  @override
  String get wizardStepOfLabel => 'од';

  @override
  String get wizardBackButton => 'Назад';

  @override
  String get wizardNextButton => 'Понатаму';

  @override
  String get wizardPublishButton => 'Објави';

  @override
  String get wizardCategoryFarmRecreation => 'Рекреација и релаксација';

  @override
  String get wizardCategoryOffFarmTours => 'Тури надвор од фарма';

  @override
  String get wizardStep1Heading => 'Кажете ни за вашата понуда';

  @override
  String get wizardStep1Subtitle =>
      'Изберете категорија и дадете наслов на вашата понуда.';

  @override
  String get wizardCategoryLabel => 'Категорија';

  @override
  String get wizardTitleLabel => 'Наслов на понудата';

  @override
  String get wizardTitlePlaceholder => 'На пр. Гостинска соба со појадок';

  @override
  String get wizardStep2Heading => 'Каде се наоѓа вашата понуда?';

  @override
  String get wizardStep2Subtitle =>
      'Вашата адреса ќе биде споделена со гостите дури откако ќе резервираат.';

  @override
  String get wizardLocationLabel => 'Адреса / населено место';

  @override
  String get wizardLocationPlaceholder => 'Брајчино, Преспа';

  @override
  String get wizardStep3Heading => 'Колку гости може да прифатите?';

  @override
  String get wizardStep3Subtitle => 'Ова подоцна може да го промените.';

  @override
  String get wizardGuestsLabel => 'Гости';

  @override
  String get wizardRoomsLabel => 'Соби';

  @override
  String get wizardBedsLabel => 'Кревети';

  @override
  String get wizardStep4Heading => 'Кажете им на гостите што нудите';

  @override
  String get wizardStep4Subtitle => 'Изберете ги сите нешта кои ги нудите.';

  @override
  String get wizardStep5Heading => 'Додадете фотографии';

  @override
  String get wizardStep5Subtitle =>
      'Најмалку 5 фотографии се потребни за да ја објавите понудата.';

  @override
  String get wizardStep6Heading => 'Опишете ја вашата понуда';

  @override
  String get wizardStep6Subtitle =>
      'Кратко опишете што нудите и одредете цена.';

  @override
  String get wizardDescriptionLabel => 'Опис';

  @override
  String get wizardDescriptionPlaceholder =>
      'Пространа традиционална куќа во срцето на Преспа...';

  @override
  String get wizardPriceLabel =>
      'Цена (по ноќ, доколку се работи за сместување)';

  @override
  String get wizardPricePlaceholder => '2.770 ден.';

  @override
  String get wizardPriceSuffix => 'ден.';

  @override
  String get wizardPricePerNightSuffix => 'ден. / ноќ';

  @override
  String get wizardReviewHeading => 'Преглед';

  @override
  String get wizardReviewSubtitle =>
      'Проверете ги деталите пред да ја објавите понудата.';

  @override
  String get wizardReviewTitleRow => 'Наслов';

  @override
  String get wizardReviewCategoryRow => 'Категорија';

  @override
  String get wizardReviewLocationRow => 'Локација';

  @override
  String get wizardReviewCapacityRow => 'Капацитет';

  @override
  String get wizardReviewAmenitiesRow => 'Опрема';

  @override
  String get wizardReviewPhotosRow => 'Фотографии';

  @override
  String get wizardReviewPriceRow => 'Цена';

  @override
  String get wizardRoomSingular => 'соба';

  @override
  String get wizardRoomsPlural => 'соби';

  @override
  String get wizardBedSingular => 'кревет';

  @override
  String get wizardBedsPlural => 'кревети';

  @override
  String get wizardAmenitySingular => 'нешто';

  @override
  String get wizardAmenitiesPlural => 'нешта';

  @override
  String get wizardPhotoSingular => 'фотографија';

  @override
  String get wizardPhotosPlural => 'фотографии';

  @override
  String get wizardDiscardDialogTitle => 'Да ја напуштите понудата?';

  @override
  String get wizardDiscardDialogMessage =>
      'Внесените информации нема да бидат зачувани.';

  @override
  String get wizardDiscardDialogCancel => 'Откажи';

  @override
  String get wizardDiscardDialogConfirm => 'Напушти';

  @override
  String get amenityParking => 'Бесплатен паркинг';

  @override
  String get amenityKitchen => 'Опремена кујна';

  @override
  String get amenityAirConditioning => 'Клима уред';

  @override
  String get amenityTv => 'ТВ';

  @override
  String get amenityFireplace => 'Огниште';

  @override
  String get amenityFarmAccess => 'Пристап до фарма';

  @override
  String get amenityHotWater => 'Топла вода';

  @override
  String get amenityPetsAllowed => 'Домашни миленици дозволени';

  @override
  String get offerPublishedTitle => 'Понуда објавена';

  @override
  String get offerPublishedHeading => 'Понудата е објавена!';

  @override
  String get offerPublishedSubtitle =>
      'Вашата понуда сега е видлива за гостите на платформата.';

  @override
  String get offerPublishedViewOffersButton => 'Прегледај ги моите понуди';

  @override
  String get offerPublishedGoToDashboardButton => 'Оди на контролна табла';

  @override
  String get rateGuestTitle => 'Оцени гостин';

  @override
  String get rateGuestQuestion => 'Како беше престојот на гостинот?';

  @override
  String get rateGuestNoteLabel => 'Белешка (опционално)';

  @override
  String get rateGuestNotePlaceholder =>
      'На пр. Одличен гостин, ја остави куќата уредна.';

  @override
  String get rateGuestHelperText =>
      'Согласно правилата на платформата, гостинот може да биде оценет само по завршена услуга каде постоела резервација.';

  @override
  String get submitRatingButton => 'Испрати оцена';

  @override
  String get ratingSavedTitle => 'Оценка';

  @override
  String get ratingSavedHeading => 'Оценката е зачувана!';

  @override
  String get homeGreetingPrefix => 'Здраво, ';

  @override
  String get homeSubtitle => 'Пронајдете го вашето следно рурално доживување';

  @override
  String get homeSearchPlaceholder => 'Пребарај дестинации, понуди...';

  @override
  String get homeCategoriesHeading => 'Категории';

  @override
  String get homeCategoriesLoadFailed => 'Категориите не можат да се вчитаат.';

  @override
  String get homeCategoriesRetry => 'Обиди се повторно';

  @override
  String get homeRecommendedHeading => 'Препорачано за вас';

  @override
  String get homePricePrefix => 'од ';

  @override
  String get homeBanner1Title => 'До 20% попуст на избрани понуди';

  @override
  String get homeBanner1Action => 'Погледни ги →';

  @override
  String get homeBanner2Title => 'Нови понуди оваа недела';

  @override
  String get homeBanner2Action => 'Истражи ги →';

  @override
  String get homeBanner3Title => 'Омилено на гостите: Villa Zdravkovski';

  @override
  String get homeBanner3Action => 'Резервирај →';

  @override
  String get filtersSheetTitle => 'Филтри';

  @override
  String get filtersKeywordLabel => 'Клучен збор';

  @override
  String get filtersKeywordPlaceholder => 'На пр. куќа со базен';

  @override
  String get filtersLocationLabel => 'Локација';

  @override
  String get filtersAllLocationsOption => 'Сите локации';

  @override
  String get filtersPriceRangeLabel => 'Ценовен опсег';

  @override
  String get filtersPriceRangeUnit => 'ден.';

  @override
  String get filtersDateLabel => 'Датум на престој';

  @override
  String get filtersDatePlaceholder => 'Изберете датуми';

  @override
  String get filtersRatingLabel => 'Оценка';

  @override
  String get filtersRatingAllOption => 'Сите';

  @override
  String get filtersGuestCountLabel => 'Број на гости';

  @override
  String get filtersAmenityHeading => 'Опрема';

  @override
  String get filtersClearButton => 'Избриши филтри';

  @override
  String get filtersShowResultsButton => 'Прикажи резултати';

  @override
  String get resultsTitle => 'Резултати';

  @override
  String get resultsFiltersChipLabel => 'Филтри';

  @override
  String get resultsRatingChipLabel => 'Оценка 4+';

  @override
  String get resultsPriceChipLabel => 'Цена';

  @override
  String get resultsCountSuffix => 'понуди';

  @override
  String get resultsCountLocationPrefix => 'во';

  @override
  String get resultsSortLabel => 'Прикажани по релевантност';

  @override
  String get resultsMapButtonLabel => 'Карта';

  @override
  String get resultsShowDetailsButton => 'Прикажи детали';

  @override
  String get resultsReservationsSuffix => 'резервации';

  @override
  String get resultsPricePerNightSuffix => 'ден./ноќ';

  @override
  String get detailsTitle => 'Детали';

  @override
  String get detailsHostPrefix => 'Домаќин: ';

  @override
  String get detailsHostSincePrefix => 'Тука од ';

  @override
  String get detailsAboutHeading => 'За понудата';

  @override
  String get detailsAmenitiesHeading => 'Што нуди?';

  @override
  String get detailsLocationHeading => 'Каде се наоѓа?';

  @override
  String get detailsReserveButton => 'Резервирај';

  @override
  String get reservationFlowTitle => 'Резервација';

  @override
  String get bookingDatesUnavailableError =>
      'Избраните датуми не се достапни за оваа понуда.';

  @override
  String get bookingRequestSentHeading =>
      'Барањето за резервација е испратено!';

  @override
  String get bookingRequestSentSubtitle =>
      'Ќе добиете е-пошта штом понудувачот ја потврди вашата резервација.';

  @override
  String get tripDetailsHeading => 'Детали за престојот';

  @override
  String get checkInLabel => 'Пристигнување';

  @override
  String get checkOutLabel => 'Заминување';

  @override
  String get paymentDetailsHeading => 'Детали за плаќањето';

  @override
  String get serviceFeeLabel => 'Такса за услуга';

  @override
  String get totalLabel => 'Вкупно';

  @override
  String get reservationNumberLabel => 'Број на резервација';

  @override
  String get nightSingular => 'ноќ';

  @override
  String get nightsPlural => 'ноќи';

  @override
  String get viewMyReservationsButton => 'Прегледај ги моите резервации';

  @override
  String get backToHomeButton => 'Назад кон почетна';

  @override
  String get myReservationsTitle => 'Мои резервации';

  @override
  String get upcomingTabLabel => 'Претстојни';

  @override
  String get pastTabLabel => 'Минати';

  @override
  String get myReservationsDetailsButton => 'Прегледај детали';

  @override
  String get leaveReviewButton => 'Остави рецензија';

  @override
  String get myReservationsEmptyUpcoming => 'Нема претстојни резервации.';

  @override
  String get myReservationsEmptyPast => 'Нема минати резервации.';

  @override
  String get leaveReviewQuestion => 'Каков беше вашиот престој?';

  @override
  String get leaveReviewTextLabel => 'Вашата рецензија';

  @override
  String get leaveReviewTextPlaceholder =>
      'Споделете го вашето искуство со идните гости...';

  @override
  String get leaveReviewDisclaimer =>
      'Рецензија може да оставите само по валидна завршена резервација, преку мобилна или веб апликација.';

  @override
  String get submitReviewButton => 'Испрати рецензија';

  @override
  String get reviewSubmittedTitle => 'Рецензија';

  @override
  String get reviewSubmittedHeading => 'Ви благодариме за рецензијата!';

  @override
  String get backToReservationsButton => 'Назад кон резервации';

  @override
  String get welcomeToBulka => 'Добредојде во Булка';

  @override
  String get whoAreYou => 'Вие сте?';

  @override
  String get chooseProfile => 'Изберете го вашиот тип на профил';

  @override
  String get tourist => 'Турист';

  @override
  String get touristDescription => 'Пребарувај и резервирај уникатни искуства';

  @override
  String get owner => 'Сопственик на имот/услуги';

  @override
  String get ownerDescription => 'Огласи и управувај со своите понуди';

  @override
  String get continueText => 'ПРОДОЛЖИ';

  @override
  String get alreadyAccount => 'Веќе имате сметка? Најавете се';

  @override
  String get routeNotFoundTitle => 'Страницата не е пронајдена';

  @override
  String get routeNotFoundMessage =>
      'Оваа страница не постои или повеќе не е достапна.';

  @override
  String get routeNotFoundButton => 'ОДИ НА ПОЧЕТОК';

  @override
  String agoMinutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'пред $count минути',
      one: 'пред 1 минута',
    );
    return '$_temp0';
  }

  @override
  String agoHours(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'пред $count часа',
      one: 'пред 1 час',
    );
    return '$_temp0';
  }

  @override
  String agoDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'пред $count дена',
      one: 'пред 1 ден',
    );
    return '$_temp0';
  }
}
