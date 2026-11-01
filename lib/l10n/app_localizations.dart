import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_mk.dart';
import 'app_localizations_sq.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('mk'),
    Locale('sq'),
  ];

  /// No description provided for @splashTitle.
  ///
  /// In mk, this message translates to:
  /// **'Агро Еко Туризам'**
  String get splashTitle;

  /// No description provided for @splashSubtitle.
  ///
  /// In mk, this message translates to:
  /// **'Откријте ја убавината на руралниот туризам во Македонија'**
  String get splashSubtitle;

  /// No description provided for @chooseLanguage.
  ///
  /// In mk, this message translates to:
  /// **'Изберете јазик'**
  String get chooseLanguage;

  /// No description provided for @continueButton.
  ///
  /// In mk, this message translates to:
  /// **'Продолжи'**
  String get continueButton;

  /// No description provided for @emailLabel.
  ///
  /// In mk, this message translates to:
  /// **'Е-пошта'**
  String get emailLabel;

  /// No description provided for @emailPlaceholder.
  ///
  /// In mk, this message translates to:
  /// **'tvojotmejl@example.com'**
  String get emailPlaceholder;

  /// No description provided for @passwordLabel.
  ///
  /// In mk, this message translates to:
  /// **'Лозинка'**
  String get passwordLabel;

  /// No description provided for @backToLoginAction.
  ///
  /// In mk, this message translates to:
  /// **'Најавете се'**
  String get backToLoginAction;

  /// No description provided for @loginTitle.
  ///
  /// In mk, this message translates to:
  /// **'Најава'**
  String get loginTitle;

  /// No description provided for @loginWelcomeBack.
  ///
  /// In mk, this message translates to:
  /// **'Добредојдовте назад!'**
  String get loginWelcomeBack;

  /// No description provided for @loginWelcomeBackSubtitle.
  ///
  /// In mk, this message translates to:
  /// **'Најавете се на вашата сметка'**
  String get loginWelcomeBackSubtitle;

  /// No description provided for @loginForgotPassword.
  ///
  /// In mk, this message translates to:
  /// **'Заборавена лозинка?'**
  String get loginForgotPassword;

  /// No description provided for @loginSubmitButton.
  ///
  /// In mk, this message translates to:
  /// **'НАЈАВИ СЕ'**
  String get loginSubmitButton;

  /// No description provided for @loginGoogleButton.
  ///
  /// In mk, this message translates to:
  /// **'ПРОДОЛЖИ СО GOOGLE'**
  String get loginGoogleButton;

  /// No description provided for @loginFooterPrompt.
  ///
  /// In mk, this message translates to:
  /// **'Немате сметка? '**
  String get loginFooterPrompt;

  /// No description provided for @loginFooterAction.
  ///
  /// In mk, this message translates to:
  /// **'Регистрирајте се'**
  String get loginFooterAction;

  /// No description provided for @loginErrorEmptyFields.
  ///
  /// In mk, this message translates to:
  /// **'Внесете е-пошта и лозинка.'**
  String get loginErrorEmptyFields;

  /// No description provided for @loginErrorInvalidCredentials.
  ///
  /// In mk, this message translates to:
  /// **'Погрешна е-пошта или лозинка.'**
  String get loginErrorInvalidCredentials;

  /// No description provided for @loginErrorTwoFactorUnsupported.
  ///
  /// In mk, this message translates to:
  /// **'Оваа сметка има вклучена двофакторска автентикација, која сè уште не е поддржана во апликацијата.'**
  String get loginErrorTwoFactorUnsupported;

  /// No description provided for @registerErrorFullName.
  ///
  /// In mk, this message translates to:
  /// **'Внесете име и презиме.'**
  String get registerErrorFullName;

  /// No description provided for @registerErrorEmail.
  ///
  /// In mk, this message translates to:
  /// **'Внесете валидна е-пошта.'**
  String get registerErrorEmail;

  /// No description provided for @registerErrorPhone.
  ///
  /// In mk, this message translates to:
  /// **'Внесете телефонски број во меѓународен формат, на пр. +389 70 123 456.'**
  String get registerErrorPhone;

  /// No description provided for @registerErrorPasswordRules.
  ///
  /// In mk, this message translates to:
  /// **'Лозинката мора да има најмалку 8 знаци, голема буква, бројка и специјален знак.'**
  String get registerErrorPasswordRules;

  /// No description provided for @registerErrorPasswordMismatch.
  ///
  /// In mk, this message translates to:
  /// **'Лозинките не се совпаѓаат.'**
  String get registerErrorPasswordMismatch;

  /// No description provided for @emailVerificationResent.
  ///
  /// In mk, this message translates to:
  /// **'Испративме нова порака за потврда.'**
  String get emailVerificationResent;

  /// No description provided for @apiErrorEmailRequired.
  ///
  /// In mk, this message translates to:
  /// **'Е-поштата е задолжителна.'**
  String get apiErrorEmailRequired;

  /// No description provided for @apiErrorFirstNameRequired.
  ///
  /// In mk, this message translates to:
  /// **'Името е задолжително.'**
  String get apiErrorFirstNameRequired;

  /// No description provided for @apiErrorLastNameRequired.
  ///
  /// In mk, this message translates to:
  /// **'Презимето е задолжително.'**
  String get apiErrorLastNameRequired;

  /// No description provided for @apiErrorPhoneRequired.
  ///
  /// In mk, this message translates to:
  /// **'Телефонскиот број е задолжителен.'**
  String get apiErrorPhoneRequired;

  /// No description provided for @apiErrorPasswordRequired.
  ///
  /// In mk, this message translates to:
  /// **'Лозинката е задолжителна.'**
  String get apiErrorPasswordRequired;

  /// No description provided for @apiErrorCodeRequired.
  ///
  /// In mk, this message translates to:
  /// **'Кодот за потврда е задолжителен.'**
  String get apiErrorCodeRequired;

  /// No description provided for @apiErrorTermsRequired.
  ///
  /// In mk, this message translates to:
  /// **'Мора да ги прифатите условите за користење.'**
  String get apiErrorTermsRequired;

  /// No description provided for @apiErrorPrivacyRequired.
  ///
  /// In mk, this message translates to:
  /// **'Мора да ја прифатите политиката за приватност.'**
  String get apiErrorPrivacyRequired;

  /// No description provided for @apiErrorPasswordTooShort.
  ///
  /// In mk, this message translates to:
  /// **'Лозинката мора да има најмалку 8 знаци.'**
  String get apiErrorPasswordTooShort;

  /// No description provided for @apiErrorPasswordNeedsUppercase.
  ///
  /// In mk, this message translates to:
  /// **'Лозинката мора да содржи голема буква.'**
  String get apiErrorPasswordNeedsUppercase;

  /// No description provided for @apiErrorPasswordNeedsLowercase.
  ///
  /// In mk, this message translates to:
  /// **'Лозинката мора да содржи мала буква.'**
  String get apiErrorPasswordNeedsLowercase;

  /// No description provided for @apiErrorPasswordNeedsDigit.
  ///
  /// In mk, this message translates to:
  /// **'Лозинката мора да содржи бројка.'**
  String get apiErrorPasswordNeedsDigit;

  /// No description provided for @apiErrorPasswordNeedsSpecial.
  ///
  /// In mk, this message translates to:
  /// **'Лозинката мора да содржи специјален знак.'**
  String get apiErrorPasswordNeedsSpecial;

  /// No description provided for @apiErrorVerificationCodeInvalid.
  ///
  /// In mk, this message translates to:
  /// **'Кодот за потврда не е точен. Проверете ја е-поштата и обидете се повторно.'**
  String get apiErrorVerificationCodeInvalid;

  /// No description provided for @apiErrorInvalidInput.
  ///
  /// In mk, this message translates to:
  /// **'Некои од внесените податоци не се точни. Проверете ги и обидете се повторно.'**
  String get apiErrorInvalidInput;

  /// No description provided for @apiErrorNetwork.
  ///
  /// In mk, this message translates to:
  /// **'Нема интернет конекција. Проверете ја врската и обидете се повторно.'**
  String get apiErrorNetwork;

  /// No description provided for @apiErrorTimeout.
  ///
  /// In mk, this message translates to:
  /// **'Серверот не одговара. Обидете се повторно.'**
  String get apiErrorTimeout;

  /// No description provided for @apiErrorUnauthorized.
  ///
  /// In mk, this message translates to:
  /// **'Сесијата истече. Најавете се повторно.'**
  String get apiErrorUnauthorized;

  /// No description provided for @apiErrorServer.
  ///
  /// In mk, this message translates to:
  /// **'Настана грешка на серверот. Обидете се подоцна.'**
  String get apiErrorServer;

  /// No description provided for @apiErrorUnknown.
  ///
  /// In mk, this message translates to:
  /// **'Настана неочекувана грешка. Обидете се повторно.'**
  String get apiErrorUnknown;

  /// No description provided for @forgotPasswordTitle.
  ///
  /// In mk, this message translates to:
  /// **'Заборавена лозинка'**
  String get forgotPasswordTitle;

  /// No description provided for @forgotPasswordHeading.
  ///
  /// In mk, this message translates to:
  /// **'Ресетирајте ја лозинката'**
  String get forgotPasswordHeading;

  /// No description provided for @forgotPasswordSubheading.
  ///
  /// In mk, this message translates to:
  /// **'Внесете ја вашата е-пошта и ќе ви испратиме код за ресетирање на лозинката.'**
  String get forgotPasswordSubheading;

  /// No description provided for @forgotPasswordSubmitButton.
  ///
  /// In mk, this message translates to:
  /// **'ИСПРАТИ КОД'**
  String get forgotPasswordSubmitButton;

  /// No description provided for @forgotPasswordFooterPrompt.
  ///
  /// In mk, this message translates to:
  /// **'Се сетивте на лозинката? '**
  String get forgotPasswordFooterPrompt;

  /// No description provided for @resetPasswordTitle.
  ///
  /// In mk, this message translates to:
  /// **'Нова лозинка'**
  String get resetPasswordTitle;

  /// No description provided for @resetPasswordHeading.
  ///
  /// In mk, this message translates to:
  /// **'Внесете нова лозинка'**
  String get resetPasswordHeading;

  /// No description provided for @resetPasswordSubheading.
  ///
  /// In mk, this message translates to:
  /// **'Внесете го кодот што ви го испративме по е-пошта и изберете нова лозинка.'**
  String get resetPasswordSubheading;

  /// No description provided for @resetPasswordCodeLabel.
  ///
  /// In mk, this message translates to:
  /// **'Код за ресетирање'**
  String get resetPasswordCodeLabel;

  /// No description provided for @resetPasswordCodePlaceholder.
  ///
  /// In mk, this message translates to:
  /// **'Внесете го кодот од е-поштата'**
  String get resetPasswordCodePlaceholder;

  /// No description provided for @resetPasswordNewPasswordLabel.
  ///
  /// In mk, this message translates to:
  /// **'Нова лозинка'**
  String get resetPasswordNewPasswordLabel;

  /// No description provided for @resetPasswordSubmitButton.
  ///
  /// In mk, this message translates to:
  /// **'РЕСЕТИРАЈ ЛОЗИНКА'**
  String get resetPasswordSubmitButton;

  /// No description provided for @resetPasswordSuccess.
  ///
  /// In mk, this message translates to:
  /// **'Лозинката е успешно променета. Најавете се.'**
  String get resetPasswordSuccess;

  /// No description provided for @registerBusinessNameLabel.
  ///
  /// In mk, this message translates to:
  /// **'Име на бизнисот'**
  String get registerBusinessNameLabel;

  /// No description provided for @registerBusinessNamePlaceholder.
  ///
  /// In mk, this message translates to:
  /// **'Агро Еко Фарма ДООЕЛ'**
  String get registerBusinessNamePlaceholder;

  /// No description provided for @registerErrorBusinessName.
  ///
  /// In mk, this message translates to:
  /// **'Внесете го името на бизнисот.'**
  String get registerErrorBusinessName;

  /// No description provided for @apiErrorBusinessNameRequired.
  ///
  /// In mk, this message translates to:
  /// **'Името на бизнисот е задолжително.'**
  String get apiErrorBusinessNameRequired;

  /// No description provided for @apiErrorEmailNotVerified.
  ///
  /// In mk, this message translates to:
  /// **'Е-поштата сè уште не е потврдена. Внесете го кодот што ви го испративме.'**
  String get apiErrorEmailNotVerified;

  /// No description provided for @registerTitle.
  ///
  /// In mk, this message translates to:
  /// **'Регистрација'**
  String get registerTitle;

  /// No description provided for @registerRoleLabel.
  ///
  /// In mk, this message translates to:
  /// **'Изберете тип на профил'**
  String get registerRoleLabel;

  /// No description provided for @registerRoleGuest.
  ///
  /// In mk, this message translates to:
  /// **'Гостин'**
  String get registerRoleGuest;

  /// No description provided for @registerRoleProvider.
  ///
  /// In mk, this message translates to:
  /// **'Понудувач'**
  String get registerRoleProvider;

  /// No description provided for @registerNameLabel.
  ///
  /// In mk, this message translates to:
  /// **'Име и презиме'**
  String get registerNameLabel;

  /// No description provided for @registerNamePlaceholder.
  ///
  /// In mk, this message translates to:
  /// **'Јован Јовановски'**
  String get registerNamePlaceholder;

  /// No description provided for @registerPhoneLabel.
  ///
  /// In mk, this message translates to:
  /// **'Телефон'**
  String get registerPhoneLabel;

  /// No description provided for @registerConfirmPasswordLabel.
  ///
  /// In mk, this message translates to:
  /// **'Потврди лозинка'**
  String get registerConfirmPasswordLabel;

  /// No description provided for @registerTermsPrefix.
  ///
  /// In mk, this message translates to:
  /// **'Се согласувам со '**
  String get registerTermsPrefix;

  /// No description provided for @registerTermsOfService.
  ///
  /// In mk, this message translates to:
  /// **'Условите за користење'**
  String get registerTermsOfService;

  /// No description provided for @registerPrivacyPolicy.
  ///
  /// In mk, this message translates to:
  /// **'Политиката за приватност'**
  String get registerPrivacyPolicy;

  /// No description provided for @registerTermsSuffix.
  ///
  /// In mk, this message translates to:
  /// **' и Одговорностите на корисникот.'**
  String get registerTermsSuffix;

  /// No description provided for @registerSubmitButton.
  ///
  /// In mk, this message translates to:
  /// **'РЕГИСТРИРАЈ СЕ'**
  String get registerSubmitButton;

  /// No description provided for @registerFooterPrompt.
  ///
  /// In mk, this message translates to:
  /// **'Веќе имате сметка? '**
  String get registerFooterPrompt;

  /// No description provided for @termsPrivacyTitle.
  ///
  /// In mk, this message translates to:
  /// **'Услови и правила'**
  String get termsPrivacyTitle;

  /// No description provided for @termsPrivacySubtitle.
  ///
  /// In mk, this message translates to:
  /// **'Ве молиме прочитајте пред да продолжите'**
  String get termsPrivacySubtitle;

  /// No description provided for @termsPrivacyTermsHeading.
  ///
  /// In mk, this message translates to:
  /// **'1. Услови за користење'**
  String get termsPrivacyTermsHeading;

  /// No description provided for @termsPrivacyTermsBody.
  ///
  /// In mk, this message translates to:
  /// **'Со користење на платформата се согласувате дека понудите се објавуваат од страна на понудувачите и дека платформата делува како посредник меѓу понудувачот и гостинот. Резервациите подлежат на политиките за откажување дефинирани за секоја понуда. Платформата задржува право да модерира, одобрува или отстранува содржина што не е во согласност со правилата на заедницата.\n\nКорисниците се обврзуваат да внесуваат точни и ажурирани податоци при регистрација и користење на услугите.'**
  String get termsPrivacyTermsBody;

  /// No description provided for @termsPrivacyPolicyHeading.
  ///
  /// In mk, this message translates to:
  /// **'2. Политика на приватност'**
  String get termsPrivacyPolicyHeading;

  /// No description provided for @termsPrivacyPolicyBody.
  ///
  /// In mk, this message translates to:
  /// **'Личните податоци се обработуваат согласно важечките прописи за заштита на лични податоци и се користат исклучиво за целите на резервација, комуникација и подобрување на услугата.'**
  String get termsPrivacyPolicyBody;

  /// No description provided for @termsPrivacyConsentTerms.
  ///
  /// In mk, this message translates to:
  /// **'Ги прочитав и се согласувам со Условите за користење.'**
  String get termsPrivacyConsentTerms;

  /// No description provided for @termsPrivacyConsentPrivacy.
  ///
  /// In mk, this message translates to:
  /// **'Ја прочитав и се согласувам со Политиката за приватност.'**
  String get termsPrivacyConsentPrivacy;

  /// No description provided for @termsPrivacyConsentResponsibilities.
  ///
  /// In mk, this message translates to:
  /// **'Ги прифаќам одговорностите на корисникот при резервација и плаќање.'**
  String get termsPrivacyConsentResponsibilities;

  /// No description provided for @termsPrivacySubmitButton.
  ///
  /// In mk, this message translates to:
  /// **'ПРИФАТИ И ПРОДОЛЖИ'**
  String get termsPrivacySubmitButton;

  /// No description provided for @emailVerificationTitle.
  ///
  /// In mk, this message translates to:
  /// **'Потврдете ја вашата е-пошта'**
  String get emailVerificationTitle;

  /// No description provided for @emailVerificationSentTo.
  ///
  /// In mk, this message translates to:
  /// **'Испративме код за потврда до'**
  String get emailVerificationSentTo;

  /// No description provided for @emailVerificationInstructions.
  ///
  /// In mk, this message translates to:
  /// **'Внесете го кодот од е-поштата за да го активирате вашиот профил и да продолжите со користење на апликацијата.'**
  String get emailVerificationInstructions;

  /// No description provided for @emailVerificationCodeLabel.
  ///
  /// In mk, this message translates to:
  /// **'Код за потврда'**
  String get emailVerificationCodeLabel;

  /// No description provided for @emailVerificationCodePlaceholder.
  ///
  /// In mk, this message translates to:
  /// **'Внесете го кодот'**
  String get emailVerificationCodePlaceholder;

  /// No description provided for @emailVerificationSubmitButton.
  ///
  /// In mk, this message translates to:
  /// **'ПОТВРДИ'**
  String get emailVerificationSubmitButton;

  /// No description provided for @emailVerificationErrorEmptyCode.
  ///
  /// In mk, this message translates to:
  /// **'Внесете го кодот од е-поштата.'**
  String get emailVerificationErrorEmptyCode;

  /// No description provided for @emailVerificationSuccess.
  ///
  /// In mk, this message translates to:
  /// **'Е-поштата е потврдена. Најавете се за да продолжите.'**
  String get emailVerificationSuccess;

  /// No description provided for @emailVerificationBadge.
  ///
  /// In mk, this message translates to:
  /// **'НЕ Е ПОТВРДЕНО'**
  String get emailVerificationBadge;

  /// No description provided for @emailVerificationResendButton.
  ///
  /// In mk, this message translates to:
  /// **'ИСПРАТИ ПОВТОРНО'**
  String get emailVerificationResendButton;

  /// No description provided for @emailVerificationChangeEmail.
  ///
  /// In mk, this message translates to:
  /// **'Промени е-пошта'**
  String get emailVerificationChangeEmail;

  /// No description provided for @profileTitle.
  ///
  /// In mk, this message translates to:
  /// **'Мојот профил'**
  String get profileTitle;

  /// No description provided for @profilePersonalDataHeading.
  ///
  /// In mk, this message translates to:
  /// **'Лични податоци'**
  String get profilePersonalDataHeading;

  /// No description provided for @profilePhoneLabel.
  ///
  /// In mk, this message translates to:
  /// **'Телефонски број'**
  String get profilePhoneLabel;

  /// No description provided for @profileCityLabel.
  ///
  /// In mk, this message translates to:
  /// **'Град / Локација'**
  String get profileCityLabel;

  /// No description provided for @profileCityPlaceholder.
  ///
  /// In mk, this message translates to:
  /// **'Охрид, Северна Македонија'**
  String get profileCityPlaceholder;

  /// No description provided for @profileReservationsLabel.
  ///
  /// In mk, this message translates to:
  /// **'Резервации'**
  String get profileReservationsLabel;

  /// No description provided for @profileFavoritePlacesLabel.
  ///
  /// In mk, this message translates to:
  /// **'Омилени места'**
  String get profileFavoritePlacesLabel;

  /// No description provided for @profileSaveButton.
  ///
  /// In mk, this message translates to:
  /// **'Зачувај промени'**
  String get profileSaveButton;

  /// No description provided for @providerSubjectTypeLabel.
  ///
  /// In mk, this message translates to:
  /// **'Тип на субјект'**
  String get providerSubjectTypeLabel;

  /// No description provided for @providerSubjectTypeIndividual.
  ///
  /// In mk, this message translates to:
  /// **'Физичко лице'**
  String get providerSubjectTypeIndividual;

  /// No description provided for @providerSubjectTypeLegal.
  ///
  /// In mk, this message translates to:
  /// **'Правно лице'**
  String get providerSubjectTypeLegal;

  /// No description provided for @providerLegalEntityComingSoon.
  ///
  /// In mk, this message translates to:
  /// **'Полињата за правни лица ќе бидат достапни наскоро.'**
  String get providerLegalEntityComingSoon;

  /// No description provided for @providerOfferInfoHeading.
  ///
  /// In mk, this message translates to:
  /// **'Информации за понудата'**
  String get providerOfferInfoHeading;

  /// No description provided for @providerOfferNameLabel.
  ///
  /// In mk, this message translates to:
  /// **'Име на понуда / искуство'**
  String get providerOfferNameLabel;

  /// No description provided for @providerOfferNamePlaceholder.
  ///
  /// In mk, this message translates to:
  /// **'Гостинска соба со појадок'**
  String get providerOfferNamePlaceholder;

  /// No description provided for @providerCategoryHeading.
  ///
  /// In mk, this message translates to:
  /// **'Категорија на понуда'**
  String get providerCategoryHeading;

  /// No description provided for @providerCategoryAccommodation.
  ///
  /// In mk, this message translates to:
  /// **'Сместување'**
  String get providerCategoryAccommodation;

  /// No description provided for @providerCategoryGastronomy.
  ///
  /// In mk, this message translates to:
  /// **'Гастрономија'**
  String get providerCategoryGastronomy;

  /// No description provided for @providerCategoryFarmParticipation.
  ///
  /// In mk, this message translates to:
  /// **'Активно учество на фарма'**
  String get providerCategoryFarmParticipation;

  /// No description provided for @providerCategoryDirectSales.
  ///
  /// In mk, this message translates to:
  /// **'Директна продажба'**
  String get providerCategoryDirectSales;

  /// No description provided for @providerCategoryFarmEducation.
  ///
  /// In mk, this message translates to:
  /// **'Едукација на фарма'**
  String get providerCategoryFarmEducation;

  /// No description provided for @providerCategoryFarmRecreation.
  ///
  /// In mk, this message translates to:
  /// **'Рекреација и релаксација на фарма'**
  String get providerCategoryFarmRecreation;

  /// No description provided for @providerCategoryOffFarmTours.
  ///
  /// In mk, this message translates to:
  /// **'Тури и активности надвор од фарма'**
  String get providerCategoryOffFarmTours;

  /// No description provided for @providerLocationLabel.
  ///
  /// In mk, this message translates to:
  /// **'Локација'**
  String get providerLocationLabel;

  /// No description provided for @providerLocationPlaceholder.
  ///
  /// In mk, this message translates to:
  /// **'Крушево'**
  String get providerLocationPlaceholder;

  /// No description provided for @providerActiveOffersLabel.
  ///
  /// In mk, this message translates to:
  /// **'Активни понуди'**
  String get providerActiveOffersLabel;

  /// No description provided for @providerAverageRatingLabel.
  ///
  /// In mk, this message translates to:
  /// **'Просечна оценка'**
  String get providerAverageRatingLabel;

  /// No description provided for @providerNotVerifiedBadge.
  ///
  /// In mk, this message translates to:
  /// **'НЕ Е ВЕРИФИКУВАН'**
  String get providerNotVerifiedBadge;

  /// No description provided for @providerVerifiedBadge.
  ///
  /// In mk, this message translates to:
  /// **'ВЕРИФИКУВАН'**
  String get providerVerifiedBadge;

  /// No description provided for @providerExampleName.
  ///
  /// In mk, this message translates to:
  /// **'Ана Трајковска'**
  String get providerExampleName;

  /// No description provided for @providerSetupTitle.
  ///
  /// In mk, this message translates to:
  /// **'Поставување профил'**
  String get providerSetupTitle;

  /// No description provided for @providerSetupSubtitle.
  ///
  /// In mk, this message translates to:
  /// **'Внесете ги основните податоци за вашиот профил'**
  String get providerSetupSubtitle;

  /// No description provided for @providerAddLogoLabel.
  ///
  /// In mk, this message translates to:
  /// **'Додади лого'**
  String get providerAddLogoLabel;

  /// No description provided for @providerLegalCompanyNameLabel.
  ///
  /// In mk, this message translates to:
  /// **'Име на компанија / носител на дејност'**
  String get providerLegalCompanyNameLabel;

  /// No description provided for @providerLegalResponsiblePersonLabel.
  ///
  /// In mk, this message translates to:
  /// **'Одговорно лице'**
  String get providerLegalResponsiblePersonLabel;

  /// No description provided for @providerLegalResponsiblePersonPlaceholder.
  ///
  /// In mk, this message translates to:
  /// **'Владимир Здравковски'**
  String get providerLegalResponsiblePersonPlaceholder;

  /// No description provided for @providerLegalEmailPlaceholder.
  ///
  /// In mk, this message translates to:
  /// **'На пример: контакт@company.mk'**
  String get providerLegalEmailPlaceholder;

  /// No description provided for @providerLegalBusinessDetailsHeading.
  ///
  /// In mk, this message translates to:
  /// **'Деловни податоци'**
  String get providerLegalBusinessDetailsHeading;

  /// No description provided for @providerLegalTaxIdLabel.
  ///
  /// In mk, this message translates to:
  /// **'ЕДБ / Даночен број'**
  String get providerLegalTaxIdLabel;

  /// No description provided for @providerLegalCategoryHeading.
  ///
  /// In mk, this message translates to:
  /// **'Категорија на дејност'**
  String get providerLegalCategoryHeading;

  /// No description provided for @providerLegalAddressLabel.
  ///
  /// In mk, this message translates to:
  /// **'Адреса на бизнисот'**
  String get providerLegalAddressLabel;

  /// No description provided for @providerLegalAddressPlaceholder.
  ///
  /// In mk, this message translates to:
  /// **'Брајчино, Преспа'**
  String get providerLegalAddressPlaceholder;

  /// No description provided for @providerAdditionalContactsHeading.
  ///
  /// In mk, this message translates to:
  /// **'Дополнителни контакти'**
  String get providerAdditionalContactsHeading;

  /// No description provided for @providerAdditionalContactLabel.
  ///
  /// In mk, this message translates to:
  /// **'Контакт (телефон или е-пошта)'**
  String get providerAdditionalContactLabel;

  /// No description provided for @providerAdditionalContactPlaceholder.
  ///
  /// In mk, this message translates to:
  /// **'Внесете телефон или е-пошта'**
  String get providerAdditionalContactPlaceholder;

  /// No description provided for @providerAddContactButton.
  ///
  /// In mk, this message translates to:
  /// **'+ Додади контакт'**
  String get providerAddContactButton;

  /// No description provided for @providerSaveAndContinueButton.
  ///
  /// In mk, this message translates to:
  /// **'Зачувај и продолжи'**
  String get providerSaveAndContinueButton;

  /// No description provided for @imageSourceGallery.
  ///
  /// In mk, this message translates to:
  /// **'Галерија'**
  String get imageSourceGallery;

  /// No description provided for @imageSourceCamera.
  ///
  /// In mk, this message translates to:
  /// **'Камера'**
  String get imageSourceCamera;

  /// No description provided for @navTouristHome.
  ///
  /// In mk, this message translates to:
  /// **'Дома'**
  String get navTouristHome;

  /// No description provided for @navTouristSearch.
  ///
  /// In mk, this message translates to:
  /// **'Пребарај'**
  String get navTouristSearch;

  /// No description provided for @navTouristBookings.
  ///
  /// In mk, this message translates to:
  /// **'Резервации'**
  String get navTouristBookings;

  /// No description provided for @navProviderDashboard.
  ///
  /// In mk, this message translates to:
  /// **'Табла'**
  String get navProviderDashboard;

  /// No description provided for @navProviderOffers.
  ///
  /// In mk, this message translates to:
  /// **'Понуди'**
  String get navProviderOffers;

  /// No description provided for @navProviderCalendar.
  ///
  /// In mk, this message translates to:
  /// **'Календар'**
  String get navProviderCalendar;

  /// No description provided for @navMessages.
  ///
  /// In mk, this message translates to:
  /// **'Пораки'**
  String get navMessages;

  /// No description provided for @navProfile.
  ///
  /// In mk, this message translates to:
  /// **'Профил'**
  String get navProfile;

  /// No description provided for @settingsTitle.
  ///
  /// In mk, this message translates to:
  /// **'Поставки'**
  String get settingsTitle;

  /// No description provided for @settingsLanguageHeading.
  ///
  /// In mk, this message translates to:
  /// **'Јазик на апликацијата'**
  String get settingsLanguageHeading;

  /// No description provided for @settingsLanguageRowLabel.
  ///
  /// In mk, this message translates to:
  /// **'Изберете јазик'**
  String get settingsLanguageRowLabel;

  /// No description provided for @settingsNotificationsLabel.
  ///
  /// In mk, this message translates to:
  /// **'Известувања'**
  String get settingsNotificationsLabel;

  /// No description provided for @settingsPrivacyHeading.
  ///
  /// In mk, this message translates to:
  /// **'Приватност и податоци'**
  String get settingsPrivacyHeading;

  /// No description provided for @settingsPrivacyDescription.
  ///
  /// In mk, this message translates to:
  /// **'Во согласност со GDPR можете да ги преземете или избришете вашите лични податоци.'**
  String get settingsPrivacyDescription;

  /// No description provided for @settingsDownloadDataButton.
  ///
  /// In mk, this message translates to:
  /// **'Преземи ги моите податоци'**
  String get settingsDownloadDataButton;

  /// No description provided for @settingsDeleteAccountButton.
  ///
  /// In mk, this message translates to:
  /// **'Побарај бришење на сметката'**
  String get settingsDeleteAccountButton;

  /// No description provided for @settingsLogoutButton.
  ///
  /// In mk, this message translates to:
  /// **'Одјава'**
  String get settingsLogoutButton;

  /// No description provided for @notificationsTitle.
  ///
  /// In mk, this message translates to:
  /// **'Известувања'**
  String get notificationsTitle;

  /// No description provided for @notificationsUnreadSuffix.
  ///
  /// In mk, this message translates to:
  /// **'непрочитани известувања'**
  String get notificationsUnreadSuffix;

  /// No description provided for @timeJustNow.
  ///
  /// In mk, this message translates to:
  /// **'сега'**
  String get timeJustNow;

  /// No description provided for @timeMinutesSuffix.
  ///
  /// In mk, this message translates to:
  /// **'мин'**
  String get timeMinutesSuffix;

  /// No description provided for @timeHoursSuffix.
  ///
  /// In mk, this message translates to:
  /// **'ч'**
  String get timeHoursSuffix;

  /// No description provided for @timeDaysSuffix.
  ///
  /// In mk, this message translates to:
  /// **'ден'**
  String get timeDaysSuffix;

  /// No description provided for @chatToday.
  ///
  /// In mk, this message translates to:
  /// **'Денес'**
  String get chatToday;

  /// No description provided for @chatInputPlaceholder.
  ///
  /// In mk, this message translates to:
  /// **'Напишете порака...'**
  String get chatInputPlaceholder;

  /// No description provided for @myTicketsTitle.
  ///
  /// In mk, this message translates to:
  /// **'Мои тикети'**
  String get myTicketsTitle;

  /// No description provided for @createTicketButton.
  ///
  /// In mk, this message translates to:
  /// **'Креирај нов тикет'**
  String get createTicketButton;

  /// No description provided for @ticketStatusOpen.
  ///
  /// In mk, this message translates to:
  /// **'ОТВОРЕН'**
  String get ticketStatusOpen;

  /// No description provided for @ticketStatusInProgress.
  ///
  /// In mk, this message translates to:
  /// **'ВО ТЕК'**
  String get ticketStatusInProgress;

  /// No description provided for @ticketStatusResolved.
  ///
  /// In mk, this message translates to:
  /// **'РЕШЕН'**
  String get ticketStatusResolved;

  /// No description provided for @ticketLastChangedLabel.
  ///
  /// In mk, this message translates to:
  /// **'Последна промена'**
  String get ticketLastChangedLabel;

  /// No description provided for @newTicketTitle.
  ///
  /// In mk, this message translates to:
  /// **'Нов тикет за поддршка'**
  String get newTicketTitle;

  /// No description provided for @newTicketSubtitle.
  ///
  /// In mk, this message translates to:
  /// **'Опишете го проблемот и ќе ви одговориме наскоро'**
  String get newTicketSubtitle;

  /// No description provided for @newTicketCategoryLabel.
  ///
  /// In mk, this message translates to:
  /// **'Категорија'**
  String get newTicketCategoryLabel;

  /// No description provided for @newTicketTitleLabel.
  ///
  /// In mk, this message translates to:
  /// **'Наслов'**
  String get newTicketTitleLabel;

  /// No description provided for @newTicketTitlePlaceholder.
  ///
  /// In mk, this message translates to:
  /// **'На пр. Проблем со плаќање'**
  String get newTicketTitlePlaceholder;

  /// No description provided for @newTicketDescriptionLabel.
  ///
  /// In mk, this message translates to:
  /// **'Опис на проблемот'**
  String get newTicketDescriptionLabel;

  /// No description provided for @newTicketDescriptionPlaceholder.
  ///
  /// In mk, this message translates to:
  /// **'Опишете детално што се случи, кога и на кој оглас или резервација се однесува...'**
  String get newTicketDescriptionPlaceholder;

  /// No description provided for @newTicketAttachmentLabel.
  ///
  /// In mk, this message translates to:
  /// **'Прикачи слика или документ'**
  String get newTicketAttachmentLabel;

  /// No description provided for @newTicketAttachmentOptional.
  ///
  /// In mk, this message translates to:
  /// **'(опционално)'**
  String get newTicketAttachmentOptional;

  /// No description provided for @newTicketSubmitButton.
  ///
  /// In mk, this message translates to:
  /// **'Испрати барање'**
  String get newTicketSubmitButton;

  /// No description provided for @newTicketCategoryReservations.
  ///
  /// In mk, this message translates to:
  /// **'Резервации'**
  String get newTicketCategoryReservations;

  /// No description provided for @newTicketCategoryListings.
  ///
  /// In mk, this message translates to:
  /// **'Огласи'**
  String get newTicketCategoryListings;

  /// No description provided for @newTicketCategoryPayments.
  ///
  /// In mk, this message translates to:
  /// **'Плаќање'**
  String get newTicketCategoryPayments;

  /// No description provided for @newTicketCategoryProfile.
  ///
  /// In mk, this message translates to:
  /// **'Профил'**
  String get newTicketCategoryProfile;

  /// No description provided for @newTicketCategoryOther.
  ///
  /// In mk, this message translates to:
  /// **'Друго'**
  String get newTicketCategoryOther;

  /// No description provided for @attachmentSourceDocument.
  ///
  /// In mk, this message translates to:
  /// **'Документ'**
  String get attachmentSourceDocument;

  /// No description provided for @dashboardTitle.
  ///
  /// In mk, this message translates to:
  /// **'Контролна табла'**
  String get dashboardTitle;

  /// No description provided for @dashboardGreetingPrefix.
  ///
  /// In mk, this message translates to:
  /// **'Добредојдовте, '**
  String get dashboardGreetingPrefix;

  /// No description provided for @dashboardAddListingButton.
  ///
  /// In mk, this message translates to:
  /// **'+ Додади нова понуда'**
  String get dashboardAddListingButton;

  /// No description provided for @dashboardListingsSummaryHeading.
  ///
  /// In mk, this message translates to:
  /// **'Преглед на понуди'**
  String get dashboardListingsSummaryHeading;

  /// No description provided for @dashboardActiveListingsLabel.
  ///
  /// In mk, this message translates to:
  /// **'Активни понуди'**
  String get dashboardActiveListingsLabel;

  /// No description provided for @dashboardPendingReviewListingsLabel.
  ///
  /// In mk, this message translates to:
  /// **'На преглед'**
  String get dashboardPendingReviewListingsLabel;

  /// No description provided for @dashboardMonthlyReservationsLabel.
  ///
  /// In mk, this message translates to:
  /// **'Резервации овој месец'**
  String get dashboardMonthlyReservationsLabel;

  /// No description provided for @dashboardPendingReservationsHeading.
  ///
  /// In mk, this message translates to:
  /// **'Резервации кои чекаат'**
  String get dashboardPendingReservationsHeading;

  /// No description provided for @dashboardCompletedReservationsHeading.
  ///
  /// In mk, this message translates to:
  /// **'Завршени резервации'**
  String get dashboardCompletedReservationsHeading;

  /// No description provided for @reservationStatusPending.
  ///
  /// In mk, this message translates to:
  /// **'НА ЧЕКАЊЕ'**
  String get reservationStatusPending;

  /// No description provided for @reservationStatusAccepted.
  ///
  /// In mk, this message translates to:
  /// **'ПРИФАТЕНА'**
  String get reservationStatusAccepted;

  /// No description provided for @reservationStatusAcceptedTourist.
  ///
  /// In mk, this message translates to:
  /// **'ПОТВРДЕНА'**
  String get reservationStatusAcceptedTourist;

  /// No description provided for @reservationStatusRejected.
  ///
  /// In mk, this message translates to:
  /// **'ОДБИЕНА'**
  String get reservationStatusRejected;

  /// No description provided for @reservationStatusCompleted.
  ///
  /// In mk, this message translates to:
  /// **'ЗАВРШЕНА'**
  String get reservationStatusCompleted;

  /// No description provided for @reservationStatusCancelled.
  ///
  /// In mk, this message translates to:
  /// **'ОТКАЖАНА'**
  String get reservationStatusCancelled;

  /// No description provided for @reservationGuestSingular.
  ///
  /// In mk, this message translates to:
  /// **'гостин'**
  String get reservationGuestSingular;

  /// No description provided for @reservationGuestsPlural.
  ///
  /// In mk, this message translates to:
  /// **'гости'**
  String get reservationGuestsPlural;

  /// No description provided for @acceptReservationButton.
  ///
  /// In mk, this message translates to:
  /// **'Прифати'**
  String get acceptReservationButton;

  /// No description provided for @rejectReservationButton.
  ///
  /// In mk, this message translates to:
  /// **'Одбиј'**
  String get rejectReservationButton;

  /// No description provided for @rateGuestButton.
  ///
  /// In mk, this message translates to:
  /// **'Оцени гостин'**
  String get rateGuestButton;

  /// No description provided for @offersTitle.
  ///
  /// In mk, this message translates to:
  /// **'Моите понуди'**
  String get offersTitle;

  /// No description provided for @offersSubtitle.
  ///
  /// In mk, this message translates to:
  /// **'Управувајте со вашите понуди и нивниот статус'**
  String get offersSubtitle;

  /// No description provided for @offersFilterAll.
  ///
  /// In mk, this message translates to:
  /// **'Сите'**
  String get offersFilterAll;

  /// No description provided for @offersFilterActive.
  ///
  /// In mk, this message translates to:
  /// **'Активни'**
  String get offersFilterActive;

  /// No description provided for @offersFilterPendingReview.
  ///
  /// In mk, this message translates to:
  /// **'На преглед'**
  String get offersFilterPendingReview;

  /// No description provided for @offersFilterRejected.
  ///
  /// In mk, this message translates to:
  /// **'Одбиени'**
  String get offersFilterRejected;

  /// No description provided for @listingStatusActive.
  ///
  /// In mk, this message translates to:
  /// **'АКТИВНА'**
  String get listingStatusActive;

  /// No description provided for @listingStatusPendingReview.
  ///
  /// In mk, this message translates to:
  /// **'НА ПРЕГЛЕД'**
  String get listingStatusPendingReview;

  /// No description provided for @listingStatusRejected.
  ///
  /// In mk, this message translates to:
  /// **'ОДБИЕНО'**
  String get listingStatusRejected;

  /// No description provided for @listingStatusArchived.
  ///
  /// In mk, this message translates to:
  /// **'АРХИВИРАНО'**
  String get listingStatusArchived;

  /// No description provided for @listingReservationsThisMonthLabel.
  ///
  /// In mk, this message translates to:
  /// **'резервации овој месец'**
  String get listingReservationsThisMonthLabel;

  /// No description provided for @listingSubmittedForReviewLabel.
  ///
  /// In mk, this message translates to:
  /// **'Испратено на преглед'**
  String get listingSubmittedForReviewLabel;

  /// No description provided for @listingRejectedReasonPrefix.
  ///
  /// In mk, this message translates to:
  /// **'Одбиено: '**
  String get listingRejectedReasonPrefix;

  /// No description provided for @listingArchivedOnLabel.
  ///
  /// In mk, this message translates to:
  /// **'Архивирано на'**
  String get listingArchivedOnLabel;

  /// No description provided for @editListingButton.
  ///
  /// In mk, this message translates to:
  /// **'Уреди'**
  String get editListingButton;

  /// No description provided for @editAndResubmitListingButton.
  ///
  /// In mk, this message translates to:
  /// **'Уреди и поднеси повторно'**
  String get editAndResubmitListingButton;

  /// No description provided for @reactivateListingButton.
  ///
  /// In mk, this message translates to:
  /// **'Активирај повторно'**
  String get reactivateListingButton;

  /// No description provided for @calendarTitle.
  ///
  /// In mk, this message translates to:
  /// **'Календар на достапност'**
  String get calendarTitle;

  /// No description provided for @availabilityStatusAvailable.
  ///
  /// In mk, this message translates to:
  /// **'Слободно'**
  String get availabilityStatusAvailable;

  /// No description provided for @availabilityStatusOccupied.
  ///
  /// In mk, this message translates to:
  /// **'Зафатено'**
  String get availabilityStatusOccupied;

  /// No description provided for @availabilityStatusBlocked.
  ///
  /// In mk, this message translates to:
  /// **'Блокирано'**
  String get availabilityStatusBlocked;

  /// No description provided for @weekdayMon.
  ///
  /// In mk, this message translates to:
  /// **'Пон'**
  String get weekdayMon;

  /// No description provided for @weekdayTue.
  ///
  /// In mk, this message translates to:
  /// **'Вт'**
  String get weekdayTue;

  /// No description provided for @weekdayWed.
  ///
  /// In mk, this message translates to:
  /// **'Ср'**
  String get weekdayWed;

  /// No description provided for @weekdayThu.
  ///
  /// In mk, this message translates to:
  /// **'Чет'**
  String get weekdayThu;

  /// No description provided for @weekdayFri.
  ///
  /// In mk, this message translates to:
  /// **'Пет'**
  String get weekdayFri;

  /// No description provided for @weekdaySat.
  ///
  /// In mk, this message translates to:
  /// **'Саб'**
  String get weekdaySat;

  /// No description provided for @weekdaySun.
  ///
  /// In mk, this message translates to:
  /// **'Нед'**
  String get weekdaySun;

  /// No description provided for @blockSelectedDatesButton.
  ///
  /// In mk, this message translates to:
  /// **'Блокирај избрани датуми'**
  String get blockSelectedDatesButton;

  /// No description provided for @unblockSelectedDatesButton.
  ///
  /// In mk, this message translates to:
  /// **'Отклучи избрани датуми'**
  String get unblockSelectedDatesButton;

  /// No description provided for @wizardHeaderTitle.
  ///
  /// In mk, this message translates to:
  /// **'Нова понуда'**
  String get wizardHeaderTitle;

  /// No description provided for @wizardStepLabel.
  ///
  /// In mk, this message translates to:
  /// **'Чекор'**
  String get wizardStepLabel;

  /// No description provided for @wizardStepOfLabel.
  ///
  /// In mk, this message translates to:
  /// **'од'**
  String get wizardStepOfLabel;

  /// No description provided for @wizardBackButton.
  ///
  /// In mk, this message translates to:
  /// **'Назад'**
  String get wizardBackButton;

  /// No description provided for @wizardNextButton.
  ///
  /// In mk, this message translates to:
  /// **'Понатаму'**
  String get wizardNextButton;

  /// No description provided for @wizardPublishButton.
  ///
  /// In mk, this message translates to:
  /// **'Објави'**
  String get wizardPublishButton;

  /// No description provided for @wizardCategoryFarmRecreation.
  ///
  /// In mk, this message translates to:
  /// **'Рекреација и релаксација'**
  String get wizardCategoryFarmRecreation;

  /// No description provided for @wizardCategoryOffFarmTours.
  ///
  /// In mk, this message translates to:
  /// **'Тури надвор од фарма'**
  String get wizardCategoryOffFarmTours;

  /// No description provided for @wizardStep1Heading.
  ///
  /// In mk, this message translates to:
  /// **'Кажете ни за вашата понуда'**
  String get wizardStep1Heading;

  /// No description provided for @wizardStep1Subtitle.
  ///
  /// In mk, this message translates to:
  /// **'Изберете категорија и дадете наслов на вашата понуда.'**
  String get wizardStep1Subtitle;

  /// No description provided for @wizardCategoryLabel.
  ///
  /// In mk, this message translates to:
  /// **'Категорија'**
  String get wizardCategoryLabel;

  /// No description provided for @wizardTitleLabel.
  ///
  /// In mk, this message translates to:
  /// **'Наслов на понудата'**
  String get wizardTitleLabel;

  /// No description provided for @wizardTitlePlaceholder.
  ///
  /// In mk, this message translates to:
  /// **'На пр. Гостинска соба со појадок'**
  String get wizardTitlePlaceholder;

  /// No description provided for @wizardStep2Heading.
  ///
  /// In mk, this message translates to:
  /// **'Каде се наоѓа вашата понуда?'**
  String get wizardStep2Heading;

  /// No description provided for @wizardStep2Subtitle.
  ///
  /// In mk, this message translates to:
  /// **'Вашата адреса ќе биде споделена со гостите дури откако ќе резервираат.'**
  String get wizardStep2Subtitle;

  /// No description provided for @wizardLocationLabel.
  ///
  /// In mk, this message translates to:
  /// **'Адреса / населено место'**
  String get wizardLocationLabel;

  /// No description provided for @wizardLocationPlaceholder.
  ///
  /// In mk, this message translates to:
  /// **'Брајчино, Преспа'**
  String get wizardLocationPlaceholder;

  /// No description provided for @wizardStep3Heading.
  ///
  /// In mk, this message translates to:
  /// **'Колку гости може да прифатите?'**
  String get wizardStep3Heading;

  /// No description provided for @wizardStep3Subtitle.
  ///
  /// In mk, this message translates to:
  /// **'Ова подоцна може да го промените.'**
  String get wizardStep3Subtitle;

  /// No description provided for @wizardGuestsLabel.
  ///
  /// In mk, this message translates to:
  /// **'Гости'**
  String get wizardGuestsLabel;

  /// No description provided for @wizardRoomsLabel.
  ///
  /// In mk, this message translates to:
  /// **'Соби'**
  String get wizardRoomsLabel;

  /// No description provided for @wizardBedsLabel.
  ///
  /// In mk, this message translates to:
  /// **'Кревети'**
  String get wizardBedsLabel;

  /// No description provided for @wizardStep4Heading.
  ///
  /// In mk, this message translates to:
  /// **'Кажете им на гостите што нудите'**
  String get wizardStep4Heading;

  /// No description provided for @wizardStep4Subtitle.
  ///
  /// In mk, this message translates to:
  /// **'Изберете ги сите нешта кои ги нудите.'**
  String get wizardStep4Subtitle;

  /// No description provided for @wizardStep5Heading.
  ///
  /// In mk, this message translates to:
  /// **'Додадете фотографии'**
  String get wizardStep5Heading;

  /// No description provided for @wizardStep5Subtitle.
  ///
  /// In mk, this message translates to:
  /// **'Најмалку 5 фотографии се потребни за да ја објавите понудата.'**
  String get wizardStep5Subtitle;

  /// No description provided for @wizardStep6Heading.
  ///
  /// In mk, this message translates to:
  /// **'Опишете ја вашата понуда'**
  String get wizardStep6Heading;

  /// No description provided for @wizardStep6Subtitle.
  ///
  /// In mk, this message translates to:
  /// **'Кратко опишете што нудите и одредете цена.'**
  String get wizardStep6Subtitle;

  /// No description provided for @wizardDescriptionLabel.
  ///
  /// In mk, this message translates to:
  /// **'Опис'**
  String get wizardDescriptionLabel;

  /// No description provided for @wizardDescriptionPlaceholder.
  ///
  /// In mk, this message translates to:
  /// **'Пространа традиционална куќа во срцето на Преспа...'**
  String get wizardDescriptionPlaceholder;

  /// No description provided for @wizardPriceLabel.
  ///
  /// In mk, this message translates to:
  /// **'Цена (по ноќ, доколку се работи за сместување)'**
  String get wizardPriceLabel;

  /// No description provided for @wizardPricePlaceholder.
  ///
  /// In mk, this message translates to:
  /// **'2.770 ден.'**
  String get wizardPricePlaceholder;

  /// No description provided for @wizardPriceSuffix.
  ///
  /// In mk, this message translates to:
  /// **'ден.'**
  String get wizardPriceSuffix;

  /// No description provided for @wizardPricePerNightSuffix.
  ///
  /// In mk, this message translates to:
  /// **'ден. / ноќ'**
  String get wizardPricePerNightSuffix;

  /// No description provided for @wizardReviewHeading.
  ///
  /// In mk, this message translates to:
  /// **'Преглед'**
  String get wizardReviewHeading;

  /// No description provided for @wizardReviewSubtitle.
  ///
  /// In mk, this message translates to:
  /// **'Проверете ги деталите пред да ја објавите понудата.'**
  String get wizardReviewSubtitle;

  /// No description provided for @wizardReviewTitleRow.
  ///
  /// In mk, this message translates to:
  /// **'Наслов'**
  String get wizardReviewTitleRow;

  /// No description provided for @wizardReviewCategoryRow.
  ///
  /// In mk, this message translates to:
  /// **'Категорија'**
  String get wizardReviewCategoryRow;

  /// No description provided for @wizardReviewLocationRow.
  ///
  /// In mk, this message translates to:
  /// **'Локација'**
  String get wizardReviewLocationRow;

  /// No description provided for @wizardReviewCapacityRow.
  ///
  /// In mk, this message translates to:
  /// **'Капацитет'**
  String get wizardReviewCapacityRow;

  /// No description provided for @wizardReviewAmenitiesRow.
  ///
  /// In mk, this message translates to:
  /// **'Опрема'**
  String get wizardReviewAmenitiesRow;

  /// No description provided for @wizardReviewPhotosRow.
  ///
  /// In mk, this message translates to:
  /// **'Фотографии'**
  String get wizardReviewPhotosRow;

  /// No description provided for @wizardReviewPriceRow.
  ///
  /// In mk, this message translates to:
  /// **'Цена'**
  String get wizardReviewPriceRow;

  /// No description provided for @wizardRoomSingular.
  ///
  /// In mk, this message translates to:
  /// **'соба'**
  String get wizardRoomSingular;

  /// No description provided for @wizardRoomsPlural.
  ///
  /// In mk, this message translates to:
  /// **'соби'**
  String get wizardRoomsPlural;

  /// No description provided for @wizardBedSingular.
  ///
  /// In mk, this message translates to:
  /// **'кревет'**
  String get wizardBedSingular;

  /// No description provided for @wizardBedsPlural.
  ///
  /// In mk, this message translates to:
  /// **'кревети'**
  String get wizardBedsPlural;

  /// No description provided for @wizardAmenitySingular.
  ///
  /// In mk, this message translates to:
  /// **'нешто'**
  String get wizardAmenitySingular;

  /// No description provided for @wizardAmenitiesPlural.
  ///
  /// In mk, this message translates to:
  /// **'нешта'**
  String get wizardAmenitiesPlural;

  /// No description provided for @wizardPhotoSingular.
  ///
  /// In mk, this message translates to:
  /// **'фотографија'**
  String get wizardPhotoSingular;

  /// No description provided for @wizardPhotosPlural.
  ///
  /// In mk, this message translates to:
  /// **'фотографии'**
  String get wizardPhotosPlural;

  /// No description provided for @wizardDiscardDialogTitle.
  ///
  /// In mk, this message translates to:
  /// **'Да ја напуштите понудата?'**
  String get wizardDiscardDialogTitle;

  /// No description provided for @wizardDiscardDialogMessage.
  ///
  /// In mk, this message translates to:
  /// **'Внесените информации нема да бидат зачувани.'**
  String get wizardDiscardDialogMessage;

  /// No description provided for @wizardDiscardDialogCancel.
  ///
  /// In mk, this message translates to:
  /// **'Откажи'**
  String get wizardDiscardDialogCancel;

  /// No description provided for @wizardDiscardDialogConfirm.
  ///
  /// In mk, this message translates to:
  /// **'Напушти'**
  String get wizardDiscardDialogConfirm;

  /// No description provided for @amenityParking.
  ///
  /// In mk, this message translates to:
  /// **'Бесплатен паркинг'**
  String get amenityParking;

  /// No description provided for @amenityKitchen.
  ///
  /// In mk, this message translates to:
  /// **'Опремена кујна'**
  String get amenityKitchen;

  /// No description provided for @amenityAirConditioning.
  ///
  /// In mk, this message translates to:
  /// **'Клима уред'**
  String get amenityAirConditioning;

  /// No description provided for @amenityTv.
  ///
  /// In mk, this message translates to:
  /// **'ТВ'**
  String get amenityTv;

  /// No description provided for @amenityFireplace.
  ///
  /// In mk, this message translates to:
  /// **'Огниште'**
  String get amenityFireplace;

  /// No description provided for @amenityFarmAccess.
  ///
  /// In mk, this message translates to:
  /// **'Пристап до фарма'**
  String get amenityFarmAccess;

  /// No description provided for @amenityHotWater.
  ///
  /// In mk, this message translates to:
  /// **'Топла вода'**
  String get amenityHotWater;

  /// No description provided for @amenityPetsAllowed.
  ///
  /// In mk, this message translates to:
  /// **'Домашни миленици дозволени'**
  String get amenityPetsAllowed;

  /// No description provided for @offerPublishedTitle.
  ///
  /// In mk, this message translates to:
  /// **'Понуда објавена'**
  String get offerPublishedTitle;

  /// No description provided for @offerPublishedHeading.
  ///
  /// In mk, this message translates to:
  /// **'Понудата е објавена!'**
  String get offerPublishedHeading;

  /// No description provided for @offerPublishedSubtitle.
  ///
  /// In mk, this message translates to:
  /// **'Вашата понуда сега е видлива за гостите на платформата.'**
  String get offerPublishedSubtitle;

  /// No description provided for @offerPublishedViewOffersButton.
  ///
  /// In mk, this message translates to:
  /// **'Прегледај ги моите понуди'**
  String get offerPublishedViewOffersButton;

  /// No description provided for @offerPublishedGoToDashboardButton.
  ///
  /// In mk, this message translates to:
  /// **'Оди на контролна табла'**
  String get offerPublishedGoToDashboardButton;

  /// No description provided for @rateGuestTitle.
  ///
  /// In mk, this message translates to:
  /// **'Оцени гостин'**
  String get rateGuestTitle;

  /// No description provided for @rateGuestQuestion.
  ///
  /// In mk, this message translates to:
  /// **'Како беше престојот на гостинот?'**
  String get rateGuestQuestion;

  /// No description provided for @rateGuestNoteLabel.
  ///
  /// In mk, this message translates to:
  /// **'Белешка (опционално)'**
  String get rateGuestNoteLabel;

  /// No description provided for @rateGuestNotePlaceholder.
  ///
  /// In mk, this message translates to:
  /// **'На пр. Одличен гостин, ја остави куќата уредна.'**
  String get rateGuestNotePlaceholder;

  /// No description provided for @rateGuestHelperText.
  ///
  /// In mk, this message translates to:
  /// **'Согласно правилата на платформата, гостинот може да биде оценет само по завршена услуга каде постоела резервација.'**
  String get rateGuestHelperText;

  /// No description provided for @submitRatingButton.
  ///
  /// In mk, this message translates to:
  /// **'Испрати оцена'**
  String get submitRatingButton;

  /// No description provided for @ratingSavedTitle.
  ///
  /// In mk, this message translates to:
  /// **'Оценка'**
  String get ratingSavedTitle;

  /// No description provided for @ratingSavedHeading.
  ///
  /// In mk, this message translates to:
  /// **'Оценката е зачувана!'**
  String get ratingSavedHeading;

  /// No description provided for @homeGreetingPrefix.
  ///
  /// In mk, this message translates to:
  /// **'Здраво, '**
  String get homeGreetingPrefix;

  /// No description provided for @homeSubtitle.
  ///
  /// In mk, this message translates to:
  /// **'Пронајдете го вашето следно рурално доживување'**
  String get homeSubtitle;

  /// No description provided for @homeSearchPlaceholder.
  ///
  /// In mk, this message translates to:
  /// **'Пребарај дестинации, понуди...'**
  String get homeSearchPlaceholder;

  /// No description provided for @homeCategoriesHeading.
  ///
  /// In mk, this message translates to:
  /// **'Категории'**
  String get homeCategoriesHeading;

  /// No description provided for @homeRecommendedHeading.
  ///
  /// In mk, this message translates to:
  /// **'Препорачано за вас'**
  String get homeRecommendedHeading;

  /// No description provided for @homePricePrefix.
  ///
  /// In mk, this message translates to:
  /// **'од '**
  String get homePricePrefix;

  /// No description provided for @homeBanner1Title.
  ///
  /// In mk, this message translates to:
  /// **'До 20% попуст на избрани понуди'**
  String get homeBanner1Title;

  /// No description provided for @homeBanner1Action.
  ///
  /// In mk, this message translates to:
  /// **'Погледни ги →'**
  String get homeBanner1Action;

  /// No description provided for @homeBanner2Title.
  ///
  /// In mk, this message translates to:
  /// **'Нови понуди оваа недела'**
  String get homeBanner2Title;

  /// No description provided for @homeBanner2Action.
  ///
  /// In mk, this message translates to:
  /// **'Истражи ги →'**
  String get homeBanner2Action;

  /// No description provided for @homeBanner3Title.
  ///
  /// In mk, this message translates to:
  /// **'Омилено на гостите: Villa Zdravkovski'**
  String get homeBanner3Title;

  /// No description provided for @homeBanner3Action.
  ///
  /// In mk, this message translates to:
  /// **'Резервирај →'**
  String get homeBanner3Action;

  /// No description provided for @filtersSheetTitle.
  ///
  /// In mk, this message translates to:
  /// **'Филтри'**
  String get filtersSheetTitle;

  /// No description provided for @filtersKeywordLabel.
  ///
  /// In mk, this message translates to:
  /// **'Клучен збор'**
  String get filtersKeywordLabel;

  /// No description provided for @filtersKeywordPlaceholder.
  ///
  /// In mk, this message translates to:
  /// **'На пр. куќа со базен'**
  String get filtersKeywordPlaceholder;

  /// No description provided for @filtersLocationLabel.
  ///
  /// In mk, this message translates to:
  /// **'Локација'**
  String get filtersLocationLabel;

  /// No description provided for @filtersAllLocationsOption.
  ///
  /// In mk, this message translates to:
  /// **'Сите локации'**
  String get filtersAllLocationsOption;

  /// No description provided for @filtersPriceRangeLabel.
  ///
  /// In mk, this message translates to:
  /// **'Ценовен опсег'**
  String get filtersPriceRangeLabel;

  /// No description provided for @filtersPriceRangeUnit.
  ///
  /// In mk, this message translates to:
  /// **'ден.'**
  String get filtersPriceRangeUnit;

  /// No description provided for @filtersDateLabel.
  ///
  /// In mk, this message translates to:
  /// **'Датум на престој'**
  String get filtersDateLabel;

  /// No description provided for @filtersDatePlaceholder.
  ///
  /// In mk, this message translates to:
  /// **'Изберете датуми'**
  String get filtersDatePlaceholder;

  /// No description provided for @filtersRatingLabel.
  ///
  /// In mk, this message translates to:
  /// **'Оценка'**
  String get filtersRatingLabel;

  /// No description provided for @filtersRatingAllOption.
  ///
  /// In mk, this message translates to:
  /// **'Сите'**
  String get filtersRatingAllOption;

  /// No description provided for @filtersGuestCountLabel.
  ///
  /// In mk, this message translates to:
  /// **'Број на гости'**
  String get filtersGuestCountLabel;

  /// No description provided for @filtersAmenityHeading.
  ///
  /// In mk, this message translates to:
  /// **'Опрема'**
  String get filtersAmenityHeading;

  /// No description provided for @filtersClearButton.
  ///
  /// In mk, this message translates to:
  /// **'Избриши филтри'**
  String get filtersClearButton;

  /// No description provided for @filtersShowResultsButton.
  ///
  /// In mk, this message translates to:
  /// **'Прикажи резултати'**
  String get filtersShowResultsButton;

  /// No description provided for @resultsTitle.
  ///
  /// In mk, this message translates to:
  /// **'Резултати'**
  String get resultsTitle;

  /// No description provided for @resultsFiltersChipLabel.
  ///
  /// In mk, this message translates to:
  /// **'Филтри'**
  String get resultsFiltersChipLabel;

  /// No description provided for @resultsRatingChipLabel.
  ///
  /// In mk, this message translates to:
  /// **'Оценка 4+'**
  String get resultsRatingChipLabel;

  /// No description provided for @resultsPriceChipLabel.
  ///
  /// In mk, this message translates to:
  /// **'Цена'**
  String get resultsPriceChipLabel;

  /// No description provided for @resultsCountSuffix.
  ///
  /// In mk, this message translates to:
  /// **'понуди'**
  String get resultsCountSuffix;

  /// No description provided for @resultsCountLocationPrefix.
  ///
  /// In mk, this message translates to:
  /// **'во'**
  String get resultsCountLocationPrefix;

  /// No description provided for @resultsSortLabel.
  ///
  /// In mk, this message translates to:
  /// **'Прикажани по релевантност'**
  String get resultsSortLabel;

  /// No description provided for @resultsMapButtonLabel.
  ///
  /// In mk, this message translates to:
  /// **'Карта'**
  String get resultsMapButtonLabel;

  /// No description provided for @resultsShowDetailsButton.
  ///
  /// In mk, this message translates to:
  /// **'Прикажи детали'**
  String get resultsShowDetailsButton;

  /// No description provided for @resultsReservationsSuffix.
  ///
  /// In mk, this message translates to:
  /// **'резервации'**
  String get resultsReservationsSuffix;

  /// No description provided for @resultsPricePerNightSuffix.
  ///
  /// In mk, this message translates to:
  /// **'ден./ноќ'**
  String get resultsPricePerNightSuffix;

  /// No description provided for @detailsTitle.
  ///
  /// In mk, this message translates to:
  /// **'Детали'**
  String get detailsTitle;

  /// No description provided for @detailsHostPrefix.
  ///
  /// In mk, this message translates to:
  /// **'Домаќин: '**
  String get detailsHostPrefix;

  /// No description provided for @detailsHostSincePrefix.
  ///
  /// In mk, this message translates to:
  /// **'Тука од '**
  String get detailsHostSincePrefix;

  /// No description provided for @detailsAboutHeading.
  ///
  /// In mk, this message translates to:
  /// **'За понудата'**
  String get detailsAboutHeading;

  /// No description provided for @detailsAmenitiesHeading.
  ///
  /// In mk, this message translates to:
  /// **'Што нуди?'**
  String get detailsAmenitiesHeading;

  /// No description provided for @detailsLocationHeading.
  ///
  /// In mk, this message translates to:
  /// **'Каде се наоѓа?'**
  String get detailsLocationHeading;

  /// No description provided for @detailsReserveButton.
  ///
  /// In mk, this message translates to:
  /// **'Резервирај'**
  String get detailsReserveButton;

  /// No description provided for @reservationFlowTitle.
  ///
  /// In mk, this message translates to:
  /// **'Резервација'**
  String get reservationFlowTitle;

  /// No description provided for @bookingDatesUnavailableError.
  ///
  /// In mk, this message translates to:
  /// **'Избраните датуми не се достапни за оваа понуда.'**
  String get bookingDatesUnavailableError;

  /// No description provided for @bookingRequestSentHeading.
  ///
  /// In mk, this message translates to:
  /// **'Барањето за резервација е испратено!'**
  String get bookingRequestSentHeading;

  /// No description provided for @bookingRequestSentSubtitle.
  ///
  /// In mk, this message translates to:
  /// **'Ќе добиете е-пошта штом понудувачот ја потврди вашата резервација.'**
  String get bookingRequestSentSubtitle;

  /// No description provided for @tripDetailsHeading.
  ///
  /// In mk, this message translates to:
  /// **'Детали за престојот'**
  String get tripDetailsHeading;

  /// No description provided for @checkInLabel.
  ///
  /// In mk, this message translates to:
  /// **'Пристигнување'**
  String get checkInLabel;

  /// No description provided for @checkOutLabel.
  ///
  /// In mk, this message translates to:
  /// **'Заминување'**
  String get checkOutLabel;

  /// No description provided for @paymentDetailsHeading.
  ///
  /// In mk, this message translates to:
  /// **'Детали за плаќањето'**
  String get paymentDetailsHeading;

  /// No description provided for @serviceFeeLabel.
  ///
  /// In mk, this message translates to:
  /// **'Такса за услуга'**
  String get serviceFeeLabel;

  /// No description provided for @totalLabel.
  ///
  /// In mk, this message translates to:
  /// **'Вкупно'**
  String get totalLabel;

  /// No description provided for @reservationNumberLabel.
  ///
  /// In mk, this message translates to:
  /// **'Број на резервација'**
  String get reservationNumberLabel;

  /// No description provided for @nightSingular.
  ///
  /// In mk, this message translates to:
  /// **'ноќ'**
  String get nightSingular;

  /// No description provided for @nightsPlural.
  ///
  /// In mk, this message translates to:
  /// **'ноќи'**
  String get nightsPlural;

  /// No description provided for @viewMyReservationsButton.
  ///
  /// In mk, this message translates to:
  /// **'Прегледај ги моите резервации'**
  String get viewMyReservationsButton;

  /// No description provided for @backToHomeButton.
  ///
  /// In mk, this message translates to:
  /// **'Назад кон почетна'**
  String get backToHomeButton;

  /// No description provided for @myReservationsTitle.
  ///
  /// In mk, this message translates to:
  /// **'Мои резервации'**
  String get myReservationsTitle;

  /// No description provided for @upcomingTabLabel.
  ///
  /// In mk, this message translates to:
  /// **'Претстојни'**
  String get upcomingTabLabel;

  /// No description provided for @pastTabLabel.
  ///
  /// In mk, this message translates to:
  /// **'Минати'**
  String get pastTabLabel;

  /// No description provided for @myReservationsDetailsButton.
  ///
  /// In mk, this message translates to:
  /// **'Прегледај детали'**
  String get myReservationsDetailsButton;

  /// No description provided for @leaveReviewButton.
  ///
  /// In mk, this message translates to:
  /// **'Остави рецензија'**
  String get leaveReviewButton;

  /// No description provided for @myReservationsEmptyUpcoming.
  ///
  /// In mk, this message translates to:
  /// **'Нема претстојни резервации.'**
  String get myReservationsEmptyUpcoming;

  /// No description provided for @myReservationsEmptyPast.
  ///
  /// In mk, this message translates to:
  /// **'Нема минати резервации.'**
  String get myReservationsEmptyPast;

  /// No description provided for @leaveReviewQuestion.
  ///
  /// In mk, this message translates to:
  /// **'Каков беше вашиот престој?'**
  String get leaveReviewQuestion;

  /// No description provided for @leaveReviewTextLabel.
  ///
  /// In mk, this message translates to:
  /// **'Вашата рецензија'**
  String get leaveReviewTextLabel;

  /// No description provided for @leaveReviewTextPlaceholder.
  ///
  /// In mk, this message translates to:
  /// **'Споделете го вашето искуство со идните гости...'**
  String get leaveReviewTextPlaceholder;

  /// No description provided for @leaveReviewDisclaimer.
  ///
  /// In mk, this message translates to:
  /// **'Рецензија може да оставите само по валидна завршена резервација, преку мобилна или веб апликација.'**
  String get leaveReviewDisclaimer;

  /// No description provided for @submitReviewButton.
  ///
  /// In mk, this message translates to:
  /// **'Испрати рецензија'**
  String get submitReviewButton;

  /// No description provided for @reviewSubmittedTitle.
  ///
  /// In mk, this message translates to:
  /// **'Рецензија'**
  String get reviewSubmittedTitle;

  /// No description provided for @reviewSubmittedHeading.
  ///
  /// In mk, this message translates to:
  /// **'Ви благодариме за рецензијата!'**
  String get reviewSubmittedHeading;

  /// No description provided for @backToReservationsButton.
  ///
  /// In mk, this message translates to:
  /// **'Назад кон резервации'**
  String get backToReservationsButton;

  /// No description provided for @welcomeToBulka.
  ///
  /// In mk, this message translates to:
  /// **'Добредојде во Булка'**
  String get welcomeToBulka;

  /// No description provided for @whoAreYou.
  ///
  /// In mk, this message translates to:
  /// **'Вие сте?'**
  String get whoAreYou;

  /// No description provided for @chooseProfile.
  ///
  /// In mk, this message translates to:
  /// **'Изберете го вашиот тип на профил'**
  String get chooseProfile;

  /// No description provided for @tourist.
  ///
  /// In mk, this message translates to:
  /// **'Турист'**
  String get tourist;

  /// No description provided for @touristDescription.
  ///
  /// In mk, this message translates to:
  /// **'Пребарувај и резервирај уникатни искуства'**
  String get touristDescription;

  /// No description provided for @owner.
  ///
  /// In mk, this message translates to:
  /// **'Сопственик на имот/услуги'**
  String get owner;

  /// No description provided for @ownerDescription.
  ///
  /// In mk, this message translates to:
  /// **'Огласи и управувај со своите понуди'**
  String get ownerDescription;

  /// No description provided for @continueText.
  ///
  /// In mk, this message translates to:
  /// **'ПРОДОЛЖИ'**
  String get continueText;

  /// No description provided for @alreadyAccount.
  ///
  /// In mk, this message translates to:
  /// **'Веќе имате сметка? Најавете се'**
  String get alreadyAccount;

  /// No description provided for @routeNotFoundTitle.
  ///
  /// In mk, this message translates to:
  /// **'Страницата не е пронајдена'**
  String get routeNotFoundTitle;

  /// No description provided for @routeNotFoundMessage.
  ///
  /// In mk, this message translates to:
  /// **'Оваа страница не постои или повеќе не е достапна.'**
  String get routeNotFoundMessage;

  /// No description provided for @routeNotFoundButton.
  ///
  /// In mk, this message translates to:
  /// **'ОДИ НА ПОЧЕТОК'**
  String get routeNotFoundButton;

  /// Relative time, e.g. on support tickets and listing cards.
  ///
  /// In mk, this message translates to:
  /// **'{count, plural, =1{пред 1 минута} other{пред {count} минути}}'**
  String agoMinutes(int count);

  /// No description provided for @agoHours.
  ///
  /// In mk, this message translates to:
  /// **'{count, plural, =1{пред 1 час} other{пред {count} часа}}'**
  String agoHours(int count);

  /// No description provided for @agoDays.
  ///
  /// In mk, this message translates to:
  /// **'{count, plural, =1{пред 1 ден} other{пред {count} дена}}'**
  String agoDays(int count);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'mk', 'sq'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'mk':
      return AppLocalizationsMk();
    case 'sq':
      return AppLocalizationsSq();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
