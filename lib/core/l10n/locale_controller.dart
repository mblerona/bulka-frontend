import 'package:flutter/widgets.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bulka_frontend/l10n/app_localizations.dart';

/// The app's current language (MK / SQ / EN). [AppStrings] reads its text
/// from [strings], and `BulkaApp` rebuilds every screen when it changes.
///
/// First launch uses the phone's language if it's one of ours, otherwise
/// Macedonian. After the user picks one, that choice is saved.
class LocaleController extends ChangeNotifier {
  LocaleController._();

  static final LocaleController instance = LocaleController._();

  static const Locale fallbackLocale = Locale('mk');
  static const String _prefsKey = 'app.languageCode';

  Locale _locale = fallbackLocale;
  AppLocalizations _strings = lookupAppLocalizations(fallbackLocale);

  Locale get locale => _locale;
  AppLocalizations get strings => _strings;

  /// "MK" / "SQ" / "EN" — the codes the [LanguageSwitch] widget shows.
  String get switchCode => _locale.languageCode.toUpperCase();

  /// Call once before `runApp`.
  Future<void> load() async {
    await initializeDateFormatting();
    String? saved;
    try {
      saved = (await SharedPreferences.getInstance()).getString(_prefsKey);
    } catch (e) {
      debugPrint('[Locale] Could not read the saved language: $e');
    }
    _apply(_supported(saved) ?? _deviceLocale() ?? fallbackLocale);
  }

  /// Accepts either a language code ("mk") or a [LanguageSwitch] code
  /// ("MK"). Unknown codes are ignored.
  Future<void> setLanguage(String code) async {
    final locale = _supported(code);
    if (locale == null || locale == _locale) return;
    _apply(locale);
    notifyListeners();
    try {
      await (await SharedPreferences.getInstance()).setString(
        _prefsKey,
        locale.languageCode,
      );
    } catch (e) {
      debugPrint('[Locale] Could not save the language: $e');
    }
  }

  void _apply(Locale locale) {
    _locale = locale;
    _strings = lookupAppLocalizations(locale);
    Intl.defaultLocale = locale.languageCode;
  }

  static Locale? _supported(String? code) {
    if (code == null) return null;
    final languageCode = code.toLowerCase();
    for (final locale in AppLocalizations.supportedLocales) {
      if (locale.languageCode == languageCode) return locale;
    }
    return null;
  }

  static Locale? _deviceLocale() {
    for (final locale in WidgetsBinding.instance.platformDispatcher.locales) {
      final supported = _supported(locale.languageCode);
      if (supported != null) return supported;
    }
    return null;
  }
}
