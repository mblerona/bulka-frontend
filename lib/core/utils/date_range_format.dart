import 'package:intl/intl.dart';

// Month names come from `intl` in the app's current language
// (`Intl.defaultLocale`, set by LocaleController), e.g. "август" /
// "August" / "gusht". The day/range shapes are the same in every language.

/// Full month name as it's written on its own, e.g. the Provider
/// Availability Calendar's "Август 2026" title (the caller capitalizes).
String monthName(int month) => DateFormat.LLLL().format(DateTime(2000, month));

String _fullMonth(DateTime date) => DateFormat.MMMM().format(date);

/// Abbreviated month without the trailing dot some languages use
/// ("авг.", "sept."), to match the design's "12 авг 2026".
String _shortMonth(DateTime date) =>
    DateFormat.MMM().format(date).replaceAll('.', '');

/// Date range, e.g. "12–15 август" in one month or "28 јули – 2 август"
/// across months (Provider Dashboard, booking forms).
String formatDateRange(DateTime start, DateTime end) {
  if (start.year == end.year && start.month == end.month) {
    return '${start.day}–${end.day} ${_fullMonth(start)}';
  }
  return '${start.day} ${_fullMonth(start)} – ${end.day} ${_fullMonth(end)}';
}

/// A single date with a short month and the year, e.g. "12 авг 2026"
/// (Reservation Confirmation's check-in/check-out rows).
String formatDateShort(DateTime date) =>
    '${date.day} ${_shortMonth(date)} ${date.year}';

/// Like [formatDateRange] with short months, e.g. "12–15 авг", for narrow
/// spots (the Search Results summary pill).
String formatDateRangeShort(DateTime start, DateTime end) {
  if (start.year == end.year && start.month == end.month) {
    return '${start.day}–${end.day} ${_shortMonth(start)}';
  }
  return '${start.day} ${_shortMonth(start)} – ${end.day} ${_shortMonth(end)}';
}

/// Like [formatDateRangeShort] plus the year, e.g. "12–15 авг 2026" or
/// "28 дек 2025 – 2 јан 2026" (My Reservations' card meta line).
String formatDateRangeShortWithYear(DateTime start, DateTime end) {
  final s = _shortMonth(start);
  final e = _shortMonth(end);
  if (start.year == end.year && start.month == end.month) {
    return '${start.day}–${end.day} $s ${end.year}';
  }
  if (start.year == end.year) {
    return '${start.day} $s – ${end.day} $e ${end.year}';
  }
  return '${start.day} $s ${start.year} – ${end.day} $e ${end.year}';
}
