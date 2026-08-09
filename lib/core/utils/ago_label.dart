import 'package:bulka_frontend/core/constants/app_strings.dart';

/// "пред 2 дена" / "пред 1 час" style relative-time label, with correct
/// Macedonian singular/plural for minutes/hours/days. Shared by My Tickets
/// ("Последна промена: пред X") and Provider Offers (submitted-for-review
/// / archived-on style card messages) — same format, same words.
String agoLabel(DateTime since) {
  final diff = DateTime.now().difference(since);
  final String amount;
  if (diff.inMinutes < 60) {
    amount = diff.inMinutes == 1
        ? '1 ${AppStrings.agoMinuteSingular}'
        : '${diff.inMinutes} ${AppStrings.agoMinutesPlural}';
  } else if (diff.inHours < 24) {
    amount = diff.inHours == 1
        ? '1 ${AppStrings.agoHourSingular}'
        : '${diff.inHours} ${AppStrings.agoHoursPlural}';
  } else {
    amount = diff.inDays == 1
        ? '1 ${AppStrings.agoDaySingular}'
        : '${diff.inDays} ${AppStrings.agoDaysPlural}';
  }
  return '${AppStrings.agoPrefix} $amount';
}
