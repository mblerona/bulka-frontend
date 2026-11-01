import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:bulka_frontend/l10n/app_localizations.dart';

/// The current language, for code that has no `BuildContext`: `AppStrings`,
/// the API client's Accept-Language header, and `intl` date/number
/// formatting. Only `LocaleBloc` changes it; widgets should read the
/// language from `LocaleBloc` instead.
abstract final class AppLocale {
  static const Locale fallback = Locale('mk');

  static Locale _current = fallback;
  static AppLocalizations _strings = lookupAppLocalizations(fallback);

  static Locale get current => _current;
  static AppLocalizations get strings => _strings;

  static void apply(Locale locale) {
    _current = locale;
    _strings = lookupAppLocalizations(locale);
    Intl.defaultLocale = locale.languageCode;
  }

  /// The supported locale for a language code ("mk") or a language-switch
  /// code ("MK"); null if the app doesn't support it.
  static Locale? supported(String? code) {
    if (code == null) return null;
    final languageCode = code.toLowerCase();
    for (final locale in AppLocalizations.supportedLocales) {
      if (locale.languageCode == languageCode) return locale;
    }
    return null;
  }
}
