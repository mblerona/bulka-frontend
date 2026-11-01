import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bulka_frontend/core/l10n/app_locale.dart';

part 'locale_event.dart';
part 'locale_state.dart';

/// The app's language (MK / SQ / EN). First launch uses the phone's
/// language if it's one of ours, otherwise Macedonian; after that the
/// user's choice is saved.
class LocaleBloc extends Bloc<LocaleEvent, LocaleState> {
  LocaleBloc({required Locale initialLocale})
    : super(LocaleState(initialLocale)) {
    AppLocale.apply(initialLocale);
    on<LanguageChanged>(_onLanguageChanged);
  }

  static const String _prefsKey = 'app.languageCode';

  /// Call once before `runApp`, then pass the result to [LocaleBloc].
  static Future<Locale> loadInitialLocale() async {
    await initializeDateFormatting();
    String? saved;
    try {
      saved = (await SharedPreferences.getInstance()).getString(_prefsKey);
    } catch (e) {
      debugPrint('[Locale] Could not read the saved language: $e');
    }
    final locale =
        AppLocale.supported(saved) ?? _deviceLocale() ?? AppLocale.fallback;
    AppLocale.apply(locale);
    return locale;
  }

  static Locale? _deviceLocale() {
    for (final locale in WidgetsBinding.instance.platformDispatcher.locales) {
      final supported = AppLocale.supported(locale.languageCode);
      if (supported != null) return supported;
    }
    return null;
  }

  Future<void> _onLanguageChanged(
    LanguageChanged event,
    Emitter<LocaleState> emit,
  ) async {
    final locale = AppLocale.supported(event.code);
    if (locale == null || locale == state.locale) return;
    AppLocale.apply(locale);
    emit(LocaleState(locale));
    try {
      await (await SharedPreferences.getInstance()).setString(
        _prefsKey,
        locale.languageCode,
      );
    } catch (e) {
      debugPrint('[Locale] Could not save the language: $e');
    }
  }
}
