part of 'locale_bloc.dart';

final class LocaleState {
  const LocaleState(this.locale);

  final Locale locale;

  /// "MK" / "SQ" / "EN" — the codes the language switch shows.
  String get switchCode => locale.languageCode.toUpperCase();
}
