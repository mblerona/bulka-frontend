part of 'locale_bloc.dart';

sealed class LocaleEvent {
  const LocaleEvent();
}

/// The user picked a language. [code] is a language code ("mk") or a
/// language-switch code ("MK"); unknown codes are ignored.
final class LanguageChanged extends LocaleEvent {
  const LanguageChanged(this.code);

  final String code;
}
