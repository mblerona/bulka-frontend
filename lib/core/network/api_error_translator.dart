import 'package:bulka_frontend/core/constants/app_strings.dart';
import 'package:bulka_frontend/core/network/api_response.dart';

/// The backend's error messages are always English (it ignores
/// Accept-Language), so the app shows its own text, chosen by the error's
/// `code` and `field`, in the app's current language. Returns null for
/// errors it doesn't know yet; the caller then falls back to a generic
/// message.
///
/// To support a new error, add its code here and its text to the .arb
/// files in lib/l10n/.
String? translateApiError(ApiError error) {
  final field = error.field;
  switch (error.code) {
    case 'AUTH_INVALID_CREDENTIALS':
      return AppStrings.loginErrorInvalidCredentials;
    case 'AUTH_EMAIL_VERIFICATION_INVALID':
      return AppStrings.apiErrorVerificationCodeInvalid;
    case 'VALIDATION_REQUIRED':
      return _requiredMessage(field);
    case 'VALIDATION_INVALID':
      if (field == 'password') return _passwordRule(error.message);
      return _invalidMessage(field);
  }
  return null;
}

// Functions rather than const maps, so the text is read in the current
// language every time.
String? _requiredMessage(String? field) => switch (field) {
  'email' => AppStrings.apiErrorEmailRequired,
  'firstName' => AppStrings.apiErrorFirstNameRequired,
  'lastName' => AppStrings.apiErrorLastNameRequired,
  'phone' => AppStrings.apiErrorPhoneRequired,
  'password' => AppStrings.apiErrorPasswordRequired,
  'code' => AppStrings.apiErrorCodeRequired,
  'acceptedTerms' => AppStrings.apiErrorTermsRequired,
  'acceptedPrivacy' => AppStrings.apiErrorPrivacyRequired,
  _ => null,
};

String? _invalidMessage(String? field) => switch (field) {
  'email' => AppStrings.registerErrorEmail,
  'phone' => AppStrings.registerErrorPhone,
  _ => null,
};

/// Every password rule uses the same code, so the rule is told apart by the
/// English message text.
String _passwordRule(String? message) {
  final text = (message ?? '').toLowerCase();
  if (text.contains('at least')) return AppStrings.apiErrorPasswordTooShort;
  if (text.contains('uppercase')) {
    return AppStrings.apiErrorPasswordNeedsUppercase;
  }
  if (text.contains('lowercase')) {
    return AppStrings.apiErrorPasswordNeedsLowercase;
  }
  if (text.contains('digit')) return AppStrings.apiErrorPasswordNeedsDigit;
  if (text.contains('non-alphanumeric')) {
    return AppStrings.apiErrorPasswordNeedsSpecial;
  }
  return AppStrings.registerErrorPasswordRules;
}
