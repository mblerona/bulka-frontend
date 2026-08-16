/// Lowercase Macedonian month names, index 0 = January. Public so other
/// screens (e.g. the Provider Availability Calendar's "Август 2026" title)
/// can reuse this one list instead of keeping a second copy.
const List<String> mkMonthNames = [
  'јануари',
  'февруари',
  'март',
  'април',
  'мај',
  'јуни',
  'јули',
  'август',
  'септември',
  'октомври',
  'ноември',
  'декември',
];

/// Short Macedonian date-range label, e.g. "12–15 август" for a same-month
/// range or "28 јули – 2 август" across months. Shared by any screen that
/// needs to show a reservation/booking date range (currently the Provider
/// Dashboard; a future Calendar screen will likely need the same format).
String formatMkDateRange(DateTime start, DateTime end) {
  final startMonth = mkMonthNames[start.month - 1];
  if (start.year == end.year && start.month == end.month) {
    return '${start.day}–${end.day} $startMonth';
  }
  final endMonth = mkMonthNames[end.month - 1];
  return '${start.day} $startMonth – ${end.day} $endMonth';
}

/// A single date with a 3-letter abbreviated month and the year, e.g.
/// "12 авг 2026" — the Reservation Confirmation screen's check-in/
/// check-out rows. Derived from the same [mkMonthNames] list as
/// [formatMkDateRange]/[formatMkDateRangeShort], not a third copy.
String formatMkDateShort(DateTime date) {
  final month = mkMonthNames[date.month - 1].substring(0, 3);
  return '${date.day} $month ${date.year}';
}

/// Same shape as [formatMkDateRange] but with a 3-letter abbreviated month
/// (e.g. "12–15 авг") — derived from the same [mkMonthNames] list rather
/// than a second month-name list, for contexts too narrow for the full
/// name (the Search Results/Map search-summary pill).
String formatMkDateRangeShort(DateTime start, DateTime end) {
  final startMonth = mkMonthNames[start.month - 1].substring(0, 3);
  if (start.year == end.year && start.month == end.month) {
    return '${start.day}–${end.day} $startMonth';
  }
  final endMonth = mkMonthNames[end.month - 1].substring(0, 3);
  return '${start.day} $startMonth – ${end.day} $endMonth';
}

/// Same shape as [formatMkDateRangeShort] but with the year appended, e.g.
/// "12–15 авг 2026" or "28 дек 2025 – 2 јан 2026" across years — My
/// Reservations' card meta line, the only date-range context that needs
/// the year alongside the range itself.
String formatMkDateRangeShortWithYear(DateTime start, DateTime end) {
  final startMonth = mkMonthNames[start.month - 1].substring(0, 3);
  if (start.year == end.year && start.month == end.month) {
    return '${start.day}–${end.day} $startMonth ${end.year}';
  }
  final endMonth = mkMonthNames[end.month - 1].substring(0, 3);
  if (start.year == end.year) {
    return '${start.day} $startMonth – ${end.day} $endMonth ${end.year}';
  }
  return '${start.day} $startMonth ${start.year} – ${end.day} $endMonth '
      '${end.year}';
}
